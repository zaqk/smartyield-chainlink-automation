interface IProvider {
  struct Reward {
      address token;
      bytes toNativePath; // Uniswap V3 routes
      uint256 swapThreshold; // minimum amount to be swapped to native
  }
  function getRewardList() external returns (Reward[] memory);
}