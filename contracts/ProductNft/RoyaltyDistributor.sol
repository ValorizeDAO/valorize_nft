
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RoyaltyDistributor is Ownable {

  event royaltiesDistributed(address royaltyReceivers, uint256 royaltyAmount);

 address[] royaltyReceivers;

  constructor(
    address[] memory _royaltyReceivers 
  ) {
    royaltyReceivers = _royaltyReceivers;
  }
  
  function balanceOfContract() public view returns(uint256) { 
    return address(this).balance;
  }
  
  function receiveRoyalties() external payable {}

  function _setRoyaltyAmount(uint256 artistAmount) internal view returns (uint256 royaltyAmount) {
    royaltyAmount = (balanceOfContract() / artistAmount);
  }

  function royaltyTransfer() external onlyOwner {
    for( uint256 i=0; i < royaltyReceivers.length; i++) {
      payable(royaltyReceivers[i]).transfer(_setRoyaltyAmount(royaltyReceivers.length));
      emit royaltiesDistributed(royaltyReceivers[i], _setRoyaltyAmount(royaltyReceivers.length)); 
    }
  }
}
