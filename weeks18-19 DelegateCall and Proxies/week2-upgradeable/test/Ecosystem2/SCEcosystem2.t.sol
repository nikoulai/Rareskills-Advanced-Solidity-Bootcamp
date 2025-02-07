// test/SCEcosystem1.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/Ecosystem2/PrimeNFT.sol";
import "../../src/Ecosystem2/EnumerateNFT.sol";
import "forge-std/console.sol";

contract SCEcosystem2Test is Test {
    PrimeNFT public primeNFT;
    EnumerateNFT public enumerateNFT;
    address public owner;
    address public addr1;
    address public addr2;

    function setUp() public {
        owner = address(this);
        addr1 = makeAddr("user1");
        addr2 = makeAddr("user2");

        // console.logBytes32(leaves[0]);
        primeNFT = new PrimeNFT(owner);

        enumerateNFT = new EnumerateNFT(address(this));

        for(uint256 i = 0; i < 100; i++) {
            address mintTo = i % 3 == 0 && !(i % 5 ==0) ? addr1 : addr2;
            primeNFT.safeMint(mintTo, i);
        }
    }

    function testMint() public {
        assertEq(primeNFT.totalSupply(), 100);

        uint256 ownerSupply1 = primeNFT.balanceOf(addr1);
        uint256 ownerSupply2 = primeNFT.balanceOf(addr2);

        assertEq(ownerSupply1, 27);
        assertEq(ownerSupply2, 73);
    }

    function testPrimeTest() public {

     uint8[25] memory primes = [  2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97];


        for(uint256 i = 0; i < 25; i++) {
            assert(enumerateNFT.primeTest(primes[i]));
        }

        assert(!enumerateNFT.primeTest(1));
        assert(!enumerateNFT.primeTest(4));
        assert(!enumerateNFT.primeTest(6));
        assert(!enumerateNFT.primeTest(8));
        assert(!enumerateNFT.primeTest(9));
        assert(!enumerateNFT.primeTest(10));
        assert(!enumerateNFT.primeTest(12));
        assert(!enumerateNFT.primeTest(14));
        assert(!enumerateNFT.primeTest(50));
        assert(!enumerateNFT.primeTest(72));
        assert(!enumerateNFT.primeTest(74));
        assert(!enumerateNFT.primeTest(100));
    }


    function testEnumerate() public {
        enumerateNFT = new EnumerateNFT(address(primeNFT));

        // uint256 primeCounter1 = enumerateNFT.enumeratePrimeNFTs(addr1);
        uint256 primeCounter2 = enumerateNFT.enumeratePrimeNFTs(addr2);

        assertEq(primeCounter2, 24);
    }

    // function testMintWithDiscount() public {
    //     vm.deal(addr1, 1 ether);
    //     proof = new bytes32[](1);
    //     proof[0] = leaves[1];
    //     vm.prank(addr1);
    //     scecosystem1.mintWithDiscount{value: 0.05 ether}(proof, 0);
    //     assertEq(scecosystem1.totalSupply(), 1);
    //     assertEq(scecosystem1.ownerOf(0), addr1);
    // }

    // function testMaxSupply() public {
    //     for (uint256 i = 0; i < 1000; i++) {
    //         vm.deal(addr1, 1 ether);
    //         vm.prank(addr1);
    //         scecosystem1.mint{value: 0.1 ether}();
    //     }
    //     vm.deal(addr1, 1 ether);
    //     vm.prank(addr1);
    //     vm.expectRevert("Max supply reached");
    //     scecosystem1.mint{value: 0.1 ether}();
    // }

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
