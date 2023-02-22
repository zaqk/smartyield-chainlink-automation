// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Vm} from "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

interface MintableERC20 {
  function mint(address to, uint256 amount) external;
  function bridgeMint(address to, uint256 amount) external;
}

library TestUtils {

  Vm private constant vm = Vm(address(uint160(uint256(keccak256('hevm cheat code')))));

  // Chain IDs
  uint256 constant public MAINNET_CHAIN_ID = 1;
  uint256 constant public OPTIMISM_CHAIN_ID = 10;
  uint256 constant public ARBITRUM_CHAIN_ID = 42161;

  // Smartyield Aave
  address constant public MAINNET_SMARTYIELD_AAVE = 0x8A897a3b2dd6756fF7c17E5cc560367a127CA11F;
  address constant public ARBITRUM_SMARTYIELD_AAVE = 0x1ADDAbB3fAc49fC458f2D7cC24f53e53b290d09e;

  // Uniswap V3
  address constant public OMNICHAIN_UNISWAP_V3_QUOTER = 0x61fFE014bA17989E743c5F6cB21bF9697530B21e;

  // Velodrome
  address constant public OPTIMSIM_VELODROME_ROUTER = 0x9c12939390052919aF3155f41Bf4160Fd3666A6f;

  // Tokens
  address constant public MAINNET_AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
  address constant public MAINNET_CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
  address constant public MAINNET_USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address constant public MAINNET_DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address constant public MAINNET_WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  address constant public ARBITRUM_AAVE = 0xba5DdD1f9d7F570dc94a51479a000E3BCE967196;
  address constant public ARBITRUM_CRV = 0x11cDb42B0EB46D95f990BeDD4695A6e3fA034978;
  address constant public ARBITRUM_USDC = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
  address constant public ARBITRUM_DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
  address constant public ARBITRUM_WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

  address constant public OPTIMISM_VELO = 0x3c8B650257cFb5f272f799F5e2b4e65093a11a05;
  address constant public OPTIMISM_AAVE = 0x76FB31fb4af56892A25e32cFC43De717950c9278;
  address constant public OPTIMISM_CRV = 0x0994206dfE8De6Ec6920FF4D779B0d950605Fb53;
  address constant public OPTIMISM_USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
  address constant public OPTIMISM_DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
  address constant public OPTIMISM_WETH = 0x4200000000000000000000000000000000000006;

  // Uni V3 Fees
  uint24 constant public MAINNET_AAVE_WETH_FEE = 3_000;
  uint24 constant public MAINNET_CRV_WETH_FEE = 10_000;
  uint24 constant public MAINNET_WETH_USDC_FEE = 3_000;

  uint24 constant public ARBITRUM_AAVE_WETH_FEE = 10_000;
  uint24 constant public ARBITRUM_CRV_WETH_FEE = 10_000;
  uint24 constant public ARBITRUM_WETH_USDC_FEE = 3_000;

  uint24 constant public OPTIMISM_AAVE_WETH_FEE = 10_000;
  uint24 constant public OPTIMISM_CRV_WETH_FEE = 10_000;
  uint24 constant public OPTIMISM_WETH_USDC_FEE = 3_000;

  // PRIVLEDGED ACCOUNTS
  address constant public MAINNET_AAVE_WHALE = 0x4da27a545c0c5B758a6BA100e3a049001de870f5;
  address constant public MAINNET_CRV_MINTER = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;

  address constant public ARBITRUM_AAVE_MINTER = 0x09e9222E96E7B4AE2a407B98d48e330053351EEe;
  address constant public ARBITRUM_CRV_MINTER = 0x09e9222E96E7B4AE2a407B98d48e330053351EEe;

  address constant public OPTIMISM_AAVE_MINTER = 0x4200000000000000000000000000000000000010;
  address constant public OPTIMISM_CRV_MINTER = 0x4200000000000000000000000000000000000010;
  address constant public VELO_MINTER = 0x3460Dc71A8863710D1C907B8d9D5DBC053a4102d;

  function getSmartYieldAaveAddr() internal view returns (address) {
    if (block.chainid == MAINNET_CHAIN_ID) {
      return MAINNET_SMARTYIELD_AAVE;
    } else if (block.chainid == ARBITRUM_CHAIN_ID) {
      return ARBITRUM_SMARTYIELD_AAVE;
    } else {
      revert("Unsupported chain");
    }
  }

  function getTokens() internal view returns (
    ERC20 VELO_,
    ERC20 AAVE_,
    ERC20 CRV_,
    ERC20 USDC_,
    ERC20 DAI_,
    ERC20 WETH_
  ) {
    if (block.chainid == MAINNET_CHAIN_ID) {
      return (
        ERC20(address(0)),
        ERC20(MAINNET_AAVE),
        ERC20(MAINNET_CRV),
        ERC20(MAINNET_USDC),
        ERC20(MAINNET_DAI),
        ERC20(MAINNET_WETH)
      );
    } else if (block.chainid == ARBITRUM_CHAIN_ID) {
      return (
        ERC20(address(0)),
        ERC20(ARBITRUM_AAVE),
        ERC20(ARBITRUM_CRV),
        ERC20(ARBITRUM_USDC),
        ERC20(ARBITRUM_DAI),
        ERC20(ARBITRUM_WETH)
      );
    } else if (block.chainid == OPTIMISM_CHAIN_ID) {
      return (
        ERC20(OPTIMISM_VELO),
        ERC20(OPTIMISM_AAVE),
        ERC20(OPTIMISM_CRV),
        ERC20(OPTIMISM_USDC),
        ERC20(OPTIMISM_DAI),
        ERC20(OPTIMISM_WETH)
      );
    } else {
      revert("Unsupported chain");
    }
  }

  function getUniV3Paths() internal view returns (bytes memory aaveUsdcPath, bytes memory crvUsdcPath) {
    if (block.chainid == MAINNET_CHAIN_ID) {
      return (
        abi.encodePacked(
          MAINNET_AAVE,
          MAINNET_AAVE_WETH_FEE,
          MAINNET_WETH,
          MAINNET_WETH_USDC_FEE,
          MAINNET_USDC
        ),
        abi.encodePacked(
          MAINNET_CRV,
          MAINNET_CRV_WETH_FEE,
          MAINNET_WETH,
          MAINNET_WETH_USDC_FEE,
          MAINNET_USDC
        )
      );
    } else if (block.chainid == ARBITRUM_CHAIN_ID) {
      return (
        abi.encodePacked(
          ARBITRUM_AAVE,
          ARBITRUM_AAVE_WETH_FEE,
          ARBITRUM_WETH,
          ARBITRUM_WETH_USDC_FEE,
          ARBITRUM_USDC
        ),
        abi.encodePacked(
          ARBITRUM_CRV,
          ARBITRUM_CRV_WETH_FEE,
          ARBITRUM_WETH,
          ARBITRUM_WETH_USDC_FEE,
          ARBITRUM_USDC
        )
      );
    } else if (block.chainid == OPTIMISM_CHAIN_ID) {
      return (
        abi.encodePacked(
          OPTIMISM_AAVE,
          OPTIMISM_AAVE_WETH_FEE,
          OPTIMISM_WETH,
          OPTIMISM_WETH_USDC_FEE,
          OPTIMISM_USDC
        ),
        abi.encodePacked(
          OPTIMISM_CRV,
          OPTIMISM_CRV_WETH_FEE,
          OPTIMISM_WETH,
          OPTIMISM_WETH_USDC_FEE,
          OPTIMISM_USDC
        )
      );
    } else {
      revert("Unsupported chain");
    }
  }

  function mintAave(address to, uint256 amount) public {
    if (block.chainid == MAINNET_CHAIN_ID) {
      vm.prank(MAINNET_AAVE_WHALE);
      ERC20(MAINNET_AAVE).transfer(to, amount);
    } else if (block.chainid == ARBITRUM_CHAIN_ID) {
      vm.prank(ARBITRUM_AAVE_MINTER);
      MintableERC20(ARBITRUM_AAVE).bridgeMint(to, amount);
    } else if (block.chainid == OPTIMISM_CHAIN_ID) {
      vm.prank(OPTIMISM_AAVE_MINTER);
      MintableERC20(OPTIMISM_AAVE).mint(to, amount);
    } else {
      revert("Unsupported chain");
    }
  }

  function mintCrv(address to, uint256 amount) public {
    if (block.chainid == MAINNET_CHAIN_ID) {
      vm.prank(MAINNET_CRV_MINTER);
      MintableERC20(MAINNET_CRV).mint(to, amount);
    } else if (block.chainid == ARBITRUM_CHAIN_ID) {
      vm.prank(ARBITRUM_CRV_MINTER);
      MintableERC20(ARBITRUM_CRV).bridgeMint(to, amount);
    } else if (block.chainid == OPTIMISM_CHAIN_ID) {
      vm.prank(OPTIMISM_CRV_MINTER);
      MintableERC20(OPTIMISM_CRV).mint(to, amount);
    } else {
      revert("Unsupported chain");
    }
  }

  function mintVelo(address to, uint256 amount) public {
    if (block.chainid == OPTIMISM_CHAIN_ID) {
      vm.prank(VELO_MINTER);
      MintableERC20(OPTIMISM_VELO).mint(to, amount);
    } else {
      revert("Unsupported chain");
    } 
  }

  function isOptimism() internal view returns (bool) {
    return block.chainid == OPTIMISM_CHAIN_ID;
  }
}