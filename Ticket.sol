// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/openzeppelin-contracts/contracts/utils/Counters.sol";

contract Ticket is ERC721{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    constructor(uint256 _available_seats) ERC721("Ticket", "TCT"){
        totalSupply_ = _available_seats;
    }
    
    function mint(address _to, uint256 _tokenId) external {
        super._mint(_to, _tokenId);
    }

}

