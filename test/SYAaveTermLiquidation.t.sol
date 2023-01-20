// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {ISmartYieldAave} from "src/external/ISmartYieldAave.sol";
import {SYAaveTermLiquidation} from "src/SYAaveTermLiquidation.sol";

import {console2} from "forge-std/console2.sol";

contract SYAaveTermLiquidationTest is Test {

  function smartYieldAddr() public virtual returns (address) {
    console2.log("block.chainId", block.chainid);
    if (block.chainid == 1) return 0x8A897a3b2dd6756fF7c17E5cc560367a127CA11F;
    else if (block.chainid == 42161) return 0x1ADDAbB3fAc49fC458f2D7cC24f53e53b290d09e;
    else revert("unsupported chain");
  }

  SYAaveTermLiquidation automation;
  ISmartYieldAave smartYield;

  uint256 startTime;
  uint256 endTime;

  address nextTerm;

  function setUp() public {
    smartYield = ISmartYieldAave(smartYieldAddr());
    automation = new SYAaveTermLiquidation(smartYield);

    // load current term data
    (startTime,endTime,,nextTerm,,,) = smartYield.bondData(
      smartYield.activeTerm()
    );
  }

  function testCorrectness_checkUpkeep() public {
    // should always return true
    (bool isReady,) = automation.checkUpkeep(new bytes(0));
    assertTrue(isReady);
  }

  function testCorrectness_performUpkeep() public {
    bytes memory selector = abi.encodeWithSelector(
      ISmartYieldAave.liquidateTerm.selector,
      smartYield.activeTerm()
    );

    // expect performUpkeep to call smartYield.liquidateTerm()
    vm.warp(endTime + 1 days);
    vm.expectCall(address(automation.smartYield()), selector);
    automation.performUpkeep(new bytes(0));
  }

  function testRevert_performUpkeep() public {
    // expect revert if term is not ready to be liqudated
    vm.warp(startTime);
    vm.expectRevert("SmartYield: term hasn't ended");
    automation.performUpkeep(new bytes(0));
  }

}
