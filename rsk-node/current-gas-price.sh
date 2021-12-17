#!/bin/sh
curl https://public-node.testnet.rsk.co/ -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":1}' > .gas-price-testnet.json