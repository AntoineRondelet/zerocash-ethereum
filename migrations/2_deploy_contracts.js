//const KeyManager = artifacts.require("./KeyManager.sol");
//const TransactionRelay = artifacts.require("./TransactionRelay.sol");
//const CoinProvider = artifacts.require("./CoinProvider.sol");
const SumsToFifteenDebug = artifacts.require("./SumsToFifteenDebug.sol");
//const Verifier = artifacts.require("./Verifier.sol");
//const Factorize = artifacts.require("./factorize.sol");

module.exports = (deployer) => {
  //deployer.deploy(KeyManager);
  //deployer.deploy(TransactionRelay);
  //deployer.deploy(CoinProvider);
  //deployer.deploy(Verifier);
  //deployer.deploy(Factorize);
  deployer.deploy(SumsToFifteenDebug);
};
