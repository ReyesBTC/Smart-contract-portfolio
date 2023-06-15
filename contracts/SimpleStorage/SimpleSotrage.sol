// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract SimpleStorage {

  string private info = "default"; 

  function addInfo(string memory _info) external {
    info = _info; 
  }

  function getInfo() external view returns(string memory){
    return info;
  }
  
}