// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Test.sol";

// contract DumbBankRobberTest is Test {
//     DumbBank victimContract;
//     address attackerWallet;

//     function setUp() public {
//         victimContract = new DumbBank();
//         victimContract.deposit{value: 10 ether}();

//         attackerWallet = address(0x1234);
//         vm.deal(attackerWallet, 1 ether);
//     }

//     function testExploit() public {
//         vm.startPrank(attackerWallet);
//         new BankRobber{value: 1 ether}(address(victimContract));
//         vm.stopPrank();

//         assertEq(address(victimContract).balance, 0);
//         assertEq(attackerWallet.balance, 11 ether);
//     }
// }
