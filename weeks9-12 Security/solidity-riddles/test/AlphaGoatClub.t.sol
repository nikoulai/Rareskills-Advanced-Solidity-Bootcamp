// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Test.sol";

// contract AlphaGoatClubTest is Test {
//     AlphaGoatClubPrototypeNFT alphaGoatClub;
//     address attacker;

//     function setUp() public {
//         attacker = address(0x1234); // Replace with a valid address
//         alphaGoatClub = new AlphaGoatClubPrototypeNFT();
//     }

//     function testExploit() public {
//         // Your exploit here
//         /**
//          * The goal is to use the attacker wallet to mint the NFT at index 0 to itself.
//          */
//         vm.startPrank(attacker);
//         alphaGoatClub.mint(attacker, 0); // Assuming mint function exists and takes (address, tokenId)
//         vm.stopPrank();

//         // Check the owner of the NFT
//         assertEq(alphaGoatClub.ownerOf(0), attacker);

//         // Check the transaction count
//         uint256 txCount = vm.getNonce(attacker);
//         assert(txCount < 3, "must exploit in two transactions or less");
//     }
// }
