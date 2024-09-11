// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GodToken is ERC20, Ownable {
    mapping(address => bool) public bannedAddresses;

    constructor() ERC20("GodToken", "GT") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function godTokenTransfer(address _from, address _to, uint256 _value) public onlyOwner {
        _transfer(_from, _to, _value);
    }
}
