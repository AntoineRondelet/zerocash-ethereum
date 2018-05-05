const KeyManager = artifacts.require("./KeyManager.sol");
const TransactionRelay = artifacts.require("./TransactionRelay.sol");
const CoinProvider = artifacts.require("./CoinProvider.sol");
const Verifier = artifacts.require("./verifier.sol");
const Factorize = artifacts.require("./factorize.sol");

module.exports = (deployer) => {
  deployer.deploy(KeyManager);
  deployer.deploy(TransactionRelay);
  deployer.deploy(CoinProvider);
  deployer.deploy(Verifier);
  deployer.deploy(Factorize);
};
