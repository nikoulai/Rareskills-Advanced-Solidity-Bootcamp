// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import {console} from "forge-std/console.sol";

contract EnumerateNFT {
    IERC721Enumerable private primeNFT;

    constructor(address _primeNFT) {
        primeNFT = IERC721Enumerable(_primeNFT);
    }

    function enumeratePrimeNFTs(address nftOwner) external view returns (uint256 primeCounter) {
        uint256 ownerSupply = primeNFT.balanceOf(nftOwner);

        primeCounter = 0;

        uint256[] memory tokenIds = new uint256[](ownerSupply);

        for (uint256 i = 0; i < ownerSupply; i++) {
            tokenIds[i] = primeNFT.tokenOfOwnerByIndex(nftOwner, i);
        }

        // for (uint256 i = 0; i < ownerSupply;) {
        uint256 i = 0;
        do {
            if (primeTest(tokenIds[i])) {
                primeCounter++;
                console.logUint(tokenIds[i]);
            }

            unchecked {
                ++i;
            }
        } while (i < ownerSupply);
        // }

        return primeCounter;
    }

    function primeTest(uint256 tokenId) public pure returns (bool) {
        if (tokenId <= 1) {
            return false;
        }

        for (uint256 i = 2; i < tokenId; i++) {
            if (tokenId % i == 0) {
                return false;
            }
        }

        return true;
    }
}
