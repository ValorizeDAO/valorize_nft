import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { ExposedProductNft } from "../typechain/ExposedProductNft";
import { ExposedProductNftFactory } from "../typechain/ExposedProductNftFactory";
import { string } from "hardhat/internal/core/params/argumentTypes";

chai.use(solidity);

const { expect } = chai;

const BASE_URI = "https://token-cdn-domain/";
const START_RARER = 12;
const START_RARE = 1012;
const TOTAL_AMOUNT = 2012;

describe("ProductNft", () => {
  let productNft: ExposedProductNft,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupProductNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    productNft = await new ExposedProductNftFactory(deployer).deploy(BASE_URI, START_RARER, START_RARE, TOTAL_AMOUNT);
    await productNft.deployed();
  };

  describe("Deployment", async () => {
    beforeEach(setupProductNft)

    it("should deploy", async () => {
      expect(productNft).to.be.ok;
    });
  })

  describe("Minting rarest, rarer and rare NFTs", async () => {
    beforeEach(setupProductNft)

    it("mints the next token Id by following a counter", async () => {
      const tokenCountBeforeIncrement = await productNft.rarestTokenIdCounter();
      await productNft.countBasedOnRarity(0);
      const tokenCountAfterIncrement = await productNft.rarestTokenIdCounter();
      expect(tokenCountAfterIncrement).to.equal(tokenCountBeforeIncrement.add(1));
    })

    it("batch mints a rarest NFT", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("7.5")}
      const tokenCountBeforeMint = await productNft.rarestTokenIdCounter();
      const mintAmount = 5;
      await productNft.rarestBatchMint(mintAmount, overridesRarest);
      const tokenCountAfterMint = await productNft.rarestTokenIdCounter();
      expect(tokenCountAfterMint).to.equal(tokenCountBeforeMint.add(5));
    });

    it("decreases the amount of tokens that are left after a rarest mint", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("7.5")}
      const tokensLeftBeforeMint = ethers.BigNumber.from(await productNft.rarestTokensLeft());
      const mintAmount = 5;
      await productNft.rarestBatchMint(mintAmount, overridesRarest);
      const tokensLeftAfterMint = ethers.BigNumber.from(await productNft.rarestTokensLeft());
      expect(tokensLeftBeforeMint).to.equal(tokensLeftAfterMint.add(5));
    }) 

    it("fails to batch mint rarest NFTs if sold out", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("20")}
      const mintAmount = 13;
      await expect(productNft.rarestBatchMint(mintAmount, overridesRarest)
      ).to.be.revertedWith("Mycelia NFTs are sold out");
    });

    it("reverts rarest batch mint when not enough Ether is sent", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("5")}
      const mintAmount = 9;
      await expect(productNft.rarestBatchMint(mintAmount, overridesRarest)
      ).to.be.revertedWith("Ether value sent is not correct");
    });

    it("reverts rarest batch mint when the chosen amount is zero", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("5")}
      const mintAmount = 0;
      await expect(productNft.rarestBatchMint(mintAmount, overridesRarest)
      ).to.be.revertedWith("You need to mint atleast one NFT");
    });

    it("batch mints a rarer NFT", async () => {
      const overridesRarer = {value: ethers.utils.parseEther("6")}
      const tokenIdBeforeMint = await productNft.rarerTokenIdCounter();
      const mintAmount = 5;
      await productNft.rarerBatchMint(mintAmount, overridesRarer);
      const tokenIdAfterMint = await productNft.rarerTokenIdCounter();
      expect(tokenIdAfterMint).to.equal(tokenIdBeforeMint.add(5));
    });

    it("reverts rarer batch mint when not enough Ether is sent", async () => {
      const overridesRarer = {value: ethers.utils.parseEther("1")}
      const mintAmount = 4;
      await expect(productNft.rarerBatchMint(mintAmount, overridesRarer)
      ).to.be.revertedWith("Ether value sent is not correct");
    });

    it("reverts rarer batch mint when the chosen amount is zero", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("5")}
      const mintAmount = 0;
      await expect(productNft.rarerBatchMint(mintAmount, overridesRarest)
      ).to.be.revertedWith("You need to mint atleast one NFT");
    });

    it("batch mints a rare NFT", async () => {
      const overridesRare = {value: ethers.utils.parseEther("5")}
      const tokenCountBeforeMint = await productNft.rareTokenIdCounter();
      const mintAmount = 10;
      await productNft.rareBatchMint(mintAmount, overridesRare);
      const tokenCountAfterMint = await productNft.rareTokenIdCounter();
      expect(tokenCountAfterMint).to.equal(tokenCountBeforeMint.add(10));
    });

    it("reverts rare batch mint when not enough Ether is sent", async () => {
      const overridesRarer = {value: ethers.utils.parseEther("1")}
      const mintAmount = 6;
      await expect(productNft.rareBatchMint(mintAmount, overridesRarer)
      ).to.be.revertedWith("Ether value sent is not correct");
    });

    it("reverts rare batch mint when the chosen amount is zero", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("5")}
      const mintAmount = 0;
      await expect(productNft.rareBatchMint(mintAmount, overridesRarest)
      ).to.be.revertedWith("You need to mint atleast one NFT");
    });
  });
  
  describe("setting the token URIs", async () => {
    beforeEach(setupProductNft)

    it("sets the token URI for rarest mint", async() => {
      const overridesRarest = {value: ethers.utils.parseEther("1.5")}
      const amount = 1;
      await productNft.rarestBatchMint(amount, overridesRarest);
      const tokenId = await productNft.rarestTokenIdCounter();
      const findTokenURI = await productNft._URI(tokenId);
      expect(findTokenURI).to.equal("https://token-cdn-domain/" + tokenId + ".json");
    });
  });

  describe("emit token Info by tokenId", async () => {
    beforeEach(setupProductNft)

    it("emits token info when tokenId is given", async() => {
      const tokenIdList = [1, 3, 5, 7, 8];
      const getTokenInfo = await productNft.emitTokenInfo(tokenIdList[1]);
      const getTokenURI = await productNft.URIS(tokenIdList[1]);
      const rarity = await productNft.returnRarityByTokenId(tokenIdList[1]);
      const getProductStatus = await productNft.ProductStatusByTokenId(tokenIdList[1]);
      expect(getTokenInfo).to.emit(productNft, "returnTokenInfo").withArgs(
        tokenIdList[1], rarity, getTokenURI, getProductStatus,
      );
    });
  });

  describe("setting the product status of an array of token Ids", async () => {
    beforeEach(setupProductNft)

    it("sets the product status to ready for Mycelia and Silver NFTs", async() => {
      const tokenIdList = [1, 3, 5, 7, 8];
      const rarity = 2;
      await productNft.initialProductStatusBasedOnRarity(tokenIdList[3], rarity);
      const getProductStatus = await productNft.ProductStatusByTokenId(tokenIdList[3]);
      const predictedProductStatus = 1;
      expect(getProductStatus).to.equal(predictedProductStatus);
    });

    it("switches the product status of not_ready to ready", async() => {
      const overridesRarest = {value: ethers.utils.parseEther("7.5")}
      await productNft.rarerBatchMint(5, overridesRarest);
      const tokenIdList = [13, 14, 15, 16, 17];
      await productNft.connect(deployer).switchProductStatusToReady(tokenIdList);
      const getProductStatus = await productNft.ProductStatusByTokenId(tokenIdList[3]);
      expect(getProductStatus).to.equal(1);
    });

    it("switches the product status of ready to deployed", async() => {
      const overridesRarest = {value: ethers.utils.parseEther("7.5")}
      await productNft.rarestBatchMint(5, overridesRarest);
      const tokenIdList = [1, 2, 3, 4, 5];
      await productNft.connect(deployer).switchProductStatusToDeployed(tokenIdList);
      const getProductStatus = await productNft.ProductStatusByTokenId(tokenIdList[2]);
      expect(getProductStatus).to.equal(2);
    });

    it("should fail if a token already set to ready is set to ready again", async() => {
      const tokenIdList = [1, 3, 5, 7, 8];
      await expect(productNft.connect(deployer).switchProductStatusToReady(tokenIdList)
      ).to.be.revertedWith("Product status is already set to ready");
    });

    it("should fail if attempting to set a token that is not ready to status deployed", async() => {
      //const tokenIdList = [14, 19, 201, 560, 788];
      const tokenIdList = [1, 3, 5, 7, 8];
      await expect(productNft.connect(deployer).switchProductStatusToDeployed(tokenIdList)
      ).to.be.revertedWith("Your token is not ready yet");
    });
  });
});