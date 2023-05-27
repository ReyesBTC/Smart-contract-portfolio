// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title PassportNFT w/ reward capabilities 
/// @author Christian Reyes ChristianReyesTBC@protonmail.com
/// @notice Soulbound Passport w/ reward capabilities
/// @dev sould bound nft as ERC-721 w/ ERC-1155 rewards.

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Rewards.sol";

contract PassportNFT is ERC721, Ownable {

Rewards private _rewards; // Instance of the Rewards contract so we can call functions from there. 

//Struct 
// struct Reward {
//   uint256 id;
//   uint256 amount;
// }

using Counters for Counters.Counter;
Counters.Counter private _tokenIds;

//Mappings 
mapping(address => uint256) public ownerOfPassport;
mapping(uint256 => uint256[]) private passportRewards; //array of rewards struct. 

constructor(address rewardsAddress) ERC721("PassportNFT", "PSPT"){
  _rewards = Rewards(rewardsAddress);  // Create instant for the Rewards contract look up how to get that address in there. 
  _tokenIds.increment();
}

function safeMint(address to, uint256 tokenId) public onlyOwner {
  _safeMint(to, tokenId);
  tokenId = _tokenIds.current();
  ownerOfPassport[to] = tokenId;
  _tokenIds.increment();
}

function addRewardToPassport(uint256 passportId, uint256 rewardId, uint256 rewardAmount) external onlyOwner {
  _rewards.mint(msg.sender, rewardId, rewardAmount, ""); // Mint the reward in the Rewards contract
  passportRewards[passportId].push(rewardId, rewardAmount); // mapping the Add the reward to the passport's list of rewards
}

//SoulBound Transfer Functions disabled. 
 function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function approve(
    address approved,
    uint256 _tokenId
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function setApprovalForAll(
    address operator,
    bool allowed
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function getApproved(
    uint256 tokenId
  ) public pure {
    revert Soulbound("SOULBOUND");
  }

  function isApprovedForAll(
    address owner,
    address operator
  ) public pure returns(bool) {
    return false;
  }
}
