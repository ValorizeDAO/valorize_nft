import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { RoyaltyDistributorProductNft } from "../typechain/RoyaltyDistributorProductNft";
import { RoyaltyDistributorProductNftFactory } from "../typechain/RoyaltyDistributorProductNftFactory";
import { string } from "hardhat/internal/core/params/argumentTypes";

chai.use(solidity);

const { expect } = chai;

const provider = ethers.getDefaultProvider();

describe.only("RoyaltyDistributorProductNft", () => {
  let productNft: RoyaltyDistributorProductNft,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupProductNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    productNft = await new RoyaltyDistributorProductNftFactory(deployer).deploy( 
      await addresses[0].getAddress(), await addresses[1].getAddress());
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
      await productNft.connect(deployer).royaltyTransfer(8);
      const balanceArtistAfterRoyalty = await productNft.provider.getBalance(artistAddress);
      expect(balanceArtistAfterRoyalty).to.equal(balanceArtistBeforeRoyalty.add(4));
    });
  });
});