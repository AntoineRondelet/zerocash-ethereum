const CoinProvider = artifacts.require("./CoinProvider.sol");

const secretHash = "0x17fa14b0d73aa6a26d6b8720c1c84b50984f5c188ee1c113d2361e430f1b6764";
const secretPreImage = 1234;
const denomination = 20000000000000000;

function CreateTestPayableTx(account, value) {
    return { from: account, value: value };
}

function CreateTestNonPayableTx(account) {
    return { from: account };
}

contract('CoinProvider', (accounts) => {
    it('Create a coin', async () => {
        const validTxObj = CreateTestPayableTx(accounts[0], denomination);
        const invalidTxObj = CreateTestPayableTx(accounts[1], 19);
        const accounts0StartingBalance = web3.eth.getBalance(accounts[0]);

        let instance = await CoinProvider.deployed();
        const contractStartingBalance = web3.eth.getBalance(instance.address);

        // The coin creation should work because the denomination is valid
        let result = await instance.createCoin(denomination, secretHash, validTxObj);
        assert.ok(result.receipt.status, "Could not create coin");
        const contractBalance = web3.eth.getBalance(instance.address);
        assert.equal(contractBalance.toString(), contractStartingBalance.add(denomination).toString());
        const accounts0Balance = web3.eth.getBalance(accounts[0]);
        const hasBalanceDiminished = (accounts0StartingBalance > accounts0Balance + denomination);
        // Since accounts[0] get debited after he created a coin, his balance decremented
        // But since he needs to pay some gas fees to do the call on the contract, we do not exactly have balanceBefore = balanceAfter + denomination, so
        // we verify that accounts[0]'s balance has diminished with the hasBalanceDiminished variable
        assert.ok(hasBalanceDiminished, "Bad balance after creating a coin");


        // The coin creation should not work, the denomination does not match the TxObj value
        ok = false;
        result = await instance.createCoin(denomination, secretHash, invalidTxObj).catch(function(err){
            assert.include(err.message, 'revert', 'Denomination and msg.value are not equal');
            ok = true;
        })
        if(!ok) {
            assert.fail("Invalid coin creation, the denomination doesn't match the value");
        }
    });

    it('Claim funds', async () => {
        const validTxObj = CreateTestNonPayableTx(accounts[0]);
        const accounts0StartingBalance = web3.eth.getBalance(accounts[0]);

        let instance = await CoinProvider.deployed();

        // The claimFunds call by accounts[0] should be successful
        let result = await instance.claimFunds(secretPreImage, validTxObj);
        assert.ok(result, "Couldn't redeem funds");
        const accounts0Balance = web3.eth.getBalance(accounts[0]);
        const hasBalanceIncreased = (accounts0Balance > accounts0StartingBalance); 
        // Since accounts[0] get credited after he redeem his funds, his balance increases
        // But since he needs to pay some gas fees to do the call on the contract, we do not exactly have balanceAfter = balanceBefore + denomination, so
        // we verify that accounts[0]'s balance has increased with the hasBalanceIncreased variable
        assert.ok(hasBalanceIncreased, "Incoherent balance after claiming funds");
        
        // The claimFunds call by accounts[1] should fail because his coin creation failed
        ok = false;
        const badPreImage = 222;
        result = await instance.claimFunds(badPreImage, validTxObj).catch(function(err){
            assert.include(err.message, 'revert', 'Coin is not associated with a commitment in the commitList');
            ok = true;
        })
        assert.fail("Trying to redeem funds from a coin that does not exists");
    });
});
