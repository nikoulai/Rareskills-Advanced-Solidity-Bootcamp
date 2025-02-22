// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Exercise4.sol";
import "../lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract Exercise4Test is Test {
    using ECDSA for bytes32;

    Week22Exercise4 public exercise4;

    function setUp() public {
        // Deploy contracts
        exercise4 = new Week22Exercise4();
    }

    function testCustomSignature() public {
        // // https://optimistic.etherscan.io/tx/0x08e18539b6a2b45c74aa3eb4bc769a173baf87b3373437123c9498d72f02c2e2
        // bytes memory data =
        //     hex"0498979800000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000e61747461636b206174206461776e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041e5d0b13209c030a26b72ddb84866ae7b32f806d64f28136cb5516ab6ca15d3c438d9e7c79efa063198fda1a5b48e878a954d79372ed71922003f847029bf2e751b00000000000000000000000000000000000000000000000000000000000000";

        // address(exercise4).call(data);

        // cast decode-transaction 0x02f8758189248506fc23ac00853fdfea8026825208940000000ccc7439f4972897ccd70994123e0921bc880de0b6b3a764000080c001a09ef4899e556330b0c4e764d90b7a4c864ef03ba9725aa694ac67783bcf004aa0a00c01b87088c349649c938589f7b9f633f28ada510ee3e57d2d559fb8fc9da10e
        // {
        //   "type": "0x2",
        //   "chainId": "0x89",
        //   "nonce": "0x24",
        //   "gas": "0x5208",
        //   "maxFeePerGas": "0x3fdfea8026",
        //   "maxPriorityFeePerGas": "0x6fc23ac00",
        //   "to": "0x0000000ccc7439f4972897ccd70994123e0921bc",
        //   "value": "0xde0b6b3a7640000",
        //   "accessList": [],
        //   "input": "0x",
        //   "r": "0x9ef4899e556330b0c4e764d90b7a4c864ef03ba9725aa694ac67783bcf004aa0",
        //   "s": "0xc01b87088c349649c938589f7b9f633f28ada510ee3e57d2d559fb8fc9da10e",
        //   "yParity": "0x1",
        //   "v": "0x1",
        //   "hash": "0x09281ab72c20092dc9b414745ef2673116e36dfe069b61d2e37ecb8815b140bf"
        // }
        // bytes32 hash = 0x09281ab72c20092dc9b414745ef2673116e36dfe069b61d2e37ecb8815b140bf;
        // bytes32 hash = 0x0fcd833c3e7cd5e31ef14edd0b7b82f85c92cbd45b5e24e75ec6f286caa2c1aa;

        //which data are rlp encoded for the transaction?
        bytes32 hash = 0xa0eea3cd5ae052d3ffe50ec82baa3e4f0deb99c6537d1de6ae43d51cd1fbb0f8;
        uint8 v = 28;
        bytes32 r = 0x9ef4899e556330b0c4e764d90b7a4c864ef03ba9725aa694ac67783bcf004aa0;
        bytes32 s = 0x0c01b87088c349649c938589f7b9f633f28ada510ee3e57d2d559fb8fc9da10e;
        address recovered = ecrecover(hash, v, r, s);
        // console.log("recovered", recovered);
        assertEq(recovered, exercise4.signer());
        recovered = hash.recover(
            hex"9ef4899e556330b0c4e764d90b7a4c864ef03ba9725aa694ac67783bcf004aa00c01b87088c349649c938589f7b9f633f28ada510ee3e57d2d559fb8fc9da10e1c"
        );
        //  "publicKey": "0x0429a272134c84cd93c1520a85007c2a0e38e80d0f312266b88089c17b61c48101b0257964abfb5640adc754419df69b142f773cb3687fe6a1601b3f07c71904b2"
        // bytes memory malformedSignature =
        // hex"29a272134c84cd93c1520a85007c2a0e38e80d0f312266b88089c17b61c4810129a272134c84cd93c1520a85007c2a0e38e80d0f312266b88089c17b61c481010000";

        // bytes32 sr = hex"29a272134c84cd93c1520a85007c2a0e38e80d0f312266b88089c17b61c48101";
        // recovered = ecrecover(hex"", 27, sr, sr);
        // console.log("recovered", recovered);
        assertEq(recovered, exercise4.signer());
        // exercise4.claimAirdrop(0, hex"", malformedSignature);
    }
}

//I modified ethersjs to add a compute signature function
//usage
// console.log("--------Starting computing signature------------");
// const res = ethers.computeSignature("0x", {r,s,v}, recPubKey.split('0x')[1]);
// console.log("Computed Q ", res.pubKey);
// console.log(res.signature)
// // console.log("Address from computeSignature: ", ethers.computeAddress(('0x'+res.pubKey)))
// // console.log("The malformed signature: ", res.signature);
// const res2 = ethers.recoverAddress("0x", '0x' + res.signature + '00' );
// console.log(res2)

// function computeSignature(digest, signature, hexPubKey) {
//     return SigningKey.computeSignature(digest, signature, hexPubKey);
// }

//    static computeSignature(digest, signature, hexPubKey) {
//         // assertArgument(dataLength(digest) === 32, "invalid digest length", "digest", digest);
//         const sig = Signature.from(signature);
//         let secpSig = secp256k1.Signature.fromCompact(getBytesCopy(concat([sig.r, sig.s])));
//         secpSig = secpSig.addRecoveryBit(sig.yParity);
//         const hashAndSignature = secpSig.computeSignature(getBytesCopy(digest),hexPubKey);
//         // assertArgument(pubKey != null, "invalid signautre for digest", "signature", signature);
//         // return "0x" + hashAndSignature.toHex(false);
//         return {pubKey: hashAndSignature.Q.toHex(false), ...hashAndSignature};//, r: hashAndSignature.r.hexify, v: hashAndSignature.v.toHex(false)};
//     }
//         computeSignature(msgHash, hexPubKey) {
//             // (sr^-1)R-(hr^-1)G = -(hr^-1)G + (sr^-1) ----> h=0 ----> Q = (sr^-1)R ----> s = (Q/R) * r
//             //if h is 0, then Q = (sr^-1)R //that's what we see above
//             // if s = r^-1 then Q = R, so we want R = S and s = r^-1
//             console.log('The hexPubKey: ', hexPubKey)
//             //setup Q
//             const pubKeyPoint = Point.fromHex(hexPubKey);
//             // let { r, s, recovery: rec } = this; // not useful actually, just keeping it to have valid values
//             const h = bits2int_modN(ensureBytes('msgHash', msgHash)); // Truncate hash
//             // const h = BigInt(0) // initialize 0
//             console.log("The number of h ", h);
//             //we can skip these checks
//             // if (rec == null || ![0, 1, 2, 3].includes(rec))
//             //     throw new Error('recovery id invalid');
//             let rec = this.recovery;
//             this.r = pubKeyPoint.px;
//             const radj = rec === 2 || rec === 3 ? this.r + CURVE.n : this.r;
//             console.log("The number of radj ", radj);
//             if (radj >= Fp.ORDER)
//                 throw new Error('recovery id 2 or 3 invalid');
//             const prefix = (rec & 1) === 0 ? '02' : '03';
//             // const prefix = "";
//             const R = Point.fromHex(prefix + numToNByteStr(radj));
//             // const R = pubKeyPoint; //the result we want
//             console.log("The point R: ", R.toHex());
//             //keep the computations as they are
//             const ir = invN(radj); // r^-1

//             this.s = radj; // s = (r^-1)^-1 --> s = r
//             const u1 = modN(-h * ir); // -hr^-1
//             console.log("u1: ", u1)
//             const u2 = modN(this.s * ir); // sr^-1
//             console.log("u2: ", u2)
//             const Q = Point.BASE.multiplyAndAddUnsafe(R, u1, u2); // (sr^-1)R-(hr^-1)G = -(hr^-1)G + (sr^-1)
//             console.log(this)
//             if (!Q)
//                 throw new Error('point at infinify'); // unsafe is fine: no priv data leaked
//             Q.assertValidity();
//             return {Q, signature: this.toCompactHex(), r: this.r, s: this.s, v: this.recovery};
//             // return ;
//         }
