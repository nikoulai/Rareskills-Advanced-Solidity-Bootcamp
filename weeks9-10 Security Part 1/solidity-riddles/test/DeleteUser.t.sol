// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DeleteUser.sol";

contract DeleteUserTest is Test {
  DeleteUser victimContract;
  address attackerWallet;

  function setUp() public {
    victimContract = new DeleteUser();
    vm.deal(address(victimContract), 1 ether);
    attackerWallet = address(0x1234);
  }

  function testExploit() public {
    // Conduct your attack here

    // Assert the balance of the victim contract is 0
    assertEq(address(victimContract).balance, 0);

    // Assert the attacker wallet has conducted one transaction
    assertEq(vm.getNonce(attackerWallet), 1);
  }
}
