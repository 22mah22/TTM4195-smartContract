// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// import files
import "./Seat.sol";
import "@bokkypoobah/BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";
import "./Ticket.sol";
import "./Poster.sol";

contract TicketBookingSystem{
    string private _title;
    string private _date;
    uint8 private _available_seats;
    Seat[] private seats;
    Ticket private tickets = Ticket(available_seats_);

    // Should this be in seat?
    // TODO Change seller to better var name
    address payable public seller;
    address payable public buyer;
    
    struct Seat {
        //TODO Seat as a struct and not as own Contract
    }
    
    constructor(string memory title_, string memory date_, uint8 available_seats_) {
        _title = title_;
        _date = date_;
        _available_seats = available_seats_;
        seller = msg.sender;
        for (uint i=0; i < _available_seats; i++){
            Seat storage newStorage = Seat(title_, date_, 10, i, 1, "link")[i];
            seats.push(newStorage);
        }
        
    }
    
    // Define a modifier for a function that only the buyer can call
    modifier onlyBuyer() {
        require( msg.sender == buyer , "Only buyer can call this.");
        _;
    }
    
    // Define a modifier for a function that only the seller can call
    modifier onlySeller() {
        require( msg.sender == seller , "Only seller can call this.");
        _;
    }
    
    modifier paymentValid() {
        require (msg.value >= _price, "not enough Ethereum paid");
         _;
   }
    
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }
    
    // function to buy ticket of the next available seat
    // TODO buy a token TICKET
    function buy() public {
        buyer = msg.sender;
        seat = check_available_seats();
        seller.transfer(seat.price);
        seat.available_ = false;            //perhaps have seat[id] instead of only seat
        
        tickets.mint(buyer, 0); //TODO tokenid as increamtned number
    }
    
    // function for checking the next available seat
    function check_available_seats() private {
        for(i=0; i <= available_seats_; i++){
            if (seats[i].available_) {
                return seats[i];
            } 
        }
        
    }
}
