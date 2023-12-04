// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract Voting {
    // Admin address who manages the election
    address public admin; 
    // Voter structure
    TheVoter[] public TheVotersList;
    mapping(address => TheVoter) public TheVoters;
    
    // representatives structure
    struct TheCand {
      string name;// Name of the rep
      uint256 votes;// Number of votes received by the rep
      bytes32 hash;// Hash of the rep's name
    }
    struct TheVoter {
        string name; // Whos voting
        bool isRegistered;// Flag indicating if the voter is registered
        bool hasVoted;// Flag indicating if the voter has voted
        address TheVoterAddress;// Address of the voter
    }
    TheCand[] public representativesList;// List of rep
    
    // Voting statistics
    uint public allVotesIn; // Total allVotes

    // Constructor, sets the admin address
    constructor ()   {
      admin = msg.sender;
    }
    // Register TheVoter -- only admn can 
    function registerTheVoter(address _TheVoter, string memory _name) external {
        require(msg.sender == admin, "Adminitrator function");
        require(_TheVoter != address(0), "Not a TheVoter add");
        TheVoters[_TheVoter] = TheVoter(_name, true, false, _TheVoter);
        TheVotersList.push(TheVoters[_TheVoter] );
    }

    // TheVoter details  
    function getTheVoterDetails(address _TheVoter) external view returns (string memory) {
        require(TheVoters[_TheVoter].isRegistered, "TheVoter is not in memory");
        return TheVoters[_TheVoter].name;
    }

     // Get all registred TheVoters
    function getTheVotersList() external view returns(TheVoter[] memory){
         return TheVotersList;
    }

    // Check did TheVoter voted
    function CheckIfVoterVoted(address _TheVoter) external view returns (bool) {
        return TheVoters[_TheVoter].hasVoted;
    }
    
    // Put representatives on system --  admin can
    function addTheCand(string memory _name) external {
        require(msg.sender == admin, "Adminitrator function");
        require(bytes(_name).length > 0, "TheCand has to be filled");
        bytes32 hash = keccak256(bytes(_name)); // create a hash for representatives
        representativesList.push(TheCand(_name, 0, hash));
    }

    // Get the names of all reps
    function getTheCands() external view returns (string[] memory) {
        string[] memory representativesNames = new string[](representativesList.length);
        for (uint256 i = 0; i < representativesList.length; i++) {
            representativesNames[i] = representativesList[i].name;
        }
        return representativesNames;
    }

    function getTheCandList() external view returns (TheCand[] memory) {
        return representativesList;
    }
    
    // Cast a vote
    function castBallot(bytes32 _representativesHash) external {
        require(!TheVoters[msg.sender].hasVoted, "TheVoter voted");
        require(TheVoters[msg.sender].isRegistered, "TheVoters function");
        require(representativesExists(_representativesHash), "Not a valid representatives");
          
        allVotesIn++;
        updateTheCandVotes(_representativesHash);
        TheVoters[msg.sender].hasVoted = true;
        
    }
    // Check if a reps exists
    function representativesExists(bytes32 _representativesHash) internal view returns (bool) {
        for (uint256 i = 0; i < representativesList.length; i++) {
            if (representativesList[i].hash == _representativesHash) {
                return true;
            }
        }
        return false;
    }
    // Get the vote count for any one rep
    function checkVotesPerGotRep(bytes32 _representativesHash) external view returns (uint256) {
        require(representativesExists(_representativesHash), "Not valid representatives");
        for (uint256 i = 0; i < representativesList.length; i++) {
            if (representativesList[i].hash == _representativesHash) {
                return representativesList[i].votes;
            }
        }
        return 0;
    }
    // This is for updating the vote count for any one rep
    function updateTheCandVotes(bytes32 _representativesHash) internal {
        for (uint256 i = 0; i < representativesList.length; i++) {
            if (representativesList[i].hash == _representativesHash) {
                representativesList[i].votes++;
                break;
            }
        }
    }
    
    //check who won
    function winnerChecking() external view returns (TheCand memory winner) {
        require(representativesList.length > 0, "No representativess in memory");

        winner = representativesList[0]; 
        uint256 maxVotes = winner.votes;

        for (uint256 i = 1; i < representativesList.length; i++) {
            if (representativesList[i].votes > maxVotes) {
                winner = representativesList[i];
                maxVotes = winner.votes;
            }
        }
    }

    // Get all recieved vote number
    function numberOfTotalVotes() external view returns(uint256){
        return allVotesIn;
    }
}