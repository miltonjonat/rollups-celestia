// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IInputBox} from "@cartesi/rollups/contracts/inputs/IInputBox.sol";
import "../blobstream-contracts/src/IDAOracle.sol";
import "../blobstream-contracts/src/lib/verifier/DAVerifier.sol";


/// @title CelestiaRelay
/// @notice Relays Celestia blocks as inputs to Cartesi DApps
contract CelestiaRelay {

    IInputBox internal inputBox;
    IDAOracle internal blobstreamX;

    /// @notice Constructor
    /// @param _inputBox InputBox contract to send inputs to Cartesi DApps
    /// @param _blobstreamX BlobstreamX contract where Celestia commitments are being stored
    constructor(IInputBox _inputBox, IDAOracle _blobstreamX) {
        inputBox = _inputBox;
        blobstreamX = _blobstreamX;
    }

    /// @notice Relay a pointer to the specified Celestia shares as an input to a DApp's input box
    /// @dev Called by clients to securely process Celestia data in Cartesi DApps
    /// @param _dapp The address of the DApp
    /// @param _proof SharesProof object showing that a range of shares is committed to Celestia
    /// @param _execLayerData Additional data to be interpreted by the execution layer
    /// @return The hash of the input as returned by the Cartesi DApp's input box
    function relayShares(
        address _dapp,
        SharesProof memory _proof,
        bytes calldata _execLayerData
    ) external returns (bytes32)
    {
        // retrieve "dataRoot" from proof (commitment for Celestia block that contains the shares)
        bytes32 dataRoot = _proof.attestationProof.tuple.dataRoot;

        // verify if shares are committed to the Celestia Blobstream contract
        (bool verified, DAVerifier.ErrorCodes errorCode) =
            DAVerifier.verifySharesToDataRootTupleRoot(
                blobstreamX,
                _proof,
                dataRoot
            );
        require(verified, "Shares not committed to Celestia BlobstreamX contract");

        // relay data specification as a Cartesi DApp input
        // input payload corresponds to the ABI encoding of the following fields:
        // - namespace: Celestia identifier for the DApp (29 bytes)
        // - dataRoot: commitment for the Celestia block that contains the relayed data (32 bytes)
        // - blockHeight: height of the Celestia block that contains the relayed data (32 bytes)
        // - start: index of the initial "share" (chunk) for the relayed data within the given Celestia block (32 bytes)
        // - end: index of the final "share" (chunk) for the relayed data within the given Celestia block (32 bytes)
        // - execLayerData: arbitrary additional data to be interpreted by the DApp code
        Namespace memory namespace = _proof.namespace;
        uint256 blockHeight = _proof.attestationProof.tuple.height;
        uint256 start = _proof.shareProofs[0].beginKey;
        uint256 end = _proof.shareProofs[_proof.shareProofs.length-1].endKey;
        return inputBox.addInput(_dapp, abi.encode(namespace, dataRoot, blockHeight, start, end, _execLayerData));
    }
}
