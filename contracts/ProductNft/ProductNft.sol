//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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

    uint16 public startRarerTokenIdIndex;
    uint16 public startRareTokenIdIndex;
    uint16 totalAmountOfTokenIds;
    uint16 public rarestTokensLeft;
    uint16 public rarerTokensLeft;
    uint16 public rareTokensLeft;
    Counters.Counter public rarestTokenIds;
    Counters.Counter public rarerTokenIds;
    Counters.Counter public rareTokenIds;
    uint256 public constant PRICE_PER_RAREST_TOKEN = 1.5 ether;
    uint256 public constant PRICE_PER_RARER_TOKEN = 0.55 ether;
    uint256 public constant PRICE_PER_RARE_TOKEN = 0.2 ether;
    string public baseURI;

  mapping(uint => string) public URIS;

  enum Rarity {rarest, rarer, rare} 

  event returnTokenInfo(uint256 tokenId, string rarity, string tokenURI);

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
        rareTokensLeft = _totalAmountOfTokenIds - _startRareTokenIdIndex;
    }

    function emitTokenInfo(uint256 _tokenId) public {
      emit returnTokenInfo(_tokenId, returnRarityByTokenId(_tokenId), URIS[_tokenId]);
    }

    function returnRarityByTokenId(uint256 _tokenId) public view returns (string memory rarity) {
        if(_tokenId < startRarerTokenIdIndex) {
            return "Mycelia";
        } else if(_tokenId <= startRareTokenIdIndex && _tokenId > startRarerTokenIdIndex) {
            return "Diamond";
        } else if(_tokenId > startRareTokenIdIndex) {
            return "Silver";
        }
    }

    /**
    *@dev   This function allows the generation of a URI for a specific token Id: baseURI/tokenId.json 
    *       if it does not exist already. If it does exist, that token URI will be returned.
    *@param tokenId is the token Id to generate or return the URI for.     
    */
    function _URI(uint256 tokenId) public view returns (string memory) {
      if(bytes(URIS[tokenId]).length != 0) {
        return string(URIS[tokenId]);
      }
      return string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json"));
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
    function _countBasedOnRarity(Rarity rarity) internal returns (uint256 tokenId) {
        if(rarity == Rarity.rarest) {
            rarestTokenIds.increment();
            tokenId = rarestTokenIds.current();
            require(tokenId <= startRarerTokenIdIndex, "Mycelia NFTs are sold out");
            return tokenId;   
        } else if (rarity == Rarity.rarer) {
            rarerTokenIds.increment();
            tokenId = startRarerTokenIdIndex + rarerTokenIds.current();
            require(tokenId >= startRarerTokenIdIndex && tokenId <= startRareTokenIdIndex, "Diamond NFTS are sold out");
            return tokenId;
        } else if (rarity == Rarity.rare) {
            rareTokenIds.increment();
            tokenId = startRareTokenIdIndex + rareTokenIds.current();
            require(tokenId <= totalAmountOfTokenIds, "Silver NFTs are sold out");
            return tokenId;
        }
    }

    function _setURI(uint256 tokenId) internal {
            URIS[tokenId] = _URI(tokenId);
            emitTokenInfo(tokenId);
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
    function _turnTokenIdsIntoArray(Rarity rarity, uint16 amount) internal returns (uint256[] memory tokenIdArray) {
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

    function _reducesTokensLeft(uint16 amount, Rarity rarity) internal {
        for(uint16 i; i < _turnAmountIntoArray(amount).length;) {
            if (rarity == Rarity.rarest) {
                rarestTokensLeft--;
            } else if (rarity == Rarity.rarer) {
                rarerTokensLeft--;
            } else if (rarity == Rarity.rare) {
                rareTokensLeft--;
            }
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
        _mintBatch(msg.sender, _turnTokenIdsIntoArray(Rarity.rarest, amount), _turnAmountIntoArray(amount), '');
        _reducesTokensLeft(amount, Rarity.rarest);
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
        _mintBatch(msg.sender, _turnTokenIdsIntoArray(Rarity.rarer, amount), _turnAmountIntoArray(amount), '');
        _reducesTokensLeft(amount, Rarity.rarer);
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
        _mintBatch(msg.sender, _turnTokenIdsIntoArray(Rarity.rare, amount), _turnAmountIntoArray(amount), '');
        _reducesTokensLeft(amount, Rarity.rare);
    }
}
