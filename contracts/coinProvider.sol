pragma solidity ^0.4.19;

contract CoinProvider {

    struct Coin {
        bytes32 serialNumber;
        bytes32 hashOfSecret;
        uint32 value;
        bool isValid;
    }
    
    mapping(bytes32 => Coin) internal commitList;

    function CoinProvider() public {
        // Nothing
    }

    function () public {
        revert();
    }

    function createCoin(uint32 denomination, bytes32 hashOfSecret) public payable returns (bytes32) {
        bytes32 serialNumber = keccak256(msg.sender, now);
        commitList[serialNumber] = Coin({
            serialNumber: serialNumber, 
            hashOfSecret: hashOfSecret,
            value: denomination,
            isValid: true
        });

        return serialNumber;
    }

    function claimFunds(bytes32 serialNumber, uint256 secretPreImage) returns (bool) {
        require(keccak256(secretPreImage) == commitList[serialNumber].hashOfSecret);
        msg.sender.transfer(commitList[serialNumber].value);
        commitList[serialNumber].isValid = false; // prevent to redeem the same coin multiple times
        return true;
    }

}
