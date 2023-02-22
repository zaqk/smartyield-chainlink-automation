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

# We specify the anvil url as http://localhost:8545
# We need to specify the sender for our local anvil node
forge script script/DeploySYAave.s.sol:DeploySYAave --sig "runArbitrum()(address)"\
    --fork-url http://localhost:8545 \
    --broadcast \
    -vvvv \
    --private-key $DEPLOYER_KEY \
    $args

# Once finished, we want to kill our anvil instance running in the background
trap "exit" INT TERM
trap "kill 0" EXIT
