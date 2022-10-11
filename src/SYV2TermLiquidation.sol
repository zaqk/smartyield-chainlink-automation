// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {AutomationCompatible} from "chainlink/AutomationCompatible.sol";
import {Owned} from "solmate/auth/Owned.sol";

import {ISmartYield} from "./external/ISmartYield.v2.sol";

/// @title Smart Yield  V2 Term Liquidation
contract SYV2TermLiquidation is AutomationCompatible, Owned {
  ISmartYield public smartYield;
  mapping (address => bool) whitelist;

  constructor(ISmartYield _smartYield, address _owner) Owned(_owner) {
    smartYield = _smartYield;
  }

  function checkUpkeep(bytes calldata checkData) external cannotExecute returns (
    bool upkeepNeeded,
    bytes memory performData
  ) {
    (address provider) = abi.decode(checkData, (address));
    require(whitelist[provider], "Not whitelisted");
    (,,,address activeTerm,,) = smartYield.poolByProvider(provider);
    (,uint256 end,,,,,bool liquidated) = smartYield.getTermInfo(activeTerm);
    
    return (
      block.timestamp > end && !liquidated,
      abi.encode(activeTerm)
    );
  }

  function performUpkeep(bytes calldata performData) external {
    (address activeTerm) = abi.decode(performData, (address));
    smartYield.liquidateTerm(activeTerm);
  }

  function addProvider(address _provider) external onlyOwner {
    whitelist[_provider] = true;
  }

  function removeProvider(address _provider) external onlyOwner {
    whitelist[_provider] = false;
  }

}
