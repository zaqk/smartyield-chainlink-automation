#!/usr/bin/env bash

# Read the RPC URL
source .env

# Run the script with interactive inputs
forge script script/DeploySYAave.s.sol:DeploySYAave --sig "runArbitrum()(address)" \
    --rpc-url $RPC_URL \
    --broadcast \
    -vvvv \
    --private-key $DEPLOYER_KEY \
    $args
