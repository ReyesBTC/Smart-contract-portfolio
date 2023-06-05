// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title PassportNFT w/ reward capabilities 
/// @author Christian Reyes ChristianReyesTBC@protonmail.com
/// @notice Soulbound Passport w/ reward capabilities
/// @dev sould bound nft as ERC-721 w/ ERC-1155 rewards.

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Rewards.sol";

contract PassportNFT is ERC721, Ownable {

address public _rewards; // Instance of the Rewards contract so we can call functions from there. 

using Counters for Counters.Counter;
Counters.Counter private _tokenIds;

//Mappings 
mapping(address => uint256) public ownerOfPassport;
mapping(uint256 => uint256[]) private passportRewards; //array of rewards uints256. 

constructor() ERC721("PassportNFT", "PSPT"){
   // Create instant for the Rewards contract look up how to get that address in there. 
  address owner = msg.sender; 
}

function safeMint(address to) public onlyOwner {
  require(ownerOfPassport[to] <= 0, "Already owns a passport");
  uint256 tokenId = _tokenIds.current(); 
  _safeMint(to, tokenId);
  ownerOfPassport[to] = tokenId;
  _tokenIds.increment();
}

function getRewards(uint256 _passportId) public view returns(uint256[] memory) {
  require(ownerOfPassport[msg.sender] == _passportId, "Access denied");
  return passportRewards[_passportId];
}

function setRewardsAddress(address rewardsAddress) public {
  _rewards = rewardsAddress;
}

function getRewardsOwner(uint256 _passportId) public view onlyOwner returns(uint256[] memory) {
  return passportRewards[_passportId];
}

function onERC1155Received(address operator, address from, uint256 country, uint256 value, bytes memory data) public returns(bytes4) {
    require(from == address(_rewards), "Only accept rewards from Rewards contract"); // Only accept tokens from the Rewards contract
    (uint256 passportId, address contractAddress, uint256 country) = abi.decode(data, (uint256, address, uint256)); // Decode the data to get the passport ID and expect uint256. 
    passportRewards[passportId].push(country); // Map the reward token to the passport
    return this.onERC1155Received.selector; // Return the function selector as per the ERC1155 standard
}

function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) 
    public virtual returns(bytes4) {
    revert("Not supported");
    }

//SoulBound Transfer Functions disabled. 
 function safeTransferFrom(address from, address to, uint256 tokenId) public pure override { 
    revert("SOULBOUND");
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public pure override {
    revert("SOULBOUND");
  }

  function transferFrom(address from, address to, uint256 tokenId) public pure override {
    revert("SOULBOUND");
  }

  function approve(address approved, uint256 _tokenId) public pure override {
    revert("SOULBOUND");
  }

  function setApprovalForAll(address operator, bool allowed) public pure override {
    revert("SOULBOUND");
  }

  function getApproved(uint256 tokenId) public view virtual override returns (address) {
    revert("SOULBOUND");
  }

  function isApprovedForAll(address owner,address operator) public pure override returns(bool) {
    return false;
  }
}
