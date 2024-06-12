// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IInputBox} from "@cartesi/rollups/contracts/inputs/IInputBox.sol";


/// @title CelestiaRelay
/// @notice Relays Celestia blocks as inputs to Cartesi DApps
contract CelestiaRelay {

    IInputBox internal inputBox;

    /// @notice Constructor
    /// @param _inputBox input box to send inputs to Cartesi DApps
    constructor(IInputBox _inputBox) {
        inputBox = _inputBox;
    }

    /// @notice Relay the specified Celestia share range as an input to a DApp's input box
    /// @dev Called by clients to securely relay Celestia data to Cartesi DApps
    /// @param _dapp The address of the DApp
    /// @return The hash of the input as returned by the Cartesi DApp's input box
    function relayShareRange(
        address _dapp
    ) external returns (bytes32)
    {
        // relay data
        return inputBox.addInput(_dapp, abi.encode(0));
    }
}
