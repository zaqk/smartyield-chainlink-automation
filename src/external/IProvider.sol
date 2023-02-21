// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

interface IProvider {
  struct Reward {
      address token;
      bytes toNativePath;
      uint256 swapThreshold;
  }
  function getRewardList() external returns (Reward[] memory);
}