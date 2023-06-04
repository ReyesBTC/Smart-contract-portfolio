// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9; 

contract VotingDapp {

address chairperson;
bool electionOpen;
string[] public listOfCandidates;

//Events 
  event PollsOpened();
  event HasVoted(address indexed voter);
  event CandidateAdded(address indexed candidate, string name);
  event ElectionClosed();

//Modifiers 
modifier onlychairperson() {
  require( msg.sender == chairperson, "you need to be the owner."); //Will require that the function caller be the owner of the contract. 
  _;
}

modifier onlyWhenPollOpen() {
  require(electionOpen, "Elections are not currently open"); //Will require that the Elections are open. 
  _;
}

modifier onlyWhenPollClosed() {
  require(electionOpen = false, "Election is open"); //Will require that polls are closed
  _;
}

constructor() {
  chairperson = msg.sender;
  electionOpen = false;
}

//Mappings 
mapping(address => uint256) public votes; //counts votes per address.
mapping(address => bool) public hasVoted; //to make sure voters only cast one vote. 
mapping(address => string) public candidates; //address to names.
mapping(string => bool) private isCandidateNameRegistered; //avoid double registration. 

  function addCandidate(string memory candidateName, address candidateId) public onlychairperson {
    // require(candidates[candidateId] == candidateName, "Candidate has already been registered");
    require(!isCandidateNameRegistered[candidateName], "This name has already been registered as a candidate.");
    listOfCandidates.push(candidateName);
    candidates[candidateId] = candidateName;
    isCandidateNameRegistered[candidateName] = true;
    emit CandidateAdded(candidateId, candidateName);
  }

  function vote(address voteFor) public onlyWhenPollOpen {
    require(hasVoted[msg.sender] = false, "You have already voted");
    votes[voteFor] ++;
  }

  function openElection() public onlyWhenPollClosed {
    require(electionOpen = false, "Election is already open");
    electionOpen = true;
  }

  function closeElection() public onlyWhenPollOpen onlychairperson {
    electionOpen = false;
  }

  function countVotes() public onlyWhenPollOpen {

  }

}