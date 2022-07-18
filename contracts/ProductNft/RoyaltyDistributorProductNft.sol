
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RoyaltyDistributorProductNft is Ownable {

  event royaltiesDistributed(address artist, address valorize, uint256 royaltyAmount);

  address payable artistAddress;
  address payable valorizeAddress;

  constructor(
    address payable _artistAddress,
    address payable _valorizeAddress  
  ) {
    artistAddress = _artistAddress;
    valorizeAddress = _valorizeAddress;
  }
  function balanceOf() public view returns(uint256) { 
    return address(this).balance;
  }

  function royaltyTransfer() external virtual payable onlyOwner{
      uint256 royaltyAmount = (balanceOf() / 2);
      artistAddress.transfer(royaltyAmount);
      valorizeAddress.transfer(royaltyAmount);
      emit royaltiesDistributed(artistAddress, valorizeAddress, royaltyAmount);
  }
}
