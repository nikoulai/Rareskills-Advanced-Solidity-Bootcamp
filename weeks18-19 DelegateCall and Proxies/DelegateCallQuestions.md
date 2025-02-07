# DelegateCall Behavior Questions

## Table of Contents
1. [Implementation Self-Destruct](#implementation-self-destruct)
2. [Empty Implementation](#empty-implementation)
3. [Call Chain Msg.Sender](#call-chain-msgsender)
4. [Balance Check](#balance-check)
5. [Code Size](#code-size)
6. [Revert Behavior](#revert-behavior)
7. [Memory Pointer](#memory-pointer)
8. [Immutable Variables](#immutable-variables)
9. [Nested DelegateCall](#nested-delegatecall)

## Implementation Self-Destruct
- [ ] If a proxy calls an implementation, and the implementation self-destructs in the function that gets called, what happens?
	- Nothing, returns success.

## Empty Implementation
- [ ] If a proxy calls an empty address or an implementation that was previously self-destructed, what happens?
	- If high level delegatecall is used, it will revert (solidity adds the check if there is code at the address).
	- If low level delegatecall is used, it will not revert.


## Call Chain Msg.Sender
- [ ] If a user calls a proxy makes a delegatecall to A, and A makes a regular call to B, from A's perspective, who is msg.sender? from B's perspective, who is msg.sender? From the proxy's perspective, who is msg.sender?
	- From A's perspective, msg.sender is the user.
	- From B's perspective, msg.sender is the proxy.
	- From the proxy's perspective, msg.sender is the user.

## Balance Check
- [ ] If a proxy makes a delegatecall to A, and A does address(this).balance, whose balance is returned, the proxy's or A?
	- The balance of the proxy.

## Code Size
- [ ] If a proxy makes a delegatecall to A, and A calls codesize, is codesize the size of the proxy or A?
	- The size of the proxy.

## Revert Behavior
- [ ] If a delegatecall is made to a function that reverts, what does the delegatecall do?
	- It returns false.

## Memory Pointer
- [ ] Under what conditions does the Openzeppelin Proxy.sol overwrite the free memory pointer? Why is it safe to do this?
	- It uses only assembly.

## Immutable Variables
- [ ] If a delegatecall is made to a function that reads from an immutable variable, what will the value be?
	- The value of the immutable variable, since they are in the code.

## Nested DelegateCall
- [ ] If a delegatecall is made to a contract that makes a delegatecall to another contract, who is msg.sender in the proxy, the first contract, and the second contract? 
	- In all is the user.