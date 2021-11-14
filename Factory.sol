// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TicketBookingSystem.sol";
import "./Poster.sol";

/*
    Top level factory contract that owner can use to spawn event contracts for future events.
    Links all events to a common instance of the poster smart contract, alowing token ownership in "poster"
    across different events.
*/

contract Factory is Ownable{
    Poster poster;
    TicketBookingSystem[] events;
    
    constructor() {
        poster = new Poster();
    }
    
    /*
        Function to create a new event.
        The ticket associated with an event is given minting permission in the poster smart contract.
        That way, burning of a ticket can be equivalent to minting a poster, which is very useful for us.
    */
    
    function newEvent(string memory _title, uint256 _time, uint32 _available_seats, uint256 _price) public onlyOwner{
        TicketBookingSystem sys = new TicketBookingSystem(_title, _time, _available_seats, _price, poster);
        events.push(sys);
        poster.approveMinter(sys.ticketAddress());
    }
}