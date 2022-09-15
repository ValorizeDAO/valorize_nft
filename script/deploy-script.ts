import { ethers } from "hardhat";

async function main() {
  const BASE_URI = "https://token-cdn-domain/";
  const ROYALTY_DISTRIBUTOR_ADDRESS = "0x8a7ad9A192CbB31679D0d468c25546F2949c8BB1" //royaltyDistributorAddress
  const ARTIST_ADDRESS = "0xCD892dA81cB7a981bf6B841d07f2467585E423DB" //artistAddress
  const START_RARER = 12;
  const START_RARE = 1012;
  const TOTAL_AMOUNT = 2012;

  const ProductNft = await ethers.getContractFactory("ProductNft");
  const productNft = await ProductNft.deploy(      
    BASE_URI,
    ROYALTY_DISTRIBUTOR_ADDRESS,
    ARTIST_ADDRESS,
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