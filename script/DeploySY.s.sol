 // SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {IQuoterV2} from "uniswap-v3-periphery/contracts/interfaces/IQuoterV2.sol";

import {ISmartYield} from "src/external/ISmartYield.sol";
import {IVeloRouter} from "src/external/IVeloRouter.sol";

import {SYTermLiquidation} from "src/SYTermLiquidation.sol";

/// @notice Deploy script for SYTermLiquidation
contract DeploySY is Script {


  /// @notice mainnet deployment
  function run() external returns (SYTermLiquidation){
    vm.broadcast();
    return new SYTermLiquidation(
      ISmartYield(address(0)),
      IQuoterV2(0x61fFE014bA17989E743c5F6cB21bF9697530B21e),
      IVeloRouter(address(0)),
      address(0),
      address(0)
    );
  }

  /// @notice arbitrum deployment
  function runArbitrum() external returns (SYTermLiquidation){
    vm.broadcast();
    return new SYTermLiquidation(
      ISmartYield(address(0)),
      IQuoterV2(0x61fFE014bA17989E743c5F6cB21bF9697530B21e),
      IVeloRouter(address(0)),
      address(0),
      address(0)
    );
  }

  /// @notice optimism deployment
  function runOptimism() external returns (SYTermLiquidation){
    vm.broadcast();
    return new SYTermLiquidation(
      ISmartYield(address(0)),
      IQuoterV2(0x61fFE014bA17989E743c5F6cB21bF9697530B21e),
      IVeloRouter(0x9c12939390052919aF3155f41Bf4160Fd3666A6f),
      address(0),
      address(0)
    );
  }
}