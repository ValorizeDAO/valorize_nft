//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

abstract contract SlowMintable {

    mapping(slowMintType => uint256) tokensLeftToMintPerRarityPerBatch;

    enum slowMintType { rarest, rarer, rare }

    modifier slowMintStatus(slowMintType rarity) {
        require(tokensLeftToMintPerRarityPerBatch[rarity] > 0, "Tokens are sold out for this batch");
        _;
    }
    
    function setTokensToMintPerType(slowMintType rarity, uint256 amount) public {
        tokensLeftToMintPerRarityPerBatch[rarity] = amount;
    }

}