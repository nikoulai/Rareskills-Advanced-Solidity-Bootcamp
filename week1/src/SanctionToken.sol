// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SanctionToken is ERC20, Ownable {
    mapping(address => bool) public bannedAddresses;

    //TODO add events for ban and unban
    //TODO add tests for events
    constructor() ERC20("SanctionsToken", "ST") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function banAddress(address _address) public onlyOwner {
        bannedAddresses[_address] = true;
        //emit
    }

    function unbanAddress(address _address) public onlyOwner {
        bannedAddresses[_address] = false;
        //emit
    }

    function _update(address from, address to, uint256 value) internal override {
        require(!bannedAddresses[from], "Sender is banned");
        ERC20._update(from, to, value);
    }
}
