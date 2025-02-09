// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract RewardTokenUpgradeable is ERC20Upgradeable {
    address public minter;

    function initialize(address _minter) external initializer {
        __ERC20_init("RewardToken", "RWT");
        // _mint(msg.sender, 1000000 * 10 ** decimals());
        minter = _minter;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == minter, "Only minter can mint");
        _mint(to, amount);
    }
}
