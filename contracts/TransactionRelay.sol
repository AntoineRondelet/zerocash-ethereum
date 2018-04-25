pragma solidity ^0.4.19;

contract TransactionRelay {

    // LogTransaction broadcasts the encrypted/private transaction the sender wants to do
    // This way the link sender - recipient is never revealed as they never communicate 
    // with each other. The sender encrypts the transaction he wants to send to the recipient
    // by using the recipient's public key, and sends it to the Transaction relay contract.
    // This contract then broadcast the ciphertext of the transaction to the entire network
    // in the form of an event. If the recipient listens to the event, he'll be able 
    // to decipher the ciphertext of the transaction and be aware that he just received a
    // payment from the sender.
    event LogTransaction(
        bytes cipherTx
    );

    // PrivateTx is the structure that represents an encrypted transaction from a sender
    struct PrivateTx {
        bytes ciphertext;
    }

    // This would need to be transformed into a merkle tree of private transactions
    PrivateTx[] txPool;

    function TransactionRelay() public {
        // Nothing
    }

    function () public {
        revert();
    }

    function Broadcast(bytes ciphertext) public {
        // Apppend the privateTx received into the txPool of private transactions
        // This step could be removed (we could just emit an event only)
        // We build ths first approach where we store the history of private Tx on the contract
        // But this could be removed later on (btw, the storage of Tx should done in a Merkle tree)
        // So instead of pushing into an array, we would add a leaf to a merkle tree
        txPool.push(PrivateTx(ciphertext));

        // Broadcast the ciphertext of the private transaction to the network
        // Listeners of this event will be able to check if they are recipients of this Tx
        LogTransaction(ciphertext);
    }
}
