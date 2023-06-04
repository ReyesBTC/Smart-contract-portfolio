// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.9.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";

contract MyToken is ERC1155, Ownable {
    constructor() ERC1155("") {}
    uint256[] supplies = [50, 100, 150]; // Supply limits for each token.
    uint256[] minted = [0, 0, 0]; // Actual supply of each token. 

    function setURI(string memory newuri) public  {
        _setURI(newuri);
    }

    function mint(uint256 id, uint256 amount, bytes memory data) public { // Delete the onlyOwner modifier because anyone should be able to call the function and pay the predeermined amount of eth to mint this.
        require(id <= supplies.length, "Token doesn't exist"); // Makes sure only the predetermined tokens with preset limits can be minted. 
        require(id != 0, "Token doesn't exist"); // Make sure the 
        uint256 index = id - 1; // Makes sure that ID matches the supply and supply limit indexes. 
        require()

        require(minted[index] + amount <= supplies[index], "Supply limit has been reached"); 
        _mint(msg.sender, id, amount, ""); // Making sure we only mint to the caller of the function. 
        minted[index] += amount; // Making sure that the market cap is adusted to new ciculating supply. 
    } 
}
