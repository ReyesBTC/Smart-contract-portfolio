// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9; 

contract VotingDapp {

address chairperson;
bool electionOpen;
address[] public listOfCandidates;

//Events 
  event PollsOpened();
  event CandidateAdded(address indexed candidate, string name); //indexed and emitted so that the front end can then provide names to addresses for the users to choose a candidate accordengly. Will also have an option of verifying on chain through a function to check for themselves. "Never trust, Verify"
  event HasVoted(address indexed voter); 
  event CandidateRecievedVote(address indexed Candidate);
  event ElectionClosed();

//Modifiers 
modifier onlyChairPerson() {
  require( msg.sender == chairperson, "you need to be the owner."); //Will require that the function caller be the owner of the contract. 
  _;
}

modifier onlyWhenPollOpen() {
  require(electionOpen, "Elections are not currently open"); //Will require that the Elections are open. 
  _;
}

modifier onlyWhenPollClosed() {
  require(!electionOpen, "Election is open"); //Will require that polls are closed
  _;
}

constructor() {
  chairperson = msg.sender;
  electionOpen = false;
}

//Mappings 
mapping(address => uint256) public votes; //counts votes per address.
mapping(address => bool) public hasVoted; //to make sure voters only cast one vote. 
mapping(address => string) public candidateIdToName; //candidateid to names. 
mapping(string => address) public candidatesNameToId; //names to id. 
mapping(string => bool) private isCandidateNameRegistered; //avoid double registration. 

  function addCandidate(string memory candidateName, address candidateId) public onlyChairPerson {
    // require(candidates[candidateId] == candidateName, "Candidate has already been registered");
    require(bytes(candidateIdToName[candidateId]).length == 0, "This address has already been registered as a candidate."); // this uses the default value to make sure that address has not been associated with any string yet. This also Eliminates the double register of the same person twice. 
    require(!isCandidateNameRegistered[candidateName], "This name has already been registered as a candidate.");
    listOfCandidates.push(candidateId);
    candidateIdToName[candidateId] = candidateName;
    candidatesNameToId[candidateName] = candidateId;
    isCandidateNameRegistered[candidateName] = true;
    emit CandidateAdded(candidateId, candidateName);
  }

  function getCandidateID(string memory _candidateName) public view returns(address){
    require(candidatesNameToId[_candidateName] != address(0), "This candidate is not on the ballot");
    return candidatesNameToId[_candidateName];
  }

  function vote(address voteFor) public onlyWhenPollOpen {
    require(hasVoted[msg.sender] = false, "You have already voted");
    require(bytes(candidateIdToName[voteFor]).length > 0, "This Candidate Does not on the ballot");
    hasVoted[msg.sender] = true;
    votes[voteFor] ++;
    emit HasVoted(msg.sender); 
    emit CandidateRecievedVote(voteFor);
  }

  function openElection() public onlyWhenPollClosed onlyChairPerson {
    require(!electionOpen, "Election is already open");
    electionOpen = true;
    emit PollsOpened();
  }

  function closeElection() public onlyWhenPollOpen onlyChairPerson {
    require(electionOpen, "Election is already Closed");
    electionOpen = false;
    emit ElectionClosed();
  }

  function determineWinner() public view returns (string memory winner) {
    require(!electionOpen, "Election is still open"); //Make sure the election is over
    uint256 highestVoteCount = 0;
    for (uint i = 0; i < listOfCandidates.length; i++) {
        address candidateAddress = listOfCandidates[i];
        uint256 candidateVoteCount = votes[candidateAddress];
        if (candidateVoteCount > highestVoteCount) {
            highestVoteCount = candidateVoteCount;
            winner = candidateIdToName[candidateAddress];
        }
    }
    require(highestVoteCount > 0, "No votes cast");
    return winner;
  }


//Need to figure out how to count the votes 
  // function countVotes() public onlyWhenPollOpen {
  //   for () 

  // }

}