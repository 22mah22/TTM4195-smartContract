//SPDX-Licence-Identifier: UNLICENCED
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyContract {
    string value;
    
    constructor() {
        value = "myValue";
    }
    
    function get() public view returns(string memory) {
        return value;
    }
    function set(string memory _value) public {
        value = _value;
    }
}

contract MyContractShortened {
    string public value = "myValue";
    //string public constant value = "myValue";   IF WE WANT CONSTANT...?
    
    bool public myBool = true;
    uint8 public num = 8;
    
    function set(string memory _value) public {
        value = _value;
    }
    
    
    //ENUM STUFF
    
    
    enum State { Waiting, Ready, Active};
    //instance:
    State public state;
    
    constructor() public {
        state = State.Waiting;
    }
    
    function activate() public {
        state = State.Active;
    }
    
    function isActive() public view returns(memory bool) {
        return state == State.Active;
    }
   
   
   
   
    //STRUCT STUFF
    
    struct Person{
        string _firstName;
        string _lastName;
    }
    
    Person[] public people;
    //No way to keep track of size so:
    uint8 public personCount = 0;
    
    function incrementCount() internal {
        peopleCount += 1;
    }
    
    function addPerson(string memory _firstName, string memory _lastName) public {
        incrementCount();
        people.push(Person(_firstName, _lastName));
        
    }
    
    
    //DICT STUFF
    
    mapping(uint -> Person) public dict;
    //THis, but inside the function above:
    dict[peopleCount] = dict(peopleCount, _firstName, _lastName);
    
    
    //Modifiers:
    
    address owner;
    //set in constructor for instance
    
    modifier onlyOwner() {
        //global keyword for metadata is msg:
        //this is for the one who called the func
        require(msg.sender == owner);
        //keeps going if true, error if false
        _;
    }
    //NOW THIS WONT RUN UNLESS MODIFIER IS EVALUATED TRUE
     function addPersonWithRestriction(string memory _firstName, string memory _lastName) public onlyOwner {
        incrementCount();
        people.push(Person(_firstName, _lastName));
        
    }
    constructor() public {
        //CAN SET IT TO THE PERSON INSTANCIATING THE SMART CONTRACT HERE :D
        owner = msg.owner;
    }
    
    
    
    
    //TIME STUFF
    uint256 openingtime = 0; //1960 -ettellerannet
    modifier onlyWhenOpen() {
        require(block.timestamp >= openingTime);
        _;
    }
    
}

