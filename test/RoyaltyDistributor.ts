import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { RoyaltyDistributor } from "../typechain/RoyaltyDistributor";
import { RoyaltyDistributorFactory } from "../typechain/RoyaltyDistributorFactory";
import { string } from "hardhat/internal/core/params/argumentTypes";

chai.use(solidity);

const { expect } = chai;

const provider = ethers.getDefaultProvider();

describe.only("RoyaltyDistributor", () => {
  let productNft: RoyaltyDistributor,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupProductNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    productNft = await new RoyaltyDistributorFactory(deployer).deploy( 
      [await addresses[0].getAddress(), await addresses[1].getAddress()]);
    await productNft.deployed();
  };

  describe("Deployment", async () => {
    beforeEach(setupProductNft)

    it("should deploy", async () => {
      expect(productNft).to.be.ok;
    });
  });

  describe("Minting rarest, rarer and rare NFTs", async () => {
    beforeEach(setupProductNft)

    it("receives royalties and updates the contract balance", async () => {
      const override = {value: ethers.utils.parseEther("8")}
      await productNft.receiveRoyalties(override);
      expect(await productNft.balanceOfContract()).to.equal(ethers.utils.parseEther("8"));
    });

    it("distributes the royalties", async () => {
      const override = {value: ethers.utils.parseEther("8")}
      await productNft.receiveRoyalties(override);
      const artistAddress = await addresses[0].getAddress();
      const balanceArtistBeforeRoyalty = await productNft.provider.getBalance(artistAddress);
      await productNft.connect(deployer).royaltyTransfer();
      const balanceArtistAfterRoyalty = await productNft.provider.getBalance(artistAddress);
      expect(balanceArtistAfterRoyalty).to.equal(balanceArtistBeforeRoyalty.add(ethers.utils.parseEther("4")));
    });
  });
});