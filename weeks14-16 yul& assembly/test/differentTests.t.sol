// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/Components.sol";

contract ComponentsTest is Test {
    Components public components;
    address public owner;
    address public addr1;

    string shortString = "this is short";

    string testlongString =
        "This is a long string that exceeds 256 bits in length. Solidity strings can handle such cases because they are stored as dynamic byte arrays.";

    string test31ByteString = "This is a 31 byte string";
    string test32ByteString = "This is a 32 byte stringaaaaaaaaaaaaaa";

    function setUp() public {
        // vm.startPrank(owner); // Uncomment if needed
        owner = vm.addr(1); // Alternative to makeAddr
        addr1 = vm.addr(2); // Alternative to makeAddr

        components = new Components();
    }

    function testGetShortString() public {
        string memory shortResult = components.getShortString();
        assertEq(shortString, shortResult);
    }

    function testGetLongString() public {
        string memory longResult = components.getLongString();
        assertEq(testlongString, longResult);
    }

    function testStoreShortString(string memory testShortString) public {
        // string memory testShortString = "Hello World";
        components.storeString(testShortString, 0x05);
        string memory shortResult = components.getString(0x05);
        assertEq(testShortString, shortResult);
    }

    function testStoreLongString(string memory testlongString) public {
        components.storeString(testlongString, 0x04);
        string memory longResult = components.getString(0x04);
        assertEq(testlongString, longResult);
    }
}
