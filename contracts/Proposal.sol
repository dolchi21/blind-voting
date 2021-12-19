// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Proposal {
    uint256 public requiredStake;

    uint256 public startBlock;
    uint256 public votingEndBlock;
    uint256 public revealEndBlock;

    mapping(address => bytes32) public promises;
    mapping(address => uint256) public votingPower;

    mapping(bool => uint256) public options;

    error InvalidVote();
    error RequiredStakeError();
    error RevealAlreadyEnded();
    error RevealNotStartedYet();
    error VotingAlreadyEnded();

    event VotePlaced(address indexed from, bytes32 indexed voteHash);
    event VoteRevealed(bytes32 indexed voteHash, bool option);

    constructor(
        uint256 _requiredStake,
        uint256 startAt, // start at block N
        uint256 ttl
    ) {
        startBlock = startAt;
        votingEndBlock = block.number + ttl;
        revealEndBlock = votingEndBlock + ttl;
        requiredStake = _requiredStake;
    }

    function encodeSecret(string memory secret) public pure returns (bytes32) {
        return keccak256(abi.encode(secret));
    }

    function makeVoteHash(bool vote, bytes32 secret)
        public
        pure
        returns (bytes32)
    {
        bytes memory data = abi.encode(vote, secret);
        return keccak256(data);
    }

    function placeVote(bytes32 voteHash) external payable {
        if (votingEndBlock < block.number) revert VotingAlreadyEnded();
        if (requiredStake != msg.value) revert RequiredStakeError();
        promises[msg.sender] = voteHash;
        votingPower[msg.sender] = 1;
        emit VotePlaced(msg.sender, voteHash);
    }

    function revealVote(
        address voter,
        bool vote,
        bytes32 secret
    ) public payable {
        if (block.number < votingEndBlock) revert RevealNotStartedYet();
        if (revealEndBlock < block.number) revert RevealAlreadyEnded();

        bytes32 voteHash = makeVoteHash(vote, secret);
        if (promises[voter] != voteHash) revert InvalidVote();
        options[vote] += votingPower[voter];
        delete promises[voter];
        emit VoteRevealed(voteHash, vote);

        (bool sent, ) = msg.sender.call{value: requiredStake}("");
        require(sent, "Failed to send Ether");
    }
}
