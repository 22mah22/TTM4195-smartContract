// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Poster is ERC721{
    constructor() ERC721("Poster", "PST"){
        
    }
    
    function mint(address _to, uint256 _tokenId) external {
        super._mint(_to, _tokenId);
        }
}


