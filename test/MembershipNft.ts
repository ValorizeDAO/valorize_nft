import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { ExposedMembershipNft } from "../typechain/ExposedMembershipNft";
import { ExposedMembershipNftFactory } from "../typechain/ExposedMembershipNftFactory";

chai.use(solidity);

const { expect } = chai;

const INITIAL_URI = "https://token-cdn-domain/";
const REMAINING_WHALE_FUNCTION_CALLS = [3, 18, 50, 0, 0];
const REMAINING_SEAL_FUNCTION_CALLS = [53, 68, 125, 200, 0];
const REMAINING_PLANKTON_FUNCTION_CALLS = [203, 223, 375, 1300, 3000];

const REMAINING_WHALE_FUNCTION_CALLS_V2 = [1, 2, 3, 0, 0];
const REMAINING_SEAL_FUNCTION_CALLS_V2 = [1, 2, 3, 4, 0];
const REMAINING_PLANKTON_FUNCTION_CALLS_V2 = [1, 2, 3, 4, 5];

describe.only("ExposedMembershipNft", () => {
  let membershipNft: ExposedMembershipNft,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupMembershipNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    membershipNft = await new ExposedMembershipNftFactory(deployer).deploy(
      INITIAL_URI, REMAINING_WHALE_FUNCTION_CALLS_V2, REMAINING_SEAL_FUNCTION_CALLS_V2, REMAINING_PLANKTON_FUNCTION_CALLS_V2,
    );
    await membershipNft.deployed();
  };


  describe("Deployment", async () => {
    beforeEach(setupMembershipNft)

    it("should deploy", async () => {
      expect(membershipNft).to.be.ok;
    });
  })

  describe("Minting random plankton, seal and whale NFTs", async () => {
    beforeEach(setupMembershipNft)

    it("mints a random whale NFT", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "whale");
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      const leftBeforeMint = await membershipNft.whaleTokensLeft();
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      const leftAfterMint = await membershipNft.whaleTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random seal NFT", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "seal");
      const overridesSeal = {value: ethers.utils.parseEther("0.2")}
      const leftBeforeMint = await membershipNft.sealTokensLeft();;
      await membershipNft.mintRandomSealNFT(overridesSeal);
      const leftAfterMint = await membershipNft.sealTokensLeft();;
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random plankton NFT", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "plankton");
      const overridesPlankton = {value: ethers.utils.parseEther("0.1")}
      const leftBeforeMint = await membershipNft.planktonTokensLeft();
      await membershipNft.mintRandomPlanktonNFT(overridesPlankton);
      const leftAfterMint = await membershipNft.planktonTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });
  });

  describe("Minting non-random plankton, seal and whale NFTs", async () => {
    beforeEach(setupMembershipNft)

    it("mints a whale mycelia NFT using a random number lower than ending Mycelia token Id", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "whale");
      const whaleMintType = 0;
      const whaleMyceliaId = await (await membershipNft.TokenIdsByMintType(whaleMintType)).startingMyceliaTokenId;
      const myceliaWhaleMint = await membershipNft.mintFromRandomNumber(whaleMyceliaId, whaleMintType); 
      expect(myceliaWhaleMint).to.emit(membershipNft, "MintedTokenInfo").withArgs(
        whaleMyceliaId, "Mycelia",
      );
    });
    
    it("mints a seal obsidian NFT using a random number lower than ending Obsidian token Id", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "seal");
      const sealMintType = 1;
      const sealObsidianId = await (await membershipNft.TokenIdsByMintType(sealMintType)).startingObsidianTokenId;
      const obsidianSealMint = await membershipNft.mintFromRandomNumber(sealObsidianId, sealMintType); 
      expect(obsidianSealMint).to.emit(membershipNft, "MintedTokenInfo").withArgs(
        sealObsidianId, "Obsidian",
      );
    });

    it("mints a plankton Gold NFT using a random number lower than ending Gold token Id", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "plankton");
      const planktonMintType = 2;
      const planktonGoldId = await (await membershipNft.TokenIdsByMintType(planktonMintType)).startingGoldTokenId;
      const obsidianSealMint = await membershipNft.mintFromRandomNumber(planktonGoldId, planktonMintType); 
      expect(obsidianSealMint).to.emit(membershipNft, "MintedTokenInfo").withArgs(
        planktonGoldId, "Gold",
      );
    });
  });

  describe("Minting functions revert when not enough ETH sent and when no tokens left/batch sold out", async () => {
    beforeEach(setupMembershipNft)

    it("reverts when not enough ETH is sent for the whale minting function", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "whale");
      const overridesWhale = {value: ethers.utils.parseEther("0.1")}
      await expect(membershipNft.mintRandomWhaleNFT(overridesWhale)
      ).to.be.revertedWith("Ether value sent is not correct");
    });

    it("reverts when not enough ETH is sent for the seal minting function", async () => {
      const overridesSeal = {value: ethers.utils.parseEther("0.1")}
      await expect(membershipNft.mintRandomSealNFT(overridesSeal)
      ).to.be.revertedWith("Ether value sent is not correct");
    });

    it("reverts when not enough ETH is sent for the plankton minting function", async () => {
      const overridesPlankton = {value: ethers.utils.parseEther("0.05")}
      await expect(membershipNft.mintRandomPlanktonNFT(overridesPlankton)
      ).to.be.revertedWith("Ether value sent is not correct");
    });

    it("reverts when no whale tokens are left", async () => {
      await membershipNft.setTokensToMintPerRarity(7, "whale");
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await expect(membershipNft.mintRandomWhaleNFT(overridesWhale)
      ).to.be.revertedWith("Whale NFTs are sold out");
    });

    it("reverts when too many NFTs have been minted per batch per rarity", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "whale");
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      await expect(membershipNft.mintRandomWhaleNFT(overridesWhale)
      ).to.be.revertedWith("Batch sold out");
    });
  });

  describe("setting the token URIs", async () => {
    beforeEach(setupMembershipNft)

    it("returns token URIs", async() => {
      const whaleMyceliaId = await (await membershipNft.TokenIdsByMintType(0)).startingMyceliaTokenId;
      const sealDiamondId = await (await membershipNft.TokenIdsByMintType(1)).startingDiamondTokenId;
      const planktonSilverId = await (await membershipNft.TokenIdsByMintType(2)).startingSilverTokenId;
      await membershipNft.mintFromRandomNumber(whaleMyceliaId, 0);
      await membershipNft.mintFromRandomNumber(sealDiamondId, 1);
      await membershipNft.mintFromRandomNumber(planktonSilverId, 2);
      const findTokenURIWhale = await membershipNft.tokenURI(whaleMyceliaId);
      const findTokenURISeal = await membershipNft.tokenURI(sealDiamondId);
      const findTokenURIPlankton = await membershipNft.tokenURI(planktonSilverId);
      expect(findTokenURIWhale).to.equal("https://token-cdn-domain/1");
      expect(findTokenURISeal).to.equal("https://token-cdn-domain/10");
      expect(findTokenURIPlankton).to.equal("https://token-cdn-domain/27");
    });
  });
});