// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PassportNFT.sol";

contract Rewards is ERC1155, Ownable {
  
address public _passportNFT;

constructor(address passportNFTAddress) ERC1155("") {
     _passportNFT = passportNFTAddress; 
}

enum Country { USA, Canada, Mexico, UK, Germany, France, Japan, Australia, Brazil, SouthAfrica }

function mintAndSendReward(address to, Country _country, uint256 amount, uint256 passportId) public onlyOwner {
  bytes memory data = abi.encode(passportId, address(this), _country);
   // Encode the passport ID into bytes. 
  _mint(_passportNFT, uint256(_country), amount, data); // Mint the reward to this contract's address. 
  // _safeTransferFrom(address(this), to, uint256(_country), amount, data); // Transfer the minted token to the Passport contract
  // specific place I need to 
}
} 
