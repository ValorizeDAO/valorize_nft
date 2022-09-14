import { ethers } from "hardhat";

async function main() {
  const BASE_URI = "https://token-cdn-domain/";
  const START_RARER = 12;
  const START_RARE = 1012;
  const TOTAL_AMOUNT = 2012;

  const ProductNft = await ethers.getContractFactory("ProductNft");
  const productNft = await ProductNft.deploy(      
    BASE_URI,  
    START_RARER, 
    START_RARE, 
    TOTAL_AMOUNT);

  await productNft.deployed();

  console.log(`deployed to ${productNft.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});