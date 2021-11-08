// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// import files
// import "./Seat.sol"; //deprecated
import "@bokkypoobah/BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";
import "./Ticket.sol";

//General _variable convention is to leave the regular variable names for storage variables
// prefacing with _ is normally used to differentiate the temporary variable from the permanent. 

contract TicketBookingSystem{
    address payable private owner;
    uint32 private available_seats;
    Seat[] private seats;
    Ticket private ticket;

    
    struct Seat {
        string title;
        string seatURL;
        uint256 startTime;
        uint256 price;
        uint32 seatRow;
        uint32 seatNumber;
        uint256 ticketID;
    }
    
    constructor(string memory title_, uint256 memory time_, uint32 available_seats_, uint256 price_) {
        //Create non-existing seat 0 to store information about the event:
        Seat memory _seat = Seat({
            title: title_,
            seatURL: "hurrdurr.dk",
            startTime: time_,
            price: price_,
            seatRow: 0,
            seatNumber: 0,
            ticketID: 0});

        seats.push(_seat);
        available_seats = available_seats_;
        owner = msg.sender;
        //Ticket has been set up with ownage so owner address is automatically this smart contract
        ticket = new Ticket(title, "TCK", seats[0].startTime);
    }
    
    // Define a modifier for a function that only the seller can call
    modifier onlyOwner() {
        require( msg.sender == owner , "Only owner can call this.");
        _;
    }
    
    modifier paymentValid() {
        require (msg.value >= price, "Not enough Ethereum paid");
         _;
   }
    
    function buy(uint32 _seatRow, uint32 _seatNumber) public paymentValid{

        //"Require()" will return the money to sender upon evaluating to false which is great
        require(check_available_seats(_seatRow, _seatNumber));
        owner.transfer(seat.price);
        uint256 ticket = tickets.mint(tx.origin);

        Seat memory _seat = Seat({
            title: _title,
            seatURL: "google.com",
            startTime: seats[0].startTime,
            price: seats[0].price,
            seatRow: _seatRow,
            seatNumber: _seatNumber,
            ticketID: ticket});
        
        seats.push(_seat);
    }
    
    function check_available_seats(uint32 _seatRow, uint32 _seatNumber) private returns (bool){
        //Check if seat in seats[] already, if not:
        //Mint TICKET for msg.sender
        //Create seat with owner linked to TICKET

        uint32 _numTakenSeats = seats.length;
        bool _seatFree = true;
        for(uint32 i=0; i < _numTakenSeats; i++){
            if (seats[i].seatNumber == _seatNumber && seats[i].seatRow == _seatRow){
                _seatFree = false;
            }
        }
        return _seatFree;
}
