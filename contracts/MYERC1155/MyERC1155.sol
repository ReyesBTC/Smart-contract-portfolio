// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.9.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";

contract MyERC1155 is ERC1155, Ownable {
    constructor() ERC1155("") {}
    uint256[] supplies = [50, 100, 150]; // Supply limits for each token.
    uint256[] minted = [0, 0, 0]; // Actual supply of each token. 
    uint256[] rates = [.05 ether, .1 ether, .02 ether];  //Pricing for minting the coins. 

    function setURI(string memory newuri) public onlyOner {
        _setURI(newuri);
    }

    function mint(uint256 id, uint256 amount) public payable { // Delete the onlyOwner modifier because anyone should be able to call the function and pay the predeermined amount of eth to mint this.
        require(id <= supplies.length, "Token doesn't exist"); // Makes sure only the predetermined tokens with preset limits can be minted. 
        require(id > 0, "Token doesn't exist"); // Make sure they dont mind a toke that doesnt exist. 
        uint256 index = id - 1; // Makes sure that ID matches the supply and supply limit array indexes. 

        require(minted[index] + amount <= supplies[index], "Supply limit has been reached"); 
        _mint(msg.sender, id, amount, ""); // Making sure we only mint to the caller of the function. 
        minted[index] += amount; // Making sure that the market cap is adusted to new ciculating supply. 

        require(msg.value >= amount * rates[index], "Insufficient Funds");  
    } 

       function getCirculatingSupply(uint256 tokenId) public view returns(uint256, uint256) {
        uint256 index = tokenId - 1; 
        return (minted[index], supplies[index]);
    }

    function withdraw() public onlyOwner payable{
        require(address(this).balance > 0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
    } 

}
