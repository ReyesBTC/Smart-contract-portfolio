// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract DigitalVendingMachine {

address public owner; // Variabe holding gthe owner of the contract. 
mapping(address => uint256) public sodaBalances; // This will hold the number of sodas that each address(client) owns. 

    // When 'VendingMachine' contract is deployed:
    // 1. set the deploying address as the owner of the contract
    // 2. set the deployed smart contract's soda balance to 100
constructor(){
    owner = msg.sender;
    //sodaBalances[msg.sender] = 100; This was my original thought, but now I see that we should use address(this) to give the contract itself a balance. 
    sodaBalances[address(this)] += 100; 
}
    // Allow the owner to increase the smart contract's soda balance
function addSodas(uint256 _amount ) public {
    require(owner == msg.sender, "Only owner can call this function");
    // sodaBalances[owner] += _amount;
    sodaBalances[address(this)] += _amount;
}

    // Allow anyone to purchase soda
function purchaseSoda(uint256 _amount) public payable {
    // require(0 < _amount, "You cannot purchase 0 sodas");
    require(msg.value >= _amount * 1 ether, "You must pay at least 1 Ether per soda");
    require(sodaBalances[address(this)] >= _amount, "Not enough sodas to purchase");
    sodaBalances[address(this)] -= _amount; 
    sodaBalances[msg.sender] += _amount; 
}

function checkBalance() public view returns(uint256) {
    return sodaBalances[msg.sender];
}

//Using the address(this) Balance to keep a supply limit is a great way to control the issuence of a coin. But an even better one would be to make an array with "maxSupply" to keep track of the market cap of a given coin as well)
}

// SPDX-License-Identifier: MIT