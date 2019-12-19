pragma solidity >=0.4.22 <0.6.0;

contract ticketingSystem  {


mapping (uint => Artist) public artistsRegister;  
mapping (uint => Venue) public venuesRegister;  
uint numbersOfArtists = 0; 
uint numberOfVenue=0;

event ArtistCreated(uint artistCategory, string artistName,address artistAddress);



struct Artist { 
        uint artistCategory;
        string name;
        address owner; 
}

struct Venue {
        bytes32 name;
        uint capacity;
        uint standardComission;
        address owner;
}


// Function to create  an Artist
function createArtist(string memory name,uint _artistCategory) public {
Artist memory artist= Artist(_artistCategory,name,msg.sender);
numbersOfArtists++;
artistsRegister[numbersOfArtists]=artist; 
}
//Function to modify the Artist Profile 
function modifyArtist(uint _artistId, string memory _name, uint _artistCategory,address payable owner) public{
require(artistsRegister[_artistId].owner == msg.sender);
artistsRegister[_artistId].artistCategory=_artistCategory;
artistsRegister[_artistId].name= _name;
artistsRegister[_artistId].owner= owner;
}

//Create venue Profile 
function createVenue(bytes32 _name, uint _capacity, uint _standardComission) public {
        Venue memory venue = Venue(_name,_capacity,_standardComission,msg.sender);
        numberOfVenue ++;
        venuesRegister[numberOfVenue]=venue;  
}

//Modify Venue Profile 
function modifyVenue(uint _venueId, bytes32 _name, uint _capacity, uint _standardComission, address payable _newOwner) public{
        require(venuesRegister[_venueId].owner == msg.sender);
        venuesRegister[_venueId].name=_name;
        venuesRegister[_venueId].capacity=_capacity;
        venuesRegister[_venueId].standardComission=_standardComission;
        venuesRegister[_venueId].owner=_newOwner;
}



}