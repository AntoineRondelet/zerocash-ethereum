pragma solidity ^0.4.22;

contract TransactionRelay {
    // LogTransaction broadcasts the encrypted/private transaction the sender wants to do
    // This way the link sender - recipient is never revealed as they never communicate 
    // with each other. The sender encrypts the transaction he wants to send to the recipient
    // by using the recipient's public key, and sends it to the Transaction relay contract.
    // This contract then broadcast the ciphertext of the transaction to the entire network
    // in the form of an event. If the recipient listens to the event, he'll be able 
    // to decipher the ciphertext of the transaction and be aware that he just received a
    // payment from the sender.
    event LogBroadcast(
        bytes cipherTx
    );

    function TransactionRelay() public {
        // Nothing
    }

    function () public {
        revert();
    }

    function Broadcast(bytes ciphertext) public {
        // Broadcast the ciphertext of the private transaction to the network
        // Listeners of this event will be able to check if they are recipients of this Tx
        LogBroadcast(ciphertext);
    }
}
