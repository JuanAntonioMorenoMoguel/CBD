// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Voting {
    struct Election {
        string name;
        string[] options;
        mapping(string => uint256) votes;
        mapping(address => bool) hasVoted;
        bool active;
        address creator;
        uint256 endTime;
        bool isAnonymous;
        uint256 totalVotes;
    }

    mapping(uint256 => Election) private elections;
    uint256 public electionCount;

    event ElectionCreated(uint256 indexed electionId, string name, address indexed creator, uint256 endTime, bool isAnonymous);
    event Voted(uint256 indexed electionId, string option, address indexed voter);
    event ElectionClosed(uint256 indexed electionId);
    event ElectionDeleted(uint256 indexed electionId);

    modifier onlyCreator(uint256 electionId) {
        require(msg.sender == elections[electionId].creator, "Only creator allowed");
        _;
    }

    modifier electionExists(uint256 electionId) {
        require(electionId > 0 && electionId <= electionCount, "Election does not exist");
        _;
    }

    function createElection(string memory name, string[] memory options, uint256 durationInSeconds, bool isAnonymous) public {
        require(options.length > 1, "At least 2 options required");
        electionCount++;
        Election storage e = elections[electionCount];
        e.name = name;
        e.options = options;
        e.active = true;
        e.creator = msg.sender;
        e.endTime = block.timestamp + durationInSeconds;
        e.isAnonymous = isAnonymous;
        e.totalVotes = 0;

        emit ElectionCreated(electionCount, name, msg.sender, e.endTime, isAnonymous);
    }

    function vote(uint256 electionId, string memory option) public electionExists(electionId) {
        Election storage e = elections[electionId];
        require(e.active, "Election is closed");
        require(block.timestamp <= e.endTime, "Election has ended");
        require(!e.hasVoted[msg.sender], "Already voted");

        bool validOption = false;
        for (uint i = 0; i < e.options.length; i++) {
            if (keccak256(bytes(e.options[i])) == keccak256(bytes(option))) {
                validOption = true;
                break;
            }
        }
        require(validOption, "Invalid option");

        e.votes[option]++;
        e.hasVoted[msg.sender] = true;
        e.totalVotes++;

        emit Voted(electionId, option, e.isAnonymous ? address(0) : msg.sender);
    }

    function closeElection(uint256 electionId) public onlyCreator(electionId) electionExists(electionId) {
        Election storage e = elections[electionId];
        require(e.active, "Election already closed");

        e.active = false;
        emit ElectionClosed(electionId);
    }

    function deleteElection(uint256 electionId) public onlyCreator(electionId) electionExists(electionId) {
        Election storage e = elections[electionId];
        require(e.totalVotes == 0, "Election has votes, cannot delete");

        delete elections[electionId];
        emit ElectionDeleted(electionId);
    }

    function getResults(uint256 electionId) public view electionExists(electionId) returns (string[] memory, uint256[] memory) {
        Election storage e = elections[electionId];
        uint256[] memory results = new uint256[](e.options.length);
        for (uint i = 0; i < e.options.length; i++) {
            results[i] = e.votes[e.options[i]];
        }
        return (e.options, results);
    }

    function getWinners(uint256 electionId) public view electionExists(electionId) returns (string[] memory) {
        Election storage e = elections[electionId];
        uint256 maxVotes = 0;
        uint count = 0;

        for (uint i = 0; i < e.options.length; i++) {
            uint votes = e.votes[e.options[i]];
            if (votes > maxVotes) {
                maxVotes = votes;
                count = 1;
            } else if (votes == maxVotes) {
                count++;
            }
        }

        string[] memory winners = new string[](count);
        uint index = 0;
        for (uint i = 0; i < e.options.length; i++) {
            if (e.votes[e.options[i]] == maxVotes) {
                winners[index++] = e.options[i];
            }
        }

        return winners;
    }

    function hasVoted(uint256 electionId, address voter) public view electionExists(electionId) returns (bool) {
        return elections[electionId].hasVoted[voter];
    }

    function getElectionInfo(uint256 electionId) public view electionExists(electionId) returns (
        string memory name,
        string[] memory options,
        bool active,
        address creator,
        uint256 endTime,
        bool isAnonymous,
        uint256 totalVotes
    ) {
        Election storage e = elections[electionId];
        return (e.name, e.options, e.active, e.creator, e.endTime, e.isAnonymous, e.totalVotes);
    }

    function getActiveElections() public view returns (uint256[] memory) {
        uint256[] memory temp = new uint256[](electionCount);
        uint count = 0;
        for (uint256 i = 1; i <= electionCount; i++) {
            if (elections[i].active && block.timestamp <= elections[i].endTime) {
                temp[count++] = i;
            }
        }

        uint256[] memory activeIds = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            activeIds[i] = temp[i];
        }
        return activeIds;
    }

    function getInactiveElections() public view returns (uint256[] memory) {
        uint256[] memory temp = new uint256[](electionCount);
        uint count = 0;
        for (uint256 i = 1; i <= electionCount; i++) {
            if (!elections[i].active || block.timestamp > elections[i].endTime) {
                temp[count++] = i;
            }
        }

        uint256[] memory inactiveIds = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            inactiveIds[i] = temp[i];
        }
        return inactiveIds;
    }

    function changeElectionName(uint256 electionId, string memory newName) public onlyCreator(electionId) electionExists(electionId) {
        require(elections[electionId].totalVotes == 0, "Cannot rename after voting started");
        elections[electionId].name = newName;
    }

    function changeOptionName(uint256 electionId, uint index, string memory newName) public onlyCreator(electionId) electionExists(electionId) {
        require(index < elections[electionId].options.length, "Invalid option index");
        require(elections[electionId].totalVotes == 0, "Cannot change options after voting started");
        elections[electionId].options[index] = newName;
    }
}
