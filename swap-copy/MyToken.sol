// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC721, Ownable {
    uint256 private _nextTokenId;

    constructor() ERC721("MyToken", "MTK")
        Ownable(msg.sender)
     {}

     function mint(uint256 quantity) public payable{
        require(msg.value >= quantity * 1 ether, "Not enough ETH");
        require(quantity == 1, "Can't mint more than 1 token");
        uint256 tokenId = _nextTokenId++;
        _mint(msg.sender, tokenId);
     }
}