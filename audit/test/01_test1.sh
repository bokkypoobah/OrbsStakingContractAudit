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
var _cooldownPeriodInSec = 60;
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
// constructor(uint256 _cooldownPeriodInSec, address _migrationManager, address _emergencyManager, IERC20 _token) public
var staking = stakingContract.new(_cooldownPeriodInSec, migrationManager, emergencyManager, tokenAddress, {from: deployer, data: stakingBin, gas: 5000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        stakingTx = contract.transactionHash;
      } else {
        stakingAddress = contract.address;
        addAccount(stakingAddress, "Staking");
        addAddressSymbol(stakingAddress, "Staking");
        addStakingContractAddressAndAbi(stakingAddress, stakingAbi);
        console.log("DATA: var stakingAddress=\"" + stakingAddress + "\";");
        console.log("DATA: var stakingAbi=" + JSON.stringify(stakingAbi) + ";");
        console.log("DATA: var staking=eth.contract(stakingAbi).at(stakingAddress);");
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(tokenTx, deployGroup1_Message + " - Token");
printTxData("tokenTx", tokenTx);
failIfTxStatusError(stakingTx, deployGroup1_Message + " - Staking");
printTxData("stakingTx", stakingTx);
console.log("RESULT: ");
printTokenContractDetails(0);
console.log("RESULT: ");
printStakingContractDetails();
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
var deployGroup2_4Tx = token.approve(stakingAddress, tokensToApprove.toString(), {from: user1, gas: 100000, gasPrice: defaultGasPrice});
var deployGroup2_5Tx = token.approve(stakingAddress, tokensToApprove.toString(), {from: user2, gas: 100000, gasPrice: defaultGasPrice});
var deployGroup2_6Tx = token.approve(stakingAddress, tokensToApprove.toString(), {from: user3, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(deployGroup2_1Tx, deployGroup2_Message + " - deployer -> token.transfer(user1, " + tokens.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_2Tx, deployGroup2_Message + " - deployer -> token.transfer(user2, " + tokens.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_3Tx, deployGroup2_Message + " - deployer -> token.transfer(user3, " + tokens.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_4Tx, deployGroup2_Message + " - user1 -> token.approve(stakingContract, " + tokensToApprove.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_5Tx, deployGroup2_Message + " - user2 -> token.approve(stakingContract, " + tokensToApprove.shift(-18).toString() + ")");
failIfTxStatusError(deployGroup2_6Tx, deployGroup2_Message + " - user3 -> token.approve(stakingContract, " + tokensToApprove.shift(-18).toString() + ")");
printTxData("deployGroup2_1Tx", deployGroup2_1Tx);
printTxData("deployGroup2_2Tx", deployGroup2_2Tx);
printTxData("deployGroup2_3Tx", deployGroup2_3Tx);
printTxData("deployGroup2_4Tx", deployGroup2_4Tx);
printTxData("deployGroup2_5Tx", deployGroup2_5Tx);
printTxData("deployGroup2_6Tx", deployGroup2_6Tx);
console.log("RESULT: ");
printTokenContractDetails(0);
console.log("RESULT: ");
printStakingContractDetails();
console.log("RESULT: ");

var allTests = false;

if (allTests || true) {
  // -----------------------------------------------------------------------------
  var testStaking1_Message = "Test Staking #1";
  var tokensToStake1 = new BigNumber("100").shift(18);
  var tokensToStake2 = new BigNumber("200").shift(18);
  var tokensToStake3 = new BigNumber("300").shift(18);
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + deployGroup2_Message + " ----------");
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
  printStakingContractDetails();
  console.log("RESULT: ");
}

if (allTests || true) {
  // -----------------------------------------------------------------------------
  var testUnstaking1_Message = "Test Unstaking #1";
  var tokensToUnstake1 = new BigNumber("10").shift(18);
  var tokensToUnstake2 = new BigNumber("20").shift(18);
  var tokensToUnstake3 = new BigNumber("30").shift(18);
  // -----------------------------------------------------------------------------
  console.log("RESULT: ---------- " + deployGroup2_Message + " ----------");
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
  printStakingContractDetails();
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
