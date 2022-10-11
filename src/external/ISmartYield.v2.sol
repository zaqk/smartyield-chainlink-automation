// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;

interface ISmartYield {
  function poolByProvider(address _provider) external returns (
    address underlying,
    uint256 liquidityProviderBalance,
    uint256 withdrawWindow,
    address activeTerm,
    uint256 healthFactorGuard,
    uint256 nextDebtId
  );
  function getTermInfo(address _bond) external view returns (
    uint256 start,
    uint256 end,
    uint256 feeRate,
    address nextTerm,
    address bond,
    uint256 realizedYield,
    bool liquidated
  );
  function liquidateTerm(address _term) external;
}