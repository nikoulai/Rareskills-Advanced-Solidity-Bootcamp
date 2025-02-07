# Proxy Pattern Questions

## Table of Contents
1. [OZ Upgrade Tool Defenses](#oz-upgrade-tool-defenses)
2. [Beacon Proxy Usage](#beacon-proxy-usage)
3. [Storage Gap Purpose](#storage-gap-purpose)
4. [Proxy vs Implementation Initialization](#proxy-vs-implementation-initialization)
5. [Reinitializer Usage](#reinitializer-usage)

## OZ Upgrade Tool Defenses
- [ ] **Question 1:** The OZ upgrade tool for hardhat defends against 6 kinds of mistakes. What are they and why do they matter?
	1. Validates that the implementation is upgrade safe (there is no constructor, selfdestruct, delecatecall) and compatible (storage layout of both implementations must be compatible).
	2. checks if there is an implementation with the same bytecode deployed
	3. keeps track of the implementation contracts


## Beacon Proxy Usage
- [ ] **Question 2:** What is a beacon proxy used for?
	It allows you to deploy a new implementation contract and upgrade all proxies simultaneously

## Storage Gap Purpose
- [ ] **Question 3:** Why does the openzeppelin upgradeable tool insert something like `uint256[50] private __gap;` inside the contracts? To see it, create an upgradeable smart contract that has a parent contract and look in the parent.
	1. It allows you to add new state variables to the implementation of base contracts/parents without breaking the storage layout of the proxy contract.

## Proxy vs Implementation Initialization
- [ ] **Question 4:** What is the difference between initializing the proxy and initializing the implementation? Do you need to do both? When do they need to be done?
	1. The proxy initialization is done when the proxy is deployed (constructor)
	2. The implementation initialization is done when the implementation is deployed and the proxy has to delegatecall the implementation's initialize function. The initialization in the context of the implementation sometimes needs to be in order to avoid malicious behaviors (like calling selfdestruct on the implementaiton or delegatecall another contract //although selfdestruct will be deprecated). The initialization of the impementation context is not mandatory because our application is not interacting with it.

## Reinitializer Usage
- [ ] **Question 5:** What is the use for the [reinitializer](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/Initializable.sol#L119)? Provide a minimal example of proper use in Solidity
	1. It allows to reinialize storage variables again if the version is greater than the current version. (can this be done by the inializer though?)