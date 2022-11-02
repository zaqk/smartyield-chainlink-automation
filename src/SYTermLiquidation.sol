// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {AutomationCompatible} from "chainlink/AutomationCompatible.sol";
import {Owned} from "solmate/auth/Owned.sol";

import {ISmartYield} from "./external/ISmartYield.sol";

/// @title Smart Yield V2 Term Liquidation
contract SYTermLiquidation is AutomationCompatible, Owned {
  ISmartYield public smartYield;
  address[] providers;

  constructor(ISmartYield _smartYield, address _owner) Owned(_owner) {
    smartYield = _smartYield;
  }

  function checkUpkeep(bytes calldata) external cannotExecute returns (
    bool upkeepNeeded,
    bytes memory performData
  ) {
    address[] memory termsToLiquidate;

    /// iterate through providers and check for terms that can be liquidated
    uint256 totalProviders = providers.length;
    for (uint256 i; i < totalProviders; i++) {
      address provider = providers[i];
      (,,,address activeTerm,,) = smartYield.poolByProvider(provider);
      (,uint256 end,,,,,bool liquidated) = smartYield.getTermInfo(activeTerm);

      /// add term to perfromData if it can be liquidated
      if (block.timestamp > end && !liquidated) {
        termsToLiquidate[termsToLiquidate.length - 1] = activeTerm;
      }
    }

    return (
      termsToLiquidate.length > 0,
      abi.encode(termsToLiquidate)
    );
  }

  function performUpkeep(bytes calldata performData) external {
    address[] memory termsToLiquidate = abi.decode(performData, (address[]));

    /// iterate through each term in performData and liquidate
    uint256 totalTermsToLiquidate = termsToLiquidate.length;
    for (uint256 i; i < totalTermsToLiquidate; i++) {
      address term = termsToLiquidate[i];
      smartYield.liquidateTerm(term);
    }
  }

  function addProvider(address _provider) external onlyOwner {
    providers.push(_provider);
  }

  function removeProvider(address _provider) external onlyOwner {
    uint256 totalProviders = providers.length;
    for (uint256 i; i < totalProviders; i++) {

      if (providers[i] == _provider) {

        /// replace provider with provider at end of list to delete
        address lastProvider = providers[totalProviders - 1];
        providers[i] = lastProvider;
        providers.pop();
      }
    }
  }

  function setSmartYield(ISmartYield _smartYield) external onlyOwner {
    smartYield = _smartYield;
  }
}
