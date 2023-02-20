// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Router as VeloRouter} from "velodrome/contracts/Router.sol";

interface IVeloProvider {
  function getRewardToUnderlyingRoute() external returns (VeloRouter.route[] memory);
}