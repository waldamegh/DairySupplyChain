var FarmerRole = artifacts.require("./FarmerRole.sol");
var ManufacturerRole = artifacts.require("./ManufacturerRole.sol");
var RetailerRole = artifacts.require("./RetailerRole.sol");
var ConsumerRole = artifacts.require("./ConsumerRole.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");

module.exports = function(deployer) {
  deployer.deploy(FarmerRole);
  deployer.deploy(ManufacturerRole);
  deployer.deploy(RetailerRole);
  deployer.deploy(ConsumerRole);
  deployer.deploy(SupplyChain);
};