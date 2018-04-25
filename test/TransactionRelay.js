const TransactionRelay = artifacts.require("./TransactionRelay.sol");

const message = '0x7777777777777';

contract('TransactionRelay', (accounts) => {
    it('Broadcast a message', async () => {
        const account = accounts[0];
        const logTransactionEvent = 'LogTransaction'

        let instance = await TransactionRelay.deployed();

        // Message broadcast should succeed
        let result = await instance.Broadcast(message);
        assert.ok(result.receipt.status, "Couldn't broadcast message");

        // Make sure that the event field is set to the good value
        const transactionEvent = result.logs.find(el => (el.event === logTransactionEvent));

        // TODO: Fix this broken test
        // The values are the same but the assert fails
        assert.equal(transactionEvent.args.cipherTx.toString(), message, "Messages do not match");
    });
});
