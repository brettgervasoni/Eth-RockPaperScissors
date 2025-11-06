 * Solidity Rock, Paper, Scissors Game
 *
 * Flow:
 * 1) Call register with 5 wei, from two different addresses (player1, player2)
 * 2) Call roll
 * 3) Check lastWinner. 1 = player1, 2 = player2, 0 = house
 *    Winner doubles their money.
 *
 * Based on: https://github.com/SCBuergel/ethereum-rps/blob/master/rps.sol
 * Note, the random number generator is not so random!
