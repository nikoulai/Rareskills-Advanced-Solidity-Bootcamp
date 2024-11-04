// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "./interfaces/IUniswapV2Factory.sol";
import "./UniswapV2ClonePair.sol";

contract UniswapV2CloneFactory is IUniswapV2Factory {
    address public feeToSetter;
    address public feeTo;

    address[] public allPairs;
    mapping(address => mapping(address => address)) public getPair;

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    // function getPair(address tokenA, address tokenB) external view returns (address pair) {}
    // function allPairs(uint256) external view returns (address pair) {}

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        require(tokenA != tokenB, "UniswapV2Clone: IDENTICAL_ADDRESSES");
        require(tokenA != address(0x0), "UniswapV2Clone: ZERO_ADDRESS");
        require(getPair[tokenA][tokenB] == address(0), "UniswapV2Clone: PAIR_EXISTS");

        // bytes memory bytecode = type(UniswapV2ClonePair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        pair = address(new UniswapV2ClonePair{salt: salt}());

        //The factory contract can be simplified without assembly because of Solidity updates.
        // assembly {
        //     pair := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        // }

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "UniswapV2Clone: must be called from feeToSetter");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _newFeeToSetter) external {
        require(msg.sender == feeToSetter, "UniswapV2Clone: must be called from feeToSetter");
        feeToSetter = _newFeeToSetter;
    }
}
