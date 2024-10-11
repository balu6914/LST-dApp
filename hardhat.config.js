require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  solidity: "0.8.18",
  networks: {
    polygon_amoy: {
      url: process.env.POLYGON_AMOY_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 80002,
    },
  },
};
