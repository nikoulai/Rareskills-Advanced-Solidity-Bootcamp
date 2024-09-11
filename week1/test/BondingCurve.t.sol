// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {BondingCurve} from "../src/BondingCurve.sol";

contract BondingCurveTest is Test {
    BondingCurve public bondingCurve;

    address user1;
    address user2;

    function setUp() public {
        bondingCurve = new BondingCurve(1, 1);

        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        bondingCurve.purchase(1000 ether);
        bondingCurve.purchase(1000 ether);
    }

    function test_purchase() public {
        bondingCurve.purchase(10 ether);

        assertEq(bondingCurve.balanceOf(address(this)), 10 ether);
    }

    function test_sale() public {
        bondingCurve.sell(10 ether);

        assertEq(bondingCurve.balanceOf(address(this)), 1990 ether);
    }

    function test_calculatePurchasePrice() public {
        uint256 price = bondingCurve.calculatePurchasePrice(10 ether);

        assertEq(price, 10 ether);
    }

    function test_calculateSalePrice() public {
        uint256 price = bondingCurve.calculateSalePrice(10 ether);

        assertEq(price, 10 ether);
    }

    function test_calculatePrice() public {
        uint256 price = bondingCurve.calculatePrice(1000 ether, 1010 ether);

        assertEq(price, 1010 ether);
    }

    function test_setMaxGasPrice() public {
        bondingCurve.setMaxGasPrice(10 ether);

        assertEq(bondingCurve.maxGasPrice(), 10 ether);
    }
}
