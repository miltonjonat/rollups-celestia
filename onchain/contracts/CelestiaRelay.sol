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

    /// @notice Relay the specified Celestia shares as an input to a DApp's input box
    /// @dev Called by clients to securely relay Celestia data to Cartesi DApps
    /// @param _dapp The address of the DApp
    /// @param _proof SharesProof object showing that a range of shares is committed to Celestia
    /// @param _root The Celestia "data root" for the block that contains the shares.
    /// @return The hash of the input as returned by the Cartesi DApp's input box
    function relayShares(
        address _dapp,
        SharesProof memory _proof,
        bytes32 _root
    ) external returns (bytes32)
    {
        // verify if shares are committed to the Celestia Blobstream contract
        (bool verified, DAVerifier.ErrorCodes errorCode) =
            DAVerifier.verifySharesToDataRootTupleRoot(
                blobstreamX,
                _proof,
                _root
            );
        require(verified, "Shares not committed to Celestia BlobstreamX contract");

        // relay data as a Cartesi DApp input
        Namespace memory namespace = _proof.namespace;
        bytes32 dataRoot = _proof.attestationProof.tuple.dataRoot;
        uint256 blockHeight = _proof.attestationProof.tuple.height;
        uint256 index = _proof.shareProofs[0].beginKey;
        return inputBox.addInput(_dapp, abi.encode(namespace, dataRoot, blockHeight, index));
    }
}
