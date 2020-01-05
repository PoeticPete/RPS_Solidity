pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RPS.sol";

contract test_shit {

  event log(address x);
  event log(string x);

  function test_constructor() public {
    RPS meta = new RPS();

    address expected = 0x0;

    emit log(meta.p1());
    emit log("hello");
    Assert.notEqual(meta.p1(), expected, "test");
  }

}
