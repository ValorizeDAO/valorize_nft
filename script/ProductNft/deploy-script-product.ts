import { ethers } from "hardhat";
const args = require("./argumentsProductNft")

async function main() {

  const ProductNft = await ethers.getContractFactory("ProductNft");
  const productNft = await ProductNft.deploy(      
    ...args
  );
  console.log({ productNft })
  await productNft.deployed();

  console.log(`deployed to ${productNft.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});