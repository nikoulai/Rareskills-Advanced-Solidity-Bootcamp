// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/AssignVotes.sol";

contract AssignVotesTest is Test {
    AssignVotes victimContract;
    address assignerWallet;
    address attackerWallet;

    function setUp() public {
        assignerWallet = address(0x123);
        attackerWallet = address(0x456);

        vm.deal(assignerWallet, 1 ether);
        vm.deal(attackerWallet, 1 ether);

        victimContract = new AssignVotes{value: 1 ether}();

        vm.prank(assignerWallet);
        victimContract.assign(0x976EA74026E726554dB657fA54763abd0C3a0aa9);
        vm.prank(assignerWallet);
        victimContract.assign(0x14dC79964da2C08b23698B3D3cc7Ca32193d9955);
        vm.prank(assignerWallet);
        victimContract.assign(0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f);
        vm.prank(assignerWallet);
        victimContract.assign(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);
        vm.prank(assignerWallet);
        victimContract.assign(0xBcd4042DE499D14e55001CcbB24a551F3b954096);
    }

    function testExploit() public {
        // you may only use the attacker wallet, and no other wallet
        vm.startPrank(attackerWallet);

        // Conduct your attack here

        vm.stopPrank();

        assertEq(address(victimContract).balance, 0, "victim contract balance should be 0");
        assertEq(attackerWallet.balance, 1 ether, "attacker wallet balance should be 1 ether");
    }
}
