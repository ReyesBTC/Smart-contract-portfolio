import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";

describe("MyERC1155 contract", function() {
  let MyERC1155: ContractFactory;
  let myERC1155: Contract;

  // Before is only ran once, and before each is ran before each it statement. 

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    MyERC1155 = await ethers.getContractFactory("MyERC1155");
    myERC1155 = await MyERC1155.deploy();
    await myERC1155.deployed();
  });

  it("It should Set the new URI correctly", async function () {
    const newUri = "https://example.com/metadata/{id}.json";
    await myERC1155.connect(ethers.provider.getSigner(owner)).setURI(newUri); // we wait, then call the contract, then the function 
    const uri = await myERC1155.uri(tokenId);
      expect(uri).to.equal(newUri);
  })
  

});
  
  // function mint(uint256 id, uint256 amount) public payable { // Delete the onlyOwner modifier because anyone should be able to call the function and pay the predeermined amount of eth to mint this.
  //     require(id <= supplies.length, "Token doesn't exist"); // Makes sure only the predetermined tokens with preset limits can be minted. 
  //     require(id > 0, "Token doesn't exist"); // Make sure they dont mind a toke that doesnt exist. 
  //     uint256 index = id - 1; // Makes sure that ID matches the supply and supply limit array indexes. 
  
  //     require(minted[index] + amount <= supplies[index], "Supply limit has been reached"); 
  //     _mint(msg.sender, id, amount, ""); // Making sure we only mint to the caller of the function. 
  //     minted[index] += amount; // Making sure that the market cap is adusted to new ciculating supply. 
  
  //     require(msg.value >= amount * rates[index], "Insufficient Funds");  
  // } 
  
  //    function getCirculatingSupply(uint256 tokenId) public view returns(uint256, uint256) {
    //     uint256 index = tokenId - 1; 
    //     return (minted[index], supplies[index]);
    // }
    
    // function withdraw() public onlyOwner payable{
      //     require(address(this).balance > 0, "Balance is 0");
      //     payable(owner()).transfer(address(this).balance);
    // } 

}