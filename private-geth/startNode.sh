#!/bin/bash

# Path to the geth executable (alias)
GETH=/Users/antoine/dev/go/src/github.com/ethereum/go-ethereum/build/bin/geth

# Creation of the genesis block of our ethereum network
$GETH --datadir "/Users/antoine/ethdev" init ./genesis.json

# Setup the account
$GETH --datadir "/Users/antoine/ethdev" --password ./password account new

# Start the geth instance
$GETH --datadir "/Users/antoine/ethdev" --identity=NODE_ONE --networkid=15 --verbosity=1 --mine --minerthreads=1 --rpc --rpcport=8545 --rpcaddr 0.0.0.0 --nodiscover --maxpeers=1 console
