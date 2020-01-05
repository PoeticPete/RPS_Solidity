var RPS = artifacts.require("./RPS.sol");
var Hash = artifacts.require("./hash");

module.exports = function(deployer) {
  deployer.deploy(RPS);
  deployer.deploy(Hash);
};
