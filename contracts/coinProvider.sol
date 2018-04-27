pragma solidity ^0.4.19;

contract CoinProvider {
    struct Coin {
        bytes32 hashOfSecret;
        uint256 value;
        bool isValid;
    }
    
    mapping(bytes32 => Coin) internal commitList;

    function CoinProvider() public {
        // Nothing
    }

    function () public {
        revert();
    }

    function createCoin(uint256 denomination, bytes32 hashOfSecret) public payable returns (bool) {
        require(msg.value == denomination);
        commitList[hashOfSecret] = Coin({
            hashOfSecret: hashOfSecret,
            value: denomination,
            isValid: true
        });

        return true;
    }

    function claimFunds(uint256 secretPreImage) public constant returns (bool) {
        bytes32 computedHash = keccak256(secretPreImage);
        require(computedHash == commitList[computedHash].hashOfSecret);
        msg.sender.transfer(commitList[computedHash].value);
        commitList[computedHash].isValid = false; // prevent to redeem the same coin multiple times

        return true;
    }

}
