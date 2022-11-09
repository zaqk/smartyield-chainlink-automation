 // SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {SYTermLiquidation} from "src/SYTermLiquidation.sol";
import {ISmartYield} from "src/external/ISmartYield.sol";

/// @notice Deploy script for SYV1TermLiquidation
contract DeploySY is Script {

  /// @notice The main script entrypoint
  function run() external {
    vm.broadcast();
    new SYTermLiquidation(ISmartYield(address(0)), tx.origin);
  }
}