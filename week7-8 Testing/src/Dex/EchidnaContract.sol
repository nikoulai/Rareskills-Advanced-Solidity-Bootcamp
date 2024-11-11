// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Dex, SwappableToken} from "./Dex.sol";
// run in week7-8%20Testing/
//echidna . --config src/Dex/config.yaml --contract EchidnaContract

contract EchidnaContract {
    Dex dex;
    SwappableToken token1;
    SwappableToken token2;

    address echidna; // = tx.origin;

    event Debug(uint256);

    constructor() {
        echidna = msg.sender;

        dex = new Dex();

        token1 = new SwappableToken(address(this), "Token1", "TK1", 110 ether);
        token2 = new SwappableToken(address(this), "Token2", "TK1", 110 ether);

        //setup dex
        token1.approve(address(dex), 100 ether);
        token2.approve(address(dex), 100 ether);

        dex.setTokens(address(token1), address(token2));

        dex.addLiquidity(address(token1), 100 ether);
        dex.addLiquidity(address(token2), 100 ether);

        //setup echidna
        // token1.transfer(echidna, 10);
        // token2.transfer(echidna, 10);
        emit Debug(token1.balanceOf(address(this)));
        emit Debug(token1.balanceOf(address(this)));

        //renounce ownership
        dex.transferOwnership(address(0x01));
    }

    function swap12(uint256 amount) public {
        // dex.approve(address(dex), amount);
        dex.swap(address(token1), address(token2), amount);
    }

    function swap21(uint256 amount) public {
        dex.swap(address(token2), address(token1), amount);
    }

    function echidna_check() public returns (bool) {
        emit Debug(dex.balanceOf(address(token1), address(this)));
        emit Debug(dex.balanceOf(address(token2), address(this)));
        return (
            dex.balanceOf(address(token1), address(this)) > 10 ether
                && dex.balanceOf(address(token2), address(this)) > 10 ether
        );
    }
}
