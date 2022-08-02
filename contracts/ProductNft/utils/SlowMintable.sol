//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

abstract contract SlowMintable {

    mapping(string => uint16) tokensLeftToMintPerRarityPerBatch;

    modifier slowMintStatus(string memory rarity) {
        require(tokensLeftToMintPerRarityPerBatch[rarity] > 0, "Tokens are sold out for this batch");
        _;
    }
    
    function _setTokensToMintPerType(uint16 amount, string memory rarity) internal returns (uint16) {
        tokensLeftToMintPerRarityPerBatch[rarity] = amount;
        return amount;
    }

}