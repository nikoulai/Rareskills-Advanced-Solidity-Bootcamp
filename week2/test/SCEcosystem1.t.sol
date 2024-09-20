// test/SCEcosystem1.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Ecosystem1/SCEcosystem1.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "forge-std/console.sol";

contract SCEcosystem1Test is Test {
    SCEcosystem1 public scecosystem1;
    address public owner;
    address public addr1;
    address public addr2;
    bytes32 public root;
    bytes32[] public proof;

    function setUp() public {
        owner = address(this);
        addr1 = address(0x1);
        addr2 = address(0x2);

        // Create a Merkle Tree for testing
        bytes32[] memory leaves = new bytes32[](2);
        // leaves[0] = keccak256(abi.encodePacked(addr1, uint256(0)));
        // leaves[1] = keccak256(abi.encodePacked(addr2, uint256(1)));
        leaves[0] = keccak256(bytes.concat(keccak256(abi.encode(addr1, uint256(0)))));
        // leaves[1] = keccak256(bytes.concat(keccak256(abi.encode(addr2, uint256(1)))));
        // root = keccak256(bytes.concat(leaves[0], leaves[1]));
        console.log(555);
        scecosystem1 = new SCEcosystem1(leaves[0]);
    }

    function testMint() public {
        vm.deal(addr1, 1 ether);
        vm.prank(addr1);
        scecosystem1.mint{value: 0.1 ether}();
        assertEq(scecosystem1.totalSupply(), 1);
        assertEq(scecosystem1.ownerOf(0), addr1);
    }

    function testMintWithDiscount() public {
        vm.deal(addr1, 1 ether);
        proof = new bytes32[](1);
        // proof[0] = keccak256(bytes.concat(keccak256(abi.encode(addr1, uint256(0)))));

        vm.prank(addr1);
        scecosystem1.mintWithDiscount{value: 0.05 ether}(proof, 0);
        assertEq(scecosystem1.totalSupply(), 1);
        assertEq(scecosystem1.ownerOf(0), addr1);
    }

    function testMaxSupply() public {
        for (uint256 i = 0; i < 1000; i++) {
            vm.deal(addr1, 1 ether);
            vm.prank(addr1);
            scecosystem1.mint{value: 0.1 ether}();
        }
        vm.deal(addr1, 1 ether);
        vm.prank(addr1);
        vm.expectRevert("Max supply reached");
        scecosystem1.mint{value: 0.1 ether}();
    }

    //     function testWithdraw() public {
    //         vm.deal(addr1, 1 ether);
    //         vm.prank(addr1);
    //         scecosystem1.mint{value: 0.1 ether}();

    //         uint256 initialBalance = owner.balance;
    //         scecosystem1.withdraw();
    //         uint256 finalBalance = owner.balance;
    //         assert(finalBalance > initialBalance);
    //     }

    //     function testVerifyProof() public {
    //         proof = new bytes32[](1);
    //         proof[0] = keccak256(abi.encodePacked(addr1, uint256(0)));
    //         bytes32 leaf = keccak256(abi.encodePacked(addr1, uint256(0)));
    //         assertTrue(MerkleProof.verify(proof, root, leaf));
    //     }
}
