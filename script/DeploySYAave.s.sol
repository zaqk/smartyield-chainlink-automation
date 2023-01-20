// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Script} from 'forge-std/Script.sol';
import {SYAaveTermLiquidation} from "src/SYAaveTermLiquidation.sol";
import {ISmartYieldAave} from "src/external/ISmartYieldAave.sol";

/// @notice Deploy script for SYAaveTermLiquidation
contract DeploySYAave is Script {
    address constant smartYieldAddrMainnet = 0x8A897a3b2dd6756fF7c17E5cc560367a127CA11F;
    address constant smartYieldAddrArbitrum = 0x1ADDAbB3fAc49fC458f2D7cC24f53e53b290d09e;
    address constant smartYieldAddrGoerli = 0x03481E31064f0Babd6bF3E7FD5F3E320F31141d4;

  /// @notice The main script entrypoint
  function run() external returns (SYAaveTermLiquidation) {
    vm.broadcast();
    return new SYAaveTermLiquidation(ISmartYieldAave(smartYieldAddrMainnet));
  }
  
  /// @notice The goerli testnet script entrypoint
  function runArbitrum() external returns (SYAaveTermLiquidation) {
    vm.broadcast();
    return new SYAaveTermLiquidation(ISmartYieldAave(smartYieldAddrArbitrum));
  }

  /// @notice The goerli testnet script entrypoint
  function runGoerli() external returns (SYAaveTermLiquidation) {
    vm.broadcast();
    return new SYAaveTermLiquidation(ISmartYieldAave(smartYieldAddrGoerli));
  }
}