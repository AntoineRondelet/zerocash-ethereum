pragma solidity ^0.4.19;

contract KeyManager {
    event LogKeyAdded(
        address peer,
        bytes32 key
    );
    
    event LogKeyUpdated(
        address peer,
        bytes32 formerKey,
        bytes32 newKey
    );
    
    event LogKeyDeleted(
        address peer,
        bytes32 key
    );

    struct KeyEntry {
        bytes32 publicKey;
        bool isValue; 
    }
    
    mapping(address => KeyEntry) internal keyRegister;
    bytes32 internal constant NULL_KEY = "0x0";

    function KeyManager() public {
        // Nothing
    }

    function () public {
        revert();
    }

    function AddKey(bytes32 pubKey) public {
        // We make sure that no key has been registered for this address before
        // If a key has already been declared for this address then
        // we fail, because this would be an UPDATE and NOT an ADD operation.
        require(!keyRegister[msg.sender].isValue);

        keyRegister[msg.sender] = KeyEntry({publicKey: pubKey, isValue: true});
        LogKeyAdded(msg.sender, pubKey);
    }
    
    function UpdateKey(bytes32 pubKey) public {
        // We make sure that no key has been added for this address before
        // in order to make sure that this is an UPDATE and NOT an ADD operation.
        require(keyRegister[msg.sender].isValue);

        // Get the former public key of the msg.sender in order to use it in the LogKeyUpdated event
        bytes32 formerPubKey = keyRegister[msg.sender].publicKey;

        keyRegister[msg.sender] = KeyEntry({publicKey: pubKey, isValue: true});
        LogKeyUpdated(msg.sender, formerPubKey, pubKey);
    }
    
    function DeleteKey(bytes32 pubKey) public {
        // We make sure that a key has been added for this address before
        // in order to make sure that this is NOT an UPDATE and NOT a ADD operation.
        require(keyRegister[msg.sender].isValue);

        // Set the publicKey to this address to the NULL_KEY value, and set the 
        // isValue to false in order to satisfy the require of the AddVirtualAddress function
        // next time this peer we'll call the contract to add his public key to the register
        keyRegister[msg.sender] = KeyEntry({publicKey: pubKey, isValue: false});
        LogKeyDeleted(msg.sender, pubKey);
    }

    // Returns the public key (for encryption of private Tx) of the corresponding address
    // Note that using this function right before doing a payment would leak a lot of information
    // and almost reveal the recipient of the payment.
    // AddKey, UpdateKey, DeleteKey trigger events in order to inform all the listeners that the 
    // registry has been updated. By listening to these events a peer of the network SHOULD never call
    // the GetKey function...
    function GetKey(address peer) public constant returns (bytes32) {
        if (!keyRegister[peer].isValue) {
            // If the virtualAddress doesn't exist (ie: No pubKey declared for this address)
            // Then we return the null address
            return NULL_KEY;
        }
        return keyRegister[peer].publicKey;
    }
}
