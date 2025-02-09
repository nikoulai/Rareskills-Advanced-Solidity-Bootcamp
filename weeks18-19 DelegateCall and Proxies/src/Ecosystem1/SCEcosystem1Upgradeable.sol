// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721RoyaltyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

import {console} from "forge-std/console.sol";

contract SCEcosystem1Upgradeable is ERC721RoyaltyUpgradeable, Ownable2StepUpgradeable {
    uint256 public MAX_SUPPLY;
    //reward rate of 2.5%
    uint96 public FEE_NUMERATOR;

    uint128 public MINT_FEE;

    uint256 public totalSupply;

    bytes32 public merkleRoot;
    BitMaps.BitMap private _airdropList;

    modifier maxSupply() {
        require(totalSupply < MAX_SUPPLY, "Max supply reached");
        _;
    }

    function initialize(bytes32 _merkleRoot) external initializer {
        __ERC721_init("SCEcosystem1", "SCE1");
        __ERC721Royalty_init();
        __Ownable_init(_msgSender());
        merkleRoot = _merkleRoot;
        MAX_SUPPLY = 1000;
        FEE_NUMERATOR = 250;
        MINT_FEE = 0.1 ether;
        totalSupply = 0;
    }

    function mint() external payable maxSupply {
        //todo add withdraw function
        require(msg.value >= MINT_FEE, "Insufficient funds");

        totalSupply++;

        // log the total supply before ++ operation for mload instead of sload
        _safeMint(_msgSender(), totalSupply - 1);
    }

    function mintWithDiscount(bytes32[] calldata proof, uint256 index) external payable maxSupply {
        // check if already claimed
        require(!BitMaps.get(_airdropList, index), "Already claimed");

        require(msg.value >= MINT_FEE / 2, "Insufficient funds");

        // verify proof
        _verifyProof(proof, index, msg.sender);

        // set airdrop as claimed
        BitMaps.setTo(_airdropList, index, true);

        totalSupply++;
        _safeMint(_msgSender(), totalSupply - 1);
        // _setTokenRoyalty(totalSupply-1, _msgSender(), FEE_NUMERATOR);
    }

    function _verifyProof(bytes32[] memory proof, uint256 index, address addr) private view {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, index))));
        console.logBytes32(leaf);
        console.logBytes32(proof[0]);
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721RoyaltyUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function withdraw() external onlyOwner {
        (bool success,) = payable(owner()).call{value: (address(this).balance)}("");

        require(success, "Transfer failed");
    }
}
