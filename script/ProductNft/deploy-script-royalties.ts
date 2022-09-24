import { ethers } from "hardhat";

async function main() {
  const ROYALTY_RECEIVERS = ["0xCAdC6f201822C40D1648792C6A543EdF797e7D65", "0x12b7cb6a96d11e530d2b802e172c1ad9a752717a"];

  const RoyaltyDistributor = await ethers.getContractFactory("RoyaltyDistributor");
  const royaltyDistributor = await RoyaltyDistributor.deploy(      
    ROYALTY_RECEIVERS);
    console.log({ royaltyDistributor })
  await royaltyDistributor.deployed();

  console.log(`deployed to ${royaltyDistributor.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});