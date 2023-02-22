// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

interface ISmartYield {
  function poolByProvider(address _provider) external view returns (
    address underlying,
    uint256 liquidityProviderBalance,
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
    uint256 depositCap,
    bool liquidated
  );
  function liquidateTerm(address _term, uint256[] calldata amountOutMins) external;
  function preHarvest(address _provider) external;
}