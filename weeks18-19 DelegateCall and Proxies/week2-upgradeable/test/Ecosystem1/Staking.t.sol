// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/Ecosystem1/Staking.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract MockRewardToken is IRewardToken {
    mapping(address => uint256) public balances;

    function mint(address to, uint256 amount) external override {
        balances[to] += amount;
    }
}

contract StakingTest is Test {
    Staking public staking;
    MockNFT public nft;
    MockRewardToken public rewardToken;
    address public user = address(0x123);

    function setUp() public {
        rewardToken = new MockRewardToken();
        nft = new MockNFT();
        staking = new Staking(address(rewardToken), address(nft));

        nft.mint(user, 1);
        nft.mint(user, 2);

        vm.startPrank(user);
        nft.approve(address(staking), 1);
        nft.approve(address(staking), 2);
        vm.stopPrank();
    }

    function testDeploy() public {
        rewardToken = new MockRewardToken();
        nft = new MockNFT();
        staking = new Staking(address(rewardToken), address(nft));
        assertEq(address(staking.rewardToken()), address(rewardToken));
        assertEq(address(staking.nft()), address(nft));
    }

    function testStake() public {
        vm.startPrank(user);
        nft.safeTransferFrom(user, address(staking), 1);
        vm.stopPrank();

        Staking.UserInfo memory info;
        (info.owner, info.lastReward) = staking.tokenToUserInfo(1);
        assertEq(info.owner, user);
        assertEq(info.lastReward, block.timestamp);
    }

    function testWithdrawRewards() public {
        vm.startPrank(user);
        nft.safeTransferFrom(user, address(staking), 1);
        vm.warp(block.timestamp + 2 days);
        staking.withdrawRewards(1);
        vm.stopPrank();

        assertEq(rewardToken.balances(user), 2 ether);
    }

    function testWithdrawRewardsNotStaked() public {
        vm.startPrank(user);
        nft.safeTransferFrom(user, address(staking), 1);
        vm.warp(block.timestamp + 2 days);
        vm.expectRevert("Token is not staked");
        staking.withdrawRewards(11111);
        vm.stopPrank();
    }

    function testWithdrawRewardsNotOwner() public {
        vm.startPrank(user);
        nft.safeTransferFrom(user, address(staking), 1);
        vm.warp(block.timestamp + 2 days);

        address user2 = address(0x456);
        vm.startPrank(user2);
        vm.expectRevert("Only owner can withdraw rewards");
        staking.withdrawRewards(1);
        vm.stopPrank();
    }

    function testWithdrawRewardsEarly() public {
        vm.startPrank(user);
        nft.safeTransferFrom(user, address(staking), 1);
        vm.warp(block.timestamp + 1 days);

        vm.expectRevert("At least 1 day must pass from previous reward");
        staking.withdrawRewards(1);
        vm.stopPrank();
    }

    function testUnstake() public {
        vm.startPrank(user);
        nft.safeTransferFrom(user, address(staking), 1);
        vm.warp(block.timestamp + 2 days);
        staking.unstake(1);
        vm.stopPrank();

        assertEq(nft.ownerOf(1), user);
        assertEq(rewardToken.balances(user), 2 ether);
    }

    function testUnstakeNotStaked() public {
        vm.startPrank(user);
        nft.safeTransferFrom(user, address(staking), 1);
        vm.warp(block.timestamp + 2 days);
        vm.expectRevert("Token is not staked");
        staking.unstake(11111);
    }

    function testUnstakeEarly() public {
        vm.startPrank(user);
        nft.safeTransferFrom(user, address(staking), 1);
        vm.warp(block.timestamp + 1 days);
        vm.expectRevert("At least 1 day must pass from previous reward");
        staking.unstake(1);
    }

    function testUnstakeNotOwner() public {
        vm.startPrank(user);
        nft.safeTransferFrom(user, address(staking), 1);
        vm.warp(block.timestamp + 2 days);

        address user2 = address(0x456);
        vm.startPrank(user2);
        vm.expectRevert("Only owner can unstake");
        staking.unstake(1);
        vm.stopPrank();
    }
}
