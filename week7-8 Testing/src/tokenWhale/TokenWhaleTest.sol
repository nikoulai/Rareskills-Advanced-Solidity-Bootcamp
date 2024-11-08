// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.4.21;

import "./TokenWhale.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise1/template.sol
///      ```
contract TestToken is TokenWhaleChallenge {
    address echidna = tx.origin;

    //     constructor() {
    //         balances[echidna] = 10000;
    //     }

    function echidna_test_balance() public view returns (bool) {
        return isComplete();
    }
}
