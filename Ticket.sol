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
    mapping(uint256 => saleInfo) public marketplace;

    struct saleInfo{
        uint256 price;
        address buyer; //To enable "selling" for free but only to a predetermined address.
    }

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
        _safeMint(_to, _tokenIds.current());
        _tokenIds.increment();
        return _tokenIds.current();
    }


    //TODO: Improve feedback to function caller. Don't know if return is sufficient

    function verify(uint256 _tokenID) public returns(address, bool){
        //Calling built in func in ERC721
        address _tokenOwner = ownerOf(_tokenID);
        //Simple check to see if the event takes place in the future or not
        bool _validity = (block.timestamp < startTime);
        return (_tokenOwner, _validity);
    }

    modifier startSoon() {
        uint256 _secondsUntilStart = startTime - block.timestamp;
        uint16 _zero = 0;
        uint16 _hour = 3600;
        //Must be less than an hour.
        require(_secondsUntilStart >= _zero, "Event must be in the future.");
        require(_secondsUntilStart <= _hour, "Event must begin in less than an hour.");
        _;
    }
    
    function validate(uint256 _tokenID) public startSoon{
        //Since this is burnable, this should only be callable by token owner. Needs to be tested.
        burn(_tokenID);
        poster.mint(msg.sender, _tokenID);
    }

    //TRADETICKET TO BE CALLED BY SELLER WHEN THEY WANT TO LIST THEIR TICKET FOR SALE

    function tradeTicket(uint256 _tokenID, uint256 _price, address _buyer) public {
        require( msg.sender == ownerOf(_tokenID) , "Only owner can call this.");
        marketplace[_tokenID] = saleInfo({price: _price, buyer: _buyer});
        //Give ticket transfering rights to owner of contract as a "trusted 3rd part."
        approve(owner(), _tokenID);
    }
    
    /*This was meant as a way to list tickets for anyone to buy but how do we handle approval then?
      Let's keep this as a thought process for now
      
    function tradeTicket(uint256 _tokenID, uint256 _price){
        require( msg.sender == ownerOf(_tokenID) , "Only owner can call this.");
        marketplace[_tokenID] = new saleInfo({price: _price, buyer: msg.sender});
    }
    */
}

