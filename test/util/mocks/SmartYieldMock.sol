// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ISmartYield} from "src/external/ISmartYield.sol";

contract SmartYieldMock is ISmartYield {

  struct Pool {
    address underlying;
    uint256 liquidityProviderBalance;
    address activeTerm;
    uint256 healthFactorGuard;
    uint256 nextDebtId;
  }
  mapping(address => Pool) public pools;

  struct Term {
    uint256 start;
    uint256 end;
    uint256 feeRate;
    address nextTerm;
    address bond;
    uint256 realizedYield;
    uint256 depositCap;
    bool liquidated;
  }
  mapping(address => Term) public terms;

  function setPool(
    address _provider,
    address _underlying,
    uint256 _liquidityProviderBalance,
    address _activeTerm,
    uint256 _healthFactorGuard,
    uint256 _nextDebtId
  ) external {
    pools[_provider] = Pool(
      _underlying,
      _liquidityProviderBalance,
      _activeTerm,
      _healthFactorGuard,
      _nextDebtId
    );
  }

  function setTermInfo(
    address _bond,
    uint256 _start,
    uint256 _end,
    uint256 _feeRate,
    address _nextTerm,
    uint256 _realizedYield,
    uint256 _depositCap,
    bool _liquidated
  ) external {
    terms[_bond] = Term(
      _start,
      _end,
      _feeRate,
      _nextTerm,
      _bond,
      _realizedYield,
      _depositCap,
      _liquidated
    );
  }


  function poolByProvider(address _provider) external view returns (
    address underlying_,
    uint256 liquidityProviderBalance_,
    address activeTerm_,
    uint256 healthFactorGuard_,
    uint256 nextDebtId_
  ) {
    Pool memory pool = pools[_provider];
    return (
      pool.underlying,
      pool.liquidityProviderBalance,
      pool.activeTerm,
      pool.healthFactorGuard,
      pool.nextDebtId
    );
  }
  
  function getTermInfo(address _bond) external view returns (
    uint256 start,
    uint256 end,
    uint256 feeRate,
    address nextTerm,
    address bond,
    uint256 realizedYield,
    uint256 depositCap,
    bool liquidated
  ) {
    Term memory term = terms[_bond];
    return (
      term.start,
      term.end,
      term.feeRate,
      term.nextTerm,
      term.bond,
      term.realizedYield,
      term.depositCap,
      term.liquidated
    );
  }

  function liquidateTerm(address _term, uint256[] calldata) external {
    terms[_term].liquidated = true;
  }

  function preHarvest(address _provider) external {
    // do nothing
    // reward tokens need to be distributed before hand
  }

}