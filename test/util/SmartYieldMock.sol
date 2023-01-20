// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {ISmartYield} from "src/external/ISmartYield.sol";

contract SmartYield is ISmartYield {
  
  function poolByProvider(address _provider) external returns (
    address underlying,
    uint256 liquidityProviderBalance,
    uint256 withdrawWindow,
    address activeTerm,
    uint256 healthFactorGuard,
    uint256 nextDebtId
  ) {

  }

  function getTermInfo(address _bond) external view returns (
    uint256 start,
    uint256 end,
    uint256 feeRate,
    address nextTerm,
    address bond,
    uint256 realizedYield,
    bool liquidated
  ) {

  }

  function liquidateTerm(address _term) external {

  }
}