import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai, { util } from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { RoyaltyDistributor } from "../typechain/RoyaltyDistributor";
import { RoyaltyDistributorFactory } from "../typechain/RoyaltyDistributorFactory";
import { string } from "hardhat/internal/core/params/argumentTypes";

chai.use(solidity);

const { expect } = chai;

const provider = ethers.getDefaultProvider();

describe("RoyaltyDistributor", () => {
  let productNft: RoyaltyDistributor,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupProductNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    productNft = await new RoyaltyDistributorFactory(deployer).deploy( 
      [await addresses[2].getAddress(), await addresses[3].getAddress()]);
    await productNft.deployed();
  };

  describe("Deployment", async () => {
    beforeEach(setupProductNft)

    it("should deploy", async () => {
      expect(productNft).to.be.ok;
    });
  });

  describe("Distribution of royalties for an array of addresses", async () => {
    beforeEach(setupProductNft)

    it("receives royalties and updates the contract balance", async () => {
      const override = {value: ethers.utils.parseEther("8")}
      await productNft.receiveRoyalties(override);
      expect(await productNft.balanceOfContract()).to.equal(ethers.utils.parseEther("8"));
    });

    it("distributes the royalties", async () => {
      const override = {value: ethers.utils.parseEther("8")}
      await productNft.receiveRoyalties(override);
      const artistAddress = await addresses[2].getAddress();
      const balanceArtistBeforeRoyalty = await productNft.provider.getBalance(artistAddress);
      await productNft.royaltyTransfer();
      const balanceArtistAfterRoyalty = await productNft.provider.getBalance(artistAddress);
      expect(balanceArtistAfterRoyalty).to.equal(balanceArtistBeforeRoyalty.add(ethers.utils.parseEther("4")));
    });

    it("emits an event after distribution of the royalties", async () => {
      const override = {value: ethers.utils.parseEther("8")}
      await productNft.receiveRoyalties(override);
      const artistAddress = await addresses[2].getAddress();
      const royaltyDistributor = await productNft.royaltyTransfer();
      expect(royaltyDistributor).to.emit(productNft, "RoyaltiesDistributed").withArgs(
        artistAddress, ethers.utils.parseEther("4")
      );
    });

    it("updates the royalty receiving address", async () => {
      const addressOld = await addresses[3].getAddress();
      const addressNew = await addresses[7].getAddress();
      const updateRoyaltyReceiver = await productNft.connect(addresses[3]
        ).updateRoyaltyReceiver(addressOld, addressNew);
      expect(updateRoyaltyReceiver).to.emit(productNft, "ReceiverUpdated").withArgs(
        addressOld, addressNew
      );
    });

    it("fails when the previousReceiver does not have a role", async () => {
      const randomAddress = await addresses[5].getAddress();
      const addressNew = await addresses[2].getAddress();
      expect(productNft.updateRoyaltyReceiver(randomAddress, addressNew)
      ).to.be.revertedWith("Incorrect address for previousReceiver");
    });

    it("fails when the role name cannot be retrieved", async () => {
      const inquiredAddress = await addresses[5].getAddress();
      expect(productNft.getRoleName(inquiredAddress)).to.be.revertedWith("Incorrect address");
    });
  });
});