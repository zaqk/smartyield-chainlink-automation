#!/usr/bin/env bash

# Read the RPC URL
source .env

# Run the script with interactive inputs
forge script script/DeploySY.s.sol:DeploySY --sig "runArbitrum()(address)" \
    --rpc-url $RPC_URL \
    --broadcast \
    -vvvv \
    --private-key $DEPLOYER_KEY \
    $args
