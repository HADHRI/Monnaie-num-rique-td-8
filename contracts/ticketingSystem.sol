pragma solidity >=0.4.22 <0.6.0;

contract ticketingSystem  {


mapping (uint => Artist) public artistsRegister;  
mapping (uint => Venue) public venuesRegister;  
mapping (uint => Concert) public concertsRegister;
mapping (uint => Ticket) public ticketsRegister;
mapping (string => Ticket) public distributedTicket ; // uniquePromoCode to Ticket 

uint numbersOfArtists = 0; 
uint numberOfVenue=0;
uint numberOfConcerts=0;
uint numberOfTickes=0;
uint totalTicketSold=0;



event ArtistCreated(uint artistCategory, string artistName,address artistAddress);



struct Artist { 
        uint artistCategory;
        string name;
        address payable owner; 
        uint totalTicketSold;
}

struct Venue {
        bytes32 name;
        uint capacity;
        uint standardComission;
        address payable owner;
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
        uint maxOfDisbrutedTickets; //starts from 0 and the max will be 10 
        uint numberOfDistributedTicketsConsumed; 
    
}

struct Ticket{
        uint concertId;
        uint amountPaid;
        bool isAvailable;
        address payable owner;
        bool isAvailableForSale;
        uint salePrice;
        bool distributed ;


}

// Function to create  an Artist
function createArtist(string memory name,uint _artistCategory) public {
Artist memory artist= Artist(_artistCategory,name,msg.sender,0);
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
 //define the max number Of distributed tickets for this concert
 concertsRegister[numberOfConcerts].maxOfDisbrutedTickets= 10;
 concertsRegister[numberOfConcerts].numberOfDistributedTicketsConsumed=0;

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
        Ticket memory ticket=Ticket(_concertId,msg.value,true,msg.sender,false,0,false);
        numberOfTickes++;
        ticketsRegister[numberOfTickes]=ticket;
} 
//Transfer Ticket function
function transferTicket(uint _ticketId, address payable _newOwner) public {
        require(ticketsRegister[_ticketId].owner == msg.sender);
        //Transfering to the new owner 
        ticketsRegister[_ticketId].owner=_newOwner;
} 
function cashOutConcert(uint _concertId, address payable _cashOutAddress) public {
    //Prevent trying to cash out before the start of the concert
    require(concertsRegister[_concertId].concertDate < now);    
    //prevent trying to cash out with another acount
    require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender);
    // venueShare = totalTicketSale * venue1comission / 10000
    uint venueShare = concertsRegister[_concertId].totalMoneyCollected*venuesRegister[concertsRegister[_concertId].venueId].standardComission/10000;
    //artistShare = totalTicketSale - venueShare
   uint artistShare = concertsRegister[_concertId].totalMoneyCollected - venueShare;
   // Share money to venue 
    venuesRegister[concertsRegister[_concertId].venueId].owner.transfer(venueShare);
    //Share money to the artist
    _cashOutAddress.transfer(artistShare);
    //Incrementing ticket Sold 
    artistsRegister[concertsRegister[_concertId].artistId].totalTicketSold += concertsRegister[_concertId].totalSoldTicket;
    //after sharing money , init totalMoneyCollected to 0
     concertsRegister[_concertId].totalMoneyCollected = 0;
}

function offerTicketForSale(uint _ticketId, uint _salePrice) public {
// PreventTrying to sell a ticket that does not belong to me
require(ticketsRegister[_ticketId].owner==msg.sender);
 // Prevent Trying to sell a ticket for more than I paid for it
 require(concertsRegister[ticketsRegister[_ticketId].concertId].ticketPrice > _salePrice );   
//Set ticket to available ticket
 ticketsRegister[_ticketId].isAvailable =true;
 //Ticket is available for sale
ticketsRegister[_ticketId]. isAvailableForSale =true;
//Set the sale Price for the ticket
 ticketsRegister[_ticketId].salePrice = _salePrice;
} 
function buySecondHandTicket(uint _ticketId) public  payable{
  //Prevent Trying to buy the ticket for lower than the proposed price
  require(ticketsRegister[_ticketId].salePrice == msg.value);
  //Prevent trying to buy the ticket even though it was already used
  require( ticketsRegister[_ticketId].isAvailable ==true);
  require( ticketsRegister[_ticketId].isAvailableForSale ==true);
  require(ticketsRegister[_ticketId].owner!=address(0)); 
    ticketsRegister[_ticketId].isAvailableForSale = false;
    ticketsRegister[_ticketId].owner.transfer(msg.value);
    ticketsRegister[_ticketId].owner = msg.sender;
} 
 
function createDistributedTicket(uint _concertId,string memory _promoCode) public {
  require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender); 
  // Number of max tickets Distributed by Concert
  require( concertsRegister[_concertId].maxOfDisbrutedTickets < 10);
  concertsRegister[_concertId].maxOfDisbrutedTickets++;
  // Creating a ticket but not sold 
  numberOfTickes++;
  ticketsRegister[numberOfTickes].concertId=_concertId;
  ticketsRegister[numberOfTickes].isAvailable=true;
  //No owner for the moment 
  ticketsRegister[numberOfTickes].owner=address(0); 
  ticketsRegister[numberOfTickes].distributed=true;   
  // save the distributed Ticket in the mapping ( unique promo Code to Ticket Object )
  distributedTicket[_promoCode]=ticketsRegister[numberOfTickes]; 
}
function reedemDistributedTicket(address payable _toOwner,string memory _promoCode,uint _concertId) public  { 
// check if there's  distributed tickets that are available 
require(  concertsRegister[_concertId].numberOfDistributedTicketsConsumed <  concertsRegister[_concertId].maxOfDisbrutedTickets); 
//check that this  distributed Ticket  exist 
require(distributedTicket[_promoCode].concertId !=0 ); 
require(distributedTicket[_promoCode].distributed==true);
concertsRegister[_concertId].numberOfDistributedTicketsConsumed++; 
// set the owner of the ticket 
distributedTicket[_promoCode].owner= _toOwner;
//Set Distrubuted Ticket to not available 
distributedTicket[_promoCode].distributed=false;
} 
}