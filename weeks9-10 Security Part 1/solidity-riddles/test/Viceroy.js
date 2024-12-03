// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GovernanceAttacker.sol";
import "../src/OligarchyNFT.sol";
import "../src/Governance.sol";
import "../src/CommunityWallet.sol";

contract ViceroyTest is Test {
  GovernanceAttacker attacker;
  OligarchyNFT oligarch;
  Governance governance;
  CommunityWallet communityWallet;
  address attackerWallet;

  function setUp() public {
    attackerWallet = address(0x1234);
    vm.deal(attackerWallet, 10 ether);

    attacker = new GovernanceAttacker();
    oligarch = new OligarchyNFT(address(attacker));
    governance = new Governance(address(oligarch));
    payable(address(governance)).transfer(10 ether);

    address walletAddress = governance.communityWallet();
    communityWallet = CommunityWallet(walletAddress);

    assertEq(address(governance).balance, 10 ether);
  }

  function testAttack() public {
    vm.startPrank(attackerWallet);
    attacker.attack(governance);
    vm.stopPrank();

    assertEq(address(communityWallet).balance, 0);
    assertGe(attackerWallet.balance, 10 ether);
    assertEq(attackerWallet.getTransactionCount(), 2);
  }
}
