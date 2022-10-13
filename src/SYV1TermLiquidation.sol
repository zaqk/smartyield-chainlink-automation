// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {AutomationCompatible} from "chainlink/AutomationCompatible.sol";

import {ISmartYield} from "./external/ISmartYield.v1.sol";

/// @title Smart Yield V1 Term Liquidation
contract SYV1TermLiquidation is AutomationCompatible {

  ISmartYield public smartYield;

  constructor(ISmartYield _smartYield) {
    smartYield = _smartYield;
  }

  function checkUpkeep(bytes calldata) external pure override returns (
    bool upkeepNeeded,
    bytes memory
  ) {
    return (true, "");
  }

  function performUpkeep(bytes calldata) external {
    address activeTerm = smartYield.activeTerm();
    smartYield.liquidateTerm(activeTerm);
  }

}
