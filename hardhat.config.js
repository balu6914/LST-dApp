require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    polygon_amoy: {
      url: process.env.POLYGON_AMOY_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 80002,
    },
  },
};
