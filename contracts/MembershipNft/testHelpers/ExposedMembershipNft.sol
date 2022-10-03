//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../MembershipNft.sol";

/**
@title ExposedMembershipNft
@author Marco Huberts & Javier Gonzalez
@dev    Mock-implementation of a Valorize Membership Non Fungible Token using ERC1155 for testing purposes.
*/

contract ExposedMembershipNft is MembershipNft {
    constructor(
    string memory _URI,
    uint256[] memory _whaleCalls,
    uint256[] memory _sealCalls, 
    uint256[] memory _planktonCalls,
    address[] memory _royaltyDistributorAddresses,
    address[] memory _artistAddresses
    ) MembershipNft(_URI,
    _whaleCalls,
    _sealCalls,
    _planktonCalls,
    _royaltyDistributorAddresses,
    _artistAddresses) {}


    function getRandomNumber(uint256 totalTokenAmount) external view returns (uint256) {
        return _getRandomNumber(totalTokenAmount);
    }

    function mintFromRandomNumber(uint256 randomNumber, MintType mintType) external {
        return _mintFromRandomNumber(randomNumber, mintType);
    }

    function myceliaMint(MintType mintType) external {
        return _myceliaMint(mintType);
    }

    function obsidianMint(MintType mintType) external {
        return _obsidianMint(mintType);
    }

    function diamondMint(MintType mintType) external {
        return _diamondMint(mintType);
    }

    function goldMint(MintType mintType) external {
        return _goldMint(mintType);
    }

    function silverMint() external {
        return _silverMint();
    }
}