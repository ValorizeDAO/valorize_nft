
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RoyaltyDistributorProductNft is Ownable {

  event royaltiesDistributed(address artist, address valorize, uint256 royaltyAmount);

  address payable artistAddress;
  address payable valorizeAddress;

  constructor(
    address payable _valorizeAddress, 
    address payable _artistAddress
  ) {
    valorizeAddress = _valorizeAddress;
    artistAddress = _artistAddress;
  }
  
  function balanceOfContract() public view returns(uint256) { 
    return address(this).balance;
  }
  
  function receiveRoyalties() external payable {}

  function _setRoyaltyAmount(uint256 amount) internal pure returns (uint256 royaltyAmount) {
    royaltyAmount = (amount / 2);
  }

  function royaltyTransfer(uint256 amount) external onlyOwner {
      artistAddress.transfer(_setRoyaltyAmount(amount));
      valorizeAddress.transfer(_setRoyaltyAmount(amount));
      emit royaltiesDistributed(artistAddress, valorizeAddress, _setRoyaltyAmount(amount));
  }
}
