const Proposal = artifacts.require("Proposal");

module.exports = async function (deployer) {
    const requiredStake = web3.utils.toWei('0.001', 'ether')
    const block = await web3.eth.getBlock('latest')
    deployer.deploy(Proposal, requiredStake, block.number, 100);
};
