#!/usr/bin/env bash

# Read the RPC URL
source .env

## Fork Mainnet
echo Please wait a few seconds for anvil to fork mainnet and run locally...
anvil --fork-url $RPC_URL &

# Wait for anvil to fork
sleep 10

# Run the script
echo Running Script:

# Run the script with interactive inputs
forge script script/DeploySY.s.sol:DeploySY --sig "run()(address)" \
    --rpc-url $RPC_URL \
    --broadcast \
    -vvvv \
    --private-key $DEPLOYER_KEY \
    $args
