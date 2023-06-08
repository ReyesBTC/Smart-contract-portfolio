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
mapping(address => string) public candidateIdToName; //candidateid to names. 
mapping(string => address ) public candidatesNameToId; //names to id. 
mapping(string => bool) private isCandidateNameRegistered; //avoid double registration. 

  function addCandidate(string memory candidateName, address candidateId) public onlychairperson {
    // require(candidates[candidateId] == candidateName, "Candidate has already been registered");
    require(bytes(candidateIdToName[candidateId]).length == 0, "This address has already been registered as a candidate."); // this uses the default value to make sure that address has not been associated with any string yet. This also Eliminates the double register of the same person twice. 
    require(!isCandidateNameRegistered[candidateName], "This name has already been registered as a candidate.");
    listOfCandidates.push(candidateName);
    candidateIdToName[candidateId] = candidateName;
    candidatesNameToId[candidateName] = candidateId;
    isCandidateNameRegistered[candidateName] = true;
    emit CandidateAdded(candidateId, candidateName);
  }

  function getCandidateID(string memory _candidateName) public view returns(address){
    require(candidatesNameToId[_candidateName]!= address(0), "This candidate does not exist");
    return candidatesNameToId[_candidateName];
  }
  //maybe learn how to call one function from another and use the returned values as input to the subsequent function.

  function vote(address voteFor) public onlyWhenPollOpen {
    require(hasVoted[msg.sender] = false, "You have already voted");
    hasVoted[msg.sender] = true;
    votes[voteFor] ++;
  }

  function openElection() public onlyWhenPollClosed {
    require(electionOpen = false, "Election is already open");
    electionOpen = true;
  }

  function closeElection() public onlyWhenPollOpen onlychairperson {
    electionOpen = false;
  }

  // function countVotes() public onlyWhenPollOpen {
  //   for () 

  // }

}