// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {IQuoterV2} from "uniswap-v3-periphery/contracts/interfaces/IQuoterV2.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";

import {IProvider} from "src/external/IProvider.sol";
import {IVeloProvider} from "src/external/IVeloProvider.sol";
import {IVeloRouter} from "src/external/IVeloRouter.sol";
import {ISmartYield} from "src/external/ISmartYield.sol";

import {SYTermLiquidation} from "src/SYTermLiquidation.sol";

import {SmartYieldMock} from "test/util/mocks/SmartYieldMock.sol";
import {VeloProviderMock} from "test/util/mocks/VeloProviderMock.sol";
import {ProviderMock} from "test/util/mocks/ProviderMock.sol";

import {TestUtils} from "test/util/TestUtils.sol";
import {UserFactory} from "test/util/UserFactory.sol";

///@notice test against mocked version of SmartYield (does not rely on external smart yield to be deployed)
contract SYTermLiquidationTest is Test {
  
  // automation contract
  SYTermLiquidation automation;

  // external
  IQuoterV2 quoter;
  IVeloRouter veloRouter;

  // Tokens
  ERC20 VELO;
  ERC20 AAVE;
  ERC20 CRV;
  ERC20 USDC;
  ERC20 DAI;
  ERC20 WETH;

  // mocks
  ProviderMock provider;
  VeloProviderMock veloProvider;
  SmartYieldMock smartYield;

  // addresses
  address keeperRegistry;
  address owner;
  address currentTerm;
  address veloTerm;
  
  uint256 termLength = 7 days;
  uint256 veloTermLength = 14 days;

  uint256 defaultSlippage = 9_800;

  bool isOptimism;

  function setUp() public {
    isOptimism = TestUtils.isOptimism(); // test velo router only on optimism

    quoter = IQuoterV2(TestUtils.OMNICHAIN_UNISWAP_V3_QUOTER);

    veloRouter = IVeloRouter(TestUtils.OPTIMSIM_VELODROME_ROUTER);

    address[] memory users = new UserFactory().create(3);
    keeperRegistry = users[0];
    owner = users[1];
    currentTerm = users[2];

    (VELO, AAVE, CRV, USDC, DAI, WETH) = TestUtils.getTokens();

    // configure provider
    provider = new ProviderMock();
    (bytes memory crvRewardPath, bytes memory aaveRewardPath) = TestUtils.getUniV3Paths();
    provider.addReward(address(CRV), crvRewardPath);
    provider.addReward(address(AAVE), aaveRewardPath);


    // configure smart yield
    smartYield = new SmartYieldMock();
    smartYield.setPool(
      address(provider),
      address(0),
      0,
      currentTerm,
      0,
      0
    );
    smartYield.setTermInfo(
      currentTerm,
      block.timestamp, // start
      block.timestamp + termLength, // end
      0,
      address(0),
      0,
      0,
      false
    );

    automation = new SYTermLiquidation(
      ISmartYield(smartYield),
      quoter,
      veloRouter, // zero address on chains other than optimism
      keeperRegistry,
      owner
    );

    vm.prank(owner);
    automation.addProvider(
      address(provider),
      SYTermLiquidation.SwapType.UNISWAPV3,
      true,
      uint16(defaultSlippage)
    );

    // add velo provider on optimism
    if (isOptimism) {
      address[] memory optimsimAddrs = new UserFactory().create(1);
      veloTerm = optimsimAddrs[0];

      // configure provider
      veloProvider = new VeloProviderMock();
      veloProvider.setReward(address(VELO));
      IVeloRouter.Route[] memory veloRoute = _getVeloRoutes();

      // hacky way to get past this error:
      // UnimplementedFeatureError: Copying of type struct 
      // IVeloRouter.Route memory[] memory to storage not yet supported.
      veloProvider.addRewardRoute(veloRoute[0]);
      veloProvider.addRewardRoute(veloRoute[1]);

      // configire smart yield
      smartYield.setPool(
        address(veloProvider),
        address(0),
        0,
        veloTerm,
        0,
        0
      );
      smartYield.setTermInfo(
        veloTerm,
        block.timestamp, // start
        block.timestamp + veloTermLength, // end
        0,
        address(0),
        0,
        0,
        false
      );

      vm.prank(owner);
      automation.addProvider(
        address(veloProvider),
        SYTermLiquidation.SwapType.VELO,
        true,
        uint16(defaultSlippage)
      );
    }
  }

  function test_checkUpkeep_NotReady() public {
    vm.prank(address(this), address(0));
    (bool isUpkeepNeeded, bytes memory performData) = automation.checkUpkeep(new bytes(0));

    assertFalse(isUpkeepNeeded);
    assertEq(performData.length, 0);
  }

  function test_checkUpKeep_Ready() public {
    vm.warp(block.timestamp + termLength + 1);
    vm.prank(address(this), address(0));
    (bool isUpkeepNeeded, bytes memory performData) = automation.checkUpkeep(new bytes(0));

    assertTrue(isUpkeepNeeded);
    assertTrue(performData.length > 0);
  }

  function test_checkUpKeep_NotActive() public {
    // deactivate provider
    vm.prank(owner);
    automation.toggleProvider(0);

    vm.warp(block.timestamp + termLength + 1);
    vm.prank(address(this), address(0));
    (bool isUpkeepNeeded, bytes memory performData) = automation.checkUpkeep(new bytes(0));

    assertFalse(isUpkeepNeeded);

    // re-activate Provider
    vm.prank(owner);
    automation.toggleProvider(0);

    vm.prank(address(this), address(0));
    (isUpkeepNeeded, performData) = automation.checkUpkeep(new bytes(0));

    assertTrue(isUpkeepNeeded);
  }

  function test_checkUpKeep_HasCorrectPerformData() public {

    // pre distribute rewards
    uint256 aaveAmt = 10*10**AAVE.decimals();
    uint256 crvAmt = 10*10**CRV.decimals();
    TestUtils.mintAave(address(provider), aaveAmt);
    TestUtils.mintCrv(address(provider), crvAmt);

    console2.log("provider aave amt", AAVE.balanceOf(address(provider)));
    console2.log("provider crv amt", CRV.balanceOf(address(provider)));

    // get amountOutMins
    uint256[] memory amountOutMins_ = _getAmountOutsUniswap(address(provider));

    // check up keep
    vm.warp(block.timestamp + termLength + 1);
    vm.prank(address(this), address(0));
    (, bytes memory performData) = automation.checkUpkeep(new bytes(0));
    
    
    (address activeTerm, uint256[] memory amountOutMins) = abi.decode(
      performData,
      (address, uint256[])
    );

    // verify active term is as expected
    console2.log("activeTerm", activeTerm);
    console2.log("currentTerm", currentTerm);
    assertEq(activeTerm, currentTerm);
    
    // two 2 reward tokens
    console2.log("amountOutMins.length", amountOutMins.length);
    assertEq(amountOutMins.length, 2);

    // verify rewards amountOutMins are as expected
    console2.log("amountOutMins[0]", amountOutMins[0]);
    console2.log("amountOutMins[1]", amountOutMins[1]);
    assertTrue(amountOutMins[0] > 0);
    assertTrue(amountOutMins[1] > 0);
    assertEq(amountOutMins[0], amountOutMins_[0]);
    assertEq(amountOutMins[1], amountOutMins_[1]);

    if (isOptimism) {
      
      // we need to liquidate non optimism provider before moving on
      vm.prank(keeperRegistry);
      automation.performUpkeep(performData);


      // pre distribute rewards
      uint256 veloAmt = 10*10**VELO.decimals();
      TestUtils.mintVelo(address(veloProvider), veloAmt);

      console2.log("looking at optimism");

      // get amountOutMins
      uint256[] memory amountOutMinsVelo_ = _getAmountOutsVelo(address(veloProvider));

      // check up keep
      vm.warp(block.timestamp + veloTermLength + 1);
      vm.prank(address(this), address(0));
      (, bytes memory performDataVelo) = automation.checkUpkeep(new bytes(0));
      
      (address activeTermVelo, uint256[] memory amountOutMinsVelo) = abi.decode(
        performDataVelo,
        (address, uint256[])
      );

      // verify active term is as expected
      assertEq(activeTermVelo, veloTerm);
      
      // two 2 reward tokens
      assertEq(amountOutMinsVelo.length, 1);

      // verify rewards amountOutMins are as expected
      assertTrue(amountOutMinsVelo[0] > 0);
      assertEq(amountOutMinsVelo[0], amountOutMinsVelo_[0]);
    }
  }

  function test_performUpkeep() public {
    // zero rewards
    vm.warp(block.timestamp + termLength + 1);
    vm.prank(address(this), address(0));
    (, bytes memory performData) = automation.checkUpkeep(new bytes(0));

    vm.prank(keeperRegistry);
    automation.performUpkeep(performData);

    // verify term is liquidated
    (,,,,,,,bool liquidated) = smartYield.getTermInfo(currentTerm);
    assertTrue(liquidated);

    if (isOptimism) {
      // check up keep
      vm.warp(block.timestamp + veloTermLength + 1);
      vm.prank(address(this), address(0));
      (, bytes memory performDataVelo) = automation.checkUpkeep(new bytes(0));

      vm.prank(keeperRegistry);
      automation.performUpkeep(performDataVelo);

      // verify term is liquidated
      (,,,,,,,bool veloLiquidated) = smartYield.getTermInfo(veloTerm);
      assertTrue(veloLiquidated);
    }
  }

  function test_removeProvider() public {
    
    vm.prank(owner);
    automation.addProvider(
      address(0),
      SYTermLiquidation.SwapType.NONE,
      true,
      10_000
    );
    (,SYTermLiquidation.SwapType swapType,,) = automation.providers(0);
    
    // sanity check that the first provider in the list is uniswap
    assertEq(uint8(swapType), uint8(SYTermLiquidation.SwapType.UNISWAPV3));

    // now remove the first provider in the list
    vm.prank(owner);
    automation.removeProvider(0);

    // grab the new first element in the list
    (,swapType,,) = automation.providers(0);

    // assert that the provider with a uniswap swaptype was removed
    // the first element should be the most recently added element because 
    // removing an element of the list will take the last item on the list and replace it with the removed item
    assertEq(uint8(swapType), uint8(SYTermLiquidation.SwapType.NONE));
  }

  function _getVeloRoutes() internal view returns (IVeloRouter.Route[] memory veloRoute_) {
    veloRoute_ = new IVeloRouter.Route[](2);
    veloRoute_[0] = IVeloRouter.Route({from: address(VELO), to: address(WETH), stable: false});
    veloRoute_[1] = IVeloRouter.Route({from: address(WETH), to: address(USDC), stable: false});
  }

  function _getAmountOutsUniswap(address _provider) public returns (uint256[] memory amountOutMins_) {
    uint256 snapshot = vm.snapshot();
    // calculate amountOutMin expected for each reward token to be swapped via UniswapV3 Router
    IProvider.Reward[] memory rewards = IProvider(_provider).getRewardList();
    amountOutMins_ = new uint256[](rewards.length);

    // calculate amountOutMins for each reward token
    for (uint256 i; i < rewards.length; i++) {
      uint256 amountIn = ERC20(rewards[i].token).balanceOf(_provider);

      if (amountIn == 0) continue;

      (uint256 amountOut,,,) = quoter.quoteExactInput(rewards[i].toNativePath, amountIn);
      amountOutMins_[i] = amountOut * defaultSlippage / automation.MAX_SLIPPAGE();
    }

    vm.revertTo(snapshot);
  }

  function _getAmountOutsVelo(address _veloProvider) public returns (uint256[] memory amountOutMins_) {
    uint256 snapshot = vm.snapshot();
    
    IVeloRouter.Route[] memory rewardRoute = IVeloProvider(_veloProvider).getRewardToUnderlyingRoute();
    address reward = IVeloProvider(_veloProvider).rewards(0); // veloprovider was built for only one reward
    amountOutMins_ = new uint256[](1);

    uint256 amountIn = ERC20(reward).balanceOf(_veloProvider);

    if (amountIn == 0) return amountOutMins_; // no rewards to swap

    uint256[] memory amountOuts = veloRouter.getAmountsOut(amountIn, rewardRoute);

    uint256 amountOut = amountOuts[amountOuts.length - 1];

    amountOutMins_[0] = amountOut * defaultSlippage / automation.MAX_SLIPPAGE();
    vm.revertTo(snapshot);
  }

}
