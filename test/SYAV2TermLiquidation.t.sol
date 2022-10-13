// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {ISmartYield} from "src/external/ISmartYield.av2.sol";
import {SYAV2TermLiquidation} from "src/SYAV2TermLiquidation.sol";

import {UserFactory} from "./lib/UserFactory.sol";

contract SYV1TermLiquidationTest is Test {

  address constant smartYieldAddr = 0xa0b3d2AF5a37CDcEdA1af38b58897eCB30Feaa1A;

  SYAV2TermLiquidation automation;
  ISmartYield smartYield;

  // test addresses
  address addr;

  uint256 startTime;
  uint256 endTime;

  address nextTerm;

  function setUp() public {
    smartYield = ISmartYield(smartYieldAddr);
    automation = new SYAV2TermLiquidation(smartYield);
    
    address[] memory testAddresses = new UserFactory().create(1);
    addr = testAddresses[0];

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
      ISmartYield.liquidateTerm.selector,
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
