// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {AutomationCompatible} from "chainlink/AutomationCompatible.sol";
import {Owned} from "solmate/auth/Owned.sol";

import {ISmartYield} from "./external/ISmartYield.v1.sol";

/// @title Smart Yield V1 Term Liquidation
contract SYV1TermLiquidation is AutomationCompatible, Owned {

  mapping (address => bool) whitelist;

  constructor(address _owner) Owned(_owner) {}

  function checkUpkeep(bytes calldata checkData) external cannotExecute returns (
    bool upkeepNeeded,
    bytes memory performData
  ) {
    (address smartYieldAddr) = abi.decode(checkData, (address));
    require(whitelist[smartYieldAddr], "Not whitelisted");
    
    ISmartYield smartYield = ISmartYield(smartYieldAddr);
    address term = smartYield.activeTerm();
    (,uint256 end,,,,,bool liquidated) = smartYield.bondData(term);
    
    return (
      block.timestamp > end && !liquidated,
      abi.encode(smartYieldAddr)
    );
  }

  function performUpkeep(bytes calldata performData) external {
    (address smartYieldAddr) = abi.decode(performData, (address));
    ISmartYield smartYield = ISmartYield(smartYieldAddr);
    smartYield.liquidateTerm(smartYield.activeTerm());
  }

  function addSmartYield(address _smartYield) external onlyOwner {
    whitelist[_smartYield] = true;
  }

  function removeSmartYield(address _smartYield) external onlyOwner {
    whitelist[_smartYield] = false;
  }

}
