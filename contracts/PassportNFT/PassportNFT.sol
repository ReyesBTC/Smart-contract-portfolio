// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title PassportNFT w/ reward capabilities 
/// @author Christian Reyes ChristianReyesTBC@protonmail.com
/// @notice Soulbound Passport w/ reward capabilities
/// @dev sould bound nft as ERC-721 w/ ERC-1155 rewards.

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Rewards.sol";

contract PassportNFT is ERC721, Ownable {

Rewards private _rewards; // Instance of the Rewards contract so we can call functions from there. 

//Struct 
struct Reward {
  address tokenContract;
  uint256 id;
  uint256 amount;
}

//Mappings 
mapping(address => uint256) public ownerOfPassport;
mapping(uint256 => Reward[]) private passportRewards; //array of rewards struct. 

constructor(address rewardsAddress) ERC721("PassportNFT", "PSPT"){
  _rewards = Rewards(rewardsAddress);  // Create instant for the Rewards contract.
  }

function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
        ownerOfPassport[to] = tokenId;
    }

function addRewardToPassport(uint256 passportId, uint256 rewardId, uint256 rewardAmount) external onlyOwner {
  _rewards.mint(msg.sender, rewardId, rewardAmount, ""); // Mint the reward in the Rewards contract

  _passportRewards[passportId].push(Reward(rewardId, rewardAmount)); // mapping the Add the reward to the passport's list of rewards
    }


}
