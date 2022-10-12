// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {ISmartYield} from "src/external/ISmartYield.v1.sol";
import {SYV1TermLiquidation} from "src/SYV1TermLiquidation.sol";

import {UserFactory} from "./lib/UserFactory.sol";

contract SYV1TermLiquidationTest is Test {

  address constant smartYieldAddr = 0xa0b3d2AF5a37CDcEdA1af38b58897eCB30Feaa1A;

  SYV1TermLiquidation automation;
  ISmartYield smartYield;

  // test addresses
  address addr;

  uint256 startTime;
  uint256 endTime;

  address nextTerm;

  function setUp() public {
    smartYield = ISmartYield(smartYieldAddr);
    automation = new SYV1TermLiquidation(smartYield);
    
    address[] memory testAddresses = new UserFactory().create(1);
    addr = testAddresses[0];

    // load current term data
    (startTime,endTime,,nextTerm,,,) = smartYield.bondData(
      smartYield.activeTerm()
    );
  }

  function testCorrectness_checkUpkeep() public {
    // assert false is returned when term is still running
    vm.prank(address(0), address(0));
    (bool isReady,) = automation.checkUpkeep(new bytes(0));
    assertFalse(isReady);

    // assert true is returned when term is no longer running
    vm.warp(endTime + 1 days);
    vm.prank(address(0), address(0));
    (isReady,) = automation.checkUpkeep(new bytes(0));
    assertTrue(isReady);

    // liquidate active term
    smartYield.liquidateTerm(smartYield.activeTerm());

    // assert false is returned when term has already been liquidated
    vm.prank(address(0), address(0));
    (isReady,) = automation.checkUpkeep(new bytes(0));
    assertFalse(isReady);
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
