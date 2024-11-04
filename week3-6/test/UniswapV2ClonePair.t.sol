// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {UniswapV2ClonePair} from "../src/UniswapV2ClonePair.sol";
// import "solady/tokens/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor(uint256 initialSupply) ERC20("Token", "TK") {
        _mint(msg.sender, initialSupply);
    }
}

contract UniswapV2ClonePairChild is UniswapV2ClonePair {
    function _update_harness(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) external {
        super._update(balance0, balance1, _reserve0, _reserve1);
    }
}

contract UniswapV2ClonePairTest is Test {
    UniswapV2ClonePairChild public uniswapV2ClonePair;
    address factory = makeAddr("factory");
    address liquidityProvider1 = makeAddr("liquidityProvider1");
    address liquidityProvider2 = makeAddr("liquidityProvider2");
    Token tokenA;
    Token tokenB;

    function setUp() public {
        vm.startPrank(factory);
        tokenA = new Token(1_000_000_000 * 1e18);
        tokenB = new Token(1_000_000_000 * 1e18);

        uniswapV2ClonePair = new UniswapV2ClonePairChild();

        tokenA.transfer(liquidityProvider1, 1_000_000 * 1e18);
        tokenB.transfer(liquidityProvider1, 1_000_000 * 1e18);
        tokenA.transfer(liquidityProvider2, 1_000_000 * 1e18);
        tokenB.transfer(liquidityProvider2, 1_000_000 * 1e18);
    }

    function test_initialize() public {
        uniswapV2ClonePair.initialize(address(tokenA), address(tokenB));

        assertEq(uniswapV2ClonePair.token0(), address(tokenA));
        assertEq(uniswapV2ClonePair.token1(), address(tokenB));
    }

    // function test_mint() public {
    //     vm.expectRevert("UniswapV2Clone: INSUFFICIENT_LIQUIDITY");
    //     uniswapV2ClonePair.mint(makeAddr("to"));

    //     vm.startPrank(liquidityProvider1);
    //     tokenA.transfer(address(uniswapV2ClonePair), 10 * 1e18);
    //     tokenB.transfer(address(uniswapV2ClonePair), 10 * 1e18);

    //     uint256 liquidity1 = uniswapV2ClonePair.mint(address(liquidityProvider1));
    //     require(liquidity1 > 0);
    // }
}
