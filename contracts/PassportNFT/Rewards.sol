// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Rewards is ERC1155, Ownable {
    constructor() ERC1155("") {}

using Counters for Counters.Counter;
Counters.Counter private _tokenIds;

function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyOwner //how to I make it callable from other function.
{
  _mint(account, id, amount, data);
}

}
