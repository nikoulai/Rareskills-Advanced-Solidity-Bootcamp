// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./mintable.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise3/template.sol --contract TestToken
///      ```
contract TestToken is MintableToken {
    address echidna = msg.sender;

    // TODO: update the constructor
    constructor() MintableToken(10_000) {
        owner = echidna;
    }

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
        return balances[echidna] <= 10_000;
    }
}
