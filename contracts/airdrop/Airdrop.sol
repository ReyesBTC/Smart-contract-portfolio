// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Airdrop is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    //idk how to user this. Look up after. 
    
    address owneR;
    address[] public publicUsers; 
    mapping(address => uint256[]) tokens;

    constructor() ERC721("MyToken", "MTK") {
        owneR = msg.sender;
    }

    // modifier onlyOwner() {
    //   require(owner = msg.sender, "Not Autherized, Bitch!");
    // }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
         tokens[to].push(tokenId); // Add the tokenId to the tokens mapping
    }

    function airDrop(address[] memory) private onlyOwner {
        // for loop w/ .length 
        for (uint i = 0; i < publicUsers.length; i++) {
        // will go through all addresses in array 
           uint256 tokenId = _tokenIdCounter.current();
            _safeMint(publicUsers[i], tokenId);
            tokens[publicUsers[i]].push(tokenId); // Add the tokenId to the tokens mapping
            _tokenIdCounter.increment(); // Increment the tokenId counter
            //_mint(address to, uint256 tokenId) https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721-_safeMint-address-uint256-
            //My function might be minting these tokens out of thin air XD
        }
    }
    function triggerAirDrop() public onlyOwner {
        airDrop(publicUsers);
    }

    function addUser(address _newUser) public {
      publicUsers.push(_newUser);
      // take address and insert into array. 
    }

    function getOwnerOfToken(uint256 tokenId) public view returns (address) {
        return ownerOf(tokenId);

    // function getUserBalance(address _user) public view returns{ 
    //   ownerOf(uint256 tokenId) → address;
    //   // take address and insert into array. 
    } 

    function getBalanceOfAddy(address _user) public view returns (uint256) {
        return balanceOf(_user);
    }
}