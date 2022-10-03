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
      INITIAL_URI,
      REMAINING_WHALE_FUNCTION_CALLS_V2, 
      REMAINING_SEAL_FUNCTION_CALLS_V2, 
      REMAINING_PLANKTON_FUNCTION_CALLS_V2,
      [await addresses[0].getAddress(), 
       await addresses[6].getAddress()], 
      [await addresses[1].getAddress(), 
       await addresses[2].getAddress(),
       await addresses[3].getAddress(),
       await addresses[4].getAddress(),
       await addresses[5].getAddress()]
    );
    await membershipNft.deployed();
  };


  describe("Deployment", async () => {
    beforeEach(setupMembershipNft)

    it("should deploy", async () => {
      expect(membershipNft).to.be.ok;
    });
  });

  describe("Minting of three plankton NFTs upon deployment", async () => {
    beforeEach(setupMembershipNft)
  
    it("mints three plankton NFTs upon deployment", async() => {
      const tokensLeft = await membershipNft.planktonTokensLeft();
      const totalAmount = await membershipNft.totalPlanktonTokenAmount()
      expect(totalAmount).to.equal(tokensLeft.add(3));
      
    })
  });

  describe("Minting random plankton, seal and whale NFTs", async () => {
    beforeEach(setupMembershipNft)

    it("mints a random whale NFT", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "whale");
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      const leftBeforeMint = await membershipNft.whaleTokensLeft();
      await membershipNft.randomWhaleMint(overridesWhale);
      const leftAfterMint = await membershipNft.whaleTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random seal NFT", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "seal");
      const overridesSeal = {value: ethers.utils.parseEther("0.2")}
      const leftBeforeMint = await membershipNft.sealTokensLeft();;
      await membershipNft.randomSealMint(overridesSeal);
      const leftAfterMint = await membershipNft.sealTokensLeft();;
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random plankton NFT", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "plankton");
      const overridesPlankton = {value: ethers.utils.parseEther("0.1")}
      const leftBeforeMint = await membershipNft.planktonTokensLeft();
      await membershipNft.randomPlanktonMint(overridesPlankton);
      const leftAfterMint = await membershipNft.planktonTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });
  });

  describe("Minting non-random plankton, seal and whale NFTs", async () => {
    beforeEach(setupMembershipNft)

    it("mints a whale mycelia NFT using a random number lower than ending Mycelia token Id", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "whale");
      const whaleMintType = 0;
      const whaleMyceliaId = await (await membershipNft.TokenIdsByMintType(whaleMintType)).startingMycelia;
      const myceliaWhaleMint = await membershipNft.mintFromRandomNumber(whaleMyceliaId, whaleMintType); 
      expect(myceliaWhaleMint).to.emit(membershipNft, "MintedTokenInfo").withArgs(
        whaleMyceliaId, "Mycelia",
      );
    });
    
    it("mints a seal obsidian NFT using a random number lower than ending Obsidian token Id", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "seal");
      const sealMintType = 1;
      const sealObsidianId = await (await membershipNft.TokenIdsByMintType(sealMintType)).startingObsidian;
      const obsidianSealMint = await membershipNft.mintFromRandomNumber(sealObsidianId, sealMintType); 
      expect(obsidianSealMint).to.emit(membershipNft, "MintedTokenInfo").withArgs(
        sealObsidianId, "Obsidian",
      );
    });

    it("mints a plankton Gold NFT using a random number lower than ending Gold token Id", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "plankton");
      const planktonMintType = 2;
      const planktonGoldId = await (await membershipNft.TokenIdsByMintType(planktonMintType)).startingGold;
      const obsidianSealMint = await membershipNft.mintFromRandomNumber(planktonGoldId, planktonMintType); 
      expect(obsidianSealMint).to.emit(membershipNft, "MintedTokenInfo").withArgs(
        planktonGoldId, "Gold",
      );
    });
  });

  describe("withdrawal of ether", async () => {
    beforeEach(setupMembershipNft)

    it("withdraws ether stored in contract", async() => {
      await membershipNft.setTokensToMintPerRarity(5, "whale");
      const overridesWhale = {value: ethers.utils.parseEther("1.5")}
      await membershipNft.randomWhaleMint(overridesWhale);
      const balanceContractAfterMint = await membershipNft.provider.getBalance(membershipNft.address);
      await membershipNft.connect(deployer).withdrawEther();
      const provider = ethers.provider;
      const balanceContractAfterWithdrawal = await membershipNft.provider.getBalance(membershipNft.address);
      expect(balanceContractAfterMint).to.equal(ethers.utils.parseEther("1.5"))
      expect(balanceContractAfterWithdrawal).to.equal(ethers.utils.parseEther("0"));
    });
  });

  describe("Minting function reverts", async () => {
    beforeEach(setupMembershipNft)

    it("reverts when not enough ETH is sent for the whale minting function", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "whale");
      const overridesWhale = {value: ethers.utils.parseEther("0.1")}
      await expect(membershipNft.randomWhaleMint(overridesWhale)
      ).to.be.revertedWith("Incorrect Ether value");
    });

    it("reverts when not enough ETH is sent for the seal minting function", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "seal");
      const overridesSeal = {value: ethers.utils.parseEther("0.1")}
      await expect(membershipNft.randomSealMint(overridesSeal)
      ).to.be.revertedWith("Incorrect Ether value");
    });

    it("reverts when not enough ETH is sent for the plankton minting function", async () => {
      await membershipNft.setTokensToMintPerRarity(5, "plankton");
      const overridesPlankton = {value: ethers.utils.parseEther("0.05")}
      await expect(membershipNft.randomPlanktonMint(overridesPlankton)
      ).to.be.revertedWith("Incorrect Ether value");
    });

    it("reverts when no whale tokens are left", async () => {
      await membershipNft.setTokensToMintPerRarity(7, "whale");
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      await membershipNft.randomWhaleMint(overridesWhale);
      await membershipNft.randomWhaleMint(overridesWhale);
      await membershipNft.randomWhaleMint(overridesWhale);
      await membershipNft.randomWhaleMint(overridesWhale);
      await membershipNft.randomWhaleMint(overridesWhale);
      await membershipNft.randomWhaleMint(overridesWhale);
      await expect(membershipNft.randomWhaleMint(overridesWhale)
      ).to.be.revertedWith("Sold out");
    });

    it("reverts when too many NFTs have been minted per batch per rarity", async () => {
      await membershipNft.setTokensToMintPerRarity(3, "whale");
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      await membershipNft.randomWhaleMint(overridesWhale);
      await membershipNft.randomWhaleMint(overridesWhale);
      await membershipNft.randomWhaleMint(overridesWhale);
      await expect(membershipNft.randomWhaleMint(overridesWhale)
      ).to.be.revertedWith("Batch sold out");
    });
  });

  describe("setting the token URIs", async () => {
    beforeEach(setupMembershipNft)

    it("returns token URIs", async() => {
      const whaleMyceliaId = await (await membershipNft.TokenIdsByMintType(0)).startingMycelia;
      const sealDiamondId = await (await membershipNft.TokenIdsByMintType(1)).startingDiamond;
      const planktonSilverId = await (await membershipNft.TokenIdsByMintType(2)).startingSilver;
      await membershipNft.mintFromRandomNumber(whaleMyceliaId, 0);
      await membershipNft.mintFromRandomNumber(sealDiamondId, 1);
      await membershipNft.mintFromRandomNumber(planktonSilverId, 2);
      const findTokenURIWhale = await membershipNft.tokenURI(whaleMyceliaId);
      const findTokenURISeal = await membershipNft.tokenURI(sealDiamondId);
      const findTokenURIPlankton = await membershipNft.tokenURI(planktonSilverId);
      expect(findTokenURIWhale).to.equal("https://token-cdn-domain/1");
      expect(findTokenURISeal).to.equal("https://token-cdn-domain/10");
      expect(findTokenURIPlankton).to.equal("https://token-cdn-domain/28");
    });
  });

  describe("store rarities in mapping and return rarity when token Id is given", async() => {
    beforeEach(setupMembershipNft)

    it("sets the rarity per token id after mint - Mycelia", async() => {
      await membershipNft.myceliaMint(0);
      const rarity = await membershipNft.RarityByTokenId(1);
      expect(rarity).to.equal("Mycelia");
    });

    it("sets the rarity per token id after mint - Diamond", async() => {
      await membershipNft.diamondMint(0);
      const rarity = await membershipNft.RarityByTokenId(4);
      expect(rarity).to.equal("Diamond");
    });
  });
});