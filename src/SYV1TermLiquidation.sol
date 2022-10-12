// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {AutomationCompatible} from "chainlink/AutomationCompatible.sol";
import {Owned} from "solmate/auth/Owned.sol";

import {ISmartYield} from "./external/ISmartYield.v1.sol";

/// @title Smart Yield V1 Term Liquidation
contract SYV1TermLiquidation is AutomationCompatible, Owned {

  address[] public instances;

  constructor(address _owner) Owned(_owner) { }

  function checkUpkeep(bytes calldata) external cannotExecute returns (
    bool upkeepNeeded,
    bytes memory performData
  ) {
    uint256[] memory indexesToUpKeep;

    // iterate through each smart yield instance and check if they can
    // be liquidated. If they can be liquidated add them to array.
    uint256 totalInstances = instances.length;
    for (uint256 i; i < totalInstances; i++) {
      
      // load smart yield data
      ISmartYield smartYield = ISmartYield(instances[i]);
      address term = smartYield.activeTerm();
      (,uint256 end,,,,,bool liquidated) = smartYield.bondData(term);
      
      // check if smart yield instance can be liquidated, add to array
      if (block.timestamp > end && !liquidated) {
        indexesToUpKeep[indexesToUpKeep.length - 1] = i;
      }
    }

    return (
      indexesToUpKeep.length > 0,
      abi.encode(indexesToUpKeep)
    );
  }

  function performUpkeep(bytes calldata performData) external {
    (uint256[] memory indexesToUpKeep) = abi.decode(performData, (uint256[]));
    
    // iterate through instances that need upkeep and liquidate them
    uint256 totalUpKeeps = indexesToUpKeep.length;
    for (uint256 i; i < totalUpKeeps; i++) {
      ISmartYield smartYield = ISmartYield(instances[indexesToUpKeep[i]]);
      smartYield.liquidateTerm(smartYield.activeTerm());
    }
  }

  function addInstance(address _smartYield) external onlyOwner {
    instances.push(_smartYield);
  }
  
  function removeInstance(address _smartYield) external onlyOwner {
    uint256 totalInstances = instances.length;
    for (uint256 i; i < totalInstances; i++) {
      if (instances[i] == _smartYield) {
        
        // delete the smart yield instance from the list
        instances[i] = instances[totalInstances - 1];
        instances.pop();

      }
    }
  }
}
