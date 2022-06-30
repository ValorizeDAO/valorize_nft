//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./ProductNft.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev    Implementation of a Valorize Product Non Fungible Token using ERC721.
*       Key information: the metadata should be ordered. The rarest NFTs should be the lowest tokenIds, then rarer and then rare NFTs.
*/

contract ExposedProductNft is ProductNft {
    constructor(string memory baseURI_, 
    uint16 _startRarerTokenIdIndex, 
    uint16 _startRareTokenIdIndex, 
    uint16 _totalAmountOfTokenIds) 
    ProductNft(baseURI_, 
    _startRarerTokenIdIndex, 
    _startRareTokenIdIndex, 
    _totalAmountOfTokenIds) {}

    function countBasedOnRarity(Rarity rarity) external returns (uint256) {
        return super._countBasedOnRarity(rarity);
    }
}