// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./token.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise4/template.sol --contract TestToken --test-mode assertion
///      ```
///      or by providing a config
///      ```
///      echidna program-analysis/echidna/exercises/exercise4/template.sol --contract TestToken --config program-analysis/echidna/exercises/exercise4/config.yaml
///      ```
contract TestToken is Token {
    function transfer(address to, uint256 value) public override {
        // TODO: include `assert(condition)` statements that
        // detect a breaking invariant on a transfer.
        // Hint: you may use the following to wrap the original function.

        uint256 balanceToBefore = balances[to];
        uint256 balanceFromBefore = balances[msg.sender];

        super.transfer(to, value);

        uint256 balanceToAfter = balances[to];
        uint256 balanceFromAfter = balances[msg.sender];

        assert(balanceToAfter >= balanceToBefore);
        assert(balanceFromAfter <= balanceFromBefore - value);
    }
}
