
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

    uint256 public constant PRICE_PER_WHALE_TOKEN = 1.0 ether;
    uint256 public constant PRICE_PER_SEAL_TOKEN = 0.2 ether;
    uint256 public constant PRICE_PER_PLANKTON_TOKEN = 0.1 ether;

    uint256 public whaleTokensLeft;
    uint256 public sealTokensLeft;
    uint256 public planktonTokensLeft;
    
    uint256 public totalWhaleTokenAmount;
    uint256 public totalSealTokenAmount;
    uint256 public totalPlanktonTokenAmount;

    bool internal frozen = false;

    address royaltyDistributorAddress;
    address[] artistAddresses;
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");

    mapping(MintType => TokenIds) public TokenIdsByMintType;

    enum MintType { Whale, Seal, Plankton }

    struct TokenIds {
      uint256 startingMyceliaTokenId;
      uint256 endingMyceliaTokenId;
      uint256 startingObsidianTokenId;
      uint256 endingObsidianTokenId;
      uint256 startingDiamondTokenId;
      uint256 endingDiamondTokenId;
      uint256 startingGoldTokenId;
      uint256 endingGoldTokenId;
      uint256 startingSilverTokenId;
      uint256 endingSilverTokenId;
    }

  event MintedTokenInfo(uint256 tokenId, string rarity);

  constructor(
    string memory _URI,
    uint256[] memory _remainingWhaleFunctionCalls, //  [3, 12, 35, 0, 0] // [3, 6, 9, 0, 0] //[1, 2, 3, 0, 0]
    uint256[] memory _remainingSealFunctionCalls, //   [3, 18, 40, 90, 0] // [3, 6, 9, 12, 0] // [1, 2, 3, 4, 0]
    uint256[] memory _remainingPlanktonFunctionCalls, //[4, 60, 125, 310, 2301] // [3, 6, 9, 12, 15] // [1, 2, 3, 4, 5]
    address _royaltyDistributorAddress,
    address[] memory _artistAddresses 
  ) ERC721("MEMBERSHIP", "VMEMB") {
    URI = _URI;
    
    royaltyDistributorAddress = _royaltyDistributorAddress;
    artistAddresses = _artistAddresses;
    
    whaleTokensLeft = (_remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + _remainingWhaleFunctionCalls[2] + _remainingWhaleFunctionCalls[3] + _remainingWhaleFunctionCalls[4]);
    sealTokensLeft = (_remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2] + _remainingSealFunctionCalls[3] + _remainingSealFunctionCalls[4]);
    planktonTokensLeft = (_remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3] + _remainingPlanktonFunctionCalls[4]);
    
    totalWhaleTokenAmount = (_remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + _remainingWhaleFunctionCalls[2] + _remainingWhaleFunctionCalls[3] + _remainingWhaleFunctionCalls[4]);
    totalSealTokenAmount = (_remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2] + _remainingSealFunctionCalls[3] + _remainingSealFunctionCalls[4]);
    totalPlanktonTokenAmount = (_remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3] + _remainingPlanktonFunctionCalls[4]); 
    
    TokenIdsByMintType[MintType.Whale] = TokenIds(
        1,                              
        _remainingWhaleFunctionCalls[0],
        _remainingWhaleFunctionCalls[0] + 1,
        _remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1],
        _remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + 1,
        _remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + _remainingWhaleFunctionCalls[2],//6
        _remainingWhaleFunctionCalls[3],
        _remainingWhaleFunctionCalls[3],
        _remainingWhaleFunctionCalls[4],
        _remainingWhaleFunctionCalls[4]
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
        totalWhaleTokenAmount + _remainingSealFunctionCalls[4],
        totalWhaleTokenAmount + _remainingSealFunctionCalls[4]
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
  
  for (uint256 i=0; i < _artistAddresses.length; i++) {
    _setupRole(ARTIST_ROLE, _artistAddresses[i]);
  }
    _setRoleAdmin(ARTIST_ROLE, ARTIST_ROLE);  
  
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

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl, IERC165) returns (bool) {
    return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
  }

  /**
  *@dev   sends ether stored in the contract to admin.
  */
  function withdrawEther() external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success);

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

  function _getRandomNumber(uint256 totalTokenAmount) internal view returns (uint256 randomNumber) {
    uint256 i = uint256(uint160(address(msg.sender)));
    randomNumber = (block.difficulty + i) % totalTokenAmount + 1;
  }
 
  function _mintFromRandomNumber(uint256 randomNumber, MintType mintType) internal {
    if (randomNumber <= TokenIdsByMintType[mintType].endingMyceliaTokenId) {     
      _myceliaMint(mintType);

    } else if (randomNumber <= TokenIdsByMintType[mintType].endingObsidianTokenId) {
      _obsidianMint(mintType);

    } else if (randomNumber <= TokenIdsByMintType[mintType].endingDiamondTokenId) {
      _diamondMint(mintType);

    } else if (randomNumber <= TokenIdsByMintType[mintType].endingGoldTokenId) {
      _goldMint(mintType);
      
    } else if (randomNumber <= TokenIdsByMintType[mintType].endingSilverTokenId) {
      _silverMint();
    }
  }

  function _myceliaMint(MintType mintType) internal { 
    if (TokenIdsByMintType[mintType].startingMyceliaTokenId > TokenIdsByMintType[mintType].endingMyceliaTokenId) {
      _mintFromRandomNumber((TokenIdsByMintType[mintType].startingMyceliaTokenId+1), mintType);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingMyceliaTokenId);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingMyceliaTokenId, "Mycelia");
      TokenIdsByMintType[mintType].startingMyceliaTokenId++;
    }
  }

  function _obsidianMint(MintType mintType) internal {
    if (TokenIdsByMintType[mintType].startingObsidianTokenId > TokenIdsByMintType[mintType].endingObsidianTokenId) {
      _mintFromRandomNumber(TokenIdsByMintType[mintType].startingObsidianTokenId+1, mintType);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingObsidianTokenId);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingObsidianTokenId, "Obsidian");
      TokenIdsByMintType[mintType].startingObsidianTokenId++;
    }
  }

  function _diamondMint(MintType mintType) internal {
    if (TokenIdsByMintType[MintType.Whale].startingDiamondTokenId > TokenIdsByMintType[MintType.Whale].endingDiamondTokenId) {
      _mintFromRandomNumber(TokenIdsByMintType[MintType.Whale].startingMyceliaTokenId, MintType.Whale);
    
    } else if(TokenIdsByMintType[mintType].startingDiamondTokenId > TokenIdsByMintType[mintType].endingDiamondTokenId) {
      _mintFromRandomNumber(TokenIdsByMintType[mintType].startingDiamondTokenId+1, mintType);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingDiamondTokenId);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingDiamondTokenId, "Diamond");
      TokenIdsByMintType[mintType].startingDiamondTokenId++;
    }
  } 

  function _goldMint(MintType mintType) internal {
    if (TokenIdsByMintType[MintType.Plankton].startingGoldTokenId > TokenIdsByMintType[MintType.Plankton].endingGoldTokenId) {
      _mintFromRandomNumber(TokenIdsByMintType[mintType].startingGoldTokenId+1, mintType);
    
    } else if(TokenIdsByMintType[MintType.Seal].startingGoldTokenId > TokenIdsByMintType[MintType.Seal].endingGoldTokenId) {
      _mintFromRandomNumber(TokenIdsByMintType[MintType.Seal].startingMyceliaTokenId, MintType.Seal);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingGoldTokenId);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingGoldTokenId, "Gold");
      TokenIdsByMintType[mintType].startingGoldTokenId++;
    }
  }

  function _silverMint() internal {
    if(TokenIdsByMintType[MintType.Plankton].startingSilverTokenId > TokenIdsByMintType[MintType.Plankton].endingSilverTokenId) {
      _mintFromRandomNumber(TokenIdsByMintType[MintType.Plankton].startingMyceliaTokenId, MintType.Plankton);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[MintType.Plankton].startingSilverTokenId);
      emit MintedTokenInfo(TokenIdsByMintType[MintType.Plankton].startingSilverTokenId, "Silver");
      TokenIdsByMintType[MintType.Plankton].startingSilverTokenId++;
    }
  } 

  function randomWhaleMint() public payable slowMintStatus("whale") {
      require(PRICE_PER_WHALE_TOKEN <= msg.value, "Ether value sent is not correct");
      require(whaleTokensLeft > 0, "Whale NFTs are sold out");
      uint256 randomNumber = _getRandomNumber(totalWhaleTokenAmount);
      _mintFromRandomNumber(randomNumber, MintType.Whale);
      tokensLeftToMintPerRarityPerBatch["whale"] = tokensLeftToMintPerRarityPerBatch["whale"]--;
      whaleTokensLeft--;
  }

  function randomSealMint() public payable slowMintStatus("seal") {
      require(PRICE_PER_SEAL_TOKEN <= msg.value, "Ether value sent is not correct");
      require(sealTokensLeft > 0, "Seal NFTs are sold out");
      uint256 randomNumber = totalWhaleTokenAmount + _getRandomNumber(totalSealTokenAmount);
      _mintFromRandomNumber(randomNumber, MintType.Seal);
      tokensLeftToMintPerRarityPerBatch["seal"] = tokensLeftToMintPerRarityPerBatch["seal"]--;
      sealTokensLeft--;
  }

  function randomPlanktonMint() public payable slowMintStatus("plankton") {
      require(PRICE_PER_PLANKTON_TOKEN <= msg.value, "Ether value sent is not correct");
      require(planktonTokensLeft > 0, "Plankton NFTs are sold out");
      uint256 randomNumber = (totalWhaleTokenAmount + totalSealTokenAmount) + _getRandomNumber(totalPlanktonTokenAmount);
      _mintFromRandomNumber(randomNumber, MintType.Plankton);
      tokensLeftToMintPerRarityPerBatch["plankton"] = tokensLeftToMintPerRarityPerBatch["plankton"]--;
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
        if (_tokenId <= TokenIdsByMintType[MintType.Whale].endingMyceliaTokenId 
        || (_tokenId > totalWhaleTokenAmount && _tokenId <= TokenIdsByMintType[MintType.Seal].endingMyceliaTokenId) 
        || (_tokenId > totalSealTokenAmount && _tokenId <= TokenIdsByMintType[MintType.Plankton].endingMyceliaTokenId)) {
            return(artistAddresses[(_tokenId-1)], royaltyAmount);
        } else {
          return(royaltyDistributorAddress, royaltyAmount); 
        }
    }    
}