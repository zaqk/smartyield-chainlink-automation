// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

import {AutomationCompatible} from "chainlink/automation/AutomationCompatible.sol";

import {IQuoterV2} from "uniswap-v3-periphery/contracts/interfaces/IQuoterV2.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {IVeloRouter} from "./external/IVeloRouter.sol";

import {IProvider} from "./external/IProvider.sol";
import {IVeloProvider} from "./external/IVeloProvider.sol";

import {ISmartYield} from "./external/ISmartYield.sol";

error OnlyKeeperRegistry();

/// @title Smart Yield V2 Term Liquidation
/// @dev compatible w/ all chains and all providers
contract SYTermLiquidation is AutomationCompatible, Owned {
  ISmartYield public smartYield;
  ProviderInfo[] public providers;
  address public keeperRegistry;
  IQuoterV2 public immutable quoter;
  IVeloRouter public immutable veloRouter;
  uint256 public constant MAX_SLIPPAGE = 10_000;

  enum SwapType {
    NONE,
    UNISWAPV3,
    VELO
  }

  struct ProviderInfo {
    address addr;
    SwapType swapType;
    bool active;
    uint16 slippage;
  }

  modifier onlyKeeperRegistry() {
    if (msg.sender != keeperRegistry) revert OnlyKeeperRegistry();
    _;
  }

  constructor(
    ISmartYield _smartYield,
    IQuoterV2 _quoter,
    IVeloRouter _veloRouter,
    address _keeperRegistry,
    address _owner
  ) Owned(_owner) {
    smartYield = _smartYield;
    quoter = _quoter;
    veloRouter = _veloRouter;
    keeperRegistry = _keeperRegistry;
  }

  /// @notice liquidates one term at a time with calculated amountOutMins for swaps
  function performUpkeep(bytes calldata performData) external onlyKeeperRegistry {
    (address activeTerm, uint256[] memory amountOutMins) = abi.decode(
      performData,
      (address, uint256[])
    );
    smartYield.liquidateTerm(activeTerm, amountOutMins);
  }

  ///@notice Returns the first term that can be liquidated.
  function checkUpkeep(bytes calldata) external cannotExecute returns (
    bool upkeepNeeded,
    bytes memory performData
  ) {

    for(uint256 i; i < providers.length; i++) {
      ProviderInfo memory provider = providers[i];

      if (!provider.active) continue;

      (,,address activeTerm,,) = smartYield.poolByProvider(provider.addr);
      (,uint256 end,,,,,,bool liquidated) = smartYield.getTermInfo(activeTerm);

      // if term can be liquidated
      if (block.timestamp > end && !liquidated) {
        uint256[] memory amountOutMins = _calculateAmountOutMins(provider);
        return (true, abi.encode(activeTerm, amountOutMins));
      }
    }
    return (false, bytes(""));
  }

  /// @dev called offchain to calculate amountOutMins for each reward token
  function _calculateAmountOutMins(ProviderInfo memory _provider) internal returns (uint256[] memory amountOutMins_) {

    // simulate rewards distribution provider
    smartYield.preHarvest(_provider.addr);

    if (_provider.swapType == SwapType.UNISWAPV3) {
      // calculate amountOutMin expected for each reward token to be swapped via UniswapV3 Router
      IProvider.Reward[] memory rewards = IProvider(_provider.addr).getRewardList();
      amountOutMins_ = new uint256[](rewards.length);

      // calculate amountOutMins for each reward token
      for (uint256 i; i < rewards.length; i++) {
        uint256 amountIn = ERC20(rewards[i].token).balanceOf(_provider.addr);

        if (amountIn == 0) continue;

        (uint256 amountOut,,,) = quoter.quoteExactInput(rewards[i].toNativePath, amountIn);
        amountOutMins_[i] = amountOut * uint256(_provider.slippage) / MAX_SLIPPAGE;
      }

    } else if (_provider.swapType == SwapType.VELO) {
      IVeloRouter.Route[] memory rewardRoute = IVeloProvider(_provider.addr).getRewardToUnderlyingRoute();
      address reward = IVeloProvider(_provider.addr).rewards(0); // veloprovider was built for only one reward
      amountOutMins_ = new uint256[](1);

      uint256 amountIn = ERC20(reward).balanceOf(_provider.addr);

      if (amountIn == 0) return amountOutMins_; // no rewards to swap

      uint256[] memory amountOuts = veloRouter.getAmountsOut(amountIn, rewardRoute);

      uint256 amountOut = amountOuts[amountOuts.length - 1];

      amountOutMins_[0] = amountOut * uint256(_provider.slippage) / MAX_SLIPPAGE;
    } else if (_provider.swapType == SwapType.NONE) {
      return amountOutMins_; // no swap so pass empty array
    }
  }

  function addProvider(
    address _provider,
    SwapType _swapType,
    bool _active,
    uint16 _slippage
  ) external onlyOwner {
    providers.push(ProviderInfo(_provider, _swapType, _active, _slippage));
  }

  function removeProvider(uint256 _index) external onlyOwner {
    uint256 lastIndex = providers.length - 1;

    // replace index to be deleted with last index of the list
    if (_index != lastIndex) providers[_index] = providers[lastIndex];

    // remove last index of the list
    providers.pop();
  }

  function toggleProvider(uint256 _index) external onlyOwner {
    providers[_index].active = !providers[_index].active;
  }

  function setSmartYield(ISmartYield _smartYield) external onlyOwner {
    smartYield = _smartYield;
  }

  function setKeeperRegistry(address _keeperRegistry) external onlyOwner {
    keeperRegistry = _keeperRegistry;
  }

}
