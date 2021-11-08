// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//TICKET has to be burnable so we use this preset.
//Great docs found at https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#presets
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
//Using ownage to simplify TICKET being a daughter contract of ticketsystem.
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Poster.sol";

contract Ticket is ERC721Burnable, Ownable{

    //Create counter to keep track of how many tickets have been minted.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 startTime;
    Poster poster;

    constructor(string memory name, string memory symbol, uint256 _startTime) ERC721(name, symbol) {
        //setup counter to start at 1 to avoid cluttering the 0th seat ownership
        _tokenIds.increment();
        startTime = _startTime;
        poster = new Poster(name);
    }

    //burn(tokenId) is implemented in this contract as standard. It is public and will only burn if the owner calls it.
    
    //Create public mint function that restricts minting to owner of ticket system.
    //Has to be done because the default _mint() func is private for obvious reasons.
    function mint(address _to) public onlyOwner returns(uint256){
        _safeMint(_to, _tokenIds);
        _tokenIds.increment();
        return _tokenIds;
    }


    //TODO: Improve feedback to function caller. Don't know if return is sufficient

    function verify(uint256 _tokenID) returns(address, bool){
        //Calling built in func in ERC721
        _tokenOwner = ownerOf(_tokenID);
        //Simple check to see if the event takes place in the future or not
        _validity = (block.timestamp < startTime);
        return (_tokenOwner, _validity);
    }

    modifier startSoon() {
        int256 _secondsUntilStart = startTime - block.timestamp;
        uint8 _zero = 0;
        uint8 _hour = 3600;
        //Must be less than an hour.
        require(_secondsUntilStart >= _zero, "Event must be in the future.");
        require(_secondsUntilStart <= _hour, "Event must begin in less than an hour.");
        _;
    }
    
    function validate(uint256 _tokenID) startSoon{
        //Since this is burnable, this should only be callable by token owner. Needs to be tested.
        burn(_tokenID);
        poster.mint(msg.sender, _tokenID);
    }

}

