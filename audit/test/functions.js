// 13 Jan 2020 16:11 AEDT ETH/USD from CMC and ethgasstation.info
var ethPriceUSD = 145.205;
var defaultGasPrice = web3.toWei(50, "gwei");

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "miner");
addAccount(eth.accounts[1], "deployer");
addAccount(eth.accounts[2], "migrationManager");
addAccount(eth.accounts[3], "emergencyManager");
addAccount(eth.accounts[4], "user1");
addAccount(eth.accounts[5], "user2");
addAccount(eth.accounts[6], "user3");

var miner = eth.accounts[0];
var deployer = eth.accounts[1];
var migrationManager = eth.accounts[2];
var emergencyManager = eth.accounts[3];
var user1 = eth.accounts[4];
var user2 = eth.accounts[5];
var user3 = eth.accounts[6];


console.log("DATA: var miner=\"" + eth.accounts[0] + "\";");
console.log("DATA: var deployer=\"" + eth.accounts[1] + "\";");
console.log("DATA: var migrationManager=\"" + eth.accounts[2] + "\";");
console.log("DATA: var emergencyManager=\"" + eth.accounts[3] + "\";");
console.log("DATA: var user1=\"" + eth.accounts[4] + "\";");
console.log("DATA: var user2=\"" + eth.accounts[5] + "\";");
console.log("DATA: var user3=\"" + eth.accounts[6] + "\";");


var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length && i < accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
    if (i > 0 && eth.getBalance(eth.accounts[i]) == 0) {
      personal.sendTransaction({from: eth.accounts[0], to: eth.accounts[i], value: web3.toWei(1000000, "ether")});
    }
  }
  while (txpool.status.pending > 0) {
  }
  baseBlock = eth.blockNumber;
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
  addAddressNames(account, accountName);
}

var NULLACCOUNT = "0x0000000000000000000000000000000000000000";
addAddressNames(NULLACCOUNT, "null");

// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Token Contracts
//-----------------------------------------------------------------------------
var _tokenContractAddresses = [];
var _tokenContractAbis = [];
var _tokens = [null, null, null, null];
var _symbols = ["0", "1", "2", "3"];
var _decimals = [18, 18, 18, 18];

function addTokenContractAddressAndAbi(i, address, abi) {
  _tokenContractAddresses[i] = address;
  _tokenContractAbis[i] = abi;
  _tokens[i] = web3.eth.contract(abi).at(address);
  _symbols[i] = _tokens[i].symbol.call();
  _decimals[i] = _tokens[i].decimals.call();
}


//-----------------------------------------------------------------------------
//Account ETH and token balances
//-----------------------------------------------------------------------------
function printBalances() {
  var i = 0;
  var j;
  var totalTokenBalances = [new BigNumber(0), new BigNumber(0), new BigNumber(0), new BigNumber(0)];
  console.log("RESULT:  # Account                                             EtherBalanceChange               " + padLeft(_symbols[0], 16) + "               " + padLeft(_symbols[1], 16) + " Name");
  // console.log("RESULT:                                                                                         " + padLeft(_symbols[2], 16) + "               " + padLeft(_symbols[3], 16));
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalances = [];
    for (j = 0; j < 2; j++) {
      tokenBalances[j] = _tokens[j] == null ? new BigNumber(0) : _tokens[j].balanceOf.call(e).shift(-_decimals[j]);
      totalTokenBalances[j] = totalTokenBalances[j].add(tokenBalances[j]);
    }
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " +
      padToken(tokenBalances[0], _decimals[0]) + " " + padToken(tokenBalances[1], _decimals[1]) + " " + accountNames[e]);
    // console.log("RESULT:                                                                           " +
    //   padToken(tokenBalances[2], _decimals[2]) + " " + padToken(tokenBalances[3], _decimals[3]));
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalances[0], _decimals[0]) + " " + padToken(totalTokenBalances[1], _decimals[1]) + " Total Token Balances");
  // console.log("RESULT:                                                                           " + padToken(totalTokenBalances[2], _decimals[2]) + " " + padToken(totalTokenBalances[3], _decimals[3]));
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}

