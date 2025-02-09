// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IRewardToken {
    function mint(address to, uint256 amount) external;
}
