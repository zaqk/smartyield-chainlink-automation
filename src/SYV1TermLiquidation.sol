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

  function checkUpkeep(bytes calldata) external cannotExecute returns (
    bool upkeepNeeded,
    bytes memory performData
  ) {
    address activeTerm = smartYield.activeTerm();
    (,uint256 end,,,,,bool liquidated) = smartYield.bondData(activeTerm);

    return (
      block.timestamp > end && !liquidated,
      new bytes(0) // no performData needed
    );
  }

  function performUpkeep(bytes calldata) external {
    address activeTerm = smartYield.activeTerm();
    smartYield.liquidateTerm(activeTerm);
  }

}
