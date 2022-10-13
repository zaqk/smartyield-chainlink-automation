// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Script} from 'forge-std/Script.sol';
import {SYAV2TermLiquidation} from "src/SYAV2TermLiquidation.sol";
import {ISmartYield} from "src/external/ISmartYield.av2.sol";

/// @notice Deploy script for SYV1TermLiquidation
contract DeploySYAV2 is Script {
    address constant smartYieldAddr = 0xa0b3d2AF5a37CDcEdA1af38b58897eCB30Feaa1A;

    address constant smartYieldAddrGoerli = 0x03481E31064f0Babd6bF3E7FD5F3E320F31141d4;

  /// @notice The main script entrypoint
  function run() external returns (SYAV2TermLiquidation) {
    vm.broadcast();
    return new SYAV2TermLiquidation(ISmartYield(smartYieldAddr));
  }

  /// @notice The goerli testnet script entrypoint
  function runGoerli() external returns (SYAV2TermLiquidation) {
    vm.broadcast();
    return new SYAV2TermLiquidation(ISmartYield(smartYieldAddrGoerli));
  }
}