// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SanctionToken} from "../src/SanctionToken.sol";
import "forge-std/console.sol";

contract sanctionTest is Test {
    SanctionToken public sanctionToken;
    address user;
    address bannedUser;

    function setUp() public {
        sanctionToken = new SanctionToken();

        bannedUser = makeAddr("bannedUser");
        user = makeAddr("user");

        sanctionToken.transfer(user, 1000 ether);
        sanctionToken.transfer(bannedUser, 1000 ether);
        // vm.prank(bannedUser, 1000 ether);
        // modernWETH.deposit{value: 1000 ether}();
        console.log(sanctionToken.balanceOf(user));
        /// @dev you, the whitehat, start with 10 ether
        // vm.deal(whitehat, 10 ether);
    }

    function test_Transfer() public {
        sanctionToken.transfer(bannedUser, 10 ether);
        assertEq(sanctionToken.balanceOf(bannedUser), 1010 ether);
    }

    function test_Ban() public {
        sanctionToken.banAddress(bannedUser);
        vm.startPrank(bannedUser);
        vm.expectRevert();
        sanctionToken.transfer(bannedUser, 10 ether);
        // assertEq(sanctionToken.balanceOf(bannedUser), 1010 ether);
        vm.stopPrank();
    }

    function test_ban_toggle() public {
        sanctionToken.banAddress(bannedUser);
        vm.startPrank(bannedUser);
        vm.expectRevert();
        sanctionToken.transfer(bannedUser, 10 ether);

        vm.stopPrank();
        sanctionToken.unbanAddress(bannedUser);
        vm.startPrank(bannedUser);

        sanctionToken.transfer(user, 10 ether);

        console.log(sanctionToken.balanceOf(user));
        assertEq(sanctionToken.balanceOf(user), 1010 ether);

        vm.stopPrank();
    }
}
