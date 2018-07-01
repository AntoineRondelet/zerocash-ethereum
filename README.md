# On-chain privacy

## Design

The architecture comports 5 contracts:
- **KeyStore:** Keeps the public keys of all peers. With these keys peers can encrypt and share secrets with other peers. 
- **Mixer:** Handles deposits of funds, and withdrawals. The Mixer contains a MerkleTree where the commitments are stored, and calls a Verifier to verify the provided proof during a withdrawal.
- **MerkleTree:** Contains the logic to implement a MerkleTree, where the commitments are stored
- **Verifier:** Contains the verification key and is in charge of verifying proofs provided by recipients during a withdrawal
- **Broadcaster:** This contract aims to be the recipient of all "private transactions". After a sender (Alice) has deposited a commitment in the Mixer, she encrypts the secret used to build the commitment with the recipient's public key (available in the KeyStore), and calls the "Broadcast" function of the Broadcaster contract. This "Brodcast" function only emits an event which field is the ciphertext sent by Alice. All nodes of the network listen to the events of the Broadcaster, and try to decrypt all payload of this event to see if they are the recipients of the transaction.

Here are some draws that illustrate the explanation above:

![relay contract](./.github/relayContract.png)
![mixer contract](./.github/mixerContract.png)

## Steps for a Private transactions from Alice to Bob

1. Bob generates a public key and stores it in the KeyStore contract. Thus, every peer of the network can access it, and communicate securely with Bob.
2. Alice fetches the keys of all peers of the network, and keeps her "local keystore" up to date (by listening the different events emitted by the KeyStore contract for instance)
3. If Alice wants to send 1ETH to Bob, here is what happens:
    - She creates and inserts one commitment in the commitment tree of the Mixer. By doing so, she "burns"/pay 1ETH to the Mixer.
    - Alice created the commitment, so she is the only one to know the associated secret.
    - She encrypts the coin secret (hash pre-image for instance) with Bob's public key (off-chain operation)
    - She calls the "Broadcast" function of the Broadcaster.sol contract to broadcast the ciphertext of the secret to all network peers. By doing so, she "protects" her recipient.
    - Bob (and all other network members), listen to the "LogTransaction" event of the "Broadcaster" and tries to decrypt the message.
    - All members but Bob should fail to retrieve the coin secret. Bob is now the "owner" of the coin.
    - Bob can decide to redeem 1ETH in exchange of a ZKPoK of the secret associated with the commitment Alice inserted in the tree. If Bob decides to redeem the coin/withdraw, his balance will be incremented (and an attacker could correlate Alice's balance decrease with Bob's balance increase), OR, Bob can decide to send this secret to another member - Charlie - of the network as part of another "private payment".

**Note:** The idea here is to convert part of the users' balances into some sort of "abstractions" in order to allow transfer of funds without impacting the state everytime (and thus leaking information). Only the exchange of the coins' secrets is settled **encrypted** on-chain. A user in possession of the secret at any time `t` can redeem his funds by providing the secret. This leads to the appropriate state modification (publicly visible).
While peers exchange coin secrets, their balances are not modified, and no one is able to determine the parties involved in the serie of transaction (only the coin creator, who paid to create the coin is known to be involved in a private payment, but after he sent the coin to another member, every following transactions are completely obfuscated).

**Note:** The coins' secrets is settled **encrypted** on-chain. However, one could decide to send it off-chain. The advantage of doing this exchange of secret on-chain through the Broadcaster contract is that. 1) The transaction sending the secret is subject to consensus, 2) In case where we need to keep the blockchain auditable, one could imagine a scenario where parties are compelled to tell their secret keys to a regulator (which gives the power to the regulator to decrypt the payload of all Broadcast events from the Broadcaster, and thus track the flow of funds), 3) No need to have any communication channel between peers to exchange secrets. On the other hand, one major cons of settling the coin's secret **encrypted** on-chain, is that it makes it vulnerable to a quantum attacker (able to break today's crypto)...

## Flaws of the current (naïve) design

1. After Alice has sent the secret to Bob; she still know it, and can basically redeem the 1ETH (stored on the Mixer contract's balance) before Bob or any further recipient on the chain of payment. We need to "bind" the commitment to Bob's identity to prevent malicious senders to redeem the funds and still them for the recipients.
2. This design is **absolutely not secure** against replay attacks. If someone tries to withdraw from the mixer, but the call fails (out of gas for instance), any malicious user could replay the call and steal the funds. This, again, shows the importance to bind the commitment to the recipient, to reject all attempts to redeem the 1ether associated with one commitment. 

## Advantages of this design

-  The cardinality of the anonymity set is the size of the network.

## Cons of this design

-  Overhead due to the fact that all recipients need to try to decrypt all the Broadcast events, to see if they were the recipients of a Tx. 

## TODO

- This about ways to extend the scheme to support arbitary payments value (like in ZeroCash).
- Think about the KeyStore. It could also be possible to use people's public keys (stored on keybase, or anywhere on the internet), to encrypt the secret data to be broadcasted. This, would render the KeyStore useless...

## Generate ECC key-pair to use to secure communication between parties

- Private key generation:
```bash
openssl ecparam -name secp256k1 -genkey -noout -out peer_priv_key.pem
```
- Public key computation from the private key:
```bash
openssl ec -in peer_priv_key.pem -pubout -out peer_pub_key.pem
```

## Play around with the contracts

1. Generate a key-pair for all the peers of the network. We assume, for this example, that we only have 2 peers: Alice and Bob
```bash
# Private keys generation
openssl ecparam -name secp256k1 -genkey -noout -out alice_priv_key.pem
openssl ecparam -name secp256k1 -genkey -noout -out bob_priv_key.pem

# Public key generation
openssl ec -in alice_priv_key.pem -pubout -out alice_pub_key.pem
openssl ec -in bob_priv_key.pem -pubout -out bob_pub_key.pem
```
2. Compute a shared secret between Alice and Bob (ECDH):
```bash
openssl pkeyutl -derive -inkey alice_priv_key.pem -peerkey bob_pub_key.pem -out alice_shared_secret.bin
openssl pkeyutl -derive -inkey bob_priv_key.pem -peerkey alice_pub_key.pem -out bob_shared_secret.bin

# The outputs of the 2 following commands should be equal
base64 alice_shared_secret.bin
base64 bob_shared_secret.bin
```
3. Encrypt the secret to unlock founds on the contract (Here we assume a payment from Alice to Bob):
```bash
echo '[secretData]' > plainSecret.txt
openssl enc -aes256 -base64 -k $(base64 alice_shared_secret.bin) -e -in plainSecret.txt -out cipherSecret.txt

# Send the encrypted data in a transaction to be relayed by the transaction relay contract

# Upon reception of the event from the transaction relay contract, Bob, tries to decipher it to see if he is the recipient of the message:
openssl enc -aes256 -base64 -k $(base64 bob_shared_secret.bin) -d -in cipherSecret.txt -out plainSecret.txt
```
4. If Bob managed to decipher the secret data, then he was the recipient, and now possess the secret the unlock the funds on the coin/commitment manager contract. If he cannot decipher the message, then he was not the recipient of the message, and ignore the transaction.

## Contributing

Every contributions are welcomed. 
Please open a Pull Request for any fix/suggestion you want to submit, and open an issue if you find a flaw or have any improvements in mind.

## Resources

### zk-SNARKs

- https://media.consensys.net/introduction-to-zksnarks-with-examples-3283b554fc3b
- https://github.com/jstoxrocky/zksnarks_example
- https://github.com/zcash-hackworks/babyzoe
- https://github.com/JacobEberhardt/ZoKrates
- https://medium.com/@VitalikButerin/quadratic-arithmetic-programs-from-zero-to-hero-f6d558cea649
- http://zerocash-project.org/media/pdf/zerocash-extended-20140518.pdf

### Solidity - Truffle

- https://medium.com/@gus_tavo_guim/testing-your-smart-contracts-with-javascript-40d4edc2abed
