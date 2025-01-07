// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ReadOnly.sol";

contract ReadOnlyTest is Test {
    ReadOnlyPool readOnlyContract;
    VulnerableDeFiContract vulnerableDeFiContract;
    address attackerWallet;

    function setUp() public {
        attackerWallet = address(0x1234);

        readOnlyContract = new ReadOnlyPool();
        vulnerableDeFiContract = new VulnerableDeFiContract(readOnlyContract);

        vm.deal(address(readOnlyContract), 100 ether);
        readOnlyContract.addLiquidity{value: 100 ether}();
        readOnlyContract.earnProfit{value: 1 ether}();
        vulnerableDeFiContract.snapshotPrice();

        // you start with 2 ETH
        vm.deal(attackerWallet, 2 ether);
    }

    function testExploit() public {
        // Conduct your attack here
        console.log(address(readOnlyContract).balance);
        console.logUint(1 ether);
        uint256 y = 199 ether;
        uint256 z = 100 ether;
        uint256 x = y / z;
        console.logUint(x);

        // Assert the final state
        vulnerableDeFiContract.lpTokenPrice();
        assertEq(vulnerableDeFiContract.lpTokenPrice(), 0, "snapshotPrice should be zero");
        assertLt(vm.getNonce(attackerWallet), 3, "must exploit two transactions or less");
    }
}
