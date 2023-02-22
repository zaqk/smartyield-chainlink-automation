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

  ISmartYield smartYield = ISmartYield(address(0));
  IQuoterV2 quoter = IQuoterV2(address(0));
  IVeloRouter veloRouter = IVeloRouter(address(0));
  address keeperRegistry = address(0);
  address owner = address(0);


  /// @notice The main script entrypoint
  function run() external returns (SYTermLiquidation){
    vm.broadcast();
    return new SYTermLiquidation(
      smartYield,
      quoter,
      veloRouter,
      keeperRegistry,
      owner
    );
  }
}