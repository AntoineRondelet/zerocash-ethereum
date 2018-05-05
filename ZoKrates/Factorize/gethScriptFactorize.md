# Script to test the SNARK verification on Geth

1. Start ganache-cli: `ganache-cli`
2. Deploy the contracts: `truffle deploy`
3. Compile the contract to get the ABI: echo "var factorizeOutput=`solc --optimize --combined-json abi,bin,interface contracts/factorize.sol`" > factorize.js
4. In geth:
```bash
loadScript('factorize.js')
var factorizeABI = factorizeOutput.contracts['contracts/factorize.sol:Factorize'].abi
var factorizeAddress = [addressOfTheContract]
var factorizeContract = eth.contract(JSON.parse(factorizeABI));
var factorize = factorizeContract.at(factorizeAddress);

# Proof variables
var A = ["0xdeec3a5b750054a8affbc8836995608869319b252e5d06f5e9cf481d99b56a9", "0xbfb10712ac88bf299ea58266ebc13b31c653a64c4cd79768ca30ea95d7c2b45"]
var A_p = ["0x78793a51bf35c352b8232213170e81c7fd97ac2c0e2e67441e6870bdf11e624", "0x14f1ac691c55c64519682b037fe1492fb842ec1654a373998da8cfa4e0774954"]
var B = [["0x45fa8dc65a2fe8cc4c5edc7e4003ee2fa37964ea9073a854fc843bdbcb9df79", "0x2b979fe3c5bc8638859452091d6e9dc9c6c727d8c009c5dcb5e184bcc630c265"], ["0x2081313e64d6a458d758ca7055ef945324f1a5a3bd660a7a80723bcf6629a4ac", "0x2608c85be6f552a2055d03d2ea3da14794372181ab96bbcbf8c8470c99d8ae25"]]
var B_p = ["0xa46a81f980932597e0207be47cc3440e8dc66ff05b0bc648ea460a12d4fb989", "0xba0d11233224ac6e9b2ed7b599648d9b0560e85d036a969700e91960d6fb5ab"]
var C = ["0x1d75f0e7acb31c17cb7281ebb913c17be6cc74536f6b57969f9dd6b2cfb2ec65", "0x257b8b8afa17f55dfef89a2753e2cd590e5f035aa8a9374554acaf021a1eda4b"]
var C_p = ["0xc6ae483b7cc7b32d7ad9d9073a98fe54c781c87059dcec8be3f4fa8fe611ab4", "0x17a4b980827dbef3c09a15a44f617f7ce5586c2b1ac2b64c0a395c0d9fee2362"]
var H = ["0x156964d06c99770190e7f933bc9efbb838163a314085309fe0c1e35f6eea673c", "0x1f8eb21a2aaef3c71905fb1901aaa3657636e43350e0207134386f92db69636b"]
var K = ["0x1f340d760339aef43058501a60389484ce92e04d0a3203f5ba1c2177937fca99", "0x106104d7a7a50d48555dff7691d9f0785a7715307a0bbf79b611108b1128edb6"]

var proofVerificationEvent = factorize.LogProofVerification();
proofVerificationEvent.watch(function(error, result){
    if (error) { console.log(error); return; }
    console.log("LogProofVerification Event");
    console.log("Success: " + result.args.success);
});

# Correct input
I = [27, 1]

# Call the verification:
factorize.verifyFactorize(A, A_p, B, B_p, C, C_p, H, K, I, {from: eth.account[0], gas: 2000000})
```


