const StateChannel = artifacts.require('StateChannel');

contract('StateChannel', (accounts) => {
    let stateChannel;

    before(async () => {
        stateChannel = await StateChannel.deployed();
    });

    describe('Initializing contract', async () => {
        let expectedPlayerOne = accounts[0];
        let expectedEscrowOne = web3.utils.toWei('1', 'Ether');

        // Failure: Pass an invalid (< 0) amount of funds
        //await await stateChannel({ from: accounts[0], value: web3.utils.toWei('1', 'Ether') }).should.be.rejected;

        it('Has player one', async () => {
            const playerOne = await stateChannel.playerOne();
            assert.equal(playerOne, expectedPlayerOne, 'Incorrect playerOne assignment');
        });

        it('Has escrow one', async () => {
            const escrowOne = await stateChannel.escrowOne();
            assert.equal(escrowOne, expectedEscrowOne, 'Incorrect escrowOne assignment');
        });
    });
});
