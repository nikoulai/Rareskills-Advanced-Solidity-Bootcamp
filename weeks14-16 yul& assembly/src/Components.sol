// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";

contract Components {
    uint256 shortStringSlot;
    string shortString = "this is short";
    // string shortString = "x";
    string longString =
        "This is a long string that exceeds 256 bits in length. Solidity strings can handle such cases because they are stored as dynamic byte arrays.";
    string storeStringVar;
    // function parse(uint256[] calldata) public pure returns (uint256, uint256) {
    //     assembly {
    //         function decode32Bytes(argPos) -> value {
    //             let pos := add(0x04, mul(argPos, 0x20)) // add 4bytes of funcsig
    //             if lt(calldatasize(), add(pos, 0x20)) {
    //                 // no 32bytes in pos
    //                 revert(0, 0x1212121212121212121212121212121212121212121212121212121212121212)
    //             }
    //             value := calldataload(pos)
    //         }

    //         function decodeAddress(argPos) -> value {
    //             let pos := add(0x04, mul(argPos, 0x20)) // add 4bytes of funcsig
    //             if lt(calldatasize(), add(pos, 0x20)) {
    //                 // no 32bytes in pos
    //                 revert(0, 0x3123214121312321312312312312312312312312312312312312312312312312)
    //             }
    //             value := calldataload(pos)
    //         }

    //         function decodeUintDynamicArray(argPos) -> len, pos {
    //             //arrPos is the start of the array, first has len of the array
    //             let arrPos := decode32Bytes(argPos)
    //             len := decode32Bytes(arrPos)
    //             pos := add(arrPos, 0x20)
    //         }

    //         function returnTrue() {
    //             returnUint(1)
    //         }

    //         function returnUint(value) {
    //             mstore(0, value)
    //             return(0, 0x20) // terminates execution, does not return to calling func
    //         }

    //         // let x, y := decodeUintDynamicArray(0)

    //         // mstore(0x00, x)
    //         // mstore(0x20, y)
    //         // return(0x00, 0x40)
    //     }
    // }

    function getLongString() public view returns (string memory) {
        uint256 index;
        assembly {
            index := longString.slot
        }
        return getString(index);
    }

    function getShortString() public view returns (string memory) {
        uint256 index;
        assembly {
            index := shortString.slot
        }
        return getString(index);
    }

    function getString(uint256 index) public view returns (string memory) {
        uint256 length;
        console.log("index", index);
        assembly {
            // let pos := add(0x04, mul(index, 0x20))
            let pos := index

            let value := sload(pos)

            //long string case
            if eq(and(value, 0x1), 0x01) {
                // let val := shr(mul(sub(0x20, length), 0x08), value)
                length := shr(1, value)
                //we dont care, we will overwrite it
                mstore(0x00, pos)
                pos := keccak256(0x00, 0x20)
                let memPos := 0x40
                mstore(0x00, 0x20)
                mstore(0x20, length)
                for { let i := 0 } lt(i, add(div(length, 0x20), 1)) { i := add(i, 1) } {
                    let val := sload(pos)
                    mstore(memPos, val)
                    memPos := add(memPos, 0x20)
                    pos := add(pos, 0x01)
                }

                return(0, add(length, 0x80))
            }

            //short string case
            let val := shr(mul(sub(0x20, length), 0x08), value)

            length := shr(1, and(value, 0xFF))
            mstore(0, 0x20) // store offset
            mstore(0x20, length)
            mstore(0x40, value)
            return(0, 0x60)
        }
        console.log(length);
    }

    function storeStringSolidity(string memory ssst) public {
        storeStringVar = ssst;
    }

    function storeString(string memory str, uint256 slot) public {
        uint256 length;
        uint256 val;
        uint256 pos;
        assembly {
            // pos := add(str, 0x20)
            pos := str
            length := and(mload(pos), 0xFF)
            let memPos := add(str, 0x20)
            //long string case
            if gt(length, 0x1F) {
                sstore(slot, add(shl(1, length), 0x01))

                mstore(0x00, slot)
                pos := keccak256(0x00, 0x20)

                for { let i := 0 } lt(i, add(div(length, 0x20), 0x01)) { i := add(i, 1) } {
                    val := mload(memPos)
                    sstore(pos, val)
                    memPos := add(memPos, 0x20)
                    pos := add(pos, 0x01)
                }
                return(0x00, 0x00)
            }

            let doubleLength := shl(1, length)

            let value := mload(add(pos, 0x20))

            let storeValue := or(value, doubleLength)

            sstore(slot, storeValue)
            return(0x00, 0x00)
        }

        console.log(length);
    }
}
