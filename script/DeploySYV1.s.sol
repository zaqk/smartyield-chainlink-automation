// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Script} from 'forge-std/Script.sol';
import {SYV1TermLiquidation} from "src/SYV1TermLiquidation.sol";
import {ISmartYield} from "src/external/ISmartYield.v1.sol";

/// @notice Deploy script for SYV1TermLiquidation
contract DeploySYV1 is Script {
    address constant smartYieldAddr = 0xa0b3d2AF5a37CDcEdA1af38b58897eCB30Feaa1A;

    address constant smartYieldAddrGoerli = 0x03481E31064f0Babd6bF3E7FD5F3E320F31141d4;

  /// @notice The main script entrypoint
  function run() external returns (SYV1TermLiquidation) {
    vm.broadcast();
    return new SYV1TermLiquidation(ISmartYield(smartYieldAddr));
  }

  /// @notice The goerli testnet script entrypoint
  function runGoerli() external returns (SYV1TermLiquidation) {
    vm.broadcast();
    return new SYV1TermLiquidation(ISmartYield(smartYieldAddrGoerli));
  }
}