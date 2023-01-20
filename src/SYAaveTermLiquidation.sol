// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Owned} from "solmate/auth/Owned.sol";
import {AutomationCompatible} from "chainlink/AutomationCompatible.sol";

import {ISmartYieldAave} from "./external/ISmartYieldAave.sol";

/// @title Smart Yield Aave V2 Originator Term Liquidation
contract SYAaveTermLiquidation is AutomationCompatible, Owned {

  ISmartYieldAave public smartYield;

  constructor(ISmartYieldAave _smartYield) Owned(msg.sender) {
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

  function updateSmartYield(ISmartYieldAave _smartYield) external onlyOwner {
    smartYield = _smartYield;
  }

}
