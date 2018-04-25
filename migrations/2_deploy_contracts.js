const KeyManager = artifacts.require("./KeyManager.sol");

module.exports = (deployer) => {
  deployer.deploy(KeyManager);
};
