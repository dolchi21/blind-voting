# blind-voting
Keep votes hidden until everyone is done voting.

## Motivations
- Given a vote already tilted to one side, voters may be discouraged from casting their vote as they think they will not change the course of the vote.
- Voters who want to vote B may end up voting A if the majority votes A.
- <a href="https://en.wikipedia.org/wiki/Bandwagon_effect">Bandwagon effect</a> - the tendency for people to adopt certain behaviors, styles, or attitudes simply because others are doing so.
- <a href="https://en.wikipedia.org/wiki/Asch_conformity_experiments">Asch conformity experiments</a> - a series of studies directed by Solomon Asch studying if and how individuals yielded to or defied a majority group and the effect of such influences on beliefs and opinions.
---
# contracts/Proposal.sol
**constructor(requiredStake, startAt, duration)**
- **requiredStake**: the amount of value required to stake in order to place a vote. This is used as an incentive for the user to reveal their vote in later stages but also to keep them from revealing their choice before the end of the process.
- **startAt**: votes can be placed after this block.
- **duration**: how many blocks each stage

## Stages
The contract has 3 stages:
1. **VoteStage** - Users can call ```placeVote(*voteHash*)``` to submit the ```requiredStake``` and their hashed vote created with ```makeVoteHash(choice, salt)```. After ```n``` blocks defined by the ```duration``` parameter in the constructor this stage ends and no more votes can be submitted.
    - Note that revealing their choice before the **finalized** stage may result in their stake being *stolen*.
2. **RevealStage** - Users can reveal what they (or others) have voted by calling ```revealVote``` with the same parameters used in the ```makeVoteHash/placeVote``` call. By doing so the call will update the result counter and claim the ```requiredStake```. After ```n``` blocks defined by the ```duration``` parameter in the constructor this stage ends and so does the vote.
3. **Finalized** - Users can no longer reveal their vote nor claim their staked value.

---

Pseudo code
```js
const voteHash = await contract.makeVoteHash(true, encodeSecret('mysecret'))
await contract.placeVote(voteHash, { value: requiredStake })
// wait until RevealStage
// reclaim your stake and reveal your choice
await contract.revealVote(address, true, encodeSecret('mysecret'))
// claim another voter's stake and reveal their choice
await contract.revealVote(someoneWhoRevealedTheirVote, false, encodeSecret('theirSecret'))
```