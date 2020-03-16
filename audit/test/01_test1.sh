#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2020. The MIT Licence.
# ----------------------------------------------------------------------------------------------

# echo "Options: [full|takerSell|takerBuy|exchange]"

MODE=${1:-full}

source settings
echo "---------- Settings ----------" | tee $TEST1OUTPUT
cat ./settings | tee -a $TEST1OUTPUT
echo "" | tee -a $TEST1OUTPUT

CURRENTTIME=`date +%s`
CURRENTTIMES=`perl -le "print scalar localtime $CURRENTTIME"`
START_DATE=`echo "$CURRENTTIME+45" | bc`
START_DATE_S=`perl -le "print scalar localtime $START_DATE"`
END_DATE=`echo "$CURRENTTIME+60*2" | bc`
END_DATE_S=`perl -le "print scalar localtime $END_DATE"`

printf "CURRENTTIME = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE  = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE    = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file ---
cp $SOURCEDIR/$WETH9SOL .
# cp $SOURCEDIR/$DAISOL .
# rsync -rp $SOURCEDIR/* . --exclude=Multisig.sol --exclude=test/
# rsync -rp $SOURCEDIR/* . --exclude=Multisig.sol
# Copy modified contracts if any files exist
# find ./modifiedContracts -type f -name \* -exec cp {} . \;

# --- Modify parameters ---
# `perl -pi -e "s/openzeppelin-solidity/\.\.\/\.\.\/openzeppelin-solidity/" token/dataStorage/*.sol`

../scripts/solidityFlattener.pl --contractsdir=$SOURCEDIR --mainsol=$STAKINGSOL --outputsol=$STAKINGFLATTENED --verbose --remapdir "@openzeppelin/contracts/=openzeppelin-solidity-v2.3.0/"


# DIFFS1=`diff -r -x '*.js' -x '*.json' -x '*.txt' -x 'testchain' -x '*.md' -x '*.sh' -x 'settings' -x 'modifiedContracts' $SOURCEDIR .`
# echo "--- Differences $SOURCEDIR/*.sol *.sol ---" | tee -a $TEST1OUTPUT
# echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc_0.5.16 --version | tee -a $TEST1OUTPUT

echo "var stakingOutput=`solc_0.5.16 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $STAKINGFLATTENED`;" > $STAKINGJS
echo "var tokenOutput=`solc_0.5.16 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface $TOKENSOL`;" > $TOKENJS

if [ "$MODE" = "compile" ]; then
  echo "Compiling only"
  exit 1;
fi

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$STAKINGJS");
loadScript("$TOKENJS");
loadScript("lookups.js");
loadScript("functions.js");

