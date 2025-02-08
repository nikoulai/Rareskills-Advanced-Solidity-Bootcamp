// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "openzeppelin-foundry-upgrades/Upgrades.sol";
import "../../src/Ecosystem1/SCEcosystem1.sol";
import "../../src/Ecosystem1/Staking.sol";
import "../../src/Ecosystem1/RewardToken.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract UpgradesTest is Test {
    function testTransparent() public {
        address rewardTokenProxy = Upgrades.deployTransparentProxy(
            "RewardToken.sol", msg.sender, abi.encodeCall(RewardToken.initialize, (msg.sender))
        );

        address stakingProxy = Upgrades.deployTransparentProxy(
            "Staking.sol",
            msg.sender,
            abi.encodeCall(Staking.initialize, (address(rewardTokenProxy), address(new MockNFT())))
        );

        address ecosystem1Proxy = Upgrades.deployTransparentProxy(
            "SCEcostem1.sol", msg.sender, abi.encodeCall(SCEcosystem1.initialize, (0x00))
        );

        // Get the instances of the contract
        SCEcosystem1 instance = SCEcosystem1(ecosystem1Proxy);
        Staking staking = Staking(stakingProxy);
        RewardToken rewardToken = RewardToken(rewardTokenProxy);

        // Get the implementation address of the proxy
        address ecosystem1ImplAddrV1 = Upgrades.getImplementationAddress(ecosystem1Proxy);
        address stakingImplAddrV1 = Upgrades.getImplementationAddress(stakingProxy);
        address rewardTokenImplAddrV1 = Upgrades.getImplementationAddress(rewardTokenProxy);

        // Get the admin address of the proxy
        address adminAddr = Upgrades.getAdminAddress(ecosystem1Proxy);
        address stakingAdminAddr = Upgrades.getAdminAddress(stakingProxy);
        address rewardTokenAdminAddr = Upgrades.getAdminAddress(rewardTokenProxy);

        // Ensure the admin address is valid
        // Ensure the admin address is valid
        assertFalse(adminAddr == address(0));
        assertFalse(stakingAdminAddr == address(0));
        assertFalse(rewardTokenAdminAddr == address(0));

        // Log the initial value
        console.log("----------------------------------");
        console.log("Value before upgrade --> ", instance.totalSupply());
        console.log("----------------------------------");

        // // Verify initial value is as expected
        // assertEq(instance.value(), 10);

        // // Upgrade the proxy to ContractB
        // Upgrades.upgradeProxy(proxy, "ContractB.sol", "", msg.sender);

        // // Get the new implementation address after upgrade
        // address implAddrV2 = Upgrades.getImplementationAddress(proxy);

        // // Verify admin address remains unchanged
        // assertEq(Upgrades.getAdminAddress(proxy), adminAddr);

        // // Verify implementation address has changed
        // assertFalse(implAddrV1 == implAddrV2);

        // // Invoke the increaseValue function separately
        // ContractB(address(instance)).increaseValue();

        // // Log and verify the updated value
        // console.log("----------------------------------");
        // console.log("Value after upgrade --> ", instance.value());
        // console.log("----------------------------------");
        // assertEq(instance.value(), 20);
    }

    // future code will go here
}
