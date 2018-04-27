const KeyManager = artifacts.require("./KeyManager.sol");
const TransactionRelay = artifacts.require("./TransactionRelay.sol");
const CoinProvider = artifacts.require("./CoinProvider.sol");

module.exports = (deployer) => {
  deployer.deploy(KeyManager);
  deployer.deploy(TransactionRelay);
  deployer.deploy(CoinProvider);
};
