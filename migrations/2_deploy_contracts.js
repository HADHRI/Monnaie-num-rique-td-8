const ticketingSystem = artifacts.require("Ticketing");

module.exports = function(deployer) {
  deployer.deploy(ticketingSystem);
};
