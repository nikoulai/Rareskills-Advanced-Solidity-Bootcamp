// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {UntrustedEscrow} from "../src/UntrustedEscrow.sol";
import {SanctionToken} from "../src/SanctionToken.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract UntrustedEscrowTest is Test {
    UntrustedEscrow public untrustedEscrow;

    address _seller = makeAddr("seller");
    address _buyer = makeAddr("buyer");

    ERC20 _token;

    function setUp() public {
        untrustedEscrow = new UntrustedEscrow();

        _token = new SanctionToken();

	_token.transfer(_buyer, 1000 ether);
    }

    function test_deposit_withdraw() public {

	vm.startPrank(_buyer);

	_token.approve(address(untrustedEscrow), 1000 ether);

	untrustedEscrow.deposit(_seller, address(_token), 1000 ether);


	vm.stopPrank();

	skip(3 days + 1 seconds);


	vm.startPrank(_seller);
	untrustedEscrow.withdraw();
    }

function test_deadline() public {

	vm.startPrank(_buyer);

	_token.approve(address(untrustedEscrow), 1000 ether);

	untrustedEscrow.deposit(_seller, address(_token), 1000 ether);


	vm.stopPrank();

	vm.expectRevert(bytes("Cannot withdraw before 3 days"));

	vm.startPrank(_seller);
	untrustedEscrow.withdraw();
    }
}
