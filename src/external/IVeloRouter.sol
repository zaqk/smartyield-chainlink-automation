// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

interface VeloRouter {
  struct Route {
      address tokenIn;
      address tokenOut;
      uint24 fee;
  }
  
  function getAmountsOut(
    uint256 amountIn,
    Route[] memory routes
  ) external view returns (uint256[] memory amounts);

}