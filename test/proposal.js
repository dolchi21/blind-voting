const Proposal = artifacts.require("Proposal")

contract("Proposal", function (accounts) {
	let i
	const state = {
		stake: web3.utils.toWei('0.001', 'ether')
	}
	before(async () => {
		i = await Proposal.deployed()
		state.secret = (await i.encodeSecret('secret')).toString()
		state.startBlock = (await i.startBlock()).toString()
		state.votingEndBlock = (await i.votingEndBlock()).toString()
		console.log(state)
	})
	afterEach(async () => {
		state.options = {
			true: (await i.options(true)).toString(),
			false: (await i.options(false)).toString()
		}
		console.log(state)
	})

	it('should make vote hash', async () => {
		const voteHash = await i.makeVoteHash(true, state.secret)
		state.voteHash = voteHash.toString()
	})
	it('should place vote hash', async function () {
		const placedVote = await i.placeVote(state.voteHash, {
			value: state.stake
		})
		state.placedVote = placedVote.tx
	})
	it('should reveal vote', async () => {
		const res = await i.revealVote(accounts[0], true, state.secret)
		state.reveal = res.tx
	})
})
