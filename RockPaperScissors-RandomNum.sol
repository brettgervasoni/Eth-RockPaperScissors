/*
 * Solidity Rock, Paper, Scissors Game
 *
 * This version uses a random number generator.
 *
 * Flow:
 * 1) Call register with 5 wei, frmo two different addresses (player1, player2)
 * 2) Call roll
 * 3) Check lastWinner. 1 = player1, 2 = player2, 0 = house
 *    Winner doubles their money.
 *
 * Based on: https://github.com/SCBuergel/ethereum-rps/blob/master/rps.sol
 * Note, the random number generator is not so random! Dont use for anything
 * other than testing
 */

pragma solidity ^0.4.4;

//not random, but best we can do for testing purposes by the looks of it, 3/18.
contract SolidityRandom {
  uint256 _seed;

  function solidityRandom() public returns (uint256 randomNumber) {
    _seed = uint256(keccak256(
        _seed,
        block.blockhash(block.number - 1),
        block.coinbase,
        block.difficulty,
        block.timestamp
    ));
    return _seed;
  }
  
  function random(uint256 upper) public returns (uint256 randomNumber) {
    return solidityRandom() % upper;
  }
}

contract RockPaperScissors {
    uint public amountRequired = 5; //in wei
    uint public lastWinner = 0;
    
    mapping (string => mapping(string => uint)) playOffMatrix;
    mapping (uint => string) playerChoices;
    
    address public player1;
    address public player2;
    string public player1Choice;
    string public player2Choice;

    /*
     * game
     */

    // constructor
    function RockPaperScissors() public {
        playerChoices[0] = "rock";
        playerChoices[1] = "paper";
        playerChoices[2] = "scissors";
        
        playOffMatrix["rock"]["rock"] = 0;
        playOffMatrix["rock"]["paper"] = 2;
        playOffMatrix["rock"]["scissors"] = 1;
        playOffMatrix["paper"]["rock"] = 1;
        playOffMatrix["paper"]["paper"] = 0;
        playOffMatrix["paper"]["scissors"] = 2;
        playOffMatrix["scissors"]["rock"] = 2;
        playOffMatrix["scissors"]["paper"] = 1;
        playOffMatrix["scissors"]["scissors"] = 0;
    }

    //payable function
    function register() public notAlreadyRegistered() weiRequirement(amountRequired) payable {
        if (player1 == 0)
            player1 = msg.sender;
        else if (player2 == 0)
            player2 = msg.sender;
    }
    
    function getWinner() internal returns (uint) {
        //predictable, but ok for a poc
        //r.random can be 0,1,2
        SolidityRandom r = new SolidityRandom();
        player1Choice = playerChoices[r.random(2)+1];
        player2Choice = playerChoices[r.random(2)+1];
        
        uint winner = playOffMatrix[player1Choice][player2Choice];
        
        return winner;
    }

    //sets lastWinner to whoever the winner is.
    //will revert if player choices are not set.
    function roll() public {
        require(player1 != 0 || player2 != 0);
        
        lastWinner = getWinner();
            
        if (lastWinner == 1)
            player1.transfer(10 wei);
        else if (lastWinner == 2)
            player2.transfer(10 wei);
        else {
            lastWinner = 0; //house wins
        }
        
        //reset game
        player1 = 0;
        player2 = 0;
        player1Choice = "";
        player2Choice = "";
    }

    /*
     * modifiers
     */

    //check user is not already registered for the game
    modifier notAlreadyRegistered() {
        require(msg.sender != player1 || msg.sender != player2);
        _;
    }

    //a fixed amount of Ether is required
    //how to check amount is in wei?
    modifier weiRequirement(uint amount) {
        require(msg.value == amount);
        _;
    }

    /*
     * helpers
     */
    
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
