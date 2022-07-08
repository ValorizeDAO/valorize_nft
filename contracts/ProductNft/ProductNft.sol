//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title ProductNft
@author Marco Huberts & Javier Gonzalez
@dev    Implementation of a Valorize Product Non Fungible Token using ERC1155.
*       Key information: the metadata should be ordered. The rarest NFTs should be the lowest tokenIds, then rarer and then rare NFTs.
*/

contract ProductNft is ERC1155, Ownable {
    using Counters for Counters.Counter;

    uint16 public startRarerTokenIdIndex;
    uint16 public startRareTokenIdIndex;
    uint16 public totalAmountOfTokenIds;
    uint16 public rarestTokensLeft;
    uint16 public rarerTokensLeft;
    uint16 public rareTokensLeft;
    Counters.Counter public rarestTokenIdCounter;
    Counters.Counter public rarerTokenIdCounter;
    Counters.Counter public rareTokenIdCounter;
    uint256 public constant PRICE_PER_RAREST_TOKEN = 1.5 ether;
    uint256 public constant PRICE_PER_RARER_TOKEN = 0.55 ether;
    uint256 public constant PRICE_PER_RARE_TOKEN = 0.2 ether;
    string public baseURI;

    mapping(uint256 => ProductStatus) public ProductStatusByTokenId;
    mapping(uint => string) public URIS;
  
    enum ProductStatus {not_ready, ready, deployed}
    enum Rarity {rarest, rarer, rare} 

    event returnTokenInfo(uint256 tokenId, string rarity, string tokenURI, ProductStatus);

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

    /**
    * @dev  This function returns the token information 
    *       This includes token id, rarity and URI
    * @param _tokenId is the token Id of the NFT of interest
    */
    function _emitTokenInfo(uint256 _tokenId) internal {
      emit returnTokenInfo(_tokenId, returnRarityByTokenId(_tokenId), URIS[_tokenId], ProductStatusByTokenId[_tokenId]);
    }

    /**
    * @dev  This function returns the token rarity
    * @param _tokenId is the token Id of the NFT of interest
    */
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
            rarestTokenIdCounter.increment();
            tokenId = rarestTokenIdCounter.current();
            require(tokenId <= startRarerTokenIdIndex, "Mycelia NFTs are sold out");
            return tokenId;   
        } else if (rarity == Rarity.rarer) {
            rarerTokenIdCounter.increment();
            tokenId = startRarerTokenIdIndex + rarerTokenIdCounter.current();
            require(tokenId >= startRarerTokenIdIndex && tokenId <= startRareTokenIdIndex, "Diamond NFTS are sold out");
            return tokenId;
        } else {
            rareTokenIdCounter.increment();
            tokenId = startRareTokenIdIndex + rareTokenIdCounter.current();
            require(tokenId <= totalAmountOfTokenIds, "Silver NFTs are sold out");
            return tokenId;
        }
    }

    function _setAndEmitTokenInfo(uint256 tokenId, Rarity rarity) internal {
        _initialProductStatusBasedOnRarity(tokenId, rarity);
        URIS[tokenId] = _URI(tokenId);
        _emitTokenInfo(tokenId);
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
            _setAndEmitTokenInfo(currentTokenId, rarity);
            unchecked {
                i++;
            }  
        }
    }

    /**
    *@dev   This function reduces the amount of tokens left based on 
    *       the amount that is be minted per rarity. 
    *@param amount the amount of tokens minted.
    *@param rarity the rarity of the token minted. 
    */
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

    /**
    *@dev   This function sets the product status based on rarity upon mint. 
    *       rarities rarest and rare will be set to ready.
    *       Minted rarer tokens will be set to not ready.
    *@param tokenId the token Id of the token that is minted
    *@param rarity the rarity of the token that is minted.
    */
    function _initialProductStatusBasedOnRarity(uint256 tokenId, Rarity rarity) internal {
        if (rarity == Rarity.rarest || rarity == Rarity.rare) {
            ProductStatusByTokenId[tokenId] = ProductStatus.ready;
        } else if (rarity == Rarity.rarer) {
            ProductStatusByTokenId[tokenId] = ProductStatus.not_ready;
        }
    }

    /**
    *@dev   This function will switch the status of product deployment. 
    *       If the token has not been deployed the status will be set to ready.
    *       This can only be done for tokens of the Diamond/Rarer rarity.
    *       Information regarding deployment will be retrieved using an API.
    *@param tokenIdList: the array of token Ids that is used to change the 
    *       deployment status of a token launched using the Valorize Token Launcher
    *@param deployed: set to true if a token has been deployed 
    */
    function switchProductStatus(uint256[] memory tokenIdList, bool deployed) public onlyOwner {
        if (deployed) {
            for(uint256 i=0; i < tokenIdList.length; i++) {
            ProductStatusByTokenId[tokenIdList[i]] = ProductStatus.deployed;
            }
        } else {
            for(uint256 i=0; i < tokenIdList.length; i++) {
                require(tokenIdList[i] > startRarerTokenIdIndex && tokenIdList[i] < startRareTokenIdIndex);
                ProductStatusByTokenId[tokenIdList[i]] = ProductStatus.ready;
            }
        }
    }
}
