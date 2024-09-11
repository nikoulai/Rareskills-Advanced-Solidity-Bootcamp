// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GodToken} from "../src/GodToken.sol";
import "forge-std/console.sol";

contract sanctionTest is Test {
    GodToken public godToken;

    address user1;
    address user2;

    function setUp() public {
        godToken = new GodToken();

        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        godToken.transfer(user1, 1000 ether);
        godToken.transfer(user2, 1000 ether);
    }

    function test_godTransfer() public {
        godToken.godTokenTransfer(user1, user2, 10 ether);

        assertEq(godToken.balanceOf(user1), 990 ether);
        assertEq(godToken.balanceOf(user2), 1010 ether);

        godToken.godTokenTransfer(user2, user1, 10 ether);

        assertEq(godToken.balanceOf(user1), 1000 ether);
        assertEq(godToken.balanceOf(user2), 1000 ether);
    }
}
