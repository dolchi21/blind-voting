const HDWalletProvider = require('@truffle/hdwallet-provider');

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();
if (!mnemonic || mnemonic.split(' ').length !== 12) {
  throw new Error('unable to retrieve mnemonic from .secret');
}

const gasPriceTestnetRaw = fs.readFileSync(".gas-price-testnet.json").toString().trim();
const gasPriceTestnet = parseInt(JSON.parse(gasPriceTestnetRaw).result, 16);
if (typeof gasPriceTestnet !== 'number' || isNaN(gasPriceTestnet)) {
  throw new Error('unable to retrieve network gas price from .gas-price-testnet.json');
}
console.log("Gas price Testnet: " + gasPriceTestnet);

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 4444,
      network_id: "*"
    },
    testnet: {
      provider: () => new HDWalletProvider(mnemonic, 'https://public-node.testnet.rsk.co/'),
      network_id: 31,
      gasPrice: Math.floor(gasPriceTestnet * 1.1),
      networkCheckTimeout: 1e9
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.10",    // Fetch exact version from solc-bin (default: truffle's version)
    }
  },
};
