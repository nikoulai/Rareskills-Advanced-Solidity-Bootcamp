// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {console} from "forge-std/console.sol";

contract SCEcosystem1 is ERC721, ERC721Royalty, Ownable2Step {
    uint256 public MAX_SUPPLY = 1000;
    //reward rate of 2.5%
    uint96 public FEE_NUMERATOR = 250;

    uint128 public constant MINT_FEE = 0.1 ether;

    uint256 public totalSupply = 0;

    bytes32 public immutable merkleRoot;
    BitMaps.BitMap private _airdropList;

    modifier maxSupply() {
        require(totalSupply < MAX_SUPPLY, "Max supply reached");
        _;
    }

    constructor(bytes32 _merkleRoot) ERC721("SCEcosystem1", "SCE1") Ownable(_msgSender()) {
        merkleRoot = _merkleRoot;
        _setDefaultRoyalty(_msgSender(), FEE_NUMERATOR);
    }

    function mint() external payable maxSupply {
        //todo add withdraw function
        require(msg.value >= MINT_FEE, "Insufficient funds");

        totalSupply++;

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

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function withdraw() external onlyOwner {
        (bool success,) = payable(owner()).call{value: (address(this).balance)}("");

        //maybe assert?
        require(success, "Transfer failed");
    }
}
