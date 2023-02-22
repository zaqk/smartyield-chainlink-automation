// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {TestUtils} from "test/util/TestUtils.sol";

import {ISmartYieldAave} from "src/external/ISmartYieldAave.sol";
import {SYAaveTermLiquidation} from "src/SYAaveTermLiquidation.sol";

contract SYAaveTermLiquidationTest is Test {

  SYAaveTermLiquidation automation;
  ISmartYieldAave smartYield;

  uint256 startTime;
  uint256 endTime;

  address nextTerm;

  function setUp() public {
    smartYield = ISmartYieldAave(TestUtils.getSmartYieldAaveAddr());
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
