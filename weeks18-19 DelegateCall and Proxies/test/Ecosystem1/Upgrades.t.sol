// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "openzeppelin-foundry-upgrades/Upgrades.sol";
import "../../src/Ecosystem1/SCEcosystem1Upgradeable.sol";
import "../../src/Ecosystem1/SCEcosystem1UpgradeableV2.sol";
import "../../src/Ecosystem1/StakingUpgradeable.sol";
import "../../src/Ecosystem1/RewardTokenUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract UpgradesTest is Test {
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

    function testTransparent() public {
        root = keccak256(bytes.concat(leaves[0], leaves[1]));
        address rewardTokenProxy = Upgrades.deployTransparentProxy(
            "RewardTokenUpgradeable.sol", msg.sender, abi.encodeCall(RewardTokenUpgradeable.initialize, (msg.sender))
        );

        address stakingProxy = Upgrades.deployTransparentProxy(
            "StakingUpgradeable.sol",
            msg.sender,
            abi.encodeCall(StakingUpgradeable.initialize, (address(rewardTokenProxy), address(new MockNFT())))
        );

        // vm.getCode("SCEcosystem1Upgradeable.sol");
        address ecosystem1Proxy = Upgrades.deployTransparentProxy(
            "SCEcosystem1Upgradeable.sol", msg.sender, abi.encodeCall(SCEcosystem1Upgradeable.initialize, root)
        );

        // // Get the instances of the contract
        SCEcosystem1Upgradeable instance = SCEcosystem1Upgradeable(ecosystem1Proxy);
        StakingUpgradeable staking = StakingUpgradeable(stakingProxy);
        RewardTokenUpgradeable rewardToken = RewardTokenUpgradeable(rewardTokenProxy);

        // // Get the implementation address of the proxy
        address ecosystem1ImplAddrV1 = Upgrades.getImplementationAddress(ecosystem1Proxy);
        address stakingImplAddrV1 = Upgrades.getImplementationAddress(stakingProxy);
        address rewardTokenImplAddrV1 = Upgrades.getImplementationAddress(rewardTokenProxy);

        // // Get the admin address of the proxy
        address adminAddr = Upgrades.getAdminAddress(ecosystem1Proxy);
        address stakingAdminAddr = Upgrades.getAdminAddress(stakingProxy);
        address rewardTokenAdminAddr = Upgrades.getAdminAddress(rewardTokenProxy);

        // // Ensure the admin address is valid
        // // Ensure the admin address is valid
        assertFalse(adminAddr == address(0));
        assertFalse(stakingAdminAddr == address(0));
        assertFalse(rewardTokenAdminAddr == address(0));

        // Log the initial value
        console.log("----------------------------------");
        console.log("Value before upgrade --> ", instance.totalSupply());
        console.log("----------------------------------");

        // // Verify initial value is as expected
        // assertEq(instance.value(), 10);

        bytes4 forceTransferSelector = bytes4(keccak256("forceTransfer(address,address,uint256)"));
        (bool successV1,) =
            address(ecosystem1Proxy).call(abi.encodeWithSelector(forceTransferSelector, address(0), address(0), 0));
        assertFalse(successV1);

        // Upgrade the proxy to ContractB
        Upgrades.upgradeProxy(ecosystem1Proxy, "SCEcosystem1UpgradeableV2.sol", "", msg.sender);

        // // Get the new implementation address after upgrade
        address implAddrV2 = Upgrades.getImplementationAddress(ecosystem1Proxy);

        // // Verify admin address remains unchanged
        assertEq(Upgrades.getAdminAddress(ecosystem1Proxy), adminAddr);

        // // Verify implementation address has changed
        assertFalse(ecosystem1ImplAddrV1 == implAddrV2);

        // Check if forceTransfer exists in V2 (should return true)
        // (bool successV2,) =
        //     address(ecosystem1Proxy).call(abi.encodeWithSelector(forceTransferSelector, address(0), address(0), 0));
        // assertTrue(successV2);
        // // Log and verify the updated value
        // console.log("----------------------------------");
        // console.log("Value after upgrade --> ", instance.value());
        // console.log("----------------------------------");
        // assertEq(instance.value(), 20);
    }

    // future code will go here
}
