// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {ISmartYield} from "src/external/ISmartYield.v1.sol";

contract SmartYield is ISmartYield {

  address public activeTerm;
  
  uint256 internal end;
  bool internal liquidated;

  function setActiveTerm(address _activeTerm) external {
    activeTerm = _activeTerm;
  }

  function setBondData(uint256 _end, bool _liquidated) external {
    end = _end;
    liquidated = _liquidated;
  }

  function bondData(address _term) external returns (
    uint256,
    uint256 end_,
    uint256,
    address,
    address,
    uint256,
    bool liquidated_
  ){
    require(_term == activeTerm, "Mock: only active term");
    end_ = end;
    liquidated_ = liquidated;
  }

  function liquidateTerm(address) external {}

}