var Hash = artifacts.require("Hash");
var RPS = artifacts.require("RPS");

contract('Hash', function(accounts) {
  console.log(accounts)
  it("should hash 1 and 2", function() {
    return Hash.deployed().then(function(instance) {
      return instance.get.call("Rock","0");
    }).then(function(result) {
      assert.equal(result.valueOf(), "0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", "hash is incorrect");
    });
  });
});

contract('RPS', function(accounts) {
  it("should call p1_commit with no eth and fail", function() {
    var meta;

    return RPS.deployed().then(function(instance) {
      meta = instance;
      return meta.p1_commit("0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", {value: 0, from: accounts[0]})
    }).then(function(result) {
      assert.fail("p1_commit should fail when value is 0 eth");
    }).catch(function(error) {
      // the test was successful
      // this catch block is needed to prevent an error
    });
  });
  it("should call p1_commit with 1 eth and succeed", function() {
    var meta;

    return RPS.deployed().then(function(instance) {
      meta = instance;
      return meta.p1_commit("0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", {value: 1, from: accounts[0]})
    }).then(function(result) {

    }).catch(function(error) {
      console.log("success");
      assert.fail("p1_commit should succeed when value is 1 eth");

    });
  });
  it("should call p2_join and fail because eth value is 0", function() {
    var meta;

    return RPS.deployed().then(function(instance) {
      meta = instance;
      return meta.p1_commit("0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", {value: 1, from: accounts[0]})
    }).then(function(result) {
      return meta.p2_join("Paper", {value: 0, from: accounts[1]});
    }).then(function(result) {
      assert.fail("p2_join should fail when value is 0 eth");

    }).catch(function(error) {
      // the test succeeded
      // this catch block is needed to prevent an error
    });
  });

  // THIS IS THE TEST CASE!
  it("should call p2_join and succeed because eth value matches", function() {
    var meta;

    return RPS.deployed().then(function(instance) {
      meta = instance;
      return meta.p1_commit("0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", {value: 1, from: accounts[0]})
    }).then(function(result) {
      return meta.p2_join("Paper", {value: 1, from: accounts[1]});
    }).then(function(result) {


    }).catch(function(error) {

      assert.fail("p2_join should succeed when value matches p1's stake");
    });
  });

  it("should call p2_join and succeed because eth value matches", function() {
    var meta;

    return RPS.deployed().then(function(instance) {
      meta = instance;
      return meta.p1_commit("0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", {value: 1, from: accounts[0]})
    }).then(function(result) {
      return meta.p2_join("Paper", {value: 1, from: accounts[1]});
    }).then(function(result) {


    }).catch(function(error) {

      assert.fail("p2_join should succeed when value matches p1's stake");
    });
  });


  it("should not allow p2 to call p1_commit", function() {
    var meta;

    return RPS.deployed().then(function(instance) {
      meta = instance;
      return meta.p1_commit("0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", {value: 1, from: accounts[1]})
    }).then(function(result) {
      assert.fail("p1_commit should not allow p2 to call it");
    }).catch(function(error) {
    });
  });

  it("should allow p1 to call p1_commit", function() {
    var meta;

    return RPS.deployed().then(function(instance) {
      meta = instance;
      return meta.p1_commit("0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", {value: 1, from: accounts[0]})
    }).then(function(result) {

    }).catch(function(error) {
      assert.fail("p1_commit should allow p1 to call it");
    });
  });

  it("should not allow p2 to call p1_reveal", function() {
    var meta;

    return RPS.deployed().then(function(instance) {
      meta = instance;
      return meta.p1_commit("0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", {value: 1, from: accounts[0]});
    }).then(function(result) {
      return meta.p2_join("Paper", {value: 10, from: accounts[1]});
    }).then(function(result) {
      return meta.p1_reveal("Rock", {value: 0, from: accounts[1]});

    }).then(function(result) {
      assert.fail("p1_reveal should fail when called by p2");

    }).catch(function(error) {
      // the test succeeded
      // this catch block is needed to prevent an error
    });
  });


  it("should not allow p2 to call p1_replay", function() {
    var meta;

    return RPS.deployed().then(function(instance) {
      meta = instance;
      return meta.p1_commit("0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", {value: 10, from: accounts[0]});
    }).then(function(result) {
      return meta.p2_join("Paper", {value: 10, from: accounts[1]});
    }).then(function(result) {
      return meta.p1_reveal("Paper", {value: 0, from: accounts[1]});

    }).then(function(result) {
      return meta.p1_replay("0x6639110f8fccad49eab8b75699908040a888a9cdf1aa00741ac0145e9877a00f", {value: 0, from: accounts[1]});

    }).then(function(result) {
      assert.fail("p1_replay should fail when called by p2");

    }).catch(function(error) {
      // the test succeeded
      // this catch block is needed to prevent an error
    });
  });
  // it("should send coin correctly", function() {
  //   var meta;
  //
  //   // Get initial balances of first and second account.
  //   var account_one = accounts[0];
  //   var account_two = accounts[1];
  //
  //   var account_one_starting_balance;
  //   var account_two_starting_balance;
  //   var account_one_ending_balance;
  //   var account_two_ending_balance;
  //
  //   var amount = 10;
  //
  //   return MetaCoin.deployed().then(function(instance) {
  //     meta = instance;
  //     return meta.getBalance.call(account_one);
  //   }).then(function(balance) {
  //     account_one_starting_balance = balance.toNumber();
  //     return meta.getBalance.call(account_two);
  //   }).then(function(balance) {
  //     account_two_starting_balance = balance.toNumber();
  //     return meta.sendCoin(account_two, amount, {from: account_one});
  //   }).then(function() {
  //     return meta.getBalance.call(account_one);
  //   }).then(function(balance) {
  //     account_one_ending_balance = balance.toNumber();
  //     return meta.getBalance.call(account_two);
  //   }).then(function(balance) {
  //     account_two_ending_balance = balance.toNumber();
  //
  //     assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
  //     assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
  //   });
  // });
});
