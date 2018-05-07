# Script to test the SNARK verification on Geth

1. Start ganache-cli: `ganache-cli`
2. Deploy the contracts: `truffle deploy`
3. Compile the contract to get the ABI: echo "var sumsToFifteenOutput=`solc --optimize --combined-json abi,bin,interface contracts/SumsToFifteen.sol`" > sumsToFifteen.js
4. In geth:
```bash
loadScript('sumsToFifteen.js')
var sumsToFifteenABI = sumsToFifteenOutput.contracts['contracts/SumsToFifteen.sol:SumsToFifteen'].abi
var sumsToFifteenAddress = "0x728357a61375a6ea36629b09359c66eb973896bc";
var sumsToFifteenContract = eth.contract(JSON.parse(sumsToFifteenABI));
var sumsToFifteen = sumsToFifteenContract.at(sumsToFifteenAddress);

# Proof variables
A = [0x10c00a39dc7747d769eb81232974ce9a229d110c7987a54c07c034c2c6af8350, 0x2a980770191a8331dbf00379797b63d27c1150dbe47bfc69f998e4c005794a4d]
A_p = [0x1623c7fb2136e586f0ef7591b216ea9586ce2cee5a4831147bbbf6f623e9047a, 0x1254c7fb542bd85906eeb8510c4fa5e7f40f88b2bb6fe7127e051eb1e7d6590f]
B = [[0x2b9b93b9e3833c6279a46894f7cb950f9570888776f8125c912b3515294babe, 0x1922b132a198d5e63f106d04f25a626ea351f9c9baba49e9bf4040098d7d61bd], [0x1f70c44cd6414f96fd2ee08fd7ca409ae0ccf53137ba5a3bc93ffdecd51eb35a, 0x1643d2db0ab4d405f6888bd96ae1fa7cb03ac4771e3da173ad43bdca0df85df6]]
B_p = [0x22d92a36476e28555486d2944a4fc1b1e8c36c336b3d0709b9741a5f38e00de3, 0x2c7f1663e80b8c2e3b76a60fcd7c09c72a30c6ce7fc0e347eecc3f5301c6769a]
C = [0x1a7872b0ce466bf4a2240f33baabbe8e73c804861b82c72a7aa654f6a9396f86, 0x2f9e2ebc2c99a0b6ef34c7a113bf285dca62d6b938fe4fde6ff9d40539efd0c7]
C_p = [0x1d275412b73f78096921ccdc423c4a358faa04b9c55195744eae910275006378, 0x2877b1027b093423c7f8a9e670968112d3c33a39960c5a64e9fd75f1672d51b9]
H = [0x142d590c4dc59c9c67104e386f72dcb5660021cdc875e4ca87ce91354cd76d7e, 0xe040b4c5adb5982c32b5917bd9d1a67cf53c0021d10cb13ce0d728d6473b53f]
K = [0xba173680de64db289c41b3e4e9523e543a474fcd5e4af6173fe8373b97afc12, 0x221c658314cf8cafb1e9e148c973637e603571833e5e1c6624992109710f1d0]

var resultEvent = sumsToFifteen.LogResult();
resultEvent.watch(function(error, result){
    if (error) { console.log(error); return; }
    console.log("Result proof Event");
    console.log("Success: " + result.args.res);
});

# Correct input
I = [27, 1]

# Call the verification:
sumsToFifteen.verifyFifteen(A, A_p, B, B_p, C, C_p, H, K, I, {from: eth.accounts[0], gas: 2000000})
```
