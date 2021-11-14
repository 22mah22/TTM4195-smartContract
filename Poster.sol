// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

/*
    For the Poster token, we use a preset called Access Control Enumerable.
    This allows us to give several addresses permission to mint tokens. The usecase
    of this is to allow minting posters for different events inside a common contract.
*/

contract Poster is ERC721, AccessControlEnumerable, Ownable{
    //  Addresses with the MINTER_ROLE can mint tokens. This role can be given by admin.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    /*
        We create a mapping to organize which events the different posters are for.
        Each event name is mapped to a list of minted tokens for that event.
    */
    mapping(string => uint256[]) public eventTracker;
    
    //  Constructor sets the factory as the administrator.
    constructor() ERC721("Poster", "PST"){
         _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    
    //  Factory has access to give the different events minting permission through this function.
    function approveMinter(address eventOwner) public onlyOwner{
        grantRole(MINTER_ROLE, eventOwner);
    }
    
    modifier canMint(){
        require(hasRole(MINTER_ROLE, _msgSender()));
        _;
    }
    
    /*
        Minting function mints and maps the minted token to the relevant event name.
    */
    function mint(address _to, string memory eventName) external canMint{
        _tokenIds.increment();
        _safeMint(_to, _tokenIds.current());
        eventTracker[eventName].push(_tokenIds.current());
    }
    
    /*
        When using AccessControlEnumerable, this ERC165 function requires an override. It is not used. 
    */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


