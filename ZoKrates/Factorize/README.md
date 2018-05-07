# Use zk-SNARKs to prove the knowledge of the factorization of a number

1. Start ganache-cli: `ganache-cli`
2. Deploy the contracts: `truffle deploy`
3. Compile the contract to get the ABI: echo "var factorizeOutput=`solc --optimize --combined-json abi,bin,interface contracts/factorize.sol`" > factorize.js
4. In geth:
```bash
loadScript('factorize.js')
var factorizeABI = factorizeOutput.contracts['contracts/factorize.sol:Factorize'].abi
var factorizeAddress = [Address of the contract];
var factorizeContract = eth.contract(JSON.parse(factorizeABI));
var factorize = factorizeContract.at(factorizeAddress);

# Event listener
var proofVerificationEvent = factorize.LogProofVerification();
proofVerificationEvent.watch(function(error, result){
    if (error) { console.log(error); return; }
    console.log("LogProofVerification Event");
    console.log("Success: " + result.args.success);
});

# Unlock you account for an unlimited amount of time (Just for a testing purpose!)
personal.unlockAccount(eth.accounts[0], "YourPassword", 0);

# Proof variables (factorization of 33)
var A = ["0x1c6ca76ee9dddc0329277007350dfb97798d2242703a82d89bc32bb38bdf7cc3", "0x3a8c18afa9741645e56b6e3b9435c0ac105f9e3770c58204527b12d5b72f443"]
var A_p = ["0x19bd38fd67cb0c93ffa0a33640509b0418b85aab37f72e35edfa6762fdfbca5a", "0x19844811836155920f10db836141cf40784a4c249b2cb3b433e41494fedbe41"]
var B = [["0x12cf695567d241e839652cfbf376adc698e3ff5a8e5af03fc1fb77ce0340f87d", "0xd62a9ce520ebe2edae9eb0231531b43da2e786623b67eff2d645fd41e30507b"], ["0xbab7e7078c925f82ffea2a6d00fd99eb85d84caa4ad254aadcc33cf6315aad5", "0x22faed4e159cccbb4047f6f56dcf4c675d52385114520be4bc2e537a64c7aba"]]
var B_p = ["0x17c0a5a69173853a72e3690beb1c32387b403092214c34c4836185f51cfde4f", "0x27f647235c38abd60b48ad148a685719f08841c4f4334da509b83c1bcf064f20"]
var C = ["0x69e179ba0d46c76c1682faf71b6e26885bb5407c64142e6c4d68319be19c78e", "0x1868465eb52adaa9cae2f581609e134886c83680fcbc3305d96ad7d92cefd58b"]
var C_p = ["0xe244ef42436ba6b5d2b80aa68ce3968bb3129b603f085ff28a87fb913af46f6", "0x28612d0bedca8762d5b4f0a0a533ac0689caabbd238180a15a1bfbac0faaa919"]
var H = ["0x297d5a36731dac94f622b27b0704c5e6f9288182ba2d63c377a4088faa0b846a", "0x2b0c192fd95afaf5e3a18e16b01fde445d8b9d8337793dcb86e080a278f8ec35"]
var K = ["0x2252d698bd57c1c1163dacdfffb6e17a370a8e2479310d9815fcdfa454d033d2", "0x1257e52acbd1b5e4d6c4e9d96d389e14951217a6c51c397bed5ce5898b05499c"]

# Correct input
I = [33, 1]

# Call the verification:
factorize.verifyFactorize(A, A_p, B, B_p, C, C_p, H, K, I, {from: eth.accounts[0], gas: 2000000})
# Should catch an event saying that the proof is valid

# Incorrect input
I = [21, 1]

# Call the verification:
factorize.verifyFactorize(A, A_p, B, B_p, C, C_p, H, K, I, {from: eth.accounts[0], gas: 2000000})
# Should catch an event saying that the proof is NOT valid

# Proof variables (factorization of 10)
var A = ["0x193897ed1e967774fa0dd47117bc8ae705124a421d42a3e6ee009dee39915cb3", "0xa257db5c2d332c17105ffe423b680cee4c0816129d97b3975ed97594169f693"]
var A_p = ["0xb8877b1a76757892f908eb70d7a0f68ce466591bccc617c66ed3a730af26e68", "0x230cb11f5e720da2a5ae8478b26a57ba0d15a4217886fa0f26236cc5de0e671f"]
var B = [["0x503aeb6535620c48803c332a9d432fcbf63afc48e06619f9e92f5c4de742a6b", "0x1577c53722567e1a91c0298f9af1d73ec1af30b5adb744e121b08226aa3267f2"], ["0x4cbd0251371159c2640972512066dbc8021b547f685270e5eb574f67c36753e", "0x1a033f1715d8fe4fc159ae1265eccb54cfdd2958e4fe41772b1f4cc11a0b1323"]]
var B_p = ["0xee3c7c5f2aedf377bcefd5a1d16236120108025c57f219ff322940d9e78b714", "0x692ddd31541aa370b257c67ee0290671b61202e376b4900343a9f53f43bbf4e"]
var C = ["0x4b43e62e7c086436fbe54d474290a0d50357018c0640a5de79e365fc6c8c3fa", "0x304901b8175f7ff8c0485fd2b69d3cd5926e193179022e8612cbd2cfdd0cca11"]
var C_p = ["0x9f7472d87bf720c68cf9997653c9800a7546f1769cbe7015aec639f4b1c1566", "0x29cc7fd356f0d7ed3ef9c62588489ba9572915ed0c4b72238f3835d36ded0986"]
var H = ["0x2b25a38e035e269c7a265055c713e7b952bcbb34d537d6a9383ea9458f983b25", "0x182aa663a4ea7cd5a73827bb6c918e4d78b9185b9fe45519b706d403ebaea73d"]
var K = ["0x2071c55cdfc68b1aeac89afd596a6159799904755e0d7e6fae31a621f95611f7", "0xbe83d0a30c16b675612f84add7a842896d10555e3ab772be2db76c7088e87d3"]

# Correct input
I = [10, 1]

# Call the verification:
factorize.verifyFactorize(A, A_p, B, B_p, C, C_p, H, K, I, {from: eth.accounts[0], gas: 2000000})
# Should catch an event saying that the proof is valid

# Incorrect input
I = [6, 1]

# Call the verification:
factorize.verifyFactorize(A, A_p, B, B_p, C, C_p, H, K, I, {from: eth.accounts[0], gas: 2000000})
# Should catch an event saying that the proof is NOT valid
```
