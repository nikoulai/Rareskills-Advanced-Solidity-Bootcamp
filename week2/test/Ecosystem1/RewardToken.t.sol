// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/Ecosystem1/RewardToken.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardTokenTest is Test {
    RewardToken public rewardToken;
    address public owner;
    address public addr1;

    function setUp() public {
        owner = makeAddr("owner");
        addr1 = makeAddr("user1");

        rewardToken = new RewardToken(owner);
    }

    function testOwner() public {
        assertEq(rewardToken.minter(), owner);
    }

    function testMint() public {
        vm.startPrank(owner);
        rewardToken.mint(addr1, 100);
        assertEq(rewardToken.balanceOf(addr1), 100);
    }

    function testMintFail() public {
        vm.startPrank(addr1);
        vm.expectRevert();
        rewardToken.mint(addr1, 100);
    }
}
