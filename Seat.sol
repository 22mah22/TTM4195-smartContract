// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Seat{
    
    // string private _title;
    // string private _date;
    
    // true if seat is for sale
    bool private _available;
    uint private _price;
    string private _seat_number;
    string private _row;
    string private _link_seat_view;
    address private _owner;
    
    constructor(string memory title_, string memory date_, uint price_, string memory seat_number_, string memory row_, string memory link_seat_view_, address payable public memory owner_){
        _available = false;
        _price = price_;
        _seat_number = seat_number_;
        _row = row_;
        _link_seat_view = link_seat_view_;
        _owner = owner_;
    }
    
    modifier isForSale() {
        require( _available == true, "Seat not for sale" );
        _;
    }
    
     modifier costs(uint _price) {
      if (msg.sender >= _price) {
         _;
      }
   }
    
    function changeOwner(string memory address payable address_) public {
        _owner = address_;
    }
    
}
