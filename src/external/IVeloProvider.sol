// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {IVeloRouter} from "./IVeloRouter.sol";

interface IVeloProvider {
  function getRewardToUnderlyingRoute() external returns (IVeloRouter.Route[] memory);
  function rewards(uint256 index) external returns (address);
}