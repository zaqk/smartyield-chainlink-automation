// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Script} from 'forge-std/Script.sol';
import {SYV1TermLiquidation} from "src/SYV1TermLiquidation.sol";
import {ISmartYield} from "src/external/ISmartYield.v1.sol";

/// @notice Deploy script for SYV1TermLiquidation
contract DeploySYV1 is Script {
    address constant smartYieldAddr = 0xa0b3d2AF5a37CDcEdA1af38b58897eCB30Feaa1A;

  /// @notice The main script entrypoint
  /// @return contract
  function run() external returns (SYV1TermLiquidation) {
    return new SYV1TermLiquidation(ISmartYield(smartYieldAddr));
  }
}