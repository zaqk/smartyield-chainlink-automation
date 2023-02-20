pragma 
interface IProvider {
  struct Reward {
      address token;
      bytes toNativePath;
      uint256 swapThreshold;
  }
  function getRewardList() external returns (Reward[] memory);
}