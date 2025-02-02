//how to inherit from yul contract?
// object "Example" {
//   code {
//     datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
//     return(0, datasize("Runtime"))
//   }
//   object "Runtime" {
//     // Return the calldata
//     code {
//       mstore(0x80, calldataload(0))
//       return(0x80, calldatasize())
//     }
//   }
// }
object "ERC1155" {
	code {
		let runtimeDataOffset := dataoffset("Runtime")
		let runtimeDataSize := datasize("Runtime")
		let constructorArgs := calldataload(0)

		datacopy(0, runtimeDataOffset, runtimeDataSize)
		return(0, runtimeDataSize)
	}

	object "Runtime" {
		code {
			// Storage slots
			function balanceSlot() -> p { p := 0 }
			function isApprovedForAllSlot() -> p { p := 1 }
			function uriSlot() -> p { p := 2 } 

			// Memory management
			function memPtrPos() -> p { p := 0x40 }
			function getMemPtr() -> p { p := mload(memPtrPos()) }
			function setMemPtr(v) { mstore(memPtrPos(), v) }
			function incMemPtr() { mstore(memPtrPos(), add(getMemPtr(), 0x20)) }
			function mstoreAndInc(v) { mstore(getMemPtr(), v) incMemPtr() }
			function scratchPoint() -> p { p := 0x00 }
			function zeroPoint() -> p { p := 0x60 }
			setMemPtr(0x80)
			let selector := shr(0xE0, calldataload(0))
 	                // let selector := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)


			switch selector
				// batchMint(address,uint256[],uint256[],bytes)
				case 0xb48ab8b6{
					let idArrayPos, idArrayLen := decodeUintDynamicArray(1)
					let amountArrayPos, amountArrayLen := decodeUintDynamicArray(2)
					// mstore(getMemPtr(),idArrayPos)
					// mstore(add(getMemPtr(),0x20),idArrayLen)
					// mstore(add(getMemPtr(),0x40),amountArrayPos)
					// mstore(add(getMemPtr(),0x60),amountArrayLen)
					// return(getMemPtr(),0x80)
					batchMint(caller(), decodeAddress(0), idArrayPos,idArrayLen,amountArrayPos, amountArrayLen, 3)
					returnTrue()

				}
				// mint(address,uint256,uint256,bytes)
				case 0x731133e9{
					mint(caller(),decodeAddress(0), decode32Bytes(1), decode32Bytes(2),4)
					returnTrue()
				}
				// safeTransferFrom(address,address,uint256,uint256,bytes)
				case 0xf242432a {
					safeTransferFrom(decodeAddress(0), decodeAddress(1), decode32Bytes(2), decode32Bytes(3), 4)
					returnTrue()
				}
				// safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)
				case 0x2eb2c2d6 {
					let idArrayPos, idArrayLen := decodeUintDynamicArray(2)
					let amountArrayPos, amountArrayLen := decodeUintDynamicArray(3)
					safeBatchTransferFrom(decodeAddress(0), decodeAddress(1), idArrayPos, idArrayLen, amountArrayPos, amountArrayLen, 4)
					returnTrue()
				}
				// balanceOf(address,uint256)
				case 0x00fdd58e {
					let bal := balanceOf(decodeAddress(0), decode32Bytes(1))
					returnUint(bal)
				}
				// balanceOfBatch(address[],uint256[])
				case 0x4e1273f4 {
					let ownerArrayPos, ownerArrayLen := decodeUintDynamicArray(0)
					let idArrayPos, idArrayLen := decodeUintDynamicArray(1)
					
					let balancesMemPtr, balancesSize := balanceOfBatch(ownerArrayPos, ownerArrayLen, idArrayPos, idArrayLen)
					return(balancesMemPtr, balancesSize)
				}
				// setApprovalForAll(address,bool)
				case 0xa22cb465 {
					setApprovalForAll(decodeAddress(0), decode32Bytes(1))
					emitApprovalForAll(caller(), decodeAddress(0), decode32Bytes(1))
					returnTrue()
				}

				// isApprovedForAll(address,address)
				case 0xe985e9c5 {
					let res := isApprovedForAll(decodeAddress(0), decodeAddress(1))
					returnUint(res)
				}
				default {
					// returnTrue()
					revert(0, 0)
				}

			function batchMint(operator, to, idArrayPos, idArrayLen, amountArrayPos, amountArrayLen, dataArgumentPos) {
				if iszero(eq(idArrayLen, amountArrayLen)) {
					revertLengthMismatch()
				}
				

				for { let i := 1 } lt(i, add(idArrayLen,0x01)) { i := add(i, 1) } {
					let id := calldataload(add(idArrayPos, mul(i, 0x20)))
					let amount := calldataload(add(amountArrayPos, mul(i, 0x20)))
					_mint(operator,to, id, amount, dataArgumentPos)

				}

			}
			function safeBatchTransferFrom(from, to, idArrayPos, idArrayLen, amountArrayPos, amountArrayLen, dataPos) {
				if iszero(eq(idArrayLen, amountArrayLen)) {
					mstore(getMemPtr(), idArrayLen)
					incMemPtr()
					mstore(getMemPtr(), amountArrayLen)
					incMemPtr()
					return(sub(getMemPtr(), 0x40), 0x40)
					revertLengthMismatch()
				}

				for { let i := 1 } lt(i, add(idArrayLen,0x01)) { i := add(i, 1) } {
					let id := calldataload(add(idArrayPos, mul(i, 0x20)))
					let amount := calldataload(add(amountArrayPos, mul(i, 0x20)))
					let balanceFrom := sload(getBalanceOfSlot(from, id))
					let balanceTo := sload(getBalanceOfSlot(to, id))

					let newBalanceFrom := safeSub(balanceFrom, amount)
					let newBalanceTo := safeAdd(balanceTo, amount)

					sstore(getBalanceOfSlot(from, id), newBalanceFrom)
					sstore(getBalanceOfSlot(to, id), newBalanceTo)
				}
				let idsMemPtr := _callOnERC1155BatchReceived(caller(), from, to, idArrayPos, idArrayLen, amountArrayPos, amountArrayLen, dataPos)
				emitTransferBatch(caller(), from, to, idsMemPtr, idArrayLen, amountArrayLen)
			}
			function balanceOfBatch(ownerArrayPos, ownerArrayLen, idArrayPos, idArrayLen) -> balancesMemPtr, balancesSize {
				balancesMemPtr := getMemPtr()
				mstore(balancesMemPtr, 0x20)
				incMemPtr()
				mstore(getMemPtr(), ownerArrayLen)
				incMemPtr()

				//start from 1 because of the length
				for { let i := 1 } lt(i, add(ownerArrayLen,0x01)) { i := add(i, 1) } {
					let owner := calldataload(add(ownerArrayPos, mul(i, 0x20)))
					let id := calldataload(add(idArrayPos, mul(i, 0x20)))
					let bal := balanceOf(owner, id)
					mstore(getMemPtr(), bal)
					incMemPtr()
				}
				balancesSize := add(sub(getMemPtr(), balancesMemPtr), 0x20)
			}
			function balanceOf(owner, id) -> bal {
				let balanceOwnerSlot := getBalanceOfSlot(owner, id)
				bal := sload(balanceOwnerSlot)
			}

			function mint(operator,to, id, amount, dataArgumentPos) {
				_mint(operator,to, id, amount, dataArgumentPos) 
				_callOnERC1155Received(operator, 0x00, to, id, amount, dataArgumentPos)
			}
			function _mint(operator,to, id, amount, dataArgumentPos) {
				// let balanceFrom := sload(getBalanceOfSlot(from, id))
				let balanceTo := sload(getBalanceOfSlot(to, id))

				// let newBalanceFrom := safeSub(balanceFrom, amount)
				let newBalanceTo := safeAdd(balanceTo, amount)

				// sstore(getBalanceOfSlot(from, id), newBalanceFrom)
				sstore(getBalanceOfSlot(to, id), newBalanceTo)

			}
			function safeTransferFrom(from, to, id, amount, dataArgumentPos) {
				let balanceFrom := sload(getBalanceOfSlot(from, id))
				let balanceTo := sload(getBalanceOfSlot(to, id))

				let newBalanceFrom := safeSub(balanceFrom, amount)
				let newBalanceTo := safeAdd(balanceTo, amount)

				sstore(getBalanceOfSlot(from, id), newBalanceFrom)
				sstore(getBalanceOfSlot(to, id), newBalanceTo)
				_callOnERC1155Received(caller(), from, to, id, amount, dataArgumentPos)
			}
			function setApprovalForAll(operator, approved) {
				let baseSlot := isApprovedForAllSlot()

				let operatorSlot := getApprovalSlot(caller(), operator)
				sstore(operatorSlot, approved)
			}

			function isApprovedForAll(owner, operator) -> res {
				let operatorSlot := getApprovalSlot(owner, operator)

				res := sload(operatorSlot)
				
			}
			//onERC1155BatchReceived( address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data)
			function _callOnERC1155BatchReceived(batchOperator, from, to, idArrayPos, idArrayLen, amountArrayPos, amountArrayLen, dataArgumentPos) -> idsMemPtr {
                                if eq(extcodesize(to), 0) { leave } // receiver is not a contract

				let onERC1155BatchReceivedSelector := 0xbc197c81 
				let zeroWei := 0x00
				let dataMemPtr := getMemPtr()

				mstoreAndInc(onERC1155BatchReceivedSelector)
				mstoreAndInc(batchOperator)
				mstoreAndInc(from)
				// mstore(add(getMemPtr(), 0x20), batchOperator)
                		// mstore(add(getMemPtr(), 0x40), from)
				//0x00 from
				//0x20 batchOperator
				//0x40 idArrayPos
				//0x60 amountArrayPos
				//0x80 dataPos
				//0xa0 idArrayLen
				let size := 0xa0  // 5 * 0x20, t is the number of arguments
				mstoreAndInc(size)
				
				//todo delete, placeholder
				mstoreAndInc(0x00)
				mstoreAndInc(0x00)

				//id calldata
                		mstore(add(dataMemPtr, 0xc0), idArrayLen)
				idArrayPos := add(idArrayPos, 0x20)
				calldatacopy(add(dataMemPtr, 0xe0), idArrayPos, mul(idArrayLen, 0x20))
				size := add(add(size, mul(idArrayLen, 0x20)), 0x20)

				//amount calldata
                		mstore(add(dataMemPtr, 0x80), size)
				mstore(add(add(dataMemPtr, size),0x20), amountArrayLen)
				amountArrayPos := add(amountArrayPos, 0x20)
				calldatacopy(add(add(dataMemPtr, size), 0x40), amountArrayPos, mul(amountArrayLen, 0x20))
				size := add(add(size, mul(amountArrayLen, 0x20)), 0x20)




                		mstore(add(dataMemPtr, 0xa0), size)
				let arrPos, len :=  decodeUintDynamicArray(dataArgumentPos)
				arrPos := add(arrPos, 0x20)
				mstore(add(add(dataMemPtr, size), 0x20), len)
				calldatacopy(add(add(dataMemPtr, size), 0x40), arrPos, len)
				size := add(size, len)

				// return(add(dataMemPtr, 0x1c), add(size, 0x40))
				//acoid computations, lazy
				setMemPtr(msize())

				let retMemPtr := getMemPtr()
				incMemPtr()

				// 0x1c is 28, skip the first 28 bytes to get the selector
				let success := call(gas(),to,zeroWei,add(dataMemPtr,0x1c),add(size,0x40),retMemPtr,0x20)

				let ret := mload(retMemPtr)

				ret := shr(0xe0, ret)

				if iszero(eq(ret, onERC1155BatchReceivedSelector)) {
					revertUnsafeRecipient()
				}

				idsMemPtr := add(dataMemPtr, 0xc0)

			}
			//onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data)

			function _callOnERC1155Received(operator, from, to, id, amount, dataArgumentPos) {
				if eq(extcodesize(to), 0) { leave } // receiver is not a contract

				let onERC1155ReceivedSelector := 0xf23a6e61
				let zeroWei := 0x00
				let dataMemPtr := getMemPtr()

				mstore(getMemPtr(), onERC1155ReceivedSelector)
				mstore(add(getMemPtr(), 0x20), operator)
                		mstore(add(getMemPtr(), 0x40), from)
                		mstore(add(getMemPtr(), 0x60), id)
                		mstore(add(getMemPtr(), 0x80), amount)
                		mstore(add(getMemPtr(), 0xa0), 0x00000000000000000000000000000000000000000000000000000000000000a0)

				let arrPos, len :=  decodeUintDynamicArray(dataArgumentPos)

                		mstore(add(getMemPtr(), 0xc0), len)

				setMemPtr(add(getMemPtr(), 0xe0))

				let size := 0xe0

				arrPos := add(arrPos, 0x20)

				calldatacopy(getMemPtr(), arrPos, len)
				size := add(size, len)

				setMemPtr(size)

				let retMemPtr := getMemPtr()
				incMemPtr()
				//todo test substracting 0x1c from size
				// 0x1c is 28, skip the first 28 bytes to get the selector
				let success := call(gas(),to,zeroWei,add(dataMemPtr,0x1c),size,retMemPtr,0x20)

				let ret := mload(retMemPtr)

				ret := shr(0xe0, ret)

				if iszero(eq(ret, onERC1155ReceivedSelector)) {
					revertUnsafeRecipient()
				}

			}

			function getBalanceOfSlot(owner, id) -> balanceOwnerSlot {

				let baseSlot := balanceSlot()
				let operatorsMappingSlot := calculateMappingSlot(owner, baseSlot)
				balanceOwnerSlot := calculateMappingSlot(id, operatorsMappingSlot)
			}
			function getApprovalSlot(owner, operator) -> approvalSlot {

				let baseSlot := isApprovedForAllSlot()
				let operatorsMappingSlot := calculateMappingSlot(owner, baseSlot)
				approvalSlot := calculateMappingSlot(operator, operatorsMappingSlot)
			}
			function calculateMappingSlot(key, slot) -> mappingSlot {
				mstore(scratchPoint(), key)
				mstore(add(scratchPoint(),0x20), slot)
				mappingSlot := keccak256(scratchPoint(), 0x40)

			}

			function getCalldataPosfromIndex(index) -> pos {
				pos := add(0x04, mul(index, 0x20))
			}
			function decode32Bytes(argPos) -> value {
				let pos := getCalldataPosfromIndex(argPos)
				if lt(calldatasize(), add(pos, 0x20)) {
					revert(0, 0)
				}
				value := calldataload(pos)
			}

			function decodeAddress(argPos) -> addr {
				addr := decode32Bytes(argPos)
				if iszero(iszero(and(addr, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
					revert(0, 0)
				}
			}

			function decodeUintDynamicArray(argPos) -> arrPos, len  {

                		arrPos := decode32Bytes(argPos)
				arrPos := add(arrPos, 0x04)
				len :=  calldataload(arrPos)
				// len := arrPos

			}

			function returnTrue() {
				returnUint(1)
			}

			function returnUint(value) {
				mstore(0, value)
				return(0, 0x20)
			}
			// function require(condition) -> res {
                	// 	if iszero(condition) {
                    	// 		// revertFunction()
			// 		res := 0
                	// 	}
			// 	res := 1
            		// }

			function safeAdd(a, b) -> r {
				r := add(a, b)
				if or(lt(r, a), lt(r, b)) { revert(0, 0) }
			}

			function safeSub(a, b) -> r {
				r := sub(a, b)
				if gt(r, a) { revert(0, 0) }
			}
			function revertUnauthorized() {
                		revertError(
                    			0x0f, // length("NOT_AUTHORIZED") = 15 bytes -> 0x0f
					0x4E4F545F415554484F52495A4544 // "NOT_AUTHORIZED"
                		)
            		}
			function revertLengthMismatch() {
                		revertError(
                    			0x0f, // length("LENGTH_MISMATCH") = 15 bytes -> 0x0f
					0x4C454E4754485F4D49534D41544348// "LENGTH_MISMATCH"
                		)
            		}

			function revertUnsafeRecipient() {
				revertError(
					0x10, // length("UNSAFE_RECIPIENT") = 15 bytes -> 0x0f
					0x554E534146455F524543495049454E54 // "UNSAFE_RECIPIENT"
				)	
			}

		        function revertError(errLength, errData) {
				mstore(0, 0x08c379a0)  // function selector for Error(string)
				mstore(0x20, 0x20)  // string offset
				mstore(0x40, errLength)  // length
				mstore(0x60, errData)  // data  
				revert(0x1c, sub(0x80, 0x1c))  // starts in the function selector bytes, which start at (28bytes) 
            		}

			function emitTransfer(owner, operator, approved) {
   		             mstore(scratchPoint(), approved)
    		            	// hash string is keccak256("ApprovalForAll(address,address,bool)")
	     	           	log3(
	                    	scratchPoint(),
	                    	0x20,
                    		0x5ec57f560ef929facf3b5dc5912110467a11f1c05cf1ed2714e5f5ea3114bf8e,
                        	owner,
                        	operator
                		)
            		}

			//we take advantage of the fact that the ids and amounts arrays are already stored in the memory
			function emitTransferBatch(operator, from, to, idsMemPtr, idsLen, amountsLen) {
				let signatureHash := 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb
				
				let idsStart := 0x40
				let amountsStart := add(mul(0x20, idsLen), 0x60)


				let totalSize := add(0x80, mul(mul(idsLen, 2), 0x20))
				idsMemPtr := sub(idsMemPtr, 0x40)

				mstore(idsMemPtr, idsStart) // ids start at 0x40
				mstore(add(idsMemPtr, 0x20), amountsStart) 

				log4(idsMemPtr, totalSize, signatureHash, operator, from, to)
			}



			function emitApprovalForAll(owner, operator, approved) {
                		mstore(scratchPoint(), approved)
                		log3(scratchPoint(), 0x20,0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31 , owner, operator)
			}
		}
	}
}

