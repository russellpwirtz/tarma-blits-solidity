// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155Token is ERC1155, Ownable {
    constructor() ERC1155("") {}

    function mint(address recipientAddress, uint256 tokenId) public onlyOwner {
        _mint(recipientAddress, tokenId, 1, "");
    }
}
