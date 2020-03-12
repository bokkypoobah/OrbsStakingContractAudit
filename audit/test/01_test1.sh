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
var _cooldownPeriodInSec = 5;
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

var allTests = false;

// Test Migration Manager Functions #1
// * `setMigrationManager(...)`
// * `setStakeChangeNotifier(...)`
// * `addMigrationDestination(...)`
// * `removeMigrationDestination(...)`

if (allTests || true) {
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

  printBalances();
  failIfTxStatusError(testMigrationManagerFunctions1_7Tx, testMigrationManagerFunctions1_Message + " - deployer -> staking.setStakeChangeNotifier(deployer)");
  passIfTxStatusError(testMigrationManagerFunctions1_8Tx, testMigrationManagerFunctions1_Message + " - user1 -> staking.removeMigrationDestination(miner) - Expecting failure");
  failIfTxStatusError(testMigrationManagerFunctions1_9Tx, testMigrationManagerFunctions1_Message + " - deployer -> staking.removeMigrationDestination(miner)");
  printTxData("testMigrationManagerFunctions1_7Tx", testMigrationManagerFunctions1_7Tx);
  printTxData("testMigrationManagerFunctions1_8Tx", testMigrationManagerFunctions1_8Tx);
  printTxData("testMigrationManagerFunctions1_9Tx", testMigrationManagerFunctions1_9Tx);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");

}

exit;

// Test Migration Manager Functions #1
if (allTests || true) {
  // -----------------------------------------------------------------------------
  var testAdminOwnership1_Message = "Test Admin Ownership #1";
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + testAdminOwnership1_Message + " ----------");
  // Tested with non-emergencyManager
  var testAdminOwnership1_1Tx = staking.setMigrationManager(deployer, {from: user1, gas: 500000, gasPrice: defaultGasPrice});
  var testAdminOwnership1_2Tx = staking.setEmergencyManager(deployer, {from: user2, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  var testAdminOwnership1_3Tx = staking.setMigrationManager(deployer, {from: migrationManager, gas: 500000, gasPrice: defaultGasPrice});
  var testAdminOwnership1_4Tx = staking.setEmergencyManager(deployer, {from: emergencyManager, gas: 500000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  passIfTxStatusError(testAdminOwnership1_1Tx, testAdminOwnership1_Message + " - user1 -> staking.setMigrationManager(deployer) - Expecting failure");
  passIfTxStatusError(testAdminOwnership1_2Tx, testAdminOwnership1_Message + " - user2 -> staking.setEmergencyManager(deployer) - Expecting failure");
  failIfTxStatusError(testAdminOwnership1_3Tx, testAdminOwnership1_Message + " - migrationManager -> staking.setMigrationManager(deployer)");
  failIfTxStatusError(testAdminOwnership1_4Tx, testAdminOwnership1_Message + " - emergencyManager -> staking.setEmergencyManager(deployer)");
  printTxData("testAdminOwnership1_1Tx", testAdminOwnership1_1Tx);
  printTxData("testAdminOwnership1_2Tx", testAdminOwnership1_2Tx);
  printTxData("testAdminOwnership1_3Tx", testAdminOwnership1_3Tx);
  printTxData("testAdminOwnership1_4Tx", testAdminOwnership1_4Tx);
  console.log("RESULT: ");
  printStakingContractDetails(0);
  console.log("RESULT: ");
  printStakingContractDetails(1);
  console.log("RESULT: ");
}


// Release All Stakes #1
if (allTests || false) {
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
if (allTests || false) {
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
  failIfTxStatusError(testUnstaking1_1Tx, testUnstaking1_Message + " - user1 -> staking.unstake(" + tokensToUnstake1.shift(-18).toString() + ")");
  failIfTxStatusError(testUnstaking1_2Tx, testUnstaking1_Message + " - user2 -> staking.unstake(" + tokensToUnstake2.shift(-18).toString() + ")");
  failIfTxStatusError(testUnstaking1_3Tx, testUnstaking1_Message + " - user3 -> staking.unstake(" + tokensToUnstake3.shift(-18).toString() + ")");
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


// Release All Stakes #2
if (allTests || false) {
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
if (allTests || false) {
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
  failIfTxStatusError(testWithdraw1_1Tx, testWithdraw1_Message + " - user1 -> staking.withdraw()");
  failIfTxStatusError(testWithdraw1_2Tx, testWithdraw1_Message + " - user2 -> staking.withdraw()");
  failIfTxStatusError(testWithdraw1_3Tx, testWithdraw1_Message + " - user3 -> staking.withdraw()");
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


// Test Distribute Rewards #1
if (allTests || true) {
  // -----------------------------------------------------------------------------
  var testDistributeRewards1_Message = "Test Distribute Rewards #1";
  // Check with _cooldownPeriodInSec 1 and 10000
  var totalAmount = new BigNumber(66).shift(18).toString();
  var stakeOwners = [user1, user2, user3];
  var amounts = [new BigNumber(11).shift(18).toString(), new BigNumber(22).shift(18).toString(), new BigNumber(33).shift(18).toString()];
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + deployGroup2_Message + " ----------");
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


exit;

// -----------------------------------------------------------------------------
var mintOptinoGroup1_Message = "Mint Optino Group #1";
var callPut = "0"; // 0 Call, 1 Put
var expiry = parseInt(new Date()/1000) + 2 * 60*60;
var strike = new BigNumber("200").shift(18);
// var strike1 = new BigNumber("201").shift(18);
var baseTokens = new BigNumber("10").shift(18);
var value = web3.toWei("100", "ether").toString();
// var _uiFeeAccount = "0x0000000000000000000000000000000000000000"; // or uiFeeAccount
var _uiFeeAccount = uiFeeAccount;
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + mintOptinoGroup1_Message + " ----------");
var data = vanillaOptinoFactory.mintOptinoTokens.getData(ethAddress, daiAddress, priceFeedAdaptorAddress, callPut, expiry, strike, baseTokens, _uiFeeAccount);
// console.log("RESULT: data: " + data);
var mintOptinoGroup1_1Tx = eth.sendTransaction({ to: vanillaOptinoFactoryAddress, from: maker1, data: data, value: value, gas: 6000000, gasPrice: defaultGasPrice });
// var mintOptinoGroup1_2Tx = vanillaOptinoFactory.mintOptinoTokens(wethAddress, daiAddress, priceFeedAdaptorAddress, callPut, expiry, strike, baseTokens, _uiFeeAccount, {from: maker1, gas: 6000000, gasPrice: defaultGasPrice});
// var mintOptinoGroup1_3Tx = vanillaOptinoFactory.mintOptinoTokens(wethAddress, daiAddress, priceFeedAdaptorAddress, callPut, expiry, strike, baseTokens, _uiFeeAccount, {from: maker1, gas: 6000000, gasPrice: defaultGasPrice});

while (txpool.status.pending > 0) {
}

var optinos = getVanillaOptinos();
console.log("RESULT: optinos=" + JSON.stringify(optinos));
for (var optinosIndex = 0; optinosIndex < optinos.length; optinosIndex++) {
  console.log(optinos[optinosIndex]);
  addAccount(optinos[optinosIndex], optinosIndex%2 == 0 ? "optinoToken" : "optinoCollateralToken");
  addTokenContractAddressAndAbi(optinosIndex + 2, optinos[optinosIndex], tokenAbi);
}

printBalances();
failIfTxStatusError(mintOptinoGroup1_1Tx, mintOptinoGroup1_Message + " - vanillaOptinoFactory.mintOptinoTokens(ETH, DAI, priceFeed, ...)");
// failIfTxStatusError(mintOptinoGroup1_2Tx, mintOptinoGroup1_Message + " - vanillaOptinoFactory.mintOptinoTokens(WETH, DAI, priceFeed, ...)");
// failIfTxStatusError(mintOptinoGroup1_3Tx, mintOptinoGroup1_Message + " - vanillaOptinoFactory.mintOptinoTokens(WETH, DAI, priceFeed, ...)");
printTxData("mintOptinoGroup1_1Tx", mintOptinoGroup1_1Tx);
// printTxData("mintOptinoGroup1_2Tx", mintOptinoGroup1_2Tx);
// printTxData("mintOptinoGroup1_3Tx", mintOptinoGroup1_3Tx);
console.log("RESULT: ");
printVanillaOptinoFactoryContractDetails();
console.log("RESULT: ");
printTokenContractDetails(0);
console.log("RESULT: ");
printTokenContractDetails(1);
console.log("RESULT: ");
printTokenContractDetails(2);
console.log("RESULT: ");
printTokenContractDetails(3);
console.log("RESULT: ");


if (false) {
// -----------------------------------------------------------------------------
var netOffGroup1_Message = "Net off Optino & OptinoCollateral";
var netOffBaseTokens = new BigNumber("2").shift(18);
var optino = web3.eth.contract(vanillaOptinoAbi).at(optinos[0]);
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + netOffGroup1_Message + " ----------");
var netOffGroup1_1Tx = optino.netOff(netOffBaseTokens, {from: maker1, gas: 2000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(netOffGroup1_1Tx, netOffGroup1_Message + " - optino.netOff()");
printTxData("netOffGroup1_1Tx", netOffGroup1_1Tx);
console.log("RESULT: ");
printPriceFeedContractDetails();
console.log("RESULT: ");
printPriceFeedAdaptorContractDetails();
console.log("RESULT: ");
printVanillaOptinoFactoryContractDetails();
console.log("RESULT: ");
printTokenContractDetails(0);
console.log("RESULT: ");
printTokenContractDetails(1);
console.log("RESULT: ");
// printTokenContractDetails(2);
// console.log("RESULT: ");
// printTokenContractDetails(3);
// console.log("RESULT: ");
}


if (true) {
  // -----------------------------------------------------------------------------
  var settleGroup1_Message = "Settle";
  var rate = new BigNumber("300").shift(18);
  var optino = web3.eth.contract(vanillaOptinoAbi).at(optinos[0]);
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + settleGroup1_Message + " ----------");
  var settleGroup1_1Tx = priceFeed.setValue(rate, true, {from: deployer, gas: 6000000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  var settleGroup1_1Tx = optino.settle({from: maker1, gas: 2000000, gasPrice: defaultGasPrice});
  while (txpool.status.pending > 0) {
  }
  printBalances();
  failIfTxStatusError(settleGroup1_1Tx, settleGroup1_Message + " - optino.settle()");
  printTxData("settleGroup1_1Tx", settleGroup1_1Tx);
  console.log("RESULT: ");
  printPriceFeedContractDetails();
  console.log("RESULT: ");
  printPriceFeedAdaptorContractDetails();
  console.log("RESULT: ");
  printVanillaOptinoFactoryContractDetails();
  console.log("RESULT: ");
  printTokenContractDetails(0);
  console.log("RESULT: ");
  printTokenContractDetails(1);
  console.log("RESULT: ");
  // printTokenContractDetails(2);
  // console.log("RESULT: ");
  // printTokenContractDetails(3);
  // console.log("RESULT: ");
}

exit;

// -----------------------------------------------------------------------------
var payoffCalcsGroup1_Message = "Payoff Calcs #1";
var rate = new BigNumber("250.123456789012345678").shift(18);
var optinoAddress = optinos[0];
var optino = web3.eth.contract(vanillaOptinoAbi).at(optinoAddress);
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + payoffCalcsGroup1_Message + " ----------");
var payoffCalcsGroup1_1Tx = priceFeed.setValue(rate, true, {from: deployer, gas: 6000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var payoffCalcsGroup1_2Tx = optino.setSpot({from: maker1, gas: 6000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(payoffCalcsGroup1_1Tx, payoffCalcsGroup1_Message + " - priceFeed.setValue()");
failIfTxStatusError(payoffCalcsGroup1_2Tx, payoffCalcsGroup1_Message + " - optino.setSpot()");
printTxData("payoffCalcsGroup1_1Tx", payoffCalcsGroup1_1Tx);
printTxData("payoffCalcsGroup1_2Tx", payoffCalcsGroup1_2Tx);
console.log("RESULT: ");
printPriceFeedContractDetails();
console.log("RESULT: ");
printPriceFeedAdaptorContractDetails();
console.log("RESULT: ");
printVanillaOptinoFactoryContractDetails();
console.log("RESULT: ");
printTokenContractDetails(0);
console.log("RESULT: ");
printTokenContractDetails(1);
console.log("RESULT: ");
// printTokenContractDetails(2);
// console.log("RESULT: ");
// printTokenContractDetails(3);
// console.log("RESULT: ");


exit;


// -----------------------------------------------------------------------------
var deployGroup2Message = "Deploy Group #1 - Deploy Second Token";
var symbol = "TEST";
var name = "Test";
var decimals = 18;
var totalSupply = new BigNumber("1000000000").shift(decimals);
var feeInEthers = new BigNumber("9.999999999999999999").shift(18);
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployGroup2Message + " ----------");
var deployToken_1Tx = tokenFactory.deployTokenContract(symbol, name, decimals, totalSupply, uiFeeAccount, {from: user1, value: feeInEthers, gas: 2000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var tokenContract = getTokenContractDeployed();
console.log("RESULT: tokenContract=#" + tokenContract.length + " " + JSON.stringify(tokenContract));
tokenAddress = tokenContract[0];
token = web3.eth.contract(tokenAbi).at(tokenAddress);
addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
console.log("DATA: var tokenAddress=\"" + tokenAddress + "\";");
console.log("DATA: var tokenAbi=" + JSON.stringify(tokenAbi) + ";");
console.log("DATA: var token=eth.contract(tokenAbi).at(tokenAddress);");

printBalances();
failIfTxStatusError(deployToken_1Tx, deployGroup2Message + " - Token");
printTxData("deployToken_1Tx", deployToken_1Tx);
console.log("RESULT: ");
printFactoryContractDetails();
console.log("RESULT: ");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testSecondInitMessage = "Test second init";
var symbol = "TEST2";
var name = "Test 2";
var decimals = 18;
var totalSupply = new BigNumber("1000000001").shift(decimals);
// Simulate error by commenting out in Owned:init(...) either of the two lines:
//   require(!initialised);
//   initialised = true;
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + testSecondInitMessage + " ----------");
// function init(address tokenOwner, string memory symbol, string memory name, uint8 decimals, uint fixedSupply)
console.log("RESULT: user2: " + user2);
console.log("RESULT: symbol: " + symbol);
console.log("RESULT: name: " + name);
console.log("RESULT: decimals: " + decimals);
console.log("RESULT: totalSupply: " + totalSupply.toString());
var testSecondInit_1Tx = token.init(user2, symbol, name, decimals, totalSupply.toString(), {from: user2, value: 0, gas: 2000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
passIfTxStatusError(testSecondInit_1Tx, testSecondInitMessage + " - expecting init() to fail");
printTxData("testSecondInit_1Tx", testSecondInit_1Tx);
console.log("RESULT: ");
printTokenContractDetails(0);
printTokenContractDetails(1);
console.log("RESULT: ");




EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
# egrep -e "tokenTx.*gasUsed|ordersTx.*gasUsed" $TEST1RESULTS
