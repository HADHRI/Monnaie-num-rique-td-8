pragma solidity >=0.4.22 <0.6.0;

contract ticketingSystem  {


mapping (uint => Artist) public artistsRegister;  
mapping (uint => Venue) public venuesRegister;  
mapping (uint => Concert) public concertsRegister;
mapping (uint => Ticket) public ticketsRegister;

uint numbersOfArtists = 0; 
uint numberOfVenue=0;
uint numberOfConcerts=0;
uint numberOfTickes=0;

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

struct Concert{
        uint artistId;
        uint venueId;
        uint concertDate;
        uint ticketPrice;
        bool validatedByVenue;
        bool validatedByArtist;
        uint totalSoldTicket;
        uint totalMoneyCollected;
}

struct Ticket{
        uint concertId;
        uint amountPaid;
        bool isAvailable;
        address owner;
        bool isAvailableForSale;
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

// Creating a concert 
function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _ticketPrice) public {
require(_concertDate >= now);
 numberOfConcerts++;
 concertsRegister[numberOfConcerts].artistId=_artistId;
 concertsRegister[numberOfConcerts].venueId=_venueId;
 concertsRegister[numberOfConcerts].concertDate=_concertDate;
 concertsRegister[numberOfConcerts].ticketPrice=_ticketPrice; 
 validateConcert(numberOfConcerts);
  
}

// Function on order to validate or not concert by the artist and the Venue
function validateConcert(uint _concertId) public {
// Checking if it the right artist
if(artistsRegister[concertsRegister[_concertId].artistId].owner== msg.sender) {
concertsRegister[_concertId].validatedByArtist=true;
        }
// Checking if it is the right venue in order to accept 
if (venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender ){
concertsRegister[_concertId].validatedByVenue=true;
}

}


function  emitTicket(uint _concertId, address payable _ticketOwner) public {
        //Verify that the sender will emit ticket with his ticket 
        require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender);
      concertsRegister[_concertId].totalSoldTicket ++ ;
      numberOfTickes++;
       ticketsRegister[numberOfTickes].concertId=_concertId;
       ticketsRegister[numberOfTickes].isAvailable=true;
        ticketsRegister[numberOfTickes].owner=_ticketOwner; 
}

function useTicket(uint _ticketId) public{      
        //verify that only the owner who can use the ticket 
        require(ticketsRegister[_ticketId].owner == msg.sender);
         //Verify that the date of concert is greater to now 
        require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate > now);
        // Prevent to use the ticket one day before the concert
        require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate < now + 60*60*24);
        // Verify that it'been validate by the Venue
        require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByVenue == true);
        ticketsRegister[_ticketId].isAvailable =false;
        ticketsRegister[_ticketId].owner=address(0); 
}

function buyTicket(uint _concertId) public payable { 
        concertsRegister[_concertId].totalSoldTicket ++;
        concertsRegister[_concertId].totalMoneyCollected +=msg.value;
        // Create the ticket 
        Ticket memory ticket=Ticket(_concertId,msg.value,true,msg.sender,false);
        numberOfTickes++;
        ticketsRegister[numberOfTickes]=ticket;
} 
//Transfer Ticket function
function transferTicket(uint _ticketId, address payable _newOwner) public {
        require(ticketsRegister[_ticketId].owner == msg.sender);
        //Transfering to the new owner 
        ticketsRegister[_ticketId].owner=_newOwner;
}
}