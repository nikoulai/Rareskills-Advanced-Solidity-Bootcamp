// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PredictTheFuture.sol";

contract PredictTheFutureTest is Test {
    PredictTheFuture public predictTheFuture;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        predictTheFuture = (new PredictTheFuture){value: 1 ether}();
        exploitContract = new ExploitContract(predictTheFuture);
    }

    function testGuess() public {
        // Set block number and timestamp
        // Use vm.roll() and vm.warp() to change the block.number and block.timestamp respectively
        vm.roll(104293);
        vm.warp(93582192);

        // Put your solution here

        //fast forward to calculate the answer
        vm.roll(104296);
        vm.warp(93584192);
        exploitContract.Exploiter{value: 1 ether}();

        //go back to lock in the guess
        vm.roll(104293);
        vm.warp(93582192);
        exploitContract.lockInGuess();

        //fast forward again to settle
        vm.roll(104296);
        vm.warp(93584192);
        exploitContract.settle();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(predictTheFuture.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
