/*
 * Solidity Rock, Paper, Scissors Game
 * 
 * Flow:
 * 1) Call register with 5 wei
 * 2) Call setChoice with string selection, "rock", "paper", "scissors"
 * 2) Call roll
 * 3) Check lastWinner. 1 = player1, 2 = player2, 0 = house
 *    Winner doubles their money.
 *
 * Based on: https://github.com/SCBuergel/ethereum-rps/blob/master/rps.sol
 * Note, player choice variables are always going to be known, even if set to private
 */

pragma solidity ^0.4.4;

contract RockPaperScissors {
    mapping (string => mapping(string => int)) playOffMatrix;
    
    address public player1;
    address public player2;
    string public player1Choice;
    string public player2Choice;
    uint public amountRequired = 5; //in wei
    int public lastWinner = 0;

    /*
     * game
     */

    function RockPaperScissors() public {
        // constructor
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
    
    function setChoice(string choice) public {
        require(player1 == msg.sender || player2 == msg.sender); //players are registered
        
        if (validSelection(choice)) {
            if (msg.sender == player1)
                player1Choice = choice;
            else if (msg.sender == player2)
                player2Choice = choice;
        }
    }

    //sets lastWinner to whoever the winner is.
    //will revert if player choices are not set.
    function roll() public {
        require(bytes(player1Choice).length > 0 && bytes(player2Choice).length > 0); //choices have been set
        
        lastWinner = playOffMatrix[player1Choice][player2Choice];
            
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
        player1Choice = '';
        player2Choice = '';
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

    function validSelection(string choice) internal pure returns (bool) {
        if (stringsEqual(choice, "rock"))
            return true;
        else if (stringsEqual(choice, "paper"))
            return true;
        else if (stringsEqual(choice, "scissors"))
            return true;
        else
            return false;
    }

    //from: https://github.com/ltfschoen/dex/commit/36583c0b64311b6cdc3264c8cc61df989b334317
    function stringsEqual(string memory _a, string memory _b) internal pure returns (bool) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);

        // Compare two strings quickly by length to try to avoid detailed loop comparison
        if (a.length != b.length)
            return false;

        // Compare two strings in detail Bit-by-Bit
        for (uint i = 0; i < a.length; i++)
            if (a[i] != b[i])
                return false;

        // Byte values of string are the same
        return true;
    }
    
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
