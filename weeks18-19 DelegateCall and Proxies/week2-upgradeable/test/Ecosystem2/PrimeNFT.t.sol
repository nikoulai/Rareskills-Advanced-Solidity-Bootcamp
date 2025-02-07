// test/SCEcosystem1.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/Ecosystem2/PrimeNFT.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract TestERC721Receiver is IERC721Receiver {
    // Event for logging token reception
    event Received(address operator, address from, uint256 tokenId, bytes data);

    // ERC721 token receiver function
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
        public
        override
        returns (bytes4)
    {
        // Emit event for logging
        emit Received(operator, from, tokenId, data);

        // Return the selector for onERC721Received to confirm token transfer
        return this.onERC721Received.selector;
    }
}

contract PrimeNFTTest is Test {
    PrimeNFT public primeNFT;
    address public owner;
    address public addr1;
    address public addr2;

    function setUp() public {
        owner = makeAddr("owner");
        addr1 = makeAddr("user1");
        addr2 = makeAddr("user2");

        // console.logBytes32(leaves[0]);
        primeNFT = new PrimeNFT(owner);

        vm.startPrank(owner);
        for (uint256 i = 0; i < 100; i++) {
            address mintTo = i % 3 == 0 && !(i % 5 == 0) ? addr1 : addr2;
            primeNFT.safeMint(mintTo, i);
        }
    }

    function testOwner() public {
        assertEq(address(primeNFT.owner()), owner);
    }

    function testMint() public {
        for (uint256 i = 0; i < 100; i++) {
            address mintTo = i % 3 == 0 && !(i % 5 == 0) ? addr1 : addr2;
            assertEq(primeNFT.ownerOf(i), mintTo);
        }
    }

    function testTransfer() public {
        vm.startPrank(owner);
        address receiver = address(new TestERC721Receiver());
        uint256 i = 23112;
        primeNFT.safeMint(owner, i);
        primeNFT.transferFrom(owner, receiver, i);
        // assertEq(primeNFT.ownerOf(i), addr2);
    }

    function testSupportsInterface() public {
        assertEq(primeNFT.supportsInterface(0x80ac58cd), true);
    }
}
