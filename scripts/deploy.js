const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy the LiquidToken contract first
  const LiquidToken = await ethers.getContractFactory("LiquidToken");
  const liquidToken = await LiquidToken.deploy();
  await liquidToken.deployed();
  console.log("LiquidToken deployed to:", liquidToken.address);

  // Deploy the Staking contract, passing the LiquidToken address
  const Staking = await ethers.getContractFactory("Staking");
  const staking = await Staking.deploy(liquidToken.address);
  await staking.deployed();
  console.log("Staking contract deployed to:", staking.address);

  // Transfer ownership of the LiquidToken to the Staking contract
  await liquidToken.transferOwnership(staking.address);
  console.log("Transferred ownership of LiquidToken to the Staking contract.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
