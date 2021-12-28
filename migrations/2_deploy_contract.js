const StateChannel = artifacts.require('StateChannel');

module.exports = (deployer) => {
    deployer.deploy(StateChannel);
};
