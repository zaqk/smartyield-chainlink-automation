// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {IVeloProvider} from "src/external/IVeloProvider.sol";
import {IVeloRouter} from "src/external/IVeloRouter.sol";

contract VeloProviderMock is IVeloProvider {

  address[] internal _rewards;
  IVeloRouter.Route[] internal rewardToUnderlyingRoute;

  function setReward(address _reward) external {
    _rewards.push(_reward);
  }

  function addRewardRoute(IVeloRouter.Route memory route) external {
    rewardToUnderlyingRoute.push(route);
  }

  function getRewardToUnderlyingRoute() external view returns (IVeloRouter.Route[] memory) {
    return rewardToUnderlyingRoute;
  }

  function rewards(uint256 index) external view returns (address) {
    return _rewards[index];
  }

}