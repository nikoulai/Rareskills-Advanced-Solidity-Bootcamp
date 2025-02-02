object "ParseDynamicArrayABI" {
	code {
    		datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    		return(0, datasize("Runtime"))
  	}
	object "Runtime" {

	code {
                // mstore(0, calldatasize())
                // return(0, 0x20)  // terminates execution, does not return to calling func
	//  let selector := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
	let selector := shr(0xE0,calldataload(0))
	
            switch selector
	//     case 0xea76aeaf {
		//parse(uint256[],uint256[])
		case 0x9d2085ed {
                // mstore(0, sub(calldatasize(), 0x04))
                // return(0, 0x20)  // terminates execution, does not return to calling func
			// returnTrue()
        		function decode32Bytes(argPos) -> value {
                		let pos := add(0x04, mul(argPos, 0x20))  // add 4bytes of funcsig
                		// if lt(calldatasize(), add(pos, 0x20)) {  // no 32bytes in pos
	                	// 	revert(0, 0)
                		// }
                		value := calldataload(pos)
            		}

			function decodeAddress(argPos) -> value {
                		let pos := add(0x04, mul(argPos, 0x20))  // add 4bytes of funcsig
                		// if lt(calldatasize(), add(pos, 0x20)) {  // no 32bytes in pos
	                	// 	revert(0, 0)
                		// }
                		value := calldataload(pos)
            		}

			function decodeUintDynamicArray(argPos) -> arrPos, len, firstValue {

                		// let pos := add(0x04, mul(argPos, 0x20))  // add 4bytes of funcsig
				//arrPos is the start of the array, first has len of the array
                		arrPos := decode32Bytes(argPos)
				arrPos := add(arrPos, 0x04)
				len :=  calldataload(arrPos)

				firstValue := calldataload(add(arrPos,0x40))

			}

	   function returnTrue() {
                returnUint(1)
            }

            function returnUint(value) {
                mstore(0, value)
                return(0, 0x20)  // terminates execution, does not return to calling func
            }

	                let arrPos2,len, pos := decodeUintDynamicArray(0)

			mstore(0x00, arrPos2)
			mstore(0x20, len)
			mstore(0x40, pos)
			return(0x00, 0x60)
	}
	default {
                mstore(0, sub(calldatasize(), 0x04))
                return(0, 0x20)  // terminates execution, does not return to calling func
	}
        }
    }
}