var stakingAbi = JSON.parse(stakingOutput.contracts["$STAKINGFLATTENED:$STAKINGNAME"].abi);
var stakingBin = "0x" + stakingOutput.contracts["$STAKINGFLATTENED:$STAKINGNAME"].bin;
var tokenAbi = JSON.parse(tokenOutput.contracts["$TOKENSOL:$TOKENNAME"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$TOKENSOL:$TOKENNAME"].bin;

// console.log("DATA: stakingAbi=" + JSON.stringify(stakingAbi));
// console.log("DATA: stakingBin=" + JSON.stringify(stakingBin));
// console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: tokenBin=" + JSON.stringify(tokenBin));


unlockAccounts("$PASSWORD");
// printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployGroup1_Message = "Deploy Group #1 - Contracts";
var _cooldownPeriodInSec = 1;
console.log("DATA: deployer=" + deployer);
console.log("DATA: defaultGasPrice=" + defaultGasPrice);
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployGroup1_Message + " ----------");
var tokenContract = web3.eth.contract(tokenAbi);
// console.log("DATA: tokenContract=" + JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new({from: deployer, data: tokenBin, gas: 4000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "'" + token.symbol.call() + "' '" + token.name.call() + "'");
        addTokenContractAddressAndAbi(0, tokenAddress, tokenAbi);
        addAddressSymbol(tokenAddress, "'" + token.symbol.call() + "' '" + token.name.call() + "'");
        console.log("DATA: var tokenAddress=\"" + tokenAddress + "\";");
        console.log("DATA: var tokenAbi=" + JSON.stringify(tokenAbi) + ";");
        console.log("DATA: var token=eth.contract(tokenAbi).at(tokenAddress);");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
var stakingContract = web3.eth.contract(stakingAbi);
// console.log("DATA: stakingContract=" + JSON.stringify(stakingContract));
var stakingTx = null;
var stakingAddress = null;
var staking = stakingContract.new(_cooldownPeriodInSec, migrationManager, emergencyManager, tokenAddress, {from: deployer, data: stakingBin, gas: 5000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        stakingTx = contract.transactionHash;
      } else {
        stakingAddress = contract.address;
        addAccount(stakingAddress, "Staking");
        addAddressSymbol(stakingAddress, "Staking");
        addStakingContractAddressAndAbi(0, stakingAddress, stakingAbi);
        console.log("DATA: var stakingAddress=\"" + stakingAddress + "\";");
        console.log("DATA: var stakingAbi=" + JSON.stringify(stakingAbi) + ";");
        console.log("DATA: var staking=eth.contract(stakingAbi).at(stakingAddress);");
      }
    }
  }
);
var staking2Tx = null;
var staking2Address = null;
var staking2 = stakingContract.new(_cooldownPeriodInSec, migrationManager, emergencyManager, tokenAddress, {from: deployer, data: stakingBin, gas: 5000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        staking2Tx = contract.transactionHash;
      } else {
        staking2Address = contract.address;
        addAccount(staking2Address, "Staking2");
        addAddressSymbol(staking2Address, "Staking2");
        addStakingContractAddressAndAbi(1, staking2Address, stakingAbi);
        console.log("DATA: var staking2Address=\"" + staking2Address + "\";");
        console.log("DATA: var stakingAbi=" + JSON.stringify(stakingAbi) + ";");
        console.log("DATA: var staking2=eth.contract(stakingAbi).at(staking2Address);");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
var addMigrationDestination1_1Tx = staking.addMigrationDestination(staking2Address, {from: migrationManager, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(tokenTx, deployGroup1_Message + " - Token");
failIfTxStatusError(stakingTx, deployGroup1_Message + " - Staking");
failIfTxStatusError(staking2Tx, deployGroup1_Message + " - Staking2");
failIfTxStatusError(addMigrationDestination1_1Tx, deployGroup1_Message + " - staking.addMigrationDestination(staking2)");
printTxData("tokenTx", tokenTx);
printTxData("stakingTx", stakingTx);
printTxData("staking2Tx", staking2Tx);
printTxData("addMigrationDestination1_1Tx", addMigrationDestination1_1Tx);
console.log("RESULT: ");
printTokenContractDetails(0);
console.log("RESULT: ");
printStakingContractDetails(0);
console.log("RESULT: ");
printStakingContractDetails(1);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployGroup2_Message = "Deploy Group #2 - Setup";
var tokens = new BigNumber("250000").shift(18);
var tokensToApprove = new BigNumber("1000").shift(18);
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployGroup2_Message + " ----------");
var deployGroup2_1Tx = token.transfer(user1, tokens.toString(), {from: deployer, gas: 100000, gasPrice: defaultGasPrice});
var deployGroup2_2Tx = token.transfer(user2, tokens.toString(), {from: deployer, gas: 100000, gasPrice: defaultGasPrice});
var deployGroup2_3Tx = token.transfer(user3, tokens.toString(), {from: deployer, gas: 100000, gasPrice: defaultGasPrice});
var deployGroup2_4Tx = token.approve(stakingAddress, tokensToApprove.toString(), {from: deployer, gas: 100000, gasPrice: defaultGasPrice});
var deployGroup2_5Tx = token.approve(stakingAddress, tokensToApprove.toString(), {from: user1, gas: 100000, gasPrice: defaultGasPrice});
var deployGroup2_6Tx = token.approve(stakingAddress, tokensToApprove.toString(), {from: user2, gas: 100000, gasPrice: defaultGasPrice});
var deployGroup2_7Tx = token.approve(stakingAddress, tokensToApprove.toString(), {from: user3, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(deployGroup2_1Tx, deployGroup2_Message + " - deployer -> token.transfer(user1, " + tokens.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_2Tx, deployGroup2_Message + " - deployer -> token.transfer(user2, " + tokens.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_3Tx, deployGroup2_Message + " - deployer -> token.transfer(user3, " + tokens.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_4Tx, deployGroup2_Message + " - deployer -> token.approve(stakingContract, " + tokensToApprove.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_5Tx, deployGroup2_Message + " - user1 -> token.approve(stakingContract, " + tokensToApprove.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_6Tx, deployGroup2_Message + " - user2 -> token.approve(stakingContract, " + tokensToApprove.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_7Tx, deployGroup2_Message + " - user3 -> token.approve(stakingContract, " + tokensToApprove.shift(-18).toString() + ")");
printTxData("deployGroup2_1Tx", deployGroup2_1Tx);
printTxData("deployGroup2_2Tx", deployGroup2_2Tx);
printTxData("deployGroup2_3Tx", deployGroup2_3Tx);
printTxData("deployGroup2_4Tx", deployGroup2_4Tx);
printTxData("deployGroup2_5Tx", deployGroup2_5Tx);
printTxData("deployGroup2_6Tx", deployGroup2_6Tx);
printTxData("deployGroup2_7Tx", deployGroup2_7Tx);
console.log("RESULT: ");
printTokenContractDetails(0);
console.log("RESULT: ");
printStakingContractDetails(0);
console.log("RESULT: ");
printStakingContractDetails(1);
console.log("RESULT: ");


// Test Migration Manager Functions #1
if (false) {
  // -----------------------------------------------------------------------------
  var testMigrationManagerFunctions1_Message = "Test Migration Manager Functions #1";
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + testMigrationManagerFunctions1_Message + " ----------");
  // Tested with non-emergencyManager
  var testMigrationManagerFunctions1_1Tx = staking.setMigrationManager(deployer, {from: user1, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  var testMigrationManagerFunctions1_2Tx = staking.setMigrationManager(deployer, {from: migrationManager, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  var testMigrationManagerFunctions1_3Tx = staking.setStakeChangeNotifier(miner, {from: user1, gas: 500000, gasPrice: defaultGasPrice});
  var testMigrationManagerFunctions1_4Tx = staking.setStakeChangeNotifier(miner, {from: deployer, gas: 500000, gasPrice: defaultGasPrice});
  var testMigrationManagerFunctions1_5Tx = staking.addMigrationDestination(miner, {from: user1, gas: 500000, gasPrice: defaultGasPrice});
  var testMigrationManagerFunctions1_6Tx = staking.addMigrationDestination(miner, {from: deployer, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  passIfTxStatusError(testMigrationManagerFunctions1_1Tx, testMigrationManagerFunctions1_Message + " - user1 -> staking.setMigrationManager(deployer) - Expecting failure");
  failIfTxStatusError(testMigrationManagerFunctions1_2Tx, testMigrationManagerFunctions1_Message + " - migrationManager -> staking.setMigrationManager(deployer)");
  passIfTxStatusError(testMigrationManagerFunctions1_3Tx, testMigrationManagerFunctions1_Message + " - user1 -> staking.setStakeChangeNotifier(miner) - Expecting failure");
  failIfTxStatusError(testMigrationManagerFunctions1_4Tx, testMigrationManagerFunctions1_Message + " - deployer -> staking.setStakeChangeNotifier(miner)");
  passIfTxStatusError(testMigrationManagerFunctions1_5Tx, testMigrationManagerFunctions1_Message + " - user1 -> staking.addMigrationDestination(miner) - Expecting failure");
  failIfTxStatusError(testMigrationManagerFunctions1_6Tx, testMigrationManagerFunctions1_Message + " - deployer -> staking.addMigrationDestination(miner)");
  printTxData("testMigrationManagerFunctions1_1Tx", testMigrationManagerFunctions1_1Tx);
  printTxData("testMigrationManagerFunctions1_2Tx", testMigrationManagerFunctions1_2Tx);
  printTxData("testMigrationManagerFunctions1_3Tx", testMigrationManagerFunctions1_3Tx);
  printTxData("testMigrationManagerFunctions1_4Tx", testMigrationManagerFunctions1_4Tx);
  printTxData("testMigrationManagerFunctions1_5Tx", testMigrationManagerFunctions1_5Tx);
  printTxData("testMigrationManagerFunctions1_6Tx", testMigrationManagerFunctions1_6Tx);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");

  var testMigrationManagerFunctions1_7Tx = staking.setStakeChangeNotifier("0x0000000000000000000000000000000000000000", {from: deployer, gas: 500000, gasPrice: defaultGasPrice});
  var testMigrationManagerFunctions1_8Tx = staking.removeMigrationDestination(miner, {from: user1, gas: 500000, gasPrice: defaultGasPrice});
  var testMigrationManagerFunctions1_9Tx = staking.removeMigrationDestination(miner, {from: deployer, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  var testMigrationManagerFunctions1_10Tx = staking.removeMigrationDestination(miner, {from: deployer, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }

  printBalances();
  failIfTxStatusError(testMigrationManagerFunctions1_7Tx, testMigrationManagerFunctions1_Message + " - deployer -> staking.setStakeChangeNotifier(deployer)");
  passIfTxStatusError(testMigrationManagerFunctions1_8Tx, testMigrationManagerFunctions1_Message + " - user1 -> staking.removeMigrationDestination(miner) - Expecting failure");
  failIfTxStatusError(testMigrationManagerFunctions1_9Tx, testMigrationManagerFunctions1_Message + " - deployer -> staking.removeMigrationDestination(miner)");
  passIfTxStatusError(testMigrationManagerFunctions1_10Tx, testMigrationManagerFunctions1_Message + " - deployer -> staking.removeMigrationDestination(miner) - Expecting failure as address already removed");
  printTxData("testMigrationManagerFunctions1_7Tx", testMigrationManagerFunctions1_7Tx);
  printTxData("testMigrationManagerFunctions1_8Tx", testMigrationManagerFunctions1_8Tx);
  printTxData("testMigrationManagerFunctions1_9Tx", testMigrationManagerFunctions1_9Tx);
  printTxData("testMigrationManagerFunctions1_10Tx", testMigrationManagerFunctions1_10Tx);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Test Emergency Manager Functions #1
if (false) {
  // -----------------------------------------------------------------------------
  var testEmergencyManagerFunctions1_Message = "Test Emergency Manager Functions #1";
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + testEmergencyManagerFunctions1_Message + " ----------");
  // Tested with non-emergencyManager
  var testEmergencyManagerFunctions1_1Tx = staking.setEmergencyManager(deployer, {from: user2, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  var testEmergencyManagerFunctions1_2Tx = staking.setEmergencyManager(deployer, {from: emergencyManager, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  var testEmergencyManagerFunctions1_3Tx = staking.stopAcceptingNewStakes({from: user2, gas: 500000, gasPrice: defaultGasPrice});
  var testEmergencyManagerFunctions1_4Tx = staking.releaseAllStakes({from: user2, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  var testEmergencyManagerFunctions1_5Tx = staking.stopAcceptingNewStakes({from: deployer, gas: 500000, gasPrice: defaultGasPrice});
  var testEmergencyManagerFunctions1_6Tx = staking.releaseAllStakes({from: deployer, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  passIfTxStatusError(testEmergencyManagerFunctions1_1Tx, testEmergencyManagerFunctions1_Message + " - user2 -> staking.setEmergencyManager(deployer) - Expecting failure");
  failIfTxStatusError(testEmergencyManagerFunctions1_2Tx, testEmergencyManagerFunctions1_Message + " - emergencyManager -> staking.setEmergencyManager(deployer)");
  passIfTxStatusError(testEmergencyManagerFunctions1_3Tx, testEmergencyManagerFunctions1_Message + " - user2 -> staking.stopAcceptingNewStakes() - Expecting failure");
  passIfTxStatusError(testEmergencyManagerFunctions1_4Tx, testEmergencyManagerFunctions1_Message + " - user2 -> staking.releaseAllStakes() - Expecting failure");
  passIfTxStatusError(testEmergencyManagerFunctions1_4Tx, testEmergencyManagerFunctions1_Message + " - user2 -> staking.releaseAllStakes() - Expecting failure");
  failIfTxStatusError(testEmergencyManagerFunctions1_5Tx, testEmergencyManagerFunctions1_Message + " - deployer -> staking.stopAcceptingNewStakes()");
  failIfTxStatusError(testEmergencyManagerFunctions1_6Tx, testEmergencyManagerFunctions1_Message + " - deployer -> staking.releaseAllStakes()");
  printTxData("testEmergencyManagerFunctions1_1Tx", testEmergencyManagerFunctions1_1Tx);
  printTxData("testEmergencyManagerFunctions1_2Tx", testEmergencyManagerFunctions1_2Tx);
  printTxData("testEmergencyManagerFunctions1_3Tx", testEmergencyManagerFunctions1_3Tx);
  printTxData("testEmergencyManagerFunctions1_4Tx", testEmergencyManagerFunctions1_4Tx);
  printTxData("testEmergencyManagerFunctions1_5Tx", testEmergencyManagerFunctions1_5Tx);
  printTxData("testEmergencyManagerFunctions1_6Tx", testEmergencyManagerFunctions1_6Tx);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


var allTests = false;

// Release All Stakes #1
if (false) {
  // -----------------------------------------------------------------------------
  var releaseAllStakes1_Message = "Release All Stakes #1";
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + releaseAllStakes1_Message + " ----------");
  // Tested with non-emergencyManager
  var releaseAllStakes1_1Tx = staking.releaseAllStakes({from: emergencyManager, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfTxStatusError(releaseAllStakes1_1Tx, releaseAllStakes1_Message + " - emergencyManager -> staking.releaseAllStakes()");
  printTxData("releaseAllStakes1_1Tx", releaseAllStakes1_1Tx);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}

// Stop Accepting New Stakes #1
if (false) {
  // -----------------------------------------------------------------------------
  var stopAcceptingNewStakes1_Message = "Stop Accepting New Stakes #1";
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + stopAcceptingNewStakes1_Message + " ----------");
  // Tested with non-emergencyManager
  var stopAcceptingNewStakes1_1Tx = staking.stopAcceptingNewStakes({from: emergencyManager, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfTxStatusError(stopAcceptingNewStakes1_1Tx, stopAcceptingNewStakes1_Message + " - emergencyManager -> staking.stopAcceptingNewStakes()");
  printTxData("stopAcceptingNewStakes1_1Tx", stopAcceptingNewStakes1_1Tx);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Test Staking #1
if (allTests || true) {
  // -----------------------------------------------------------------------------
  var testStaking1_Message = "Test Staking #1";
  var tokensToStake1 = new BigNumber("100").shift(18);
  var tokensToStake2 = new BigNumber("200").shift(18);
  var tokensToStake3 = new BigNumber("300").shift(18);
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + testStaking1_Message + " ----------");
  var testStaking1_1Tx = staking.stake(tokensToStake1.toString(), {from: user1, gas: 500000, gasPrice: defaultGasPrice});
  var testStaking1_2Tx = staking.stake(tokensToStake2.toString(), {from: user2, gas: 500000, gasPrice: defaultGasPrice});
  var testStaking1_3Tx = staking.stake(tokensToStake3.toString(), {from: user3, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfTxStatusError(testStaking1_1Tx, testStaking1_Message + " - user1 -> staking.stake(" + tokensToStake1.shift(-18).toString() + ")");
  failIfTxStatusError(testStaking1_2Tx, testStaking1_Message + " - user2 -> staking.stake(" + tokensToStake2.shift(-18).toString() + ")");
  failIfTxStatusError(testStaking1_3Tx, testStaking1_Message + " - user3 -> staking.stake(" + tokensToStake3.shift(-18).toString() + ")");
  printTxData("testStaking1_1Tx", testStaking1_1Tx);
  printTxData("testStaking1_2Tx", testStaking1_2Tx);
  printTxData("testStaking1_3Tx", testStaking1_3Tx);
  console.log("RESULT: ");
  printTokenContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Test Blocking #1
if (true) {
  // -----------------------------------------------------------------------------
  var testBlocking1_Message = "Test Blocking #1";
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + testBlocking1_Message + " ----------");
  var testBlocking1_1Tx = staking.setStakeChangeNotifier("0x0000000000000000000000000000000000000001", {from: migrationManager, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfTxStatusError(testBlocking1_1Tx, testBlocking1_Message + " - migrationManager -> staking.setStakeChangeNotifier(0x0000000000000000000000000000000000000001)");
  printTxData("testBlocking1_1Tx", testBlocking1_1Tx);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Test Unstaking #1
if (allTests || true) {
  // -----------------------------------------------------------------------------
  var testUnstaking1_Message = "Test Unstaking #1";
  var tokensToUnstake1 = new BigNumber("10").shift(18);
  var tokensToUnstake2 = new BigNumber("20").shift(18);
  var tokensToUnstake3 = new BigNumber("30").shift(18);
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + testUnstaking1_Message + " ----------");
  var testUnstaking1_1Tx = staking.unstake(tokensToUnstake1.toString(), {from: user1, gas: 500000, gasPrice: defaultGasPrice});
  var testUnstaking1_2Tx = staking.unstake(tokensToUnstake2.toString(), {from: user2, gas: 500000, gasPrice: defaultGasPrice});
  var testUnstaking1_3Tx = staking.unstake(tokensToUnstake3.toString(), {from: user3, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  passIfTxStatusError(testUnstaking1_1Tx, testUnstaking1_Message + " - user1 -> staking.unstake(" + tokensToUnstake1.shift(-18).toString() + ") - Expecting failure due to invalid notifier");
  passIfTxStatusError(testUnstaking1_2Tx, testUnstaking1_Message + " - user2 -> staking.unstake(" + tokensToUnstake2.shift(-18).toString() + ") - Expecting failure due to invalid notifier");
  passIfTxStatusError(testUnstaking1_3Tx, testUnstaking1_Message + " - user3 -> staking.unstake(" + tokensToUnstake3.shift(-18).toString() + ") - Expecting failure due to invalid notifier");
  printTxData("testUnstaking1_1Tx", testUnstaking1_1Tx);
  printTxData("testUnstaking1_2Tx", testUnstaking1_2Tx);
  printTxData("testUnstaking1_3Tx", testUnstaking1_3Tx);
  console.log("RESULT: ");
  printTokenContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Withdraw Released Stakes #1
if (false) {
  // -----------------------------------------------------------------------------
  var withdrawReleasedStakes2_Message = "Withdraw Released Stakes #1";
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + withdrawReleasedStakes2_Message + " ----------");
  var withdrawReleasedStakes2_1Tx = staking.releaseAllStakes({from: emergencyManager, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  var withdrawReleasedStakes2_2Tx = staking.withdrawReleasedStakes([user1, user2, user3, deployer], {from: deployer, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  var withdrawReleasedStakes2_3Tx = staking.withdrawReleasedStakes([user1, user2, user3], {from: deployer, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfTxStatusError(withdrawReleasedStakes2_1Tx, withdrawReleasedStakes2_Message + " - emergencyManager -> staking.releaseAllStakes()");
  passIfTxStatusError(withdrawReleasedStakes2_2Tx, withdrawReleasedStakes2_Message + " - deployer -> staking.withdrawReleasedStakes([user1, user2, user3, deployer]) - Expecting to fail as deployer does not have unstaked tokens");
  failIfTxStatusError(withdrawReleasedStakes2_3Tx, withdrawReleasedStakes2_Message + " - deployer -> staking.withdrawReleasedStakes([user1, user2, user3])");
  printTxData("withdrawReleasedStakes2_1Tx", withdrawReleasedStakes2_1Tx);
  printTxData("withdrawReleasedStakes2_2Tx", withdrawReleasedStakes2_2Tx);
  printTxData("withdrawReleasedStakes2_3Tx", withdrawReleasedStakes2_3Tx);
  console.log("RESULT: ");
  printTokenContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Test Restake #1
if (false) {
  // -----------------------------------------------------------------------------
  var testRestake1_Message = "Test Restake #1";
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + testRestake1_Message + " ----------");
  var testRestake1_1Tx = staking.restake({from: user1, gas: 500000, gasPrice: defaultGasPrice});
  var testRestake1_2Tx = staking.restake({from: user2, gas: 500000, gasPrice: defaultGasPrice});
  var testRestake1_3Tx = staking.restake({from: user3, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfTxStatusError(testRestake1_1Tx, testRestake1_Message + " - user1 -> staking.restake()");
  failIfTxStatusError(testRestake1_2Tx, testRestake1_Message + " - user2 -> staking.restake()");
  failIfTxStatusError(testRestake1_3Tx, testRestake1_Message + " - user3 -> staking.restake()");
  printTxData("testRestake1_1Tx", testRestake1_1Tx);
  printTxData("testRestake1_2Tx", testRestake1_2Tx);
  printTxData("testRestake1_3Tx", testRestake1_3Tx);
  console.log("RESULT: ");
  printTokenContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Release All Stakes #2
if (false) {
  // -----------------------------------------------------------------------------
  var releaseAllStakes2_Message = "Release All Stakes #2";
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + releaseAllStakes2_Message + " ----------");
  // Tested with non-emergencyManager
  var releaseAllStakes2_1Tx = staking.releaseAllStakes({from: emergencyManager, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfTxStatusError(releaseAllStakes2_1Tx, releaseAllStakes2_Message + " - emergencyManager -> staking.releaseAllStakes()");
  printTxData("releaseAllStakes2_1Tx", releaseAllStakes2_1Tx);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Test Distribute Rewards #1
if (allTests || false) {
  // -----------------------------------------------------------------------------
  var testDistributeRewards1_Message = "Test Distribute Rewards #1";
  // Check with _cooldownPeriodInSec 1 and 10000
  var totalAmount = new BigNumber(66).shift(18).toString();
  var stakeOwners = [user1, user2, user3];
  var amounts = [new BigNumber(11).shift(18).toString(), new BigNumber(22).shift(18).toString(), new BigNumber(33).shift(18).toString()];
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + testDistributeRewards1_Message + " ----------");
  var testDistributeRewards1_1Tx = staking.distributeRewards(totalAmount, stakeOwners, amounts, {from: deployer, gas: 1000000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfTxStatusError(testDistributeRewards1_1Tx, testDistributeRewards1_Message + " - deployer -> staking.distributeRewards(66, [user1, user2, user3], [11, 22, 33])");
  printTxData("testDistributeRewards1_1Tx", testDistributeRewards1_1Tx);
  console.log("RESULT: ");
  printTokenContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Test Migrate #1
if (allTests || false) {
  // -----------------------------------------------------------------------------
  var testMigrateStakedTokens1_Message = "Test Migrate #1";
  var tokensToMigrate1 = new BigNumber("1").shift(18);
  var tokensToMigrate2 = new BigNumber("2").shift(18);
  var tokensToMigrate3 = new BigNumber("3").shift(18);
  // Check with _cooldownPeriodInSec 1 and 10000
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + testMigrateStakedTokens1_Message + " ----------");
  var testMigrateStakedTokens1_1Tx = staking.migrateStakedTokens(staking2Address, tokensToMigrate1.toString(), {from: user1, gas: 500000, gasPrice: defaultGasPrice});
  var testMigrateStakedTokens1_2Tx = staking.migrateStakedTokens(staking2Address, tokensToMigrate2.toString(), {from: user2, gas: 500000, gasPrice: defaultGasPrice});
  var testMigrateStakedTokens1_3Tx = staking.migrateStakedTokens(staking2Address, tokensToMigrate3.toString(), {from: user3, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfTxStatusError(testMigrateStakedTokens1_1Tx, testMigrateStakedTokens1_Message + " - user1 -> staking.migrateStakedTokens(staking2, " + tokensToMigrate1.shift(-18).toString() + ")");
  failIfTxStatusError(testMigrateStakedTokens1_2Tx, testMigrateStakedTokens1_Message + " - user2 -> staking.migrateStakedTokens(staking2, " + tokensToMigrate2.shift(-18).toString() + ")");
  failIfTxStatusError(testMigrateStakedTokens1_3Tx, testMigrateStakedTokens1_Message + " - user3 -> staking.migrateStakedTokens(staking2, " + tokensToMigrate3.shift(-18).toString() + ")");
  printTxData("testMigrateStakedTokens1_1Tx", testMigrateStakedTokens1_1Tx);
  printTxData("testMigrateStakedTokens1_2Tx", testMigrateStakedTokens1_2Tx);
  printTxData("testMigrateStakedTokens1_3Tx", testMigrateStakedTokens1_3Tx);
  console.log("RESULT: ");
  printTokenContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Test Withdraw #1
if (allTests || true) {
  // -----------------------------------------------------------------------------
  var testWithdraw1_Message = "Test Withdraw #1";
  // Check with _cooldownPeriodInSec 1 and 10000
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + testWithdraw1_Message + " ----------");
  var testWithdraw1_1Tx = staking.withdraw({from: user1, gas: 500000, gasPrice: defaultGasPrice});
  var testWithdraw1_2Tx = staking.withdraw({from: user2, gas: 500000, gasPrice: defaultGasPrice});
  var testWithdraw1_3Tx = staking.withdraw({from: user3, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  passIfTxStatusError(testWithdraw1_1Tx, testWithdraw1_Message + " - user1 -> staking.withdraw() - Expecting failure due to invalid notifier");
  passIfTxStatusError(testWithdraw1_2Tx, testWithdraw1_Message + " - user2 -> staking.withdraw() - Expecting failure due to invalid notifier");
  passIfTxStatusError(testWithdraw1_3Tx, testWithdraw1_Message + " - user3 -> staking.withdraw() - Expecting failure due to invalid notifier");
  printTxData("testWithdraw1_1Tx", testWithdraw1_1Tx);
  printTxData("testWithdraw1_2Tx", testWithdraw1_2Tx);
  printTxData("testWithdraw1_3Tx", testWithdraw1_3Tx);
  console.log("RESULT: ");
  printTokenContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
# egrep -e "tokenTx.*gasUsed|ordersTx.*gasUsed" $TEST1RESULTS
echo "---------- Results ----------"
egrep -e "PASS|FAIL" $TEST1RESULTS
