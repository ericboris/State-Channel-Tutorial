pragma solidity ^0.5.0;

contract StateChannel {
    address payable public playerOne;
    address payable public playerTwo;
    uint256 public escrowOne;
    uint256 public escrowTwo;

    // Game variables
    uint256 public betOne;
    uint256 public betTwo;
    uint256 public balanceOne;
    uint256 public balanceTwo;
    uint256 public callOne;
    uint256 public callTwo;
    uint256 public finalBalanceOne;
    uint256 public finalBalanceTwo;
    bool public isPlayerOneBalanceSetUp;
    bool public isPlayerTwoBalanceSetUp;

    constructor() public payable {
        require(msg.value > 0, "Must supply funds");

        playerOne = msg.sender;
        escrowOne = msg.value;
    }

    function setupPlayerTwo() public payable  {
        require(msg.sender != playerOne);
        require(msg.value > 0, "Must supply funds");

        playerTwo = msg.sender;
        escrowTwo = msg.value;
    }

    function exitStateChannel(
        bytes memory message,
        uint256 call,
        uint256 bet,
        uint256 balance,
        uint256 nonce,
        uint256 sequence,
        address messageAddress) 
        public 
    {
        require(playerTwo != address(0), "1. Player's address is invalid");
        require(message.length == 65, "2. Message length is invalid");
        require(messageAddress == playerOne || messageAddress == playerTwo, "Invalid messageAddress");

        uint256 escrowToUse = escrowOne;
        if (messageAddress == playerTwo) escrowToUse = escrowTwo;

        // Recreate the signed message for the first player
        // and verify that the parameters are correct.
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", 
                          keccak256(abi.encodePacked(nonce, call, bet, balance, sequence))));
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(message, 32))
            s := mload(add(message, 64))
            v := byte(0, mload(add(message, 96)))
        }

        address originalSigner = ecrecover(message, v, r, s);
        require(originalSigner  == messageAddress, "4. Signer must be original address);

        if (messageAddress == playerOne) {
            balanceOne = balance;
            isPlayerOneBalanceSetUp = true;
            betOne = bet;
            callOne = call;
        } else {
            balanceTwo = balance;
            isPlayerTwoBalanceSetUp = true;
            betTwo = bet;
            callTwo = call;
        }

        if (isPlayerOneBalanceSetUp && isPlayerTwoBalanceSetUp) {
            if (callOne == callTwo) {
                finalBalanceTwo = balanceTwo + betTwo;
                finalBalanceOne = balanceOne - betTwo;
            } else {
                finalBalanceOne = balanceOne + betOne;
                finalBalanceTwo = balanceTwo - betOne;
            }
        }

        playerOne.transfer(finalBalanceOne);
        playerTwo.transfer(finalbalanceTwo);
    }
}
