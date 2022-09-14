//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../ProductNft.sol";

/**
@title ExposedProductNft
@author Marco Huberts & Javier Gonzalez
@dev    Mock-implementation of a Valorize Product Non Fungible Token using ERC1155 for testing purposes.
*/

contract ExposedProductNft is ProductNft {
    constructor(string memory baseURI_,
    address _royaltyDistributorAddress,
    address _artistAddress, 
    uint16 _startRarerTokenIdIndex, 
    uint16 _startRareTokenIdIndex, 
    uint16 _totalAmountOfTokenIds) 
    ProductNft(baseURI_,
    _royaltyDistributorAddress,
    _artistAddress, 
    _startRarerTokenIdIndex, 
    _startRareTokenIdIndex, 
    _totalAmountOfTokenIds) {}
            

    function countBasedOnRarity(Rarity rarity) external returns (uint256) {
        return super._countBasedOnRarity(rarity);
    }

    function initialProductStatusBasedOnRarity(uint256 _tokenId, Rarity rarity) external {
        return _initialProductStatusBasedOnRarity(_tokenId, rarity);
    }

    function permittedAmount(uint16 amount, string memory rarity, uint16 tokensLeft) external view returns (uint256) {
        return _permittedAmount(amount, rarity, tokensLeft);
    }   
}