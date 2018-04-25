const KeyManager = artifacts.require("./KeyManager.sol");
const TransactionRelay = artifacts.require("./TransactionRelay.sol");

module.exports = (deployer) => {
  deployer.deploy(KeyManager);
  deployer.deploy(TransactionRelay);
};
