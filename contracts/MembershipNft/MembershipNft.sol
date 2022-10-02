
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC2981, IERC165 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./utils/SlowMintable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Membership Non Fungible Token using ERC721.
*/

contract MembershipNft is ERC721, IERC2981, AccessControl, SlowMintable, ReentrancyGuard {


    string public URI;

    uint256 public PRICE_PER_WHALE_TOKEN;
    uint256 public PRICE_PER_SEAL_TOKEN;
    uint256 public PRICE_PER_PLANKTON_TOKEN;

    uint256 public whaleTokensLeft;
    uint256 public sealTokensLeft;
    uint256 public planktonTokensLeft;
    
    uint256 public totalWhaleTokenAmount;
    uint256 public totalSealTokenAmount;
    uint256 public totalPlanktonTokenAmount;

    uint256 whaleMyceliaAmount;
    uint256 sealMyceliaAmount;
    uint256 planktonMyceliaAmount;

    bool internal frozen = false;

    address[] royaltyDistributorAddress;
    address[] artistAddresses;
    
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");

    mapping(MintType => TokenIds) public TokenIdsByMintType;
    mapping(uint256 => string) public RarityByTokenId;

    enum MintType { Whale, Seal, Plankton }

    struct TokenIds {
      uint256 startingMycelia;
      uint256 endingMycelia;
      uint256 startingObsidian;
      uint256 endingObsidian;
      uint256 startingDiamond;
      uint256 endingDiamond;
      uint256 startingGold;
      uint256 endingGold;
      uint256 startingSilver;
      uint256 endingSilver;
    }

  event MintedTokenInfo(uint256 tokenId, string rarity);

  constructor(
    string memory _URI,
    uint256[] memory _remainingWhaleFunctionCalls, //  [3, 12, 35, 0, 0] // [3, 6, 9, 0, 0] //[1, 2, 3, 0, 0]
    uint256[] memory _remainingSealFunctionCalls, //   [3, 18, 40, 90, 0] // [3, 6, 9, 12, 0] // [1, 2, 3, 4, 0]
    uint256[] memory _remainingPlanktonFunctionCalls, //[4, 60, 125, 310, 2301] // [3, 6, 9, 12, 15] // [1, 2, 3, 4, 5]
    address[] memory _royaltyDistributorAddress,
    address[] memory _artistAddresses 
  ) ERC721("MEMBERSHIP", "VMEMB") {
    URI = _URI;
    
    royaltyDistributorAddress = _royaltyDistributorAddress;
    artistAddresses = _artistAddresses;
    
    uint i;
    uint whaleCalls = 0;
    uint sealCalls = 0;
    uint planktonCalls = 0;
      
    for(i = 0; i < _remainingWhaleFunctionCalls.length; i++){
      whaleCalls = whaleCalls + _remainingWhaleFunctionCalls[i];
      sealCalls = sealCalls + _remainingSealFunctionCalls[i];
      planktonCalls = planktonCalls + _remainingPlanktonFunctionCalls[i];
    }
    
    whaleMyceliaAmount = _remainingWhaleFunctionCalls[0];
    sealMyceliaAmount = _remainingSealFunctionCalls[0];
    planktonMyceliaAmount = _remainingPlanktonFunctionCalls[0];

    whaleTokensLeft = whaleCalls;
    sealTokensLeft = sealCalls;
    planktonTokensLeft = planktonCalls;
    
    totalWhaleTokenAmount = whaleCalls;
    totalSealTokenAmount = sealCalls;
    totalPlanktonTokenAmount = planktonCalls; 
    
    TokenIdsByMintType[MintType.Whale] = TokenIds(
        1,                              
        _remainingWhaleFunctionCalls[0],
        _remainingWhaleFunctionCalls[0] + 1,
        _remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1],
        _remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + 1,
        _remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + _remainingWhaleFunctionCalls[2],//6
        0,
        0,
        0,
        0
    );

    TokenIdsByMintType[MintType.Seal] = TokenIds(
        totalWhaleTokenAmount + 1,                            
        totalWhaleTokenAmount + _remainingSealFunctionCalls[0],
        totalWhaleTokenAmount + _remainingSealFunctionCalls[0] + 1,
        totalWhaleTokenAmount + _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1], 
        totalWhaleTokenAmount + _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + 1, 
        totalWhaleTokenAmount + _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2],
        totalWhaleTokenAmount + _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2] + 1,
        totalWhaleTokenAmount + _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2] + _remainingSealFunctionCalls[3],
        0,
        0
    );

    TokenIdsByMintType[MintType.Plankton] = TokenIds(
        totalWhaleTokenAmount + totalSealTokenAmount + 1,                             
        totalWhaleTokenAmount + totalSealTokenAmount + _remainingPlanktonFunctionCalls[0],
        totalWhaleTokenAmount + totalSealTokenAmount + _remainingPlanktonFunctionCalls[0] + 1,
        totalWhaleTokenAmount + totalSealTokenAmount + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1],
        totalWhaleTokenAmount + totalSealTokenAmount + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + 1,
        totalWhaleTokenAmount + totalSealTokenAmount + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2],
        totalWhaleTokenAmount + totalSealTokenAmount + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + 1,
        totalWhaleTokenAmount + totalSealTokenAmount + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3],
        totalWhaleTokenAmount + totalSealTokenAmount + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3] + 1,
        totalWhaleTokenAmount + totalSealTokenAmount + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3] + _remainingPlanktonFunctionCalls[4]
    );

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    
    for (uint256 j=0; j < _artistAddresses.length; j++) {
      _setupRole(ARTIST_ROLE, _artistAddresses[j]);
    }
    _setRoleAdmin(ARTIST_ROLE, ARTIST_ROLE);

    // _mintFromRandomNumber(TokenIdsByMintType[MintType.Plankton].startingMycelia, MintType.Plankton);
    // _mintFromRandomNumber(TokenIdsByMintType[MintType.Plankton].startingDiamond, MintType.Plankton);
    // _mintFromRandomNumber(TokenIdsByMintType[MintType.Plankton].startingSilver, MintType.Plankton);
    // planktonTokensLeft = planktonTokensLeft-3;  
  }

  function freeze() external onlyRole(DEFAULT_ADMIN_ROLE) {
    frozen = true;
  }

  function _baseURI() internal view override returns (string memory) {
    return URI;
  }

  function _setURI(string memory baseURI) public{
    require(!frozen);
    URI = baseURI;
  }
  
  function setTokenPrice() internal {
    PRICE_PER_WHALE_TOKEN = 1.5 ether;
    PRICE_PER_SEAL_TOKEN = 0.2 ether;
    PRICE_PER_PLANKTON_TOKEN = 0.1 ether;
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl, IERC165) returns (bool) {
    return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
  }

  /**
  *@dev Sends ether stored in the contract to admin.
  */
  function withdrawEther() external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success);
  }

  /**
  *@dev This function sets the amount of tokenIds that can be minted per rarity
  *@param amount given amount of tokenIds that can be minted    
  *@param rarity the rarity of the NFTs that will be minted
  */
  function setTokensToMintPerRarity(uint16 amount, string memory rarity) external onlyRole(DEFAULT_ADMIN_ROLE) returns (uint16) {
      return super._setTokensToMintPerRarity(amount, rarity);
  }

  function _safeMint(address to, uint256 tokenId) override internal virtual {
    _safeMint(to, tokenId, "");
  }

  /**
  *@dev This function returns a random number when the total token amount is given.
  *     The random number will be between the given total token amount and 1.
  *@param totalTokenAmount is the amount of tokens that are available per mint type.    
  */
  function _getRandomNumber(uint256 totalTokenAmount) internal view returns (uint256 randomNumber) {
    uint256 i = uint256(uint160(address(msg.sender)));
    randomNumber = (block.difficulty + i) % totalTokenAmount + 1;
  }
 
  /**
  *@dev This function determines which rarity should be minted based on the random number.
  *@param randomNumber is the number received from _getRandomNumber.
  *@param mintType is the mint type which determines which predefined set of 
  *     token Ids will be minted (see constructor).   
  */
  function _mintFromRandomNumber(uint256 randomNumber, MintType mintType) internal {
    if (randomNumber <= TokenIdsByMintType[mintType].endingMycelia) {     
      _myceliaMint(mintType);

    } else if (randomNumber <= TokenIdsByMintType[mintType].endingObsidian) {
      _obsidianMint(mintType);

    } else if (randomNumber <= TokenIdsByMintType[mintType].endingDiamond) {
      _diamondMint(mintType);

    } else if (randomNumber <= TokenIdsByMintType[mintType].endingGold) {
      _goldMint(mintType);
      
    } else if (randomNumber <= TokenIdsByMintType[mintType].endingSilver) {
      _silverMint();
    }
  }

  /**
  *@dev This mints a mycelia NFT when the startingMycelia is lower than the endingMycelia
  *     After mint, the startingMycelia will increase by 1.
  *     If startingMycelia is higher than endingMycelia the Obsidian rarity will be minted.
  *@param mintType is the mint type which determines which predefined set of 
  *     token Ids will be minted (see constructor).   
  */
  function _myceliaMint(MintType mintType) internal { 
    if (TokenIdsByMintType[mintType].startingMycelia > TokenIdsByMintType[mintType].endingMycelia) {
      _mintFromRandomNumber((TokenIdsByMintType[mintType].startingObsidian), mintType);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingMycelia);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingMycelia, "Mycelia");
      RarityByTokenId[TokenIdsByMintType[mintType].startingMycelia] = "Mycelia";
      TokenIdsByMintType[mintType].startingMycelia++;
    }
  }
  /**
  *@dev This mints an obsidian NFT when the startingObsidian is lower than the endingObsidian
  *     After mint, the startingObsidian will increase by 1.
  *     If startingObsidian is higher than endingObsidian the Diamond rarity will be minted.
  *@param mintType is the mint type which determines which predefined set of 
  *     token Ids will be minted (see constructor).   
  */
  function _obsidianMint(MintType mintType) internal {
    if (TokenIdsByMintType[mintType].startingObsidian > TokenIdsByMintType[mintType].endingObsidian) {
      _mintFromRandomNumber(TokenIdsByMintType[mintType].startingDiamond, mintType);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingObsidian);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingObsidian, "Obsidian");
      RarityByTokenId[TokenIdsByMintType[mintType].startingObsidian] = "Obsidian";
      TokenIdsByMintType[mintType].startingObsidian++;
    }
  }
  /**
  *@dev This mints a diamond NFT when the startingDiamond is lower than the endingDiamond
  *     In other words, a diamond NFT will be minted when there are still diamond NFTs available.
  *     After mint, the startingDiamond will increase by 1.
  *     If startingDiamond from mint type whale is higher than endingDiamond from mint type whale
  *     then startingMycelia (or startingObsidian) will be minted.
  *     If startingDiamond is higher than endingDiamond the Gold rarity will be minted.
  *@param mintType is the mint type which determines which predefined set of 
  *     token Ids will be minted (see constructor).   
  */
  function _diamondMint(MintType mintType) internal {
    if (TokenIdsByMintType[MintType.Whale].startingDiamond > TokenIdsByMintType[MintType.Whale].endingDiamond) {
      _mintFromRandomNumber(TokenIdsByMintType[MintType.Whale].startingMycelia, MintType.Whale);
    
    } else if(TokenIdsByMintType[mintType].startingDiamond > TokenIdsByMintType[mintType].endingDiamond) {
      _mintFromRandomNumber(TokenIdsByMintType[mintType].startingGold, mintType);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingDiamond);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingDiamond, "Diamond");
      RarityByTokenId[TokenIdsByMintType[mintType].startingDiamond] = "Diamond";
      TokenIdsByMintType[mintType].startingDiamond++;
    }
  } 

  /**
  *@dev This mints a gold NFT when the startingGold is lower than the endingGold
  *     After mint, the startingGold will increase by 1.
  *     If startingGold from mint type seal is higher than endingGold from mint type seal
  *     then startingMycelia (or higher rarity) should be minted.
  *     If startingGold from mint type plankton is higher than endingGold from mint type plankton
  *     then the startingSilver should be minted.
  *@param mintType is the mint type which determines which predefined set of 
  *     token Ids will be minted (see constructor).   
  */
  function _goldMint(MintType mintType) internal {
    if (TokenIdsByMintType[MintType.Plankton].startingGold > TokenIdsByMintType[MintType.Plankton].endingGold) {
      _mintFromRandomNumber(TokenIdsByMintType[mintType].startingSilver, mintType);
    
    } else if(TokenIdsByMintType[MintType.Seal].startingGold > TokenIdsByMintType[MintType.Seal].endingGold) {
      _mintFromRandomNumber(TokenIdsByMintType[MintType.Seal].startingMycelia, MintType.Seal);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingGold);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingGold, "Gold");
      RarityByTokenId[TokenIdsByMintType[mintType].startingGold] = "Gold";
      TokenIdsByMintType[mintType].startingGold++;
    }
  }

  /**
  *@dev This mints a silver NFT only for mint type plankton when the startingSilver is lower than the endingSilver
  *     After mint, the startingSilver will increase by 1.
  *     If startingSilver from mint type plankton is higher than endingSilver from mint type plankton
  *     then startingMycelia (or higher rarity) should be minted. 
  */
  function _silverMint() internal {
    if(TokenIdsByMintType[MintType.Plankton].startingSilver > TokenIdsByMintType[MintType.Plankton].endingSilver) {
      _mintFromRandomNumber(TokenIdsByMintType[MintType.Plankton].startingMycelia, MintType.Plankton);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[MintType.Plankton].startingSilver);
      emit MintedTokenInfo(TokenIdsByMintType[MintType.Plankton].startingSilver, "Silver");
      RarityByTokenId[TokenIdsByMintType[MintType.Plankton].startingSilver] = "Silver";
      TokenIdsByMintType[MintType.Plankton].startingSilver++;
    }
  } 

  /**
  *@dev Random minting of token Ids associated with the whale mint type.
  */
  function randomWhaleMint() public payable slowMintStatus("whale") {
      require(PRICE_PER_WHALE_TOKEN <= msg.value, "Incorrect Ether value");
      require(whaleTokensLeft > 0, "Sold out");
      uint256 randomNumber = _getRandomNumber(totalWhaleTokenAmount);
      _mintFromRandomNumber(randomNumber, MintType.Whale);
      tokensLeftToMintPerRarityPerBatch["whale"] = tokensLeftToMintPerRarityPerBatch["whale"]-1;
      whaleTokensLeft--;
  }

  /**
  *@dev Random minting of token Ids associated with the seal mint type.
  */
  function randomSealMint() public payable slowMintStatus("seal") {
      require(PRICE_PER_SEAL_TOKEN <= msg.value, "Incorrect Ether value");
      require(sealTokensLeft > 0, "Sold out");
      uint256 randomNumber = totalWhaleTokenAmount + _getRandomNumber(totalSealTokenAmount);
      _mintFromRandomNumber(randomNumber, MintType.Seal);
      tokensLeftToMintPerRarityPerBatch["seal"] = tokensLeftToMintPerRarityPerBatch["seal"]-1;
      sealTokensLeft--;
  }

  /**
  *@dev Random minting of token Ids associated with the plankton mint type.
  */
  function randomPlanktonMint() public payable slowMintStatus("plankton") {
      require(PRICE_PER_PLANKTON_TOKEN <= msg.value, "Incorrect Ether value");
      require(planktonTokensLeft > 0, "Sold out");
      uint256 randomNumber = (totalWhaleTokenAmount + totalSealTokenAmount) + _getRandomNumber(totalPlanktonTokenAmount);
      _mintFromRandomNumber(randomNumber, MintType.Plankton);
      tokensLeftToMintPerRarityPerBatch["plankton"] = tokensLeftToMintPerRarityPerBatch["plankton"]-1;
      planktonTokensLeft--;
  }

  /**
  * @dev  Information about the royalty is returned when provided with token id and sale price. 
  *       Royalty information depends on token id: if token id is smaller than 12 than the artist address is given.
  *       If token id is bigger than 12 than the funds will be sent to the contract that distributes royalties.    * @param _tokenId is the tokenId of an NFT that has been sold on the NFT marketplace
  * @param _salePrice is the price of the sale of the given token id
  */
  function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view override returns (
        address,
        uint256 royaltyAmount
    ) {
      royaltyAmount = (_salePrice / 100) * 10; 

      if (_tokenId >= 1 && _tokenId <= TokenIdsByMintType[MintType.Whale].endingMycelia) {
        return(artistAddresses[(_tokenId-1)], royaltyAmount);  
       
      } else if (_tokenId > totalWhaleTokenAmount && _tokenId <= TokenIdsByMintType[MintType.Seal].endingMycelia) {
          return(artistAddresses[(_tokenId-totalWhaleTokenAmount-1+whaleMyceliaAmount)], royaltyAmount);
         
      } else if ((_tokenId > totalSealTokenAmount && _tokenId <= TokenIdsByMintType[MintType.Plankton].endingMycelia)) {
          return(artistAddresses[(_tokenId-(totalSealTokenAmount+totalWhaleTokenAmount)-1+(whaleMyceliaAmount+sealMyceliaAmount))], royaltyAmount);
      
      } else {
        return(royaltyDistributorAddress[(_tokenId % royaltyDistributorAddress.length)], royaltyAmount); 
    } //tokenIds should be ordered per artist per 12: 
      // 12 = royaltyDistributorAddress[0]
      // 11 = royaltyDistributorAddress[11]
      // 10 = royaltyDistributorAddress[10]
  }    
        //id
        // 1 = artistAddress[0]
        // 2 = artistAddress[1]
        // 3 = artistAddress[2]
        // 51 = artistAddress[3]
        // 52 = artistAddress[4]
        // 53 = artistAddress[5]
        // 201 = artistAddress[6]
        // 202 = artistAddress[7]
        // 203 = artistAddress[8]
        // 204 = artistAddress[9]

        //put the addresses of the artists 
        //use modulo by 12 for token Id 
        // tokenId = 120
        // artists = [1,2,3,4,5,6,7,8,9,10,11,12]
        // artist = artists[tokenId % 12] => 10
        //12 royaltyDistributorAddresses    
}