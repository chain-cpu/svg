
const hre = require("hardhat");

async function main() {
  // We get the contract to deploy
  const Blobs = await hre.ethers.getContractFactory("Blobs");
  const blobs = await Blobs.deploy();

  await blobs.deployed();

  console.log("Blobs deployed to:", blobs.address);
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
