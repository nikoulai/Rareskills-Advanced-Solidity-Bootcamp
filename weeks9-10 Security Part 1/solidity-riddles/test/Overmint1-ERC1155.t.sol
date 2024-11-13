// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Overmint1-ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
// import "../src/Overmint1_ERC1155_Attacker.sol";

contract Overmint1_ERC1155_Test is Test {
    Overmint1_ERC1155 victimContract;
    Overmint1_ERC1155_Attacker attackerContract;
    address attackerWallet;

    function setUp() public {
        victimContract = new Overmint1_ERC1155();
        attackerWallet = address(0x1234);
        vm.deal(attackerWallet, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(attackerWallet);
        attackerContract = new Overmint1_ERC1155_Attacker(address(victimContract));
        attackerContract.attack();
        vm.stopPrank();

        assertEq(victimContract.balanceOf(attackerWallet, 0), 5);
        assertLt(attackerWallet.nonce, 3, "must exploit in two transactions or less");
    }
}
