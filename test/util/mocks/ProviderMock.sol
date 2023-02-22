// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {IProvider} from "src/external/IProvider.sol";

contract ProviderMock is IProvider {

  Reward[] rewardList;

  function addReward(address _reward, bytes calldata _path) external {
    rewardList.push(Reward({
      token: address(_reward),
      toNativePath: _path,
      swapThreshold: 0 // not needed
    }));
  }

  function getRewardList() external view returns (Reward[] memory) {
    return rewardList;
  }

}