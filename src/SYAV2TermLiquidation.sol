// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {AutomationCompatible} from "chainlink/AutomationCompatible.sol";

import {ISmartYield} from "./external/ISmartYield.av2.sol";

/// @title Smart Yield Aave V2 Originator Term Liquidation
contract SYAV2TermLiquidation is AutomationCompatible {

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
