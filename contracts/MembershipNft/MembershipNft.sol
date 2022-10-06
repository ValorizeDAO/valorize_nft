
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

    uint256 internal whaleMyceliaAmount;
    uint256 internal sealMyceliaAmount;
    uint256 internal planktonMyceliaAmount;

    bool internal frozen = false;

    address[] public royaltyDistributorAddresses;
    address[] public royaltyRecipients;
    
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");

    mapping(MintType => TokenIds) public TokenIdsByMintType;

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
  event RecipientUpdated(address previousRecipient, address newRecipient);

  constructor(
    string memory _URI,
    uint256[] memory _whaleCalls, //  [3, 12, 35, 0, 0] // [3, 6, 9, 0, 0] //[1, 2, 3, 0, 0]
    uint256[] memory _sealCalls, //   [3, 18, 40, 90, 0] // [3, 6, 9, 12, 0] // [1, 2, 3, 4, 0]
    uint256[] memory _planktonCalls, //[4, 60, 125, 310, 2301] // [3, 6, 9, 12, 15] // [1, 2, 3, 4, 5]
    address[] memory _royaltyDistributorAddresses,
    address[] memory _royaltyRecipients 
  ) ERC721("MEMBERSHIP", "VMEMB") {
    URI = _URI;
    
    royaltyDistributorAddresses = _royaltyDistributorAddresses;
    royaltyRecipients = _royaltyRecipients;
    
    uint i;
    uint totalWhaleCalls = 0;
    uint totalSealCalls = 0;
    uint totalPlanktonCalls = 0;
      
    for(i = 0; i < _whaleCalls.length; i++){
      totalWhaleCalls = totalWhaleCalls + _whaleCalls[i];
      totalSealCalls = totalSealCalls + _sealCalls[i];
      totalPlanktonCalls = totalPlanktonCalls + _planktonCalls[i];
    }
    
    whaleMyceliaAmount = _whaleCalls[0];
    sealMyceliaAmount = _sealCalls[0];
    planktonMyceliaAmount = _planktonCalls[0];

    whaleTokensLeft = totalWhaleCalls;
    sealTokensLeft = totalSealCalls;
    planktonTokensLeft = totalPlanktonCalls;
    
    totalWhaleTokenAmount = totalWhaleCalls;
    totalSealTokenAmount = totalSealCalls;
    totalPlanktonTokenAmount = totalPlanktonCalls; 

    uint256 startSealId = totalWhaleTokenAmount;
    uint256 startPlanktonId = totalWhaleTokenAmount + totalSealTokenAmount;
    
    TokenIdsByMintType[MintType.Whale] = TokenIds(
        1,                              
        _whaleCalls[0],
        _whaleCalls[0] + 1,
        _whaleCalls[0] + _whaleCalls[1],
        _whaleCalls[0] + _whaleCalls[1] + 1,
        _whaleCalls[0] + _whaleCalls[1] + _whaleCalls[2],
        _whaleCalls[3],
        _whaleCalls[3],
        _whaleCalls[4],
        _whaleCalls[4]
    );

    TokenIdsByMintType[MintType.Seal] = TokenIds(
        startSealId + 1,                            
        startSealId + _sealCalls[0],
        startSealId + _sealCalls[0] + 1,
        startSealId + _sealCalls[0] + _sealCalls[1], 
        startSealId + _sealCalls[0] + _sealCalls[1] + 1, 
        startSealId + _sealCalls[0] + _sealCalls[1] + _sealCalls[2],
        startSealId + _sealCalls[0] + _sealCalls[1] + _sealCalls[2] + 1,
        startSealId + _sealCalls[0] + _sealCalls[1] + _sealCalls[2] + _sealCalls[3],
        startSealId + _sealCalls[4],
        startSealId + _sealCalls[4]
    );

    TokenIdsByMintType[MintType.Plankton] = TokenIds(
        startPlanktonId + 1,                             
        startPlanktonId + _planktonCalls[0],
        startPlanktonId + _planktonCalls[0] + 1,
        startPlanktonId + _planktonCalls[0] + _planktonCalls[1],
        startPlanktonId + _planktonCalls[0] + _planktonCalls[1] + 1,
        startPlanktonId + _planktonCalls[0] + _planktonCalls[1] + _planktonCalls[2],
        startPlanktonId + _planktonCalls[0] + _planktonCalls[1] + _planktonCalls[2] + 1,
        startPlanktonId + _planktonCalls[0] + _planktonCalls[1] + _planktonCalls[2] + _planktonCalls[3],
        startPlanktonId + _planktonCalls[0] + _planktonCalls[1] + _planktonCalls[2] + _planktonCalls[3] + 1,
        startPlanktonId + _planktonCalls[0] + _planktonCalls[1] + _planktonCalls[2] + _planktonCalls[3] + _planktonCalls[4]
    );

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(DEFAULT_ADMIN_ROLE, 0xCAdC6f201822C40D1648792C6A543EdF797e7D65);
          
    for (uint256 j=0; j < _royaltyRecipients.length; j++) {
      _grantRole(keccak256(abi.encodePacked(j)), royaltyRecipients[j]);
      _setRoleAdmin(keccak256(abi.encodePacked(j)), keccak256(abi.encodePacked(j)));
    }

    _mintFromDeterminant(TokenIdsByMintType[MintType.Plankton].startingMycelia, MintType.Plankton);
    _mintFromDeterminant(TokenIdsByMintType[MintType.Plankton].startingDiamond, MintType.Plankton);
    _mintFromDeterminant(TokenIdsByMintType[MintType.Plankton].startingSilver, MintType.Plankton);
    planktonTokensLeft = planktonTokensLeft-3;
    setTokenPrice();  
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
    PRICE_PER_WHALE_TOKEN = 1.0 ether;
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
  *@dev Sets the amount of tokenIds that can be minted per rarity.
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
  *@dev Returns a random number when the total token amount is given.
  *     The random number will be between the given total token amount and 1.
  *@param totalTokenAmount is the amount of tokens that are available per mint type.    
  */
  function _getRandomNumber(uint256 totalTokenAmount) internal view returns (uint256 randomNumber) {
    uint256 i = uint256(uint160(address(msg.sender)));
    randomNumber = (block.difficulty + i) % totalTokenAmount + 1;
  }

  /**
  *@dev This function determines which rarity should be minted based on the random number.
  *@param determinant determines which range of token Ids ***
  *@param mintType is the mint type which determines which predefined set of 
  *     token Ids will be minted (see constructor).   
  */
  function _mintFromDeterminant(uint256 determinant, MintType mintType) internal {
    if (determinant <= TokenIdsByMintType[mintType].endingMycelia) {      
      _myceliaMint(mintType);

    } else if (determinant <= TokenIdsByMintType[mintType].endingObsidian) {
      _obsidianMint(mintType);

    } else if (determinant <= TokenIdsByMintType[mintType].endingDiamond) {
      _diamondMint(mintType);

    } else if (determinant <= TokenIdsByMintType[mintType].endingGold) {
      _goldMint(mintType);
      
    } else if (determinant <= TokenIdsByMintType[mintType].endingSilver) {
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
      _mintFromDeterminant((TokenIdsByMintType[mintType].startingObsidian), mintType);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingMycelia);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingMycelia, "Mycelia");
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
      _mintFromDeterminant(TokenIdsByMintType[mintType].startingDiamond, mintType);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingObsidian);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingObsidian, "Obsidian");
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
    if (
      mintType == MintType.Whale && 
      TokenIdsByMintType[MintType.Whale].startingDiamond > TokenIdsByMintType[MintType.Whale].endingDiamond
    ) {
      _mintFromDeterminant(TokenIdsByMintType[MintType.Whale].startingMycelia, MintType.Whale);
    } else if(TokenIdsByMintType[mintType].startingDiamond > TokenIdsByMintType[mintType].endingDiamond) {
      _mintFromDeterminant(TokenIdsByMintType[mintType].startingGold, mintType);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingDiamond);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingDiamond, "Diamond");
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
    if (
      mintType == MintType.Plankton &&
      TokenIdsByMintType[MintType.Plankton].startingGold > TokenIdsByMintType[MintType.Plankton].endingGold) {
      _mintFromDeterminant(TokenIdsByMintType[mintType].startingGold+1, mintType);
      
    } else if(
      mintType == MintType.Seal &&
      TokenIdsByMintType[MintType.Seal].startingGold > TokenIdsByMintType[MintType.Seal].endingGold) {
      _mintFromDeterminant(TokenIdsByMintType[MintType.Seal].startingMycelia, MintType.Seal);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[mintType].startingGold);
      emit MintedTokenInfo(TokenIdsByMintType[mintType].startingGold, "Gold");
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
      _mintFromDeterminant(TokenIdsByMintType[MintType.Plankton].startingMycelia, MintType.Plankton);
    
    } else {
      _safeMint(msg.sender, TokenIdsByMintType[MintType.Plankton].startingSilver);
      emit MintedTokenInfo(TokenIdsByMintType[MintType.Plankton].startingSilver, "Silver");
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
      _mintFromDeterminant(randomNumber, MintType.Whale);
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
      _mintFromDeterminant(randomNumber, MintType.Seal);
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
      _mintFromDeterminant(randomNumber, MintType.Plankton);
      tokensLeftToMintPerRarityPerBatch["plankton"] = tokensLeftToMintPerRarityPerBatch["plankton"]-1;
      planktonTokensLeft--;
  }

  function rarityByTokenId(uint256 _tokenId) external view returns (string memory) {
    if ((_tokenId >= 1 && _tokenId <= TokenIdsByMintType[MintType.Whale].endingMycelia) 
    || (_tokenId > totalWhaleTokenAmount && _tokenId <= TokenIdsByMintType[MintType.Seal].endingMycelia)
    || (_tokenId > totalSealTokenAmount && _tokenId <= TokenIdsByMintType[MintType.Plankton].endingMycelia)) {
      return "Mycelia";
    
    } else if ((_tokenId > TokenIdsByMintType[MintType.Whale].endingMycelia && _tokenId <= TokenIdsByMintType[MintType.Whale].endingObsidian)
    || (_tokenId > TokenIdsByMintType[MintType.Seal].endingMycelia && _tokenId <= TokenIdsByMintType[MintType.Seal].endingObsidian)
    || (_tokenId > TokenIdsByMintType[MintType.Plankton].endingMycelia && _tokenId <= TokenIdsByMintType[MintType.Plankton].endingObsidian)) {
      return "Obsidian";
    
    } else if((_tokenId > TokenIdsByMintType[MintType.Whale].endingObsidian && _tokenId <= TokenIdsByMintType[MintType.Whale].endingDiamond)
    || (_tokenId > TokenIdsByMintType[MintType.Seal].endingObsidian && _tokenId <= TokenIdsByMintType[MintType.Seal].endingDiamond)
    || (_tokenId > TokenIdsByMintType[MintType.Plankton].endingObsidian && _tokenId <= TokenIdsByMintType[MintType.Plankton].endingDiamond)) {
      return "Diamond";
    
    } else if((_tokenId > TokenIdsByMintType[MintType.Whale].endingDiamond && _tokenId <= TokenIdsByMintType[MintType.Whale].endingGold)
    || (_tokenId > TokenIdsByMintType[MintType.Seal].endingDiamond && _tokenId <= TokenIdsByMintType[MintType.Seal].endingGold)
    || (_tokenId > TokenIdsByMintType[MintType.Plankton].endingDiamond && _tokenId <= TokenIdsByMintType[MintType.Plankton].endingGold)) {
      return "Gold";
    
    } else {
      return "Silver";
    }
  }

    /**
  *@dev Using this function a role name is returned if the inquired 
  *     address is present in the royaltyReceivers array
  *@param inquired is the address used to find the role name
  */
  function getRoleName(address inquired) external view returns (bytes32) {
    for(uint256 i=0; i < royaltyRecipients.length; i++) {
      if(royaltyRecipients[i] == inquired) {
        return keccak256(abi.encodePacked(i));
      }
    }
    revert("Incorrect address");
  }

  /**
  *@dev This function updates the royalty receiving address
  *@param previousRecipient is the address that was given a role before
  *@param newRecipient is the new address that replaces the previous address
  */
  function updateRoyaltyRecepient(address previousRecipient, address newRecipient) external {
    for(uint256 i=0; i < royaltyRecipients.length; i++) {
      if(royaltyRecipients[i] == previousRecipient) {
        require(hasRole(keccak256(abi.encodePacked(i)), msg.sender));
        royaltyRecipients[i] = newRecipient;
        emit RecipientUpdated(previousRecipient, newRecipient);
        return;
      }
    }
    revert("Incorrect address");
  } 

  /**
  * @dev  Information about the royalty is returned when provided with token id and sale price. 
  *       Royalty information depends on token id: if token id is a Mycelia NFT than the artist address is returned.
  *       If token id is not a Mycelia NFT than the funds will be sent to the contract that distributes royalties.    
  * @param _tokenId is the tokenId of an NFT that has been sold on the NFT marketplace
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
        return(royaltyRecipients[(_tokenId-1)], royaltyAmount);  
       
      } else if (_tokenId > totalWhaleTokenAmount && _tokenId <= TokenIdsByMintType[MintType.Seal].endingMycelia) {
          return(royaltyRecipients[(_tokenId-1-totalWhaleTokenAmount+whaleMyceliaAmount)], royaltyAmount);

      } else if ((_tokenId > totalSealTokenAmount && _tokenId <= TokenIdsByMintType[MintType.Plankton].endingMycelia)) {
          return(royaltyRecipients[(_tokenId-1-(totalSealTokenAmount+totalWhaleTokenAmount)+whaleMyceliaAmount+sealMyceliaAmount)], royaltyAmount);
      
      } else {
        return(royaltyDistributorAddresses[(_tokenId % royaltyDistributorAddresses.length)], royaltyAmount); 
    }
  }      
}