// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {Options,Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Script} from "forge-std/Script.sol";
import "../src/Ecosystem1/SCEcosystem1UpgradeableV2.sol";

contract UpgradesScript is Script {
    address owner;
    address addr1;
    address addr2;
    bytes32 root;
    bytes32[] leaves;

    function setUp() public {
        owner = address(this);
        addr1 = address(0x1);
        addr2 = address(0x2);

        leaves = new bytes32[](2);

        // Create a Merkle Tree for testing
        // leaves[0] = keccak256(abi.encodePacked(addr1, uint256(0)));
        // leaves[1] = keccak256(abi.encodePacked(addr2, uint256(1)));
        leaves[0] = keccak256(bytes.concat(keccak256(abi.encode(addr1, uint256(0)))));
        leaves[1] = keccak256(bytes.concat(keccak256(abi.encode(addr2, uint256(1)))));
        root = keccak256(bytes.concat(leaves[0], leaves[1]));
    }
function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    // Specifying the address of the existing transparent proxy
    address ecosystem1Proxy = 'your-transparent-proxy-address';

     // Setting options for validating the upgrade
    Options memory opts;
    opts.referenceContract = "ContractA.sol";

    // Validating the compatibility of the upgrade
    Upgrades.validateUpgrade("ContractB.sol", opts);

    // Upgrading to ContractB and attempting to increase the value

    Upgrades.upgradeProxy(ecosystem1Proxy, "SCEcosystem1UpgradeableV2.sol",abi.encodeCall(SCEcosystem1UpgradeableV2.initialize, root),msg.sender);
}

}