// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Import BaseAssignment.sol
import "../BaseAssignment.sol";

// Create contract > define Contract Name
contract StateChannel_template is BaseAssignment {
   
    // Define state variables as needed.

    // Make sure to set the validator address in the BaseAssignment constructor
    constructor(address _validator) BaseAssignment(_validator) {}

    // Implement all missing methods.

    // Important!
    // Before verifying a signature with ecrecover, you need to prefix it with
    // "\x19Ethereum Signed Message:\n32", because this is automatically added
    // upon signing outside of solidity to prevent malicious transactions.

    

    // Signature methods.
    /////////////////////

    // Recover the address of the signer, from signature and message.
    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);


        // TODO: return the address of signer using ecrecover.
    }

    // Prepares the data for ecrecover.
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    /*=====  End of HELPER  ======*/
}
