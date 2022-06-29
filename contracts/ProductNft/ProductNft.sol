//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev    Implementation of a Valorize Product Non Fungible Token using ERC721.
*       Key information: the metadata should be ordered. The rarest NFTs should be the lowest tokenIds, then rarer and then rare NFTs.
*/

contract ProductNft is ERC1155 {
    using Counters for Counters.Counter;

    string public baseURI;
    uint16 totalAmountOfTokenIds;
    uint16 rarestTokensLeft;
    uint16 rarerTokensLeft;
    uint16 rareTokensLeft;
    uint8 constant rarityRarest = 1;
    uint8 constant rarityRarer = 2;
    uint8 constant rarityRare = 3;
    Counters.Counter public rarestTokenIds;
    Counters.Counter public rarerTokenIds;
    Counters.Counter public rareTokenIds;
    uint256 public constant PRICE_PER_RAREST_TOKEN = 1.5 ether;
    uint256 public constant PRICE_PER_RARER_TOKEN = 0.55 ether;
    uint256 public constant PRICE_PER_RARE_TOKEN = 0.2 ether;
    uint16 public startRarerTokenIdIndex;
    uint16 public startRareTokenIdIndex;

  mapping(uint => string) public _URIS;

  constructor( 
    string memory baseURI_,   
    uint16 _startRarerTokenIdIndex,
    uint16 _startRareTokenIdIndex,
    uint16 _totalAmountOfTokenIds
    ) ERC1155(baseURI_) {
        baseURI = baseURI_;
        startRarerTokenIdIndex = _startRarerTokenIdIndex;
        startRareTokenIdIndex = _startRareTokenIdIndex;
        totalAmountOfTokenIds = _totalAmountOfTokenIds;
        rarestTokensLeft = _startRarerTokenIdIndex;
        rarerTokensLeft = _startRareTokenIdIndex - _startRarerTokenIdIndex; 
        rareTokensLeft = totalAmountOfTokenIds - startRareTokenIdIndex;
    }

    /**
    *@dev   This function allows the generation of a URI for a specific token Id: baseURI/tokenId.json 
    *       if it does not exist already. If it does exist, that token URI will be returned.
    *@param _tokenId is the token Id to generate or return the URI for.     
    */
    function _URI(uint256 _tokenId) public view returns (string memory) {
      if(bytes(_URIS[_tokenId]).length != 0) {
        return string(_URIS[_tokenId]);
      }
      return string(abi.encodePacked(baseURI, Strings.toString(_tokenId), ".json"));
    }
    
    /**
    *@dev   Using this function, a given amount will be turned into an array.
    *       This array will be used in ERC1155's batch mint function. 
    *@param amount is the amount provided that will be turned into an array.
    */
    function _turnAmountIntoArray(uint16 amount) internal pure returns (uint256[] memory tokenAmounts) {
        tokenAmounts = new uint[](amount);
        for (uint256 i = 0; i < amount;) {
            tokenAmounts[i] = i + 1;
            unchecked {
                i++;
            }
        }
    }

    /**
    *@dev   A counter is used to track the token Ids that have been minted.
    *       A token Id will be returned and turned into an array. 
    *@param rarity The rarity defines at what point the count starts.
    *       Using requirements, rarities have been assigned a set of tokenIds. 
    */
    function _countBasedOnRarity(uint8 rarity) internal returns (uint256 tokenId) {
        if(rarity == rarityRarest) {
            rarestTokenIds.increment();
            tokenId = rarestTokenIds.current();
            require(tokenId <= startRarerTokenIdIndex, "Mycelia NFTs are sold out");
            return tokenId;   
        } else if (rarity == rarityRarer) {
            rarerTokenIds.increment();
            tokenId = startRarerTokenIdIndex + rarerTokenIds.current();
            require(tokenId >= startRarerTokenIdIndex && tokenId <= startRareTokenIdIndex, "Diamond NFTS are sold out");
            return tokenId;
        } else if (rarity == rarityRare) {
            rareTokenIds.increment();
            tokenId = startRareTokenIdIndex + rareTokenIds.current();
            require(tokenId <= totalAmountOfTokenIds, "Silver NFTs are sold out");
            return tokenId;
        }
    }

    function _setURI(uint256 tokenId) internal {
            _URIS[tokenId] = _URI(tokenId);
    }

    /**
    *@dev   For ERC1155's batch mint function, a an array of token Ids
    *       with equal length to the array of amounts is needed.  
    *@param rarity The rarity defines at what point the count starts.
    *@param amount the given amount that will be turned into an array as
    *       the _turnAmountIntoArray function is used. 
    *       For each entry in the amounts array, the counter will be used 
    *       to generate the next token Id and to store that Id in an array.
    */
    function _turnTokenIdsIntoArray(uint8 rarity, uint16 amount) internal returns (uint256[] memory tokenIdArray) {
        tokenIdArray = new uint[](_turnAmountIntoArray(amount).length); 
        for (uint16 i = 0; i < _turnAmountIntoArray(amount).length;) { 
            uint256 currentTokenId = _countBasedOnRarity(rarity);
            tokenIdArray[i] = currentTokenId;
            _setURI(currentTokenId);
            unchecked {
                i++;
            }  
        }
    }

    /**
    *@dev   This minting function allows the minting of Rarest tokenIds.
    *@param amount: Every call will recursively increment the tokenId 
    *       depending on the amount of tokens the user wants to batch mint.
    *       These tokenIds are associated with the Mycelia rarity. 
    *       This function can be called for 1.5 ETH.
    */
    function rarestBatchMint(uint16 amount) public payable {
        require(PRICE_PER_RAREST_TOKEN * amount <= msg.value, "Ether value sent is not correct");
        require(amount >= 1, "You need to mint atleast one NFT");   
        _mintBatch(msg.sender, _turnTokenIdsIntoArray(rarityRarest, amount), _turnAmountIntoArray(amount), '');
        rarestTokensLeft--;
    }

    /**
    *@dev   This minting function allows the minting of Rarer tokenIds.
    *@param amount: Every call will recursively increment the tokenId 
    *       depending on the amount of tokens the user wants to batch mint.
    *       These tokenIds are associated with the Diamond rarity. 
    *       This function can be called for 0.55 ETH.
    */
    function rarerBatchMint(uint16 amount) public payable {
        require(PRICE_PER_RARER_TOKEN * amount <= msg.value, "Ether value sent is not correct");
        require(amount >= 1, "You need to mint atleast one NFT");   
        _mintBatch(msg.sender, _turnTokenIdsIntoArray(rarityRarer, amount), _turnAmountIntoArray(amount), '');
        rarerTokensLeft--;
    }

    /**
    *@dev   This minting function allows the minting of Rare tokenIds.
    *@param amount: Every call will recursively increment the tokenId 
    *       depending on the amount of tokens the user wants to batch mint.
    *       These tokenIds are associated with the Silver rarity. 
    *       This function can be called for 0.2 ETH.
    */
    function rareBatchMint(uint16 amount) public payable {
        require(PRICE_PER_RARE_TOKEN * amount <= msg.value, "Ether value sent is not correct");
        require(amount >= 1, "You need to mint atleast one NFT");   
        _mintBatch(msg.sender, _turnTokenIdsIntoArray(rarityRare, amount), _turnAmountIntoArray(amount), '');
        rareTokensLeft--;
    }
}
