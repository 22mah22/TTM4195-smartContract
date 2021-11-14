// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
    TICKET has to be burnable so we use this preset.
    Great docs found at https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#presets
*/
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
//Using ownage to simplify TICKET being a daughter contract of ticketsystem.
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Poster.sol";

contract Ticket is ERC721Burnable, Ownable{

    //  Create counter to keep track of how many tickets have been minted.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    uint64 startTime;                                  //  Start time of event
    Poster poster;                                      //  Poster smart contract
    mapping(uint256 => saleInfo) public marketplace;    //  Mapping for trading tickets   

    struct saleInfo{
        uint128 price;
        address buyer; //   To enable "selling" for free but only to a predetermined address.
        bool exists;
    }

    //  Constructor with start time of event and poster gets created 
    constructor(string memory name, string memory symbol, uint64 _startTime, Poster _poster) ERC721(name, symbol) {
        startTime = _startTime;
        poster = _poster;
    }
    
    /*  
        Create public mint function that restricts minting to owner of ticket system.
        Has to be done because the default _mint() func is private for obvious reasons.
    */
    function mint(address _to) public onlyOwner returns(uint256){
        _tokenIds.increment();
        _safeMint(_to, _tokenIds.current());
        return _tokenIds.current();
    }

    // function to verify ticket 
    function verify(uint256 _tokenID) external view returns(address payable, bool){
        //  Checking if the token exists / if it has been burned.
        if (_exists(_tokenID) != true){
            return (payable(address(this)), false);
        }
        //  ownerOf() will never fail as long as the token exists.
        address _tokenOwner = ownerOf(_tokenID);
        //  Simple check to see if the event takes place in the future or not
        bool _validity = (block.timestamp < startTime);
        return (payable(_tokenOwner), _validity);
    }

    //  Modifier to check if current time is in a specific time interval before the event (here 1 hour before event)
    modifier startSoon() {
        uint256 _secondsUntilStart = startTime - block.timestamp;
        uint16 _zero = 0;
        uint16 _hour = 3600;
        //  Must be less than an hour.
        require(_secondsUntilStart >= _zero, "Event must be in the future.");
        require(_secondsUntilStart <= _hour, "Event must begin in less than an hour.");
        _;
    }
    
    /*  
        Validate ticket and burn it. mint a poster.
        burn(tokenId) is implemented in this contract as standard. It is public and will only burn if the owner calls it.
    */
    function validate(uint256 _tokenID) external startSoon{
        //  Since this is burnable, this should only be callable by token owner.
        burn(_tokenID);
        poster.mint(msg.sender, name());
    }
    
    //  Struct info is not accessible across contracts so this helper function extracts the struct as a tuple
    function getMarketplaceInfo(uint256 ticketID) public view returns (uint128, address, bool ) {
        return (marketplace[ticketID].price, marketplace[ticketID].buyer, marketplace[ticketID].exists);
    }    

    /*  
        Functions that a seller can utilize to list their ticket for sale.
        Checks that the seller is the owner of the token they try to sell.
        Disposes two functions which gives the seller an option to list a specific buyer address. This can be used for selling to friends or similar.
        Gives the owner (the booking system) permission to transfer the users token. 
        
    */
    function tradeTicket(uint256 _tokenID, uint128 _price, address _buyer) external {
        require( msg.sender == ownerOf(_tokenID) , "Only owner can call this.");
        marketplace[_tokenID] = saleInfo({price: _price, buyer: _buyer, exists: true});
        //  Give ticket transfering rights to owner of contract as a "trusted 3rd part."
        approve(owner(), _tokenID);
    }
    
    // Trade ticket when seller only wants to sell it but not to a specific person
    function tradeTicket(uint256 _tokenID, uint128 _price) external {
        require( msg.sender == ownerOf(_tokenID) , "Only owner can call this.");
        //  If no reserved buyer is given, the "reserved" address is set to the sellers own which is used for a check when buying.
        marketplace[_tokenID] = saleInfo({price: _price, buyer: msg.sender, exists: true});
        //  Give ticket transfering rights to owner of contract as a "trusted 3rd part."
        approve(owner(), _tokenID);
    }
    
    function returnAddress() public view returns(address){
        return address(this);
    }
}

