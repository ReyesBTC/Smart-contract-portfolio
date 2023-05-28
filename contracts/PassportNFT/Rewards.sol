// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PassportNFT.sol";

contract Rewards is ERC1155, Ownable {
  
PassportNFT private _passportNFT;

constructor(address passportNFTAddress) ERC1155("") {
      _passportNFT = PassportNFT(passportnftAddress);
}

enum Country { USA, Canada, Mexico, UK, Germany, France, Japan, Australia, Brazil, SouthAfrica }

function mintAndSendReward(address to, Country _country, uint256 amount, uint256 passportId) public onlyOwner {
  _mint(address(this), uint256(_country), amount, ""); // Mint the reward to this contract's address
  bytes memory data = abi.encode(passportId); // Encode the passport ID into bytes
  _safeTransferFrom(address(this), to, uint256(_country), amount, data); // Transfer the minted token to the Passport contract
}
}
