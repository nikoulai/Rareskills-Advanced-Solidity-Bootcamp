// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IRewardToken {
    function mint(address to, uint256 amount) external;
}

contract Staking is IERC721Receiver {
    address public immutable rewardToken;
    address public immutable nft;
    mapping(uint256 => bool) public stakedTokens;
    mapping(uint256 => UserInfo) public tokenToUserInfo;

    struct UserInfo {
        address owner;
        uint256 lastReward;
    }

    constructor(address _rewardToken, address _nft) {
        rewardToken = _rewardToken;
        nft = _nft;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        stake(tokenId, from);
        return this.onERC721Received.selector;
    }

    function stake(uint256 tokenId, address from) internal {
        // transfer token to this contract
        // IERC721(msg.sender).safeTransferFrom(msg.sender, address(this), tokenId);

        // mint reward token
        // IRewardToken(rewardToken).mint(msg.sender, 1 ether);

        UserInfo memory info = UserInfo({owner: from, lastReward: block.timestamp});

        tokenToUserInfo[tokenId] = info;
    }

    function withdrawRewards(uint256 tokenId) public {
        require(stakedTokens[tokenId], "Token is not staked");
        UserInfo memory userInfo = tokenToUserInfo[tokenId];
        require(userInfo.owner == msg.sender, "Only owner can withdraw rewards");

        //withraw reward token
        uint256 timePassed = block.timestamp - userInfo.lastReward;

        require(timePassed > 1 days, "At least 1 day must pass from previous reward");

        //update storage
        tokenToUserInfo[tokenId].lastReward = block.timestamp;

        //Is this enough for taking care of the decimals?
        // mint reward token
        uint256 reward = timePassed * 1 ether / (1 days);

        IRewardToken(rewardToken).mint(msg.sender, reward);
    }

    function unstake(uint256 tokenId) external {
        require(stakedTokens[tokenId], "Token is not staked");
        require(tokenToUserInfo[tokenId].owner == msg.sender, "Only owner can unstake");

        //withraw reward token
        withdrawRewards(tokenId);

        stakedTokens[tokenId] = false;
        // tokenToUserInfo[tokenId] = UserInfo(address(0), 0);
        delete tokenToUserInfo[tokenId];
        // transfer token to owner
        IERC721(msg.sender).safeTransferFrom(address(this), msg.sender, tokenId);
    }
}