function padLeft(s, n) {
  var o = s;
  while (o.length < n) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  var block = eth.getBlock(txReceipt.blockNumber);
  console.log("RESULT: " + name + " status=" + txReceipt.status + (txReceipt.status == 0 ? " Failure" : " Success") + " gas=" + tx.gas +
    " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH + " costUSD=" + gasCostUSD +
    " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + web3.fromWei(gasPrice, "gwei") + " gwei block=" +
    txReceipt.blockNumber + " txIx=" + tx.transactionIndex + " txId=" + txId +
    " @ " + block.timestamp + " " + new Date(block.timestamp * 1000).toUTCString());
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function failIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 0) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 1) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


//-----------------------------------------------------------------------------
// Wait one block
//-----------------------------------------------------------------------------
function waitOneBlock(oldCurrentBlock) {
  while (eth.blockNumber <= oldCurrentBlock) {
  }
  console.log("RESULT: Waited one block");
  console.log("RESULT: ");
  return eth.blockNumber;
}


//-----------------------------------------------------------------------------
// Pause for {x} seconds
//-----------------------------------------------------------------------------
function pause(message, addSeconds) {
  var time = new Date((parseInt(new Date().getTime()/1000) + addSeconds) * 1000);
  console.log("RESULT: Pausing '" + message + "' for " + addSeconds + "s=" + time + " now=" + new Date());
  while ((new Date()).getTime() <= time.getTime()) {
  }
  console.log("RESULT: Paused '" + message + "' for " + addSeconds + "s=" + time + " now=" + new Date());
  console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
//Wait until some unixTime + additional seconds
//-----------------------------------------------------------------------------
function waitUntil(message, unixTime, addSeconds) {
  var t = parseInt(unixTime) + parseInt(addSeconds) + parseInt(1);
  var time = new Date(t * 1000);
  console.log("RESULT: Waiting until '" + message + "' at " + unixTime + "+" + addSeconds + "s=" + time + " now=" + new Date());
  while ((new Date()).getTime() <= time.getTime()) {
  }
  console.log("RESULT: Waited until '" + message + "' at at " + unixTime + "+" + addSeconds + "s=" + time + " now=" + new Date());
  console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
//Wait until some block
//-----------------------------------------------------------------------------
function waitUntilBlock(message, block, addBlocks) {
  var b = parseInt(block) + parseInt(addBlocks) + parseInt(1);
  console.log("RESULT: Waiting until '" + message + "' #" + block + "+" + addBlocks + "=#" + b + " currentBlock=" + eth.blockNumber);
  while (eth.blockNumber <= b) {
  }
  console.log("RESULT: Waited until '" + message + "' #" + block + "+" + addBlocks + "=#" + b + " currentBlock=" + eth.blockNumber);
  console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
// Token Contract A
//-----------------------------------------------------------------------------
var tokenFromBlock = [0, 0, 0, 0];
function printTokenContractDetails(j) {
  if (tokenFromBlock[j] == 0) {
    tokenFromBlock[j] = baseBlock;
  }
  console.log("RESULT: token" + j + "ContractAddress=" + getShortAddressName(_tokenContractAddresses[j]));
  if (_tokenContractAddresses[j] != null) {
    var contract = _tokens[j];
    var decimals = _decimals[j];
    try {
      console.log("RESULT: token" + j + ".owner/new=" + getShortAddressName(contract.owner.call()) + "/" + getShortAddressName(contract.newOwner.call()));
    } catch (error) {
      console.log("RESULT: token" + j + ".owner/new - Function call failed");
    }
    try {
      console.log("RESULT: token" + j + ".details='" + contract.symbol.call() + "' '" + contract.name.call() + "' " + decimals + " dp");
    } catch (error) {
      console.log("RESULT: token" + j + ".details - Function call failed");
    }
    console.log("RESULT: token" + j + ".totalSupply=" + contract.totalSupply.call().shift(-decimals));

    var latestBlock = eth.blockNumber;
    var i;

    // WETH has no OwnershipTransferred event
    if (j > 0) {
      var ownershipTransferredEvents = contract.OwnershipTransferred({}, { fromBlock: tokenFromBlock[j], toBlock: latestBlock });
      i = 0;
      ownershipTransferredEvents.watch(function (error, result) {
        console.log("RESULT: token" + j + ".OwnershipTransferred " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
      });
      ownershipTransferredEvents.stopWatching();
    }

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock[j], toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      // console.log("RESULT: token" + j + ".Approval " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result));
      console.log("RESULT: token" + j + ".Approval " + i++ + " #" + result.blockNumber +
        " tokenOwner=" + getShortAddressName(result.args.tokenOwner) +
        " spender=" + getShortAddressName(result.args.spender) + " tokens=" + result.args.tokens.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock[j], toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      // console.log("RESULT: token" + j + ".Transfer " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result));
      console.log("RESULT: token" + j + ".Transfer " + i++ + " #" + result.blockNumber +
        " from=" + getShortAddressName(result.args.from) +
        " to=" + getShortAddressName(result.args.to) + " tokens=" + result.args.tokens.shift(-decimals));
    });
    transferEvents.stopWatching();

    tokenFromBlock[j] = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// Staking Contract
//-----------------------------------------------------------------------------
var _stakingContractAddress = [null, null];
var _stakingContractAbi = [null, null];
function addStakingContractAddressAndAbi(index, _address, _abi) {
  _stakingContractAddress[index] = _address;
  _stakingContractAbi[index] = _abi;
}

var _stakingContractFromBlock = 0;
function printStakingContractDetails(index) {
  console.log("RESULT: stakingContractAddress=" + _stakingContractAddress[index]);
  if (_stakingContractAddress[index] != null && _stakingContractAbi[index] != null) {
    var contract = eth.contract(_stakingContractAbi[index]).at(_stakingContractAddress[index]);
    console.log("RESULT: stakingContract.VERSION=" + contract.VERSION.call());
    console.log("RESULT: stakingContract.MAX_APPROVED_STAKING_CONTRACTS=" + contract.MAX_APPROVED_STAKING_CONTRACTS.call());
    console.log("RESULT: stakingContract.cooldownPeriodInSec=" + contract.cooldownPeriodInSec.call());
    console.log("RESULT: stakingContract.migrationManager=" + getShortAddressName(contract.migrationManager.call()));
    console.log("RESULT: stakingContract.emergencyManager=" + getShortAddressName(contract.emergencyManager.call()));
    console.log("RESULT: stakingContract.getToken=" + getShortAddressName(contract.getToken.call()));

    var i = 0;
    var v = "";
    do {
      v = contract.approvedStakingContracts.call(i);
      console.log("RESULT: stakingContract.approvedStakingContracts[" + i + "]=" + v);
      i++;
    } while (v != "0x");

    console.log("RESULT: stakingContract.notifier=" + contract.notifier.call());
    console.log("RESULT: stakingContract.acceptingNewStakes=" + contract.acceptingNewStakes.call());
    console.log("RESULT: stakingContract.releasingAllStakes=" + contract.releasingAllStakes.call());
    console.log("RESULT: stakingContract.getTotalStakedTokens=" + contract.getTotalStakedTokens.call().shift(-18).toString());
    var users = [user1, user2, user3];
    users.forEach(function(u) {
      console.log("RESULT: stakingContract.getStakeBalanceOf(" + getShortAddressName(u) + ")=" + contract.getStakeBalanceOf.call(u).shift(-18).toString());
      var data = contract.getUnstakeStatus.call(u);
      console.log("RESULT: stakingContract.getUnstakeStatus(" + getShortAddressName(u) + ")=" + data[0].shift(-18).toString() + ", cooldownEndTime=" + data[1]);
    });

    var latestBlock = eth.blockNumber;

    // event Staked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    // event Unstaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    // event Withdrew(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    // event Restaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    // event MigratedStake(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);

    var stakedEvents = contract.Staked({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    stakedEvents.watch(function (error, result) {
      console.log("RESULT: Staked " + i++ + " #" + result.blockNumber + " stakeOwner=" + getShortAddressName(result.args.stakeOwner) + ", amount=" + result.args.amount.shift(-18).toString()  + ", totalStakedAmount=" + result.args.totalStakedAmount.shift(-18).toString());
    });
    stakedEvents.stopWatching();

    var unstakedEvents = contract.Unstaked({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    unstakedEvents.watch(function (error, result) {
      console.log("RESULT: Unstaked " + i++ + " #" + result.blockNumber + " stakeOwner=" + getShortAddressName(result.args.stakeOwner) + ", amount=" + result.args.amount.shift(-18).toString()  + ", totalStakedAmount=" + result.args.totalStakedAmount.shift(-18).toString());
    });
    unstakedEvents.stopWatching();

    var withdrewEvents = contract.Withdrew({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    withdrewEvents.watch(function (error, result) {
      console.log("RESULT: Withdrew " + i++ + " #" + result.blockNumber + " stakeOwner=" + getShortAddressName(result.args.stakeOwner) + ", amount=" + result.args.amount.shift(-18).toString()  + ", totalStakedAmount=" + result.args.totalStakedAmount.shift(-18).toString());
    });
    withdrewEvents.stopWatching();

    var restakedEvents = contract.Restaked({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    restakedEvents.watch(function (error, result) {
      console.log("RESULT: Restaked " + i++ + " #" + result.blockNumber + " stakeOwner=" + getShortAddressName(result.args.stakeOwner) + ", amount=" + result.args.amount.shift(-18).toString()  + ", totalStakedAmount=" + result.args.totalStakedAmount.shift(-18).toString());
    });
    restakedEvents.stopWatching();

    var migratedStakeEvents = contract.MigratedStake({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    migratedStakeEvents.watch(function (error, result) {
      console.log("RESULT: MigratedStake " + i++ + " #" + result.blockNumber + " stakeOwner=" + getShortAddressName(result.args.stakeOwner) + ", amount=" + result.args.amount.shift(-18).toString()  + ", totalStakedAmount=" + result.args.totalStakedAmount.shift(-18).toString());
    });
    migratedStakeEvents.stopWatching();

    var migrationManagerUpdatedEvents = contract.MigrationManagerUpdated({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    migrationManagerUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: MigrationManagerUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    migrationManagerUpdatedEvents.stopWatching();

    var migrationDestinationAddedEvents = contract.MigrationDestinationAdded({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    migrationDestinationAddedEvents.watch(function (error, result) {
      console.log("RESULT: MigrationDestinationAdded " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    migrationDestinationAddedEvents.stopWatching();

    var migrationDestinationRemovedEvents = contract.MigrationDestinationRemoved({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    migrationDestinationRemovedEvents.watch(function (error, result) {
      console.log("RESULT: MigrationDestinationRemoved " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    migrationDestinationRemovedEvents.stopWatching();

    var emergencyManagerUpdatedEvents = contract.EmergencyManagerUpdated({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    emergencyManagerUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: EmergencyManagerUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    emergencyManagerUpdatedEvents.stopWatching();

    var stakeChangeNotifierUpdatedEvents = contract.StakeChangeNotifierUpdated({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    stakeChangeNotifierUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: StakeChangeNotifierUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    stakeChangeNotifierUpdatedEvents.stopWatching();

    var stoppedAcceptingNewStakeEvents = contract.StoppedAcceptingNewStake({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    stoppedAcceptingNewStakeEvents.watch(function (error, result) {
      console.log("RESULT: StoppedAcceptingNewStake " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    stoppedAcceptingNewStakeEvents.stopWatching();

    var releasedAllStakesEvents = contract.ReleasedAllStakes({}, { fromBlock: _stakingContractFromBlock, toBlock: latestBlock });
    i = 0;
    releasedAllStakesEvents.watch(function (error, result) {
      console.log("RESULT: ReleasedAllStakes " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    releasedAllStakesEvents.stopWatching();

    _stakingContractFromBlock = latestBlock + 1;
  }
}
