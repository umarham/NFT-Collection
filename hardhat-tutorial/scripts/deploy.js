const { ethers } = require("hardhat");
require("dotenv").config({path: ".env"});
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");

async function main() {
  // Address of the whitelist contract that you deployed in the previous module
  const whitelistContract = WHITELIST_CONTRACT_ADDRESS;
  // URL from where we can extract the metadata for a Alien NFT
  const metadataURL =METADATA_URL;

  const alienContract = await ethers.getContractFactory("Alien");
  const deployedAlienContract = await alienContract.deploy(metadataURL,whitelistContract);

  //print the address of the deployed cintract
  console.log(
    "Alien Contract Address:",
    deployedAlienContract.address
  );

}
// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });