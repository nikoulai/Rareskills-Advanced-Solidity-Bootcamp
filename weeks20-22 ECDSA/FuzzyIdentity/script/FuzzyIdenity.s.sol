// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/FuzzyIdentity.sol";
import "forge-std/Script.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        (address addr, uint256 salt) = fuzzIdentityAndDeploy();
        // console.log("addr", addr);
        // console.log("salt", salt);
    }

    function getBytecode() public pure returns (bytes memory) {
        bytes memory bytecode = type(ExploitContract).creationCode;

        return abi.encodePacked(bytecode);
    }

    function fuzzIdentityAndDeploy() public returns (address, uint256) {
        uint256 salt = 0xcf2c767625aa1718061429f9dac201ade443a39eb72ab40d2deb3e53d1aee9ae; // 0x695e3e1c59e96174dbce45176078b490b638548f2681782bb607159a4125f365;

        // bytes memory bytecode = getBytecode();

        bytes memory bytecode =
            hex"6080604052348015600e575f80fd5b5060ce80601a5f395ff3fe6080604052348015600e575f80fd5b50600436106026575f3560e01c806306fdde0314602a575b5f80fd5b60306044565b604051603b91906081565b60405180910390f35b5f7f736d617278000000000000000000000000000000000000000000000000000000905090565b5f819050919050565b607b81606b565b82525050565b5f60208201905060925f8301846074565b9291505056fea264697066735822122050770b992357def94f1dbfa77d11ad2ce99f83defbb59c3249947263e4c6a71d64736f6c634300081a0033";
        console.logBytes(bytecode);
        vm.deal(0x4a27c059FD7E383854Ea7DE6Be9c390a795f6eE3, 100 ether);
        vm.startPrank(0x4a27c059FD7E383854Ea7DE6Be9c390a795f6eE3);
        // while (true) {
        address addr = getAddress(bytecode, salt);
        console.logString("address");
        console.log(addr);
        if (isBadCode(addr)) {
            return (addr, salt);
        }

        salt++;
        // }
        return (address(0), 0);
    }

    function getAddress(bytes memory bytecode, uint256 _salt) public view returns (address) {
        console.logBytes(
            abi.encodePacked(
                bytes1(0xff), address(0x4a27c059FD7E383854Ea7DE6Be9c390a795f6eE3), _salt, keccak256(bytecode)
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(0x4a27c059FD7E383854Ea7DE6Be9c390a795f6eE3), _salt, keccak256(bytecode)
            )
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }

    function isBadCode(address _addr) internal pure returns (bool) {
        bytes20 addr = bytes20(_addr);
        bytes20 id = hex"000000000000000000000000000000000badc0de";
        bytes20 mask = hex"000000000000000000000000000000000fffffff";

        for (uint256 i = 0; i < 34; i++) {
            if (addr & mask == id) {
                return true;
            }
            mask <<= 4;
            id <<= 4;
        }

        return false;
    }
}
