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
const REMAINING_WHALE_FUNCTION_CALLS = [4, 20, 30, 0, 0];
const REMAINING_SEAL_FUNCTION_CALLS = [5, 20, 30, 95, 0];
const REMAINING_PLANKTON_FUNCTION_CALLS = [3, 20, 180, 625, 1200];

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
      REMAINING_WHALE_FUNCTION_CALLS, 
      REMAINING_SEAL_FUNCTION_CALLS, 
      REMAINING_PLANKTON_FUNCTION_CALLS,
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
      expect(totalAmount).to.equal(tokensLeft.add(10)); 
    })
  });

  describe("Minting random plankton, seal and whale NFTs", async () => {
    beforeEach(setupMembershipNft)

    it("mints a random whale NFT", async () => {
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      const leftBeforeMint = await membershipNft.whaleTokensLeft();
      await membershipNft.randomWhaleMint(overridesWhale);
      const leftAfterMint = await membershipNft.whaleTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random seal NFT", async () => {
      const overridesSeal = {value: ethers.utils.parseEther("0.2")}
      const leftBeforeMint = await membershipNft.sealTokensLeft();;
      await membershipNft.randomSealMint(overridesSeal);
      const leftAfterMint = await membershipNft.sealTokensLeft();;
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random plankton NFT", async () => {
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
      const whaleMintType = 0;
      const whaleMyceliaId = await (await membershipNft.TokenIdsByMintType(whaleMintType)).startingMycelia;
      const myceliaWhaleMint = await membershipNft.mintFromDeterminant(whaleMyceliaId, whaleMintType); 
      expect(myceliaWhaleMint).to.emit(membershipNft, "MintedTokenInfo").withArgs(
        whaleMyceliaId, "Mycelia",
      );
    });
    
    it("mints a seal obsidian NFT using a random number lower than ending Obsidian token Id", async () => {
      const sealMintType = 1;
      const sealObsidianId = await (await membershipNft.TokenIdsByMintType(sealMintType)).startingObsidian;
      const obsidianSealMint = await membershipNft.mintFromDeterminant(sealObsidianId, sealMintType); 
      expect(obsidianSealMint).to.emit(membershipNft, "MintedTokenInfo").withArgs(
        sealObsidianId, "Obsidian",
      );
    });

    it("mints a plankton Gold NFT using a random number lower than ending Gold token Id", async () => {
      const planktonMintType = 2;
      const planktonGoldId = await (await membershipNft.TokenIdsByMintType(planktonMintType)).startingGold;
      const obsidianSealMint = await membershipNft.mintFromDeterminant(planktonGoldId, planktonMintType); 
      expect(obsidianSealMint).to.emit(membershipNft, "MintedTokenInfo").withArgs(
        planktonGoldId, "Gold",
      );
    });
  });

  describe("withdrawal of ether", async () => {
    beforeEach(setupMembershipNft)

    it("withdraws ether stored in contract", async() => {
      const overridesWhale = {value: ethers.utils.parseEther("0.5")}
      await membershipNft.randomWhaleMint(overridesWhale);
      const balanceContractAfterMint = await membershipNft.provider.getBalance(membershipNft.address);
      await membershipNft.connect(deployer).withdrawEther();
      const provider = ethers.provider;
      const balanceContractAfterWithdrawal = await membershipNft.provider.getBalance(membershipNft.address);
      expect(balanceContractAfterMint).to.equal(ethers.utils.parseEther("0.5"))
      expect(balanceContractAfterWithdrawal).to.equal(ethers.utils.parseEther("0"));
    });
  });

  describe("Minting function reverts", async () => {
    beforeEach(setupMembershipNft)

    it("reverts when not enough ETH is sent for the whale minting function", async () => {
      const overridesWhale = {value: ethers.utils.parseEther("0.1")}
      await expect(membershipNft.randomWhaleMint(overridesWhale)
      ).to.be.revertedWith("Incorrect Ether value");
    });

    it("reverts when not enough ETH is sent for the seal minting function", async () => {
      const overridesSeal = {value: ethers.utils.parseEther("0.05")}
      await expect(membershipNft.randomSealMint(overridesSeal)
      ).to.be.revertedWith("Incorrect Ether value");
    });

    it("reverts when not enough ETH is sent for the plankton minting function", async () => {
      const overridesPlankton = {value: ethers.utils.parseEther("0.01")}
      await expect(membershipNft.randomPlanktonMint(overridesPlankton)
      ).to.be.revertedWith("Incorrect Ether value");
    });
  });

  describe("setting the token URIs", async () => {
    beforeEach(setupMembershipNft)

    it("returns token URIs", async() => {
      const whaleMyceliaId = await (await membershipNft.TokenIdsByMintType(0)).startingMycelia;
      const sealDiamondId = await (await membershipNft.TokenIdsByMintType(1)).startingDiamond;
      const planktonSilverId = await (await membershipNft.TokenIdsByMintType(2)).startingSilver;
      await membershipNft.mintFromDeterminant(whaleMyceliaId, 0);
      await membershipNft.mintFromDeterminant(sealDiamondId, 1);
      await membershipNft.mintFromDeterminant(planktonSilverId, 2);
      const findTokenURIWhale = await membershipNft.tokenURI(whaleMyceliaId);
      const findTokenURISeal = await membershipNft.tokenURI(sealDiamondId);
      const findTokenURIPlankton = await membershipNft.tokenURI(planktonSilverId);
      expect(findTokenURIWhale).to.equal("https://token-cdn-domain/1");
      expect(findTokenURISeal).to.equal("https://token-cdn-domain/103");
      expect(findTokenURIPlankton).to.equal("https://token-cdn-domain/1033");
    });
  });

  describe("Return rarity when token Id is given", async() => {
    beforeEach(setupMembershipNft)

    it("sets the rarity per token id after mint - Mycelia", async() => {
      await membershipNft.myceliaMint(0);
      const rarity = await membershipNft.rarityByTokenId(1);
      expect(rarity).to.equal("Mycelia");
    });

    it("sets the rarity per token id after mint - Diamond", async() => {
      await membershipNft.diamondMint(0);
      const rarity = await membershipNft.rarityByTokenId(25);
      expect(rarity).to.equal("Diamond");
    });
  });

  describe("Updating of royalty receiver address by artists", async () => {
    beforeEach(setupMembershipNft)

    it("updates the royalty receiving address", async () => {
      const addressOld = await addresses[5].getAddress();
      const addressNew = await addresses[7].getAddress();
      const updateRoyaltyReceiver = await membershipNft.connect(addresses[5]
        ).updateRoyaltyRecepient(addressOld, addressNew);
      expect(updateRoyaltyReceiver).to.emit(membershipNft, "RecipientUpdated").withArgs(
        addressOld, addressNew
      );
    });

    it("fails when the previousReceiver does not have a role", async () => {
      const randomAddress = await addresses[9].getAddress();
      const addressNew = await addresses[2].getAddress();
      expect(membershipNft.updateRoyaltyRecepient(randomAddress, addressNew)
      ).to.be.revertedWith("Incorrect address for previous recipient");
    });

    it("fails when the role name cannot be retrieved", async () => {
      const inquiredAddress = await addresses[5].getAddress();
      expect(membershipNft.getRoleName(inquiredAddress)).to.be.revertedWith("Incorrect address");
    });
  })
});