// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {SmartYield} from "./mocks/SmartYield.v1.sol";
import {UserFactory} from "./lib/UserFactory.sol";

import {ISmartYield} from "src/external/ISmartYield.v1.sol";
import {SYV1TermLiquidation} from "src/SYV1TermLiquidation.sol";

contract SYV1TermLiquidationTest is Test {

  SYV1TermLiquidation automation;
  SmartYield smartYield;

  // test addresses
  address addr1;
  address addr2;
  address addr3;

  uint256 defaultEndTime;

  function setUp() public {
    vm.warp(1000 days); // to avoid under/overflow
    smartYield = new SmartYield();
    automation = new SYV1TermLiquidation(smartYield);
    
    address[] memory testAddresses = new UserFactory().create(3);
    addr1 = testAddresses[0];
    addr2 = testAddresses[1];
    addr3 = testAddresses[2];

    defaultEndTime = block.timestamp;
    smartYield.setActiveTerm(addr1);
    smartYield.setBondData(defaultEndTime, false);
  }

  function testCorrectness_checkUpkeep() public {
    // assert false is returned when term is still running
    vm.warp(defaultEndTime - 1 days);
    vm.prank(address(0), address(0));
    (bool isReady,) = automation.checkUpkeep(new bytes(0));
    assertFalse(isReady);

    // assert true is returned when term is no longer running
    vm.warp(defaultEndTime + 1 days);
    vm.prank(address(0), address(0));
    (isReady,) = automation.checkUpkeep(new bytes(0));
    assertTrue(isReady);

    // set active term to liquidated
    smartYield.setBondData(defaultEndTime, true);

    // assert false is returned when term has already been liquidated
    vm.warp(defaultEndTime + 1 days);
    vm.prank(address(0), address(0));
    (isReady,) = automation.checkUpkeep(new bytes(0));
    assertFalse(isReady);
  }

  function testCorrectness_performUpkeep() public {
    
    // expect performUpkeep to call
    bytes memory selector = abi.encodeWithSelector(
      ISmartYield.liquidateTerm.selector,
      addr1
    );
    vm.expectCall(address(automation.smartYield()), selector);
    automation.performUpkeep(new bytes(0));
  }



  


}
