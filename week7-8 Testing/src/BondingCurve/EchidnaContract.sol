// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {BondingCurve} from "./BondingCurve.sol";

contract EchidnaContract is BondingCurve {
    constructor() BondingCurve(100, 1) {}

    function echidna_test_buy_price() public returns (bool) {
        uint256 purchasePriceBefore = calculatePurchasePrice(1);
        purchase(1);
        return purchasePriceBefore == calculateSalePrice(1);
    }

    function echidna_test_initial_price() public view returns (bool) {
        return a == 100;
    }

    function echidna_test_slope() public view returns (bool) {
        return b == 1;
    }
}
