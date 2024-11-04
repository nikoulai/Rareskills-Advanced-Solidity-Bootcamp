// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {UniswapV2CloneFactory} from "../src/UniswapV2CloneFactory.sol";

contract UniswapV2CloneFactoryTest is Test {
    UniswapV2CloneFactory public uniswapV2CloneFactory;
    address deployer = makeAddr("deployer");
    address newToFeeSetter = makeAddr("newToFeeSetter");
    address newToFee = makeAddr("newToFee");

    function setUp() public {
        vm.startPrank(deployer);
        uniswapV2CloneFactory = new UniswapV2CloneFactory(deployer);
    }

    function test_FeeToSetter() public {
        address feeToSetter = uniswapV2CloneFactory.feeToSetter();
        assertEq(feeToSetter, deployer);
    }

    function test_SetFeeToSetter() public {
        uniswapV2CloneFactory.setFeeToSetter(newToFeeSetter);
        address feeToSetter = uniswapV2CloneFactory.feeToSetter();
        assertEq(newToFeeSetter, feeToSetter);
    }

    function test_SetFeeTo() public {
        uniswapV2CloneFactory.setFeeTo(newToFee);

        address feeTo = uniswapV2CloneFactory.feeTo();
        assertEq(newToFee, feeTo);
    }

    function test_CreatePair() public {
        address tokenA = makeAddr("tokenA");
        address tokenB = makeAddr("tokenB");
        address pair = uniswapV2CloneFactory.createPair(tokenA, tokenB);

        assertNotEq(pair, address(0));
    }

    function test_CreatePairAddress0() public {
        address tokenA = makeAddr("tokenA");
        address tokenB = makeAddr("tokenB");
        vm.expectRevert("UniswapV2Clone: ZERO_ADDRESS");
        address pair = uniswapV2CloneFactory.createPair(address(0), tokenB);
    }

    function test_CreatePairDuplicateToken() public {
        address tokenA = makeAddr("tokenA");
        vm.expectRevert("UniswapV2Clone: IDENTICAL_ADDRESSES");
        address pair = uniswapV2CloneFactory.createPair(tokenA, tokenA);
    }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
