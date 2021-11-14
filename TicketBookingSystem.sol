// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Ticket.sol";
import "./Poster.sol";

/*
    General _variable convention is to leave the regular variable names for storage variables
    prefacing with _ is normally used to differentiate the temporary variable from the permanent. 
*/

contract TicketBookingSystem{
    address payable private owner;      // Owner of the event
    uint32 private available_seats;     // Number of available seats in event
    Seat[] private seats;               // Seat list
    Ticket private ticket;              // Ticket smart contract for event

    // Seat struct with all the information needed in a seat according to the specifications.
    struct Seat {                   
        string title;                   // Title of the event
        string seatURL;                 // URL for seat view service.
        uint256 startTime;              // Start time given in epoch timestamp
        uint256 price;                  // Price per seat. For now, all seats cost the same but this can be changed
        uint32 seatRow;                 // Seat row
        uint32 seatNumber;              // Seat number
        uint256 ticketID;               // ID of the ticket that owns the seat. 
    }
    
    constructor(string memory title_, uint256 time_, uint32 available_seats_, uint256 price_, Poster poster_) {
        // Create non-existing seat 0 to store information about the event:
        Seat memory _seat = Seat({
            title: title_,
            seatURL: "hurr.dk",
            startTime: time_,
            price: price_,
            seatRow: 0,
            seatNumber: 0,
            ticketID: 0});

        // Push the zeroth seat to seat list.
        seats.push(_seat);
        
        // Setting the contract variable:
        available_seats = available_seats_;
        owner = payable(tx.origin);
        
        //Initialize a ticket smart contract with the booking system as the owner of the contract.
        ticket = new Ticket(title_, "TCK", seats[0].startTime, poster_);
    }
    
    /*
        Define a modifier for a function that only the seller can call.
        This can be avoided by making the contract inherit "Ownage" like done in Ticket.
    */
    modifier onlyOwner() {
        require( msg.sender == owner , "Only owner can call this.");
        _;
    }
    
    
    /*
        Function to varify that the payment is sufficient to pay for the seat.
        In it's current state, this logic would fail for differently priced seats since price is stored in seat[0]..
    */
    
    modifier paymentValid() {
        require (msg.value >= seats[0].price, "Not enough Ethereum paid");
         _;
   }
    
    /*
        This function is called by the buyer for ticket purchase. The system mints a ticket on behalf of the customer.
        Security checks in order:
            - Check that sufficient ether was paid. (As modifier)
            - Check that there are still free seats.
            - Check that the seat requested is free.
    */
    
    function buy(uint32 _seatRow, uint32 _seatNumber) public payable paymentValid{
        require(seats.length < available_seats, "Event full");
        require(check_available_seats(_seatRow, _seatNumber), "This seat is taken");
        //  Mint a new ticket
        uint256 newTicket = ticket.mint(msg.sender);

        // Create new instance of the seat structure.
        Seat memory _seat = Seat({
            title: seats[0].title,
            seatURL: "google.com",
            startTime: seats[0].startTime,
            price: seats[0].price,
            seatRow: _seatRow,
            seatNumber: _seatNumber,
            ticketID: newTicket});  //  The newly minted ticket is set as the owner of the seat
        
        //Transfer the ether and push seat to seat list
        owner.transfer(_seat.price);
        seats.push(_seat);
    }
    
    /* 
        Refund the tickets. (Only owner of event can refund the tickets)
        Security checks:
            - Only the owner of the contract can refund.
            - Refunding of an empty event is made impossible to restrict double refunding.
    */
    function refund() public onlyOwner{
        require(available_seats > 0, "You can not refund an empty event");
        //  Starts at 1 in order to not refund the "test seat" at [0].
        for(uint32 i=1; i < seats.length; i++){               
            (address payable _to, bool _valid) = ticket.verify(seats[i].ticketID);
            //   Requiring validity means you can't refund expired tickets. This could perhaps be useful?
            require(_valid);
            _to.transfer(seats[i].price);
        }
        //  Set available seats to zero so no further tickets can be bought
        available_seats = 0;
    }
    
    /*
        Helper function to check if a seat is available to buy.
    */
    function check_available_seats(uint32 _seatRow, uint32 _seatNumber) private view returns (bool){
        uint32 _numTakenSeats = uint32(seats.length);
        bool _seatFree = true;
        for(uint32 i=0; i < _numTakenSeats; i++){
            if (seats[i].seatNumber == _seatNumber && seats[i].seatRow == _seatRow){
                _seatFree = false;
            }
        }
        return _seatFree;
    }
    
    /*
        Peer to peer trading from the buyer side is done through this function. 
        When a seller lists their ticket for sale, transfering rights to their token is given to the owner of the system.
        This ensures that once payment has been processed, the token can be transferred immidiately. 
            Security checks in order:
                - The buyer of the token is not the seller of the token.
                - The ticket the buyer is requesting is really for sale.
                - The ticket is not reserved for someone other than the buyer.
                - The buyer has paid a sufficient amount.
                
        The seller side of this trading process is accesed through a function in "ticket" with the same name.
    */
    function tradeTicket(uint256 _tokenID) public payable{
        require( msg.sender != ticket.ownerOf(_tokenID) , "Owner can't buy own token.");
        (uint256 _price, address _reserved, bool _exists) = ticket.getMarketplaceInfo(_tokenID);
        require(_exists, "Token requested is not for sale.");
        require(_reserved == msg.sender || _reserved == ticket.ownerOf(_tokenID), "You don't have permission to buy this token.");
        require (msg.value >= _price, "Not enough Ether paid");

        address payable seller = payable(ticket.ownerOf(_tokenID)); //  Casting address to payable

        //Safe transfer function, will only work if seller has approved transfer for ticket owner which should be this contract.
        ticket.safeTransferFrom(ticket.ownerOf(_tokenID), msg.sender, _tokenID);
        seller.transfer(msg.value);

    }
    function ticketAddress() public view returns(address){
        return ticket.returnAddress();
    }
}
