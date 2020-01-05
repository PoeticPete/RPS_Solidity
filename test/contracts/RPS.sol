pragma solidity ^0.4.21;


/** @title A contract to compute and return the keccak256 hash of two strings */
contract hash {

    // log event for debugging
    event log(string x);
    
    constructor () public {
        emit log("log this shit");
    }
    
    /**
    * The return type should be bytes32.
    * @return s Rectangle surface
    */
    function get(string x, string y) public pure returns(bytes32) {
        return keccak256(x,y);
    }
}

/** @title Rock Paper Scissors game */
contract RPS {
    
    // the address of player 1
    address p1;
    
    address p2;
    
    // the stake of the game. set by p1
    uint256 stake;
    
    // the hashed value of p1's play (RPS) with a salt
    bytes32 commitment;
    
    // player 2's play
    string private p2_play;
    
    // timestamp of last p1 move (only used for replays)
    uint p1_timestamp;
    
    // timestamp of last p2 move (only used for replays)
    uint p2_timestamp;
    
    // event logging
    event log(address x);
    event log(string x);
    
    /**
     * Constructor that sets creator as player 1
     */
    constructor() public {
        p1 = msg.sender;
        emit log(p1);
    }
    
    /**
     * Player 1 commits their stake in the game. Amount must be strictly greater
     * than 0. Only callable by player 1, who is set in the constructor. 
     * 
     * @param _commitment is the output of a keccak256 hash of “Rock”, “Paper”, 
     * or “Scissors” and a salt value.
     */
    function p1_commit(bytes32 _commitment) public payable {
        
        // only callable by p1
        require(msg.sender == p1);
        
        // amount must be strictly greater than 0
        require(msg.value > 0);
        
        stake = msg.value;
        commitment = _commitment;
        
    }
    
    /**
     * Player 2 joins the game by inputting "Rock", "Paper", or "Scissors"
     * Does nothing if there are already two players
     * Play must be either “Rock”, “Paper”, or “Scissors”
     * Must be at least enough ethereum as the stake of the game
     * Sets player 2 as msg.sender (p2)
     * 
     * @param _play is player 2's choice of Rock, Paper, or Scissors
     */
     
    function p2_join(string _play) external payable {
        
        // Does nothing if there are already two players
        require(p2==address(0));
        
        // Play must be either “Rock”, “Paper”, or “Scissors”
        require(is_valid_play(_play));
        
        // Must be at least enough ethereum as the stake of the game
        require(msg.value >= stake);
        
        // p2 is msg.sender
        p2 = msg.sender;
        
        p2_play = _play;
    }
    
    /**
     * Player 1 reveals their play. 
     * 
     * @param _play is “Rock”, “Paper”, or “Scissors”
     * @param _salt is the original salt used to generate the commitment
     */
    function p1_reveal(string _play, string _salt) external {
        
        // keccak256(_play,_salt) should be equal to the commitment provided 
        // when the contract was created
        require(keccak256(_play,_salt)==commitment);
        
        // called by player 1 only
        require(msg.sender == p1);
        
        // if no other player has joined, cancel the contract, refunding the 
        // stored ether to player 1.
        if (p2==address(0)) {
            selfdestruct(p1);
        }
        
        // After a tie, if player 2 has not moved for as least 30 seconds, 
        // p1 wins
        // 
        if(p2_timestamp != 0 && block.timestamp - p2_timestamp >= 30) {
            emit log("Player 2 has not moved for 30 seconds. P1 wins.");
            selfdestruct(p1);
        }
        
        // Require that p2 has played a move 
        require(!is_equal(p2_play, ""));
        
        // determine the winner
        uint8 winner = get_winner(_play, p2_play);
        if(winner == 0) {
            // tie
            emit log("tie!");
            // reset moves
            commitment = bytes32(0);
            p2_play = "";
            p1_timestamp = block.timestamp;
            p2_timestamp = block.timestamp;
        } else if(winner == 1) {
            // player 1 won
            emit log("p1 won!");
            selfdestruct(p1);
            
        } else {
            // player 2 won
            emit log("p2 won!");
            selfdestruct(p2);
            
            
            
        }
    }
    
    /**
     * if it’s been at least 30 seconds since player 1 has made a move, 
     * kill the contract and send the balance to player 2
     */
    function p2_payout() external {
        if(p1_timestamp != 0 && block.timestamp - p1_timestamp >= 30) {
            selfdestruct(p2);
        }
    }
    
    /**
     * P1 replay move in case of tie
     * 
     * @param _commitment the new hash of p1 move + salt
     */
    function p1_replay(bytes32 _commitment) external {
        // player 1 only
        require(p1 == msg.sender);
        
        // only if player 1 has no valid play stored 
        // (because a tie was declared)
        require(commitment == bytes32(0));
        
        // sets player 1’s commitment to _commitment
        commitment = _commitment;
        
        p1_timestamp = block.timestamp;
        
    }
    
    
    /**
     * p2 replay move in case of tie
     * 
     * @param _play is the new play
     */
    function p2_replay(string _play) external {
        // player 2 only
        require(p2 == msg.sender);
        
        // only if player 2 has no valid play stored (because a tie was declared)
        require(is_equal(p2_play, ""));
        
        // stores play as player 2’s play (should be “Rock”, “Paper”, or “Scissors”)
        require(is_valid_play(_play));
        p2_play = _play;
        
        p2_timestamp = block.timestamp;
    }
    
    
    /**
     * Determines if the play is valid ("Rock", "Paper", or "Scissors")
     * 
     * @return bool
     */
    function is_valid_play(string play) private pure returns(bool) {
        return is_equal(play, "Rock") ||
                is_equal(play, "Paper") ||
                is_equal(play, "Scissors");
    }
    
    /**
     * gets the winner of rock paper Scissors
     * 
     * @param play1 is the play of p1
     * @param play2 is the play of p2
     * 
     * @return uint8 0 means tie, 1 means p1 wins, 2 means p2 wins
     */
    function get_winner(string play1, string play2) private pure returns(uint8) {
        if(is_equal(play1, "Rock")) {
            if(is_equal(play2, "Rock")) {
                return 0;
            } else if(is_equal(play2, "Scissors")) {
                return 1;
            } else {
                return 2;
            }
        } else if(is_equal(play1, "Paper")) {
            if(is_equal(play2, "Rock")) {
                return 1;
            } else if(is_equal(play2, "Scissors")) {
                return 2;
            } else {
                return 0;
            }
        } else {
            // player 1 chose Scissors
            if(is_equal(play2, "Rock")) {
                return 2;
            } else if(is_equal(play2, "Scissors")) {
                return 0;
            } else {
                return 1;
            }
        }
    }

    
    function is_equal(string x, string y) pure private returns(bool) {
        return keccak256(x)==keccak256(y);
    }
    

}