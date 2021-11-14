// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract Poster is ERC721, AccessControlEnumerable, Ownable{
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(string => uint256[]) public eventTracker;
    
    constructor() ERC721("Poster", "PST"){
        //
    }
    
    function approveMinter(address eventOwner) public onlyOwner{
        grantRole(MINTER_ROLE, eventOwner);
    }
    
    modifier canMint(){
        require(hasRole(MINTER_ROLE, _msgSender()));
        _;
    }
    
    function mint(address _to, string memory eventName) external canMint{
        _tokenIds.increment();
        _safeMint(_to, _tokenIds.current());
        eventTracker[eventName].push(_tokenIds.current());
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


