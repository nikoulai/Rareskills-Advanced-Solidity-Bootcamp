// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/FuzzyIdentity.sol";

contract FuzzyIdentityTest is Test {
    FuzzyIdentity public fuzzyIdentity;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        fuzzyIdentity = (new FuzzyIdentity)();
    }

    function testFuzzyIdentity() public {
        vm.deal(0x4a27c059FD7E383854Ea7DE6Be9c390a795f6eE3, 100 ether);
        vm.startPrank(0x4a27c059FD7E383854Ea7DE6Be9c390a795f6eE3);

        bytes memory bytecode = type(ExploitContract).creationCode;
        console.logBytes(bytecode);

        bytecode =
            hex"6080604052348015600e575f80fd5b5060ce80601a5f395ff3fe6080604052348015600e575f80fd5b50600436106026575f3560e01c806306fdde0314602a575b5f80fd5b60306044565b604051603b91906081565b60405180910390f35b5f7f736d617278000000000000000000000000000000000000000000000000000000905090565b5f819050919050565b607b81606b565b82525050565b5f60208201905060925f8301846074565b9291505056fea264697066735822122025a7075cc13ab0a3778d555d6be017f567ec27a7d39ea4948b135762b9ff767364736f6c634300081a0033";
        // console.logBytes(bytecode);
        deploy(bytecode, 0xcf2c767625aa1718061429f9dac201ade443a39eb72ab40d2deb3e53d1aee9ae);
        // console.log("addr", addr);
        // console.log("salt", salt);

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(fuzzyIdentity.isComplete(), "Not solved");
    }

    function deploy(bytes memory bytecode, uint256 _salt) public payable {
        address addr;

        /*
        NOTE: How to call create2
        create2(v, p, n, s)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        where new address = first 20 bytes of keccak256(0xff + address(this) + s + keccak256(mem[p…(p+n)))
              s = big-endian 256-bit value
        */
        // uint256 size = bytecode.length;
        // console.logUint(size);
        assembly {
            addr :=
                create2(
                    0xff,
                    // callvalue(), // wei sent with current call
                    // Actual code starts after skipping the first 32 bytes
                    add(bytecode, 0x20),
                    mload(bytecode), // Load the size of code contained in the first 32 bytes
                    _salt // Salt from function arguments
                )

            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
    }

    receive() external payable {}
}
