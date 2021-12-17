// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Proposal {
    uint256 public requiredStake;

    uint256 public startBlock;
    uint256 public votingEndBlock;
    uint256 public revealEndBlock;

    mapping(address => bytes32) promises;
    mapping(address => uint256) votingPower;

    mapping(bool => uint256) options;

    error InvalidVote();
    error RequiredStakeError();
    error RevealAlreadyEnded();
    error RevealNotStartedYet();
    error VotingAlreadyEnded();

    constructor(
        uint256 _requiredStake,
        uint256 _startBlock,
        uint256 ttl
    ) {
        startBlock = _startBlock;
        votingEndBlock = _startBlock + ttl;
        revealEndBlock = votingEndBlock + ttl;
        requiredStake = _requiredStake;
    }

    function makeVoteHash(bool vote, string memory secret)
        public
        pure
        returns (bytes32)
    {
        bytes memory data = abi.encode(vote, secret);
        return keccak256(data);
    }

    function getVotingPower(address addr) public returns (uint256) {
        return 1;
    }

    function placeVote(bytes32 voteHash) external payable {
        if (votingEndBlock < block.number) revert VotingAlreadyEnded();
        if (requiredStake != msg.value) revert RequiredStakeError();
        promises[msg.sender] = voteHash;
        votingPower[msg.sender] = getVotingPower(msg.sender);
    }

    function revealVote(
        address voter,
        bool vote,
        string memory secret
    ) public payable {
        if (block.number < votingEndBlock) revert RevealNotStartedYet();
        if (revealEndBlock < block.number) revert RevealAlreadyEnded();

        bytes32 voteHash = makeVoteHash(vote, secret);
        if (promises[voter] == voteHash) revert InvalidVote();
        options[vote] += votingPower[voter];

        delete promises[voter];

        (bool sent, bytes memory data) = msg.sender.call{value: requiredStake}(
            ""
        );
        require(sent, "Failed to send Ether");
    }
}
