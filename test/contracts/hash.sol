pragma solidity ^0.4.21;


/** @title A contract to compute and return the keccak256 hash of two strings */
contract hash {

    // log event for debugging
    event log(string x);

    constructor () public {
        emit log("hash contract created");
    }

    /**
    * The return type should be bytes32.
    * @return s Rectangle surface
    */
    function get(string x, string y) public pure returns(bytes32) {
        return keccak256(x,y);
    }
}
