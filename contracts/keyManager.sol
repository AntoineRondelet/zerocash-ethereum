pragma solidity ^0.4.19;

// KeyManager contract keeps a table of the "virtual addresses" of the 
// network nodes on this "network abstraction". These "virtual addresses"
// contain a public key that enables nodes of the network to encrypt data
// for the corresponding recipient, by using their public key.
// A node can update his corresponding public key on the contract, but should
// always keep his private key safe and private in order to be the only one to
// be able to decrypt the data he receives.
contract KeyManager {

    // Note that in out model, a peer is "identified" by an address. Thus anyone creating 
    // N stealth addresses will be considered as N different peers of the network
    // rather than one single user controlling them all (No one should be able to know that the stealth addresses belong to the same real user)
    event LogKeyAdded(
        address peer,
        bytes key
    );
    
    event LogKeyUpdated(
        address peer,
        bytes formerKey,
        bytes newKey
    );
    
    event LogKeyDeleted(
        address peer,
        bytes key
    );

    bytes internal constant NULL_KEY = "0x0x0x0x0";

    // VirtualAddress is the address structure used to do private payments
    struct VirtualAddress {
        bytes publicKey;
        // The virtual address might need to contain other fields (see: in Monero and zCash)
        // To complete if needed ...

        // Field only used to help checking if a key is in the virtualAddresses mapping, because solidity initializes the mappings by default (contains entry for all possible address)
        bool isValue; 
    }

    // Mapping that associates addresses on the Eth network with virtual addresses
    // This mapping allows to retrieve all the data necessary to encrypt a specific Tx
    // for any user of the network. This is a registry where all peers publish
    // their public keys (like if it was an online forum)
    mapping(address => VirtualAddress) internal virtualAddresses; // Could be renamed "KeyRegister" or just "Register" --> To see

    function KeyManager() public {
        // Nothing
    }

    function () public {
        revert();
    }

    // TODO: See if it's better (from a perf perspective) to assign a value with msg.sender
    // in order to always access the sender field of the msg object (optimization ? or it doesn't change anything ?)
    function AddVirtualAddress(bytes pubKey) public {
        // We make sure that no virtual address has been added for this address before
        // If a virtual address for this address has already been declared then
        // we fail, because this would be an UPDATE and NOT an ADD operation.
        require(!virtualAddresses[msg.sender].isValue);

        virtualAddresses[msg.sender] = VirtualAddress({publicKey: pubKey, isValue: true});
        LogKeyAdded(msg.sender, pubKey);
    }
    
    function UpdateVirtualAddress(bytes pubKey) public {
        // We make sure that a virtual address has been added for this address before
        // in order to make sure that this is an UPDATE and NOT an ADD operation.
        require(virtualAddresses[msg.sender].isValue);

        // Get the former public key of the msg.sender in order to use it in the LogKeyUpdated event
        bytes formerPubKey = virtualAddresses[msg.sender].publicKey;

        virtualAddresses[msg.sender] = VirtualAddress({publicKey: pubKey, isValue: true});
        LogKeyUpdated(msg.sender, formerPubKey, pubKey);
    }
    
    function DeleteVirtualAddress(bytes pubKey) public {
        // We make sure that a virtual address has been added for this address before
        // in order to make sure that this is an UPDATE and NOT an ADD operation.
        require(virtualAddresses[msg.sender].isValue);

        // Set the publicKey to this address to the NULL_KEY value, and set the 
        // isValue to false in order to satisfy the require of the AddVirtualAddress function
        // next time this peer we'll call the contract to add his public key to the register
        virtualAddresses[msg.sender] = VirtualAddress({publicKey: pubKey, isValue: false});
        LogKeyDeleted(msg.sender, pubKey);
    }

    // Returns the public key (for encryption of private Tx) of the corresponding address
    // Note that using this function right before doing a payment would leak a lot of information
    // and almost reveal the recipient of the payment. Thus, senders should use this function in response of the 
    // AddVirtualAddress, UpdateVirtualAddress, DeleteVirtualAddress events in order to maintain their local
    // public keys registries up to date at every moment. By doing so, they SHOULD never need to do a call
    // to this function right before doing a payment (a part for special circumstances)
    function GetVirtualAddress(address addr) public returns (bytes) {
        if (!virtualAddresses[msg.sender].isValue) {
            // If the virtualAddress doesn't exist (ie: No pubKey declared for this address)
            // Then we return the null address
            return NULL_KEY;
        }
        return virtualAddresses[msg.sender].publicKey;
    }
}
