pragma solidity >=0.4.22 <0.6.0;

contract ticketingSystem  {


mapping (uint => Artist) public artistsRegister;  
uint numbersOfArtists = 0; 

event ArtistCreated(uint artistCategory, string artistName,address artistAddress);



struct Artist { 
        uint artistCategory;
        string name;
        address owner; 
}


// Function to create  an Artist
function createArtist(string memory name,uint _artistCategory) public {
Artist memory artist= Artist(_artistCategory,name,msg.sender);
numbersOfArtists++;
artistsRegister[numbersOfArtists]=artist; 
}
//Function to modify the Artist Profile 
function modifyArtist(uint _artistId, string memory _name, uint _artistCategory,address owner) public{
require(artistsRegister[_artistId].owner == msg.sender);
artistsRegister[_artistId].artistCategory=_artistCategory;
artistsRegister[_artistId].name= _name;
artistsRegister[_artistId].owner= owner;
}



}