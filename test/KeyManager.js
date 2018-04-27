const KeyManager = artifacts.require("./KeyManager.sol");

const publicKey = "0x6261373831366266386630316366656134313431343064653564616532323233"
const newPublicKey = "0x7777773831366266386630316366656134313431343064653564616532377777"

function CreateTestPayableTx(account, value) {
    return { from: account, value: value };
}

function CreateTestNonPayableTx(account) {
    return { from: account };
}

contract('KeyManager', (accounts) => {
    it('Add virtual address', async () => {
        const account = accounts[0];
        const txObj = CreateTestNonPayableTx(account);
        const logKeyAddedEvent = 'LogKeyAdded'

        let instance = await KeyManager.deployed();

        // Key deposit should succeed
        let result = await instance.AddVirtualAddress(publicKey, txObj);
        assert.ok(result.receipt.status, "Public key added to the key store");

        // Make sure that the event fields are set to the good values
        const keyAddedEvent = result.logs.find(el => (el.event === logKeyAddedEvent));
        assert.equal(keyAddedEvent.args.peer.toString(), account, "Accounts do not match");
        assert.equal(keyAddedEvent.args.key.toString(), publicKey, "Keys do not match");
        
        // Key deposit for the same address should fail
        ok = false;
        result = await instance.AddVirtualAddress(publicKey, txObj).catch(function(err){
            assert.include(err.message, 'revert', 'Address already mapped to a public key')
            ok = true;
        })
        if (!ok) {
            assert.fail("This address already has an address in the key store");
        }
    });

    it('Get virtual address', async () => {
        const account = accounts[1]; // We change the account that does the query
        const txObj = CreateTestNonPayableTx(account);

        let instance = await KeyManager.deployed();

        // Virtual address query by accounts[1] should succeed
        let result = await instance.GetVirtualAddress(accounts[0], txObj);
        assert.equal(result, publicKey, "Public key returned do not match the public key added for this user");
    });

    it('Update virtual address', async () => {
        const account = accounts[0];
        const txObj = CreateTestNonPayableTx(account);
        const logKeyUpdatedEvent = 'LogKeyUpdated'
        
        let instance = await KeyManager.deployed();

        // Update address for accounts[0] should succeed, because a key already exists for this user
        let result = await instance.UpdateVirtualAddress(newPublicKey, txObj);
        assert.ok(result.receipt.status, "Fail to update the key of the given account");
        
        // Make sure that the event fields are set to the good values
        const keyUpdatedEvent = result.logs.find(el => (el.event === logKeyUpdatedEvent));
        assert.equal(keyUpdatedEvent.args.peer.toString(), account, "Accounts do not match");
        assert.equal(keyUpdatedEvent.args.formerKey.toString(), publicKey, "Old keys do not match");
        assert.equal(keyUpdatedEvent.args.newKey.toString(), newPublicKey, "New keys do not match");
        
        // Update address for accounts[1] should fail, because a key does not exist for this account
        const erroneousTxObj = CreateTestNonPayableTx(accounts[1]);
        ok = false;;
        result = await instance.UpdateVirtualAddress(newPublicKey, erroneousTxObj).catch(function(err) {
            assert.include(err.message, 'revert', 'Try to update address that is not registered');
            ok = true;
        });
        if (!ok) {
            assert.fail("Public key of accounts[1] cannot be updated because it doesn't exist in the first place");
        }
    });
});
