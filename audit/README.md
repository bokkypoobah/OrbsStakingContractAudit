# Orbs Staking Contract Audit

Status: Work in progress

## Summary

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Risks](#risks)
* [Testing](#testing)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

* **VERY LOW IMPORTANCE** Add a function that will report back the length of the `approvedStakingContracts` array. So callers can iterate over 0..length, instead of 0..9 and detect an invalid address. I would not change the smart contracts just for this.

<br />

<hr />

## Potential Vulnerabilities

<br />

<hr />

## Scope

<br />

<hr />

## Limitations

<br />

<hr />

## Risks

<br />

<hr />

## Code Review

[OpenZeppelin Contracts v2.3.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v2.3.0)

Contracts reviewed:

* [ ] [flattened/StakingContract_flattened_comments.sol](flattened/StakingContract_flattened_comments.sol)
  * [x] library SafeMath
    * [x] `function add(...) internal`
    * [x] `function sub(...) internal`
    * [x] functions `mul(...)`, `div(...)` and `mod(...)` are unused in these smart contracts
  * [x] interface IERC20
  * [x] interface IMigratableStakingContract
  * [x] interface IStakingContract
  * [x] interface IStakeChangeNotifier
  * [ ] contract StakingContract is IStakingContract, IMigratableStakingContract
    * [x] using SafeMath for uint256;
    * [x] Structs, constants, variables, events and modifiers
    * [x] `constructor(...)`
    * [x] `function setMigrationManager(...) external`
    * [x] `function setEmergencyManager(...) external`
    * [x] `function setStakeChangeNotifier(...) external`
    * [x] `function addMigrationDestination(...) external`
    * [x] `function removeMigrationDestination(...) external`
    * [x] `function stake(...) external`
    * [x] `function unstake(...) external`
    * [x] `function withdraw() external`
    * [x] `function restake() external`
    * [ ] `function acceptMigration(...) external`
      * NOTE: See comments in `stake(...)` below
    * [ ] `function migrateStakedTokens(...) external`
    * [ ] `function distributeRewards(...) external`
    * [x] `function getStakeBalanceOf(...) external view`
    * [x] `function getTotalStakedTokens() external view`
    * [x] `function getUnstakeStatus(...) external view`
    * [x] `function getToken() external view`
    * [x] `function stopAcceptingNewStakes() external`
    * [x] `function releaseAllStakes() external`
    * [x] `function withdrawReleasedStakes(...) external`
    * [x] `function isApprovedStakingContract(...) public view`
    * [x] `function shouldNotifyStakeChange() view internal`
    * [ ] `function stakeChange(...) internal`
    * [ ] `function stakeChangeBatch(...) internal`
    * [ ] `function stakeMigration(...) internal`
    * [x] `function stake(...) private`
      * NOTE: Token balance is staked for `_stakeOwner`, while tokens are transferred from `msg.sender`'s account in the '`transferFrom(msg.sender, ...)` statement. This does not matter for the call from `stake(uint256)`, but can be different if an externally-owned-account directly executes `acceptMigration(...)`.
    * [x] `function withdraw(...) private`
    * [x] `function findApprovedStakingContractIndex(...) private view`

<br />

<hr />

## Testing

General testing setup with 250,000 (18 decimals) ERC20 token allocated to `deployer`, `user1`, `user2` and `user3`. 2 staking contracts, with the second staking contract
added as an `approvedStakingContracts` in the first staking contract.

### Constructor

* [x] Can only be executed once as this is a normal constructor
* [x] Variables set correctly - `cooldownPeriodInSec`, `migrationManager`, `emergencyManager` and `token`

Results:
```javascript
---------- Deploy Group #2 - Setup ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.111234081000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078932371000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.007166784000000000      250000.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.007166784000000000      250000.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.007166784000000000      250000.000000000000000000           0.000000000000000000 user3
 7 0x9fbfccdaf54799741c8ec053f6bcaf520fc53d4f        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x0b53e5ec7b91526f737b93200ba0a43797763f33        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking
 9 0x3605208ab7eeb9f905ab1f9615fb4915fd2453ec        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Deploy Group #2 - Setup - deployer -> token.transfer(user1, 250000)
PASS Deploy Group #2 - Setup - deployer -> token.transfer(user2, 250000)
PASS Deploy Group #2 - Setup - deployer -> token.transfer(user3, 250000)
PASS Deploy Group #2 - Setup - deployer -> token.approve(stakingContract, 1000)
PASS Deploy Group #2 - Setup - user1 -> token.approve(stakingContract, 1000)
PASS Deploy Group #2 - Setup - user2 -> token.approve(stakingContract, 1000)
PASS Deploy Group #2 - Setup - user3 -> token.approve(stakingContract, 1000)
deployGroup2_1Tx status=0x1 Success gas=100000 gasUsed=50917 costETH=0.008299471 costUSD=0.85326861351 @ ETH/USD=102.81 gasPrice=163 gwei block=62254 txIx=2 txId=0xd4d554d71055c3a588d255e4949f6bce5e9e560c2531b71a0a481ffd5055a380 @ 1584227191 Sat, 14 Mar 2020 23:06:31 UTC
deployGroup2_2Tx status=0x1 Success gas=100000 gasUsed=50917 costETH=0.008299471 costUSD=0.85326861351 @ ETH/USD=102.81 gasPrice=163 gwei block=62254 txIx=3 txId=0xc6df08eb6f3c0b415e7f62d33baf69f8951bceac50947dd2f9b2d84cfe7153c2 @ 1584227191 Sat, 14 Mar 2020 23:06:31 UTC
deployGroup2_3Tx status=0x1 Success gas=100000 gasUsed=50917 costETH=0.008299471 costUSD=0.85326861351 @ ETH/USD=102.81 gasPrice=163 gwei block=62254 txIx=4 txId=0x4c735ab3f3674c3895e43c8677ad6ecea7f51d5b9acaf7322bc1def9a14d149f @ 1584227191 Sat, 14 Mar 2020 23:06:31 UTC
deployGroup2_4Tx status=0x1 Success gas=100000 gasUsed=43968 costETH=0.007166784 costUSD=0.73681706304 @ ETH/USD=102.81 gasPrice=163 gwei block=62254 txIx=5 txId=0xadada3d9bf9eb858071bc1c0726d99400755d421a67644c16314a450fa825ce0 @ 1584227191 Sat, 14 Mar 2020 23:06:31 UTC
deployGroup2_5Tx status=0x1 Success gas=100000 gasUsed=43968 costETH=0.007166784 costUSD=0.73681706304 @ ETH/USD=102.81 gasPrice=163 gwei block=62254 txIx=1 txId=0xbe54f96a2fc32d11eb849f5d688d980ce7ccdeef17bb6d73218e6ca6ffda74fe @ 1584227191 Sat, 14 Mar 2020 23:06:31 UTC
deployGroup2_6Tx status=0x1 Success gas=100000 gasUsed=43968 costETH=0.007166784 costUSD=0.73681706304 @ ETH/USD=102.81 gasPrice=163 gwei block=62254 txIx=0 txId=0x4fa2e114db3a5eb49218b6885de43e1119fe2c32cc90463fe8f2f5bd52eecfcf @ 1584227191 Sat, 14 Mar 2020 23:06:31 UTC
deployGroup2_7Tx status=0x1 Success gas=100000 gasUsed=43968 costETH=0.007166784 costUSD=0.73681706304 @ ETH/USD=102.81 gasPrice=163 gwei block=62254 txIx=6 txId=0xca5934a6c6bde54ce18dfbeaaf64521eb8812332c8b8d114e61a018004b0f8d3 @ 1584227191 Sat, 14 Mar 2020 23:06:31 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0x9fbf
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Approval 0 #62254 tokenOwner=user2:0xa55a spender=Staking:0x0b53 tokens=1000
token0.Approval 1 #62254 tokenOwner=user1:0xa44a spender=Staking:0x0b53 tokens=1000
token0.Approval 2 #62254 tokenOwner=deployer:0xa11a spender=Staking:0x0b53 tokens=1000
token0.Approval 3 #62254 tokenOwner=user3:0xa66a spender=Staking:0x0b53 tokens=1000
token0.Transfer 0 #62254 from=deployer:0xa11a to=user1:0xa44a tokens=250000
token0.Transfer 1 #62254 from=deployer:0xa11a to=user2:0xa55a tokens=250000
token0.Transfer 2 #62254 from=deployer:0xa11a to=user3:0xa66a tokens=250000

stakingContractAddress=0x0b53e5ec7b91526f737b93200ba0a43797763f33
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x9fbf
stakingContract.approvedStakingContracts[0]=0x3605208ab7eeb9f905ab1f9615fb4915fd2453ec
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

stakingContractAddress=0x3605208ab7eeb9f905ab1f9615fb4915fd2453ec
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x9fbf
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

### `migrationManager` Admin Functions

Admin functions `setMigrationManager(...)`, `setStakeChangeNotifier(...)`, `addMigrationDestination(...)` and `removeMigrationDestination(...)`.

* [x] Can only be executed by `migrationManager`
* [x] Can only remove added migration destination
* [x] Intended state changes & logs

Results:
```javascript
---------- Test Migration Manager Functions #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.143324217000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.094984448000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.015759655000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.018246546000000000      250000.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.007166784000000000      250000.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.007166784000000000      250000.000000000000000000           0.000000000000000000 user3
 7 0x38d135023e9142251680f817b7f8bf5c45942cea        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x3d16d3b2115d9305ddc492ad6787e1d70f906633        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking
 9 0x66f6f1da92a72acaeed79e6a19a5ccb9fb8fe1a1        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Migration Manager Functions #1 - user1 -> staking.setMigrationManager(deployer) - Expecting failure
PASS Test Migration Manager Functions #1 - migrationManager -> staking.setMigrationManager(deployer)
PASS Test Migration Manager Functions #1 - user1 -> staking.setStakeChangeNotifier(miner) - Expecting failure
PASS Test Migration Manager Functions #1 - deployer -> staking.setStakeChangeNotifier(miner)
PASS Test Migration Manager Functions #1 - user1 -> staking.addMigrationDestination(miner) - Expecting failure
PASS Test Migration Manager Functions #1 - deployer -> staking.addMigrationDestination(miner)
testMigrationManagerFunctions1_1Tx status=0x0 Failure gas=500000 gasUsed=22652 costETH=0.003692276 costUSD=0.37960289556 @ ETH/USD=102.81 gasPrice=163 gwei block=63864 txIx=0 txId=0xf347a0bcd4792aefad3a9e633e423e1e853bb70e1af5e250fa9c5cabccf329c4 @ 1584230004 Sat, 14 Mar 2020 23:53:24 UTC
testMigrationManagerFunctions1_2Tx status=0x1 Success gas=500000 gasUsed=30419 costETH=0.004958297 costUSD=0.50976251457 @ ETH/USD=102.81 gasPrice=163 gwei block=63866 txIx=0 txId=0x7b5732e75a97687c86bb012627b6fe7279e849b082aad4ef5caf612dd6cd0d76 @ 1584230006 Sat, 14 Mar 2020 23:53:26 UTC
testMigrationManagerFunctions1_3Tx status=0x0 Failure gas=500000 gasUsed=22672 costETH=0.003695536 costUSD=0.37993805616 @ ETH/USD=102.81 gasPrice=163 gwei block=63868 txIx=2 txId=0x60e2c5222ed59bbe869a792b0a476e09f29f00d5e782c1c2087a0ccf12279a3e @ 1584230008 Sat, 14 Mar 2020 23:53:28 UTC
testMigrationManagerFunctions1_4Tx status=0x1 Success gas=500000 gasUsed=45422 costETH=0.007403786 costUSD=0.76118323866 @ ETH/USD=102.81 gasPrice=163 gwei block=63868 txIx=0 txId=0x573c892ad6b6d1ecf01fd6fcf3dc7854d5996e43c449544e32fba715c9469913 @ 1584230008 Sat, 14 Mar 2020 23:53:28 UTC
testMigrationManagerFunctions1_5Tx status=0x0 Failure gas=500000 gasUsed=22650 costETH=0.00369195 costUSD=0.3795693795 @ ETH/USD=102.81 gasPrice=163 gwei block=63868 txIx=3 txId=0x2007d9674447d5ba8233bf250baa7956470c277f75cadb8eb20797c1b6b6287a @ 1584230008 Sat, 14 Mar 2020 23:53:28 UTC
testMigrationManagerFunctions1_6Tx status=0x1 Success gas=500000 gasUsed=53057 costETH=0.008648291 costUSD=0.88913079771 @ ETH/USD=102.81 gasPrice=163 gwei block=63868 txIx=1 txId=0xf249032eebba95d5466aae11cf9efa72695d4cecd2d2873e4bf7905178db0fc3 @ 1584230008 Sat, 14 Mar 2020 23:53:28 UTC

stakingContractAddress=0x3d16d3b2115d9305ddc492ad6787e1d70f906633
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=deployer:0xa11a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x38d1
stakingContract.approvedStakingContracts[0]=0x66f6f1da92a72acaeed79e6a19a5ccb9fb8fe1a1
stakingContract.approvedStakingContracts[1]=0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e
stakingContract.approvedStakingContracts[2]=0x
stakingContract.notifier=0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
MigrationManagerUpdated 0 #63866 {"migrationManager":"0xa11aae29840fbb5c86e6fd4cf809eba183aef433"}
MigrationDestinationAdded 0 #63868 {"stakingContract":"0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e"}
StakeChangeNotifierUpdated 0 #63868 {"notifier":"0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e"}

stakingContractAddress=0x66f6f1da92a72acaeed79e6a19a5ccb9fb8fe1a1
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x38d1
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.158410030000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.106374562000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.015759655000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.021942245000000000      250000.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.007166784000000000      250000.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.007166784000000000      250000.000000000000000000           0.000000000000000000 user3
 7 0x38d135023e9142251680f817b7f8bf5c45942cea        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x3d16d3b2115d9305ddc492ad6787e1d70f906633        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking
 9 0x66f6f1da92a72acaeed79e6a19a5ccb9fb8fe1a1        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Migration Manager Functions #1 - deployer -> staking.setStakeChangeNotifier(deployer)
PASS Test Migration Manager Functions #1 - user1 -> staking.removeMigrationDestination(miner) - Expecting failure
PASS Test Migration Manager Functions #1 - deployer -> staking.removeMigrationDestination(miner)
PASS Test Migration Manager Functions #1 - deployer -> staking.removeMigrationDestination(miner) - Expecting failure as address already removed
testMigrationManagerFunctions1_7Tx status=0x1 Success gas=500000 gasUsed=15182 costETH=0.002474666 costUSD=0.25442041146 @ ETH/USD=102.81 gasPrice=163 gwei block=63872 txIx=0 txId=0xa9830b710ca6a6e83dac54babf2c67299aa4a56283eb1a2359d00b0a37ad82b5 @ 1584230012 Sat, 14 Mar 2020 23:53:32 UTC
testMigrationManagerFunctions1_8Tx status=0x0 Failure gas=500000 gasUsed=22673 costETH=0.003695699 costUSD=0.37995481419 @ ETH/USD=102.81 gasPrice=163 gwei block=63872 txIx=2 txId=0x99f0919143065cba71843cff5a245090a11cf71994fc329f04b17940838421e2 @ 1584230012 Sat, 14 Mar 2020 23:53:32 UTC
testMigrationManagerFunctions1_9Tx status=0x1 Success gas=500000 gasUsed=29262 costETH=0.004769706 costUSD=0.49037347386 @ ETH/USD=102.81 gasPrice=163 gwei block=63872 txIx=1 txId=0xa733304eb6b18afa223b61d5f9cb1f1b3bb1777633f0b56320f1746e827cfd1c @ 1584230012 Sat, 14 Mar 2020 23:53:32 UTC
testMigrationManagerFunctions1_10Tx status=0x0 Failure gas=500000 gasUsed=25434 costETH=0.004145742 costUSD=0.42622373502 @ ETH/USD=102.81 gasPrice=163 gwei block=63874 txIx=0 txId=0x78cf98acdca418a3e93c72aca9050d850c134bf98429921f6aae8c93c756c739 @ 1584230014 Sat, 14 Mar 2020 23:53:34 UTC

stakingContractAddress=0x3d16d3b2115d9305ddc492ad6787e1d70f906633
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=deployer:0xa11a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x38d1
stakingContract.approvedStakingContracts[0]=0x66f6f1da92a72acaeed79e6a19a5ccb9fb8fe1a1
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
MigrationDestinationRemoved 0 #63872 {"stakingContract":"0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e"}
StakeChangeNotifierUpdated 0 #63872 {"notifier":"0x0000000000000000000000000000000000000000"}

stakingContractAddress=0x66f6f1da92a72acaeed79e6a19a5ccb9fb8fe1a1
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x38d1
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

### `emergencyManager` Admin Functions

Admin functions - `setEmergencyManager(...)`, `stopAcceptingNewStakes()`, `releaseAllStakes()`

* [x] Can only be executed by `emergencyManager`
* [x] Intended state changes & logs

NOTE: If `releaseAllStakes()` is executed before `stopAcceptingNewStakes()` is executed, `stopAcceptingNewStakes()` can never be executed. This does not alter the program logic as the modifier `onlyWhenAcceptingNewStakes()` checks for both conditions.

Results:
```javascript
---------- Test Emergency Manager Functions #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.136924022000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.088706177000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0       -0.004965143000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.007166784000000000      250000.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.018117776000000000      250000.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.007166784000000000      250000.000000000000000000           0.000000000000000000 user3
 7 0xf42e922b9a245cc6fda2f1291b2937f4af790a82        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x4590d6158ef2de082c74f10c219bc8daeba3235c        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking
 9 0xe28365fb22b16a6e78a4a6a378e5f2872cefa4c3        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Emergency Manager Functions #1 - user2 -> staking.setEmergencyManager(deployer) - Expecting failure
PASS Test Emergency Manager Functions #1 - emergencyManager -> staking.setEmergencyManager(deployer)
PASS Test Emergency Manager Functions #1 - user2 -> staking.stopAcceptingNewStakes() - Expecting failure
PASS Test Emergency Manager Functions #1 - user2 -> staking.releaseAllStakes() - Expecting failure
PASS Test Emergency Manager Functions #1 - user2 -> staking.releaseAllStakes() - Expecting failure
PASS Test Emergency Manager Functions #1 - deployer -> staking.stopAcceptingNewStakes()
PASS Test Emergency Manager Functions #1 - deployer -> staking.releaseAllStakes()
testEmergencyManagerFunctions1_1Tx status=0x0 Failure gas=500000 gasUsed=22694 costETH=0.003699122 costUSD=0.38030673282 @ ETH/USD=102.81 gasPrice=163 gwei block=64467 txIx=0 txId=0x2b013120e74e777034dd04316d5bd1df04673c21e3560cbe759cf8c12425eea0 @ 1584230607 Sun, 15 Mar 2020 00:03:27 UTC
testEmergencyManagerFunctions1_2Tx status=0x1 Success gas=500000 gasUsed=30461 costETH=0.004965143 costUSD=0.51046635183 @ ETH/USD=102.81 gasPrice=163 gwei block=64469 txIx=0 txId=0x03c392cf6dd4697529ebb1ff61da883cda3f35654c75943ea136c6c7889e773c @ 1584230609 Sun, 15 Mar 2020 00:03:29 UTC
testEmergencyManagerFunctions1_3Tx status=0x0 Failure gas=500000 gasUsed=22223 costETH=0.003622349 costUSD=0.37241370069 @ ETH/USD=102.81 gasPrice=163 gwei block=64471 txIx=0 txId=0xc8c57677c73f811cfbda485c2a712cdebb8a7caedd515f9006857fdcc24e0bbe @ 1584230611 Sun, 15 Mar 2020 00:03:31 UTC
testEmergencyManagerFunctions1_4Tx status=0x0 Failure gas=500000 gasUsed=22267 costETH=0.003629521 costUSD=0.37315105401 @ ETH/USD=102.81 gasPrice=163 gwei block=64471 txIx=1 txId=0xc11067522de0dcd6a23c9c602c816bfea228a37a9174e1cf3e5fb0a38952e543 @ 1584230611 Sun, 15 Mar 2020 00:03:31 UTC
testEmergencyManagerFunctions1_5Tx status=0x1 Success gas=500000 gasUsed=30377 costETH=0.004951451 costUSD=0.50905867731 @ ETH/USD=102.81 gasPrice=163 gwei block=64473 txIx=0 txId=0x529d4f91fd8d666e5e1a1b24c564da77ce0dd61f50fa61dd589f9064f6c4d0dd @ 1584230613 Sun, 15 Mar 2020 00:03:33 UTC
testEmergencyManagerFunctions1_6Tx status=0x1 Success gas=500000 gasUsed=29585 costETH=0.004822355 costUSD=0.49578631755 @ ETH/USD=102.81 gasPrice=163 gwei block=64473 txIx=1 txId=0x4007b6dc4a8faea72bf14b69688c3be6879b848bb4a4903a5bb71f41b65126b9 @ 1584230613 Sun, 15 Mar 2020 00:03:33 UTC

stakingContractAddress=0x4590d6158ef2de082c74f10c219bc8daeba3235c
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=deployer:0xa11a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf42e
stakingContract.approvedStakingContracts[0]=0xe28365fb22b16a6e78a4a6a378e5f2872cefa4c3
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=false
stakingContract.releasingAllStakes=true
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
EmergencyManagerUpdated 0 #64469 {"emergencyManager":"0xa11aae29840fbb5c86e6fd4cf809eba183aef433"}
StoppedAcceptingNewStake 0 #64473 {}
ReleasedAllStakes 0 #64473 {}

stakingContractAddress=0xe28365fb22b16a6e78a4a6a378e5f2872cefa4c3
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf42e
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

<hr />

### Regular workflow

Set up with `cooldownPeriodInSec` set to 1 seconds to test the withdrawal.

<br />

#### `stake(...)`

`user1` stakes 100 tokens, `user2` 200 and `user3` 300.

* [x] Any account with tokens `approve(...)`-d to the staking contract can stake
* [x] Intended state changes & logs
* Also tested
  * [x] Cannot stake more than approved amount
  * [x] Cannot stake 0 tokens
  * [x] Account without approve tokens/token balance cannot stake

Results:
```javascript
---------- Test Staking #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.153604953000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.019661712000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.024551712000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.019661712000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xb797d2439cd318684f93de852b4928ea75ae6917        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x9fb3c6433aa45e3eb6df7d4f1ed943a8138a4923        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0xd53380f36e665634cf48ec4745c7095cde2c9d7f        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Staking #1 - user1 -> staking.stake(100)
PASS Test Staking #1 - user2 -> staking.stake(200)
PASS Test Staking #1 - user3 -> staking.stake(300)
testStaking1_1Tx status=0x1 Success gas=500000 gasUsed=76656 costETH=0.012494928 costUSD=1.28460354768 @ ETH/USD=102.81 gasPrice=163 gwei block=823 txIx=1 txId=0x726f4f137f5d71a66ca98aee46772b98cbe24921ee9913e9beb4aab1e9eb7ae9 @ 1584400091 Mon, 16 Mar 2020 23:08:11 UTC
testStaking1_2Tx status=0x1 Success gas=500000 gasUsed=106656 costETH=0.017384928 costUSD=1.78734444768 @ ETH/USD=102.81 gasPrice=163 gwei block=823 txIx=0 txId=0xb63eeac2488cfd720b6346119877935d39abc4da24514462e43e0b350e90a99b @ 1584400091 Mon, 16 Mar 2020 23:08:11 UTC
testStaking1_3Tx status=0x1 Success gas=500000 gasUsed=76656 costETH=0.012494928 costUSD=1.28460354768 @ ETH/USD=102.81 gasPrice=163 gwei block=823 txIx=2 txId=0xa535f643afa845c998c1ac876a765ddf159b297f3f232796252372272c34e170 @ 1584400091 Mon, 16 Mar 2020 23:08:11 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xb797
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Transfer 0 #823 from=user2:0xa55a to=Staking:0x9fb3 tokens=200
token0.Transfer 1 #823 from=user1:0xa44a to=Staking:0x9fb3 tokens=100
token0.Transfer 2 #823 from=user3:0xa66a to=Staking:0x9fb3 tokens=300

stakingContractAddress=0x9fb3c6433aa45e3eb6df7d4f1ed943a8138a4923
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xb797
stakingContract.approvedStakingContracts[0]=0xd53380f36e665634cf48ec4745c7095cde2c9d7f
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=600
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=200
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
Staked 0 #823 stakeOwner=user2:0xa55a, amount=200, totalStakedAmount=200
Staked 1 #823 stakeOwner=user1:0xa44a, amount=100, totalStakedAmount=100
Staked 2 #823 stakeOwner=user3:0xa66a, amount=300, totalStakedAmount=300

stakingContractAddress=0xd53380f36e665634cf48ec4745c7095cde2c9d7f
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xb797
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

#### `unstake(...)`

`user1` unstakes 10 tokens, `user2` 20 and `user3` 30.

* [x] Any account with staked tokens can unstake a portion of staked tokens
* [x] Intended state changes & logs

Results:
```javascript
---------- Test Unstaking #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.192519573000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.032631948000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.037523904000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.032633904000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xb797d2439cd318684f93de852b4928ea75ae6917        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x9fb3c6433aa45e3eb6df7d4f1ed943a8138a4923        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0xd53380f36e665634cf48ec4745c7095cde2c9d7f        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Unstaking #1 - user1 -> staking.unstake(10)
PASS Test Unstaking #1 - user2 -> staking.unstake(20)
PASS Test Unstaking #1 - user3 -> staking.unstake(30)
testUnstaking1_1Tx status=0x1 Success gas=500000 gasUsed=79572 costETH=0.012970236 costUSD=1.33346996316 @ ETH/USD=102.81 gasPrice=163 gwei block=827 txIx=0 txId=0xf5ae22548b6cd7cba9aadb9e3a645f1c4bf0ef182fdbe0ba6bc35f534fdf3cf7 @ 1584400095 Mon, 16 Mar 2020 23:08:15 UTC
testUnstaking1_2Tx status=0x1 Success gas=500000 gasUsed=79584 costETH=0.012972192 costUSD=1.33367105952 @ ETH/USD=102.81 gasPrice=163 gwei block=827 txIx=2 txId=0x497b958745d9f427078cc6ce6e0cac5889ebc429581d40850527d52060e0adff @ 1584400095 Mon, 16 Mar 2020 23:08:15 UTC
testUnstaking1_3Tx status=0x1 Success gas=500000 gasUsed=79584 costETH=0.012972192 costUSD=1.33367105952 @ ETH/USD=102.81 gasPrice=163 gwei block=827 txIx=1 txId=0x5c32534a3902288254353e1abf61bf4948c575b89e619cfde95cd76c0f2f65cb @ 1584400095 Mon, 16 Mar 2020 23:08:15 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xb797
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000

stakingContractAddress=0x9fb3c6433aa45e3eb6df7d4f1ed943a8138a4923
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xb797
stakingContract.approvedStakingContracts[0]=0xd53380f36e665634cf48ec4745c7095cde2c9d7f
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=540
stakingContract.getStakeBalanceOf(user1:0xa44a)=90
stakingContract.getUnstakeStatus(user1:0xa44a)=10, cooldownEndTime=1584400096
stakingContract.getStakeBalanceOf(user2:0xa55a)=180
stakingContract.getUnstakeStatus(user2:0xa55a)=20, cooldownEndTime=1584400096
stakingContract.getStakeBalanceOf(user3:0xa66a)=270
stakingContract.getUnstakeStatus(user3:0xa66a)=30, cooldownEndTime=1584400096
Unstaked 0 #827 stakeOwner=user1:0xa44a, amount=10, totalStakedAmount=90
Unstaked 1 #827 stakeOwner=user3:0xa66a, amount=30, totalStakedAmount=270
Unstaked 2 #827 stakeOwner=user2:0xa55a, amount=20, totalStakedAmount=180

stakingContractAddress=0xd53380f36e665634cf48ec4745c7095cde2c9d7f
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xb797
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

#### `distributeRewards(...)`

`deployer` distributes 11 tokens to `user1`, 22 tokens to `user2` and 33 tokens to `user3`

* [x] Any account with `approve(...)`-d tokens can distribute rewards to other accounts
* [x] Intended state changes & logs
* [x] Can distribute to account with no staked or unstaked tokens? Yes

Results:

```javascript
---------- Test Distribute Rewards #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.210141829000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.096550715000000000      249890.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.032631948000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.037523904000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.032633904000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xb797d2439cd318684f93de852b4928ea75ae6917        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x9fb3c6433aa45e3eb6df7d4f1ed943a8138a4923        0.000000000000000000         710.000000000000000000           0.000000000000000000 Staking
 9 0xd53380f36e665634cf48ec4745c7095cde2c9d7f        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Distribute Rewards #1 - deployer -> staking.distributeRewards(66, [user1, user2, user3, miner], [11, 22, 33, 44])
testDistributeRewards1_1Tx status=0x1 Success gas=1000000 gasUsed=108112 costETH=0.017622256 costUSD=1.81174413936 @ ETH/USD=102.81 gasPrice=163 gwei block=831 txIx=0 txId=0x9d1ceef8432f777aadc1f854bfc57d39753e0c2d465191aa4cf256d6f52deaf4 @ 1584400099 Mon, 16 Mar 2020 23:08:19 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xb797
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Transfer 0 #831 from=deployer:0xa11a to=Staking:0x9fb3 tokens=110

stakingContractAddress=0x9fb3c6433aa45e3eb6df7d4f1ed943a8138a4923
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xb797
stakingContract.approvedStakingContracts[0]=0xd53380f36e665634cf48ec4745c7095cde2c9d7f
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=650
stakingContract.getStakeBalanceOf(user1:0xa44a)=101
stakingContract.getUnstakeStatus(user1:0xa44a)=10, cooldownEndTime=1584400096
stakingContract.getStakeBalanceOf(user2:0xa55a)=202
stakingContract.getUnstakeStatus(user2:0xa55a)=20, cooldownEndTime=1584400096
stakingContract.getStakeBalanceOf(user3:0xa66a)=303
stakingContract.getUnstakeStatus(user3:0xa66a)=30, cooldownEndTime=1584400096
Staked 0 #831 stakeOwner=user1:0xa44a, amount=11, totalStakedAmount=101
Staked 1 #831 stakeOwner=user2:0xa55a, amount=22, totalStakedAmount=202
Staked 2 #831 stakeOwner=user3:0xa66a, amount=33, totalStakedAmount=303
Staked 3 #831 stakeOwner=miner:0xa00a, amount=44, totalStakedAmount=44

stakingContractAddress=0xd53380f36e665634cf48ec4745c7095cde2c9d7f
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xb797
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

#### `migrateStakedTokens(...)`

`user1` migrates 1 token from the first staking contract to the second, `user2` migrates 2 tokens and `user3` migrates 3 tokens

* [x] Any account with staked tokens can migrate tokens to the new approved staking contract
  * [x] Tokens transferred to the new staking contract
* [x] Intended state changes & logs

Results:
```javascript
---------- Test Migrate #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.265303963000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.096550715000000000      249890.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.054279326000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.054281282000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.049391282000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xb797d2439cd318684f93de852b4928ea75ae6917        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x9fb3c6433aa45e3eb6df7d4f1ed943a8138a4923        0.000000000000000000         704.000000000000000000           0.000000000000000000 Staking
 9 0xd53380f36e665634cf48ec4745c7095cde2c9d7f        0.000000000000000000           6.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Migrate #1 - user1 -> staking.migrateStakedTokens(staking2, 1)
PASS Test Migrate #1 - user2 -> staking.migrateStakedTokens(staking2, 2)
PASS Test Migrate #1 - user3 -> staking.migrateStakedTokens(staking2, 3)
testMigrateStakedTokens1_1Tx status=0x1 Success gas=500000 gasUsed=132806 costETH=0.021647378 costUSD=2.22556693218 @ ETH/USD=102.81 gasPrice=163 gwei block=835 txIx=0 txId=0x4e7e77ef6cdde9e2c81a596d3cf13d5b6c39c2b18b20fd11270b9deffb865ebe @ 1584400103 Mon, 16 Mar 2020 23:08:23 UTC
testMigrateStakedTokens1_2Tx status=0x1 Success gas=500000 gasUsed=102806 costETH=0.016757378 costUSD=1.72282603218 @ ETH/USD=102.81 gasPrice=163 gwei block=835 txIx=2 txId=0x1293c9af87ccb181bad72e73d7eb16a95b1156519cd545f53b376d08eeee4da7 @ 1584400103 Mon, 16 Mar 2020 23:08:23 UTC
testMigrateStakedTokens1_3Tx status=0x1 Success gas=500000 gasUsed=102806 costETH=0.016757378 costUSD=1.72282603218 @ ETH/USD=102.81 gasPrice=163 gwei block=835 txIx=1 txId=0x572ce0d4886c9a5e457a8376deabba89f9603a9daec74b54c892ff4281443897 @ 1584400103 Mon, 16 Mar 2020 23:08:23 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xb797
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Approval 0 #835 tokenOwner=Staking:0x9fb3 spender=Staking2:0xd533 tokens=1
token0.Approval 1 #835 tokenOwner=Staking:0x9fb3 spender=Staking2:0xd533 tokens=3
token0.Approval 2 #835 tokenOwner=Staking:0x9fb3 spender=Staking2:0xd533 tokens=2
token0.Transfer 0 #835 from=Staking:0x9fb3 to=Staking2:0xd533 tokens=1
token0.Transfer 1 #835 from=Staking:0x9fb3 to=Staking2:0xd533 tokens=3
token0.Transfer 2 #835 from=Staking:0x9fb3 to=Staking2:0xd533 tokens=2

stakingContractAddress=0x9fb3c6433aa45e3eb6df7d4f1ed943a8138a4923
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xb797
stakingContract.approvedStakingContracts[0]=0xd53380f36e665634cf48ec4745c7095cde2c9d7f
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=644
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=10, cooldownEndTime=1584400096
stakingContract.getStakeBalanceOf(user2:0xa55a)=200
stakingContract.getUnstakeStatus(user2:0xa55a)=20, cooldownEndTime=1584400096
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=30, cooldownEndTime=1584400096
MigratedStake 0 #835 stakeOwner=user1:0xa44a, amount=1, totalStakedAmount=100
MigratedStake 1 #835 stakeOwner=user3:0xa66a, amount=3, totalStakedAmount=300
MigratedStake 2 #835 stakeOwner=user2:0xa55a, amount=2, totalStakedAmount=200

stakingContractAddress=0xd53380f36e665634cf48ec4745c7095cde2c9d7f
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xb797
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=6
stakingContract.getStakeBalanceOf(user1:0xa44a)=1
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=2
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=3
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

#### `withdraw(...)`

`user1`, `user2` and `user3` withdraw unstaked tokens

* [x] Any account with unstaked tokens can withdraw their unstaked tokens
  * [x] Tokens transferred back to account from the staking contract
* [x] Intended state changes & logs

Results:
```javascript
---------- Test Withdraw #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.278402806000000000           4.444400000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.096550715000000000      249890.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.058645607000000000      249910.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.058647563000000000      249820.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.053757563000000000      249730.000000000000000000           0.000000000000000000 user3
 7 0xb797d2439cd318684f93de852b4928ea75ae6917        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x9fb3c6433aa45e3eb6df7d4f1ed943a8138a4923        0.000000000000000000         639.555600000000000000           0.000000000000000000 Staking
 9 0xd53380f36e665634cf48ec4745c7095cde2c9d7f        0.000000000000000000           6.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Withdraw #1 - user1 -> staking.withdraw()
PASS Test Withdraw #1 - user2 -> staking.withdraw()
PASS Test Withdraw #1 - user3 -> staking.withdraw()
PASS Test Withdraw #1 - miner -> staking.unstake(4.4444)
PASS Test Withdraw #1 - miner -> staking.withdraw()
testWithdraw1_1Tx status=0x1 Success gas=500000 gasUsed=26787 costETH=0.004366281 costUSD=0.44889734961 @ ETH/USD=102.81 gasPrice=163 gwei block=839 txIx=0 txId=0xbda3dfacd1b0564334feaffdd4ace69aad7c54de751e38e1adc2d6f6704649f7 @ 1584400107 Mon, 16 Mar 2020 23:08:27 UTC
testWithdraw1_2Tx status=0x1 Success gas=500000 gasUsed=26787 costETH=0.004366281 costUSD=0.44889734961 @ ETH/USD=102.81 gasPrice=163 gwei block=839 txIx=3 txId=0x190fcb2755990dfb231861f78a7acf030761a9504cc4f32e93f09aa1074d67ea @ 1584400107 Mon, 16 Mar 2020 23:08:27 UTC
testWithdraw1_3Tx status=0x1 Success gas=500000 gasUsed=26787 costETH=0.004366281 costUSD=0.44889734961 @ ETH/USD=102.81 gasPrice=163 gwei block=839 txIx=2 txId=0xb3ba73c63bade2030d0daac36726f5335fdd180dfd2d7358270a83ecc0cd7d87 @ 1584400107 Mon, 16 Mar 2020 23:08:27 UTC
testWithdraw1_4Tx status=0x1 Success gas=500000 gasUsed=79572 costETH=0.012970236 costUSD=1.33346996316 @ ETH/USD=102.81 gasPrice=163 gwei block=839 txIx=1 txId=0x9890071b122e8f3e85426770ffbe798c8d4509b42b7edafd126e6f06ed3e8e89 @ 1584400107 Mon, 16 Mar 2020 23:08:27 UTC
testWithdraw1_5Tx status=0x1 Success gas=500000 gasUsed=38573 costETH=0.006287399 costUSD=0.64640749119 @ ETH/USD=102.81 gasPrice=163 gwei block=841 txIx=0 txId=0xa71721855e7938bc59b6015289c3ee554311442a73dc30915fe4584ced081117 @ 1584400109 Mon, 16 Mar 2020 23:08:29 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xb797
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Transfer 0 #839 from=Staking:0x9fb3 to=user1:0xa44a tokens=10
token0.Transfer 1 #839 from=Staking:0x9fb3 to=user3:0xa66a tokens=30
token0.Transfer 2 #839 from=Staking:0x9fb3 to=user2:0xa55a tokens=20
token0.Transfer 3 #841 from=Staking:0x9fb3 to=miner:0xa00a tokens=4.4444

stakingContractAddress=0x9fb3c6433aa45e3eb6df7d4f1ed943a8138a4923
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xb797
stakingContract.approvedStakingContracts[0]=0xd53380f36e665634cf48ec4745c7095cde2c9d7f
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=639.5556
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=200
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
Unstaked 0 #839 stakeOwner=miner:0xa00a, amount=4.4444, totalStakedAmount=39.5556
Withdrew 0 #839 stakeOwner=user1:0xa44a, amount=10, totalStakedAmount=100
Withdrew 1 #839 stakeOwner=user3:0xa66a, amount=30, totalStakedAmount=300
Withdrew 2 #839 stakeOwner=user2:0xa55a, amount=20, totalStakedAmount=200
Withdrew 3 #841 stakeOwner=miner:0xa00a, amount=4.4444, totalStakedAmount=39.5556

stakingContractAddress=0xd53380f36e665634cf48ec4745c7095cde2c9d7f
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xb797
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=6
stakingContract.getStakeBalanceOf(user1:0xa44a)=1
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=2
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=3
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

<hr />

### Other workflows

Like regular workflows section, but with small differences.

<br />

#### `restake(...)`

`user1`, `user2` and `user3` restake unstaked tokens

* [x] Any account with unstaked tokens can restake their unstaked tokens
* [x] Intended state changes & logs

Results:
```javascript
---------- Test Unstaking #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.192519573000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.037521948000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.032633904000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.032633904000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xe8291b4dc4c7bfa6046b4502fc4a0465eff4a512        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x34f34f5d54c022463622b9e9bc77b10edd2b5b3f        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x4c01da023142a1b222d185880f75cbb78916ac99        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Unstaking #1 - user1 -> staking.unstake(10)
PASS Test Unstaking #1 - user2 -> staking.unstake(20)
PASS Test Unstaking #1 - user3 -> staking.unstake(30)
testUnstaking1_1Tx status=0x1 Success gas=500000 gasUsed=79572 costETH=0.012970236 costUSD=1.33346996316 @ ETH/USD=102.81 gasPrice=163 gwei block=67515 txIx=0 txId=0x15b5213af0917dfa083930a5c2f64ca3cad45cbf9375cc0440a1740c8d2c4a96 @ 1584233655 Sun, 15 Mar 2020 00:54:15 UTC
testUnstaking1_2Tx status=0x1 Success gas=500000 gasUsed=79584 costETH=0.012972192 costUSD=1.33367105952 @ ETH/USD=102.81 gasPrice=163 gwei block=67515 txIx=2 txId=0x62442e10be8c657d75cf36db047a7b126298aaf25b636a2b6ccff82ef5ac0bba @ 1584233655 Sun, 15 Mar 2020 00:54:15 UTC
testUnstaking1_3Tx status=0x1 Success gas=500000 gasUsed=79584 costETH=0.012972192 costUSD=1.33367105952 @ ETH/USD=102.81 gasPrice=163 gwei block=67515 txIx=1 txId=0x5259610093f3e2bad1e07562638aada76a341b336a0ebca7c6f8d61edf9a65c1 @ 1584233655 Sun, 15 Mar 2020 00:54:15 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xe829
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000

stakingContractAddress=0x34f34f5d54c022463622b9e9bc77b10edd2b5b3f
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xe829
stakingContract.approvedStakingContracts[0]=0x4c01da023142a1b222d185880f75cbb78916ac99
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=540
stakingContract.getStakeBalanceOf(user1:0xa44a)=90
stakingContract.getUnstakeStatus(user1:0xa44a)=10, cooldownEndTime=1584233660
stakingContract.getStakeBalanceOf(user2:0xa55a)=180
stakingContract.getUnstakeStatus(user2:0xa55a)=20, cooldownEndTime=1584233660
stakingContract.getStakeBalanceOf(user3:0xa66a)=270
stakingContract.getUnstakeStatus(user3:0xa66a)=30, cooldownEndTime=1584233660
Unstaked 0 #67515 stakeOwner=user1:0xa44a, amount=10, totalStakedAmount=90
Unstaked 1 #67515 stakeOwner=user3:0xa66a, amount=30, totalStakedAmount=270
Unstaked 2 #67515 stakeOwner=user2:0xa55a, amount=20, totalStakedAmount=180

stakingContractAddress=0x4c01da023142a1b222d185880f75cbb78916ac99
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xe829
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

---------- Test Restake #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.204543105000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.041529792000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.036641748000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.036641748000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xe8291b4dc4c7bfa6046b4502fc4a0465eff4a512        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x34f34f5d54c022463622b9e9bc77b10edd2b5b3f        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x4c01da023142a1b222d185880f75cbb78916ac99        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Restake #1 - user1 -> staking.restake()
PASS Test Restake #1 - user2 -> staking.restake()
PASS Test Restake #1 - user3 -> staking.restake()
testRestake1_1Tx status=0x1 Success gas=500000 gasUsed=24588 costETH=0.004007844 costUSD=0.41204644164 @ ETH/USD=102.81 gasPrice=163 gwei block=67519 txIx=1 txId=0x2a09292584bb3e54f573dadfc9c419cfd4c705f9a49bc0d64d3b1433e4ab5dee @ 1584233659 Sun, 15 Mar 2020 00:54:19 UTC
testRestake1_2Tx status=0x1 Success gas=500000 gasUsed=24588 costETH=0.004007844 costUSD=0.41204644164 @ ETH/USD=102.81 gasPrice=163 gwei block=67519 txIx=0 txId=0x7c09c36c7d4b8c4be52a880abf69a5c2fd4f3534123f0daf92a889fb682bbb67 @ 1584233659 Sun, 15 Mar 2020 00:54:19 UTC
testRestake1_3Tx status=0x1 Success gas=500000 gasUsed=24588 costETH=0.004007844 costUSD=0.41204644164 @ ETH/USD=102.81 gasPrice=163 gwei block=67519 txIx=2 txId=0x956af01be5d0a7b04de41477d98b204c023001d2a4bb7fdbd04d9fd974707199 @ 1584233659 Sun, 15 Mar 2020 00:54:19 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xe829
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000

stakingContractAddress=0x34f34f5d54c022463622b9e9bc77b10edd2b5b3f
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xe829
stakingContract.approvedStakingContracts[0]=0x4c01da023142a1b222d185880f75cbb78916ac99
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=600
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=200
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
Restaked 0 #67519 stakeOwner=user2:0xa55a, amount=20, totalStakedAmount=200
Restaked 1 #67519 stakeOwner=user1:0xa44a, amount=10, totalStakedAmount=100
Restaked 2 #67519 stakeOwner=user3:0xa66a, amount=30, totalStakedAmount=300

stakingContractAddress=0x4c01da023142a1b222d185880f75cbb78916ac99
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xe829
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

### `withdrawReleasedStakes(...)`

Scenario:

* `cooldownPeriodInSec` is set to 10000
* `user1` has 100 tokens staked
* `user2` has 180 tokens staked, and 20 tokens unstaked in the cooldown period
* `user3` has 0 tokens staked, and 300 tokens unstaked in the cooldown period
* `emergencyManager` executes `releaseAllStakes(...)`
* `user1` executes `withdrawReleasedStakes(["user1", "user2" and "user3"])`.

Tests:

* [x] Any account can withdraw both staked and unstaked tokens on behalf of any account with staked and/or unstaked tokens, after `emergencyManager` executes `releasedAllStakes(...)`
  * [x] Tokens transferred back to account from the staking contract
* [x] Intended state changes & logs
* [x] Cannot execute this function for accounts without any staked or unstaked tokens

Results:
```javascript
---------- Test Unstaking #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.177108249000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078932371000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.019661712000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.032633904000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.035078904000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xe4d97f7a85d1454c2a4efc020742278f61030b4d        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xbaded2da306b54bac880043418105f4491c3d617        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x63b72794f3efca62e570e127b774889c470bf238        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Unstaking #1 - user2 -> staking.unstake(20)
PASS Test Unstaking #1 - user3 -> staking.unstake(300)
testUnstaking1_2Tx status=0x1 Success gas=500000 gasUsed=79584 costETH=0.012972192 costUSD=1.33367105952 @ ETH/USD=102.81 gasPrice=163 gwei block=69682 txIx=0 txId=0x03db564de79c82409135bf07b0ada4bc75cdf5a30df855df7990393f57f55661 @ 1584237359 Sun, 15 Mar 2020 01:55:59 UTC
testUnstaking1_3Tx status=0x1 Success gas=500000 gasUsed=64584 costETH=0.010527192 costUSD=1.08230060952 @ ETH/USD=102.81 gasPrice=163 gwei block=69682 txIx=1 txId=0x636c6a00d45d96563453a943e5cc6a54e66d4e67839be39bfc7cbda790398aa6 @ 1584237359 Sun, 15 Mar 2020 01:55:59 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xe4d9
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000

stakingContractAddress=0xbaded2da306b54bac880043418105f4491c3d617
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xe4d9
stakingContract.approvedStakingContracts[0]=0x63b72794f3efca62e570e127b774889c470bf238
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=280
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=180
stakingContract.getUnstakeStatus(user2:0xa55a)=20, cooldownEndTime=1584247359
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=300, cooldownEndTime=1584247359
Unstaked 0 #69682 stakeOwner=user2:0xa55a, amount=20, totalStakedAmount=180
Unstaked 1 #69682 stakeOwner=user3:0xa66a, amount=300, totalStakedAmount=0

stakingContractAddress=0x63b72794f3efca62e570e127b774889c470bf238
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xe4d9
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

---------- Withdraw Released Stakes #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.212745917000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.109747684000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0       -0.004822355000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.019661712000000000      250000.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.032633904000000000      250000.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.035078904000000000      250000.000000000000000000           0.000000000000000000 user3
 7 0xe4d97f7a85d1454c2a4efc020742278f61030b4d        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xbaded2da306b54bac880043418105f4491c3d617        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking
 9 0x63b72794f3efca62e570e127b774889c470bf238        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Withdraw Released Stakes #1 - emergencyManager -> staking.releaseAllStakes()
PASS Withdraw Released Stakes #1 - deployer -> staking.withdrawReleasedStakes([user1, user2, user3, deployer]) - Expecting to fail as deployer does not have unstaked tokens
PASS Withdraw Released Stakes #1 - deployer -> staking.withdrawReleasedStakes([user1, user2, user3])
withdrawReleasedStakes2_1Tx status=0x1 Success gas=500000 gasUsed=29585 costETH=0.004822355 costUSD=0.49578631755 @ ETH/USD=102.81 gasPrice=163 gwei block=69686 txIx=0 txId=0xbbcea1cda73469b0948798b193be37b3d0e0a2fae7c60a586fa5297dce87337a @ 1584237363 Sun, 15 Mar 2020 01:56:03 UTC
withdrawReleasedStakes2_2Tx status=0x0 Failure gas=500000 gasUsed=126863 costETH=0.020678669 costUSD=2.12597395989 @ ETH/USD=102.81 gasPrice=163 gwei block=69688 txIx=0 txId=0xd3c84338c0d69d550aa4cdd61798643e3dcbeeabbe310b53e2ada7db1d0b02d0 @ 1584237365 Sun, 15 Mar 2020 01:56:05 UTC
withdrawReleasedStakes2_3Tx status=0x1 Success gas=500000 gasUsed=62188 costETH=0.010136644 costUSD=1.04214836964 @ ETH/USD=102.81 gasPrice=163 gwei block=69690 txIx=0 txId=0xa69a84764d29c20c0443802fda10ea2b89d67151d0227da63a80e0b896c91625 @ 1584237367 Sun, 15 Mar 2020 01:56:07 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xe4d9
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Transfer 0 #69690 from=Staking:0xbade to=user1:0xa44a tokens=100
token0.Transfer 1 #69690 from=Staking:0xbade to=user2:0xa55a tokens=200
token0.Transfer 2 #69690 from=Staking:0xbade to=user3:0xa66a tokens=300

stakingContractAddress=0xbaded2da306b54bac880043418105f4491c3d617
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xe4d9
stakingContract.approvedStakingContracts[0]=0x63b72794f3efca62e570e127b774889c470bf238
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=true
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
Withdrew 0 #69690 stakeOwner=user1:0xa44a, amount=100, totalStakedAmount=0
Withdrew 1 #69690 stakeOwner=user2:0xa55a, amount=200, totalStakedAmount=0
Withdrew 2 #69690 stakeOwner=user3:0xa66a, amount=300, totalStakedAmount=0
ReleasedAllStakes 0 #69686 {}

stakingContractAddress=0x63b72794f3efca62e570e127b774889c470bf238
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xe4d9
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

<hr />

### Other Tests

#### `withdraw()` After All Stakes Released

Scenario:

* `cooldownPeriodInSec` is set to 10000
* `user1` has 90 tokens staked, and 10 tokens unstaked in the cooldown period
* `user2` has 0 tokens staked, and 200 tokens unstaked in the cooldown period
* `user3` has 300 tokens staked, and 0 tokens unstaked in the cooldown period
* `emergencyManager` executes `releaseAllStakes(...)`
* `user1`, `user2` and `user3` execute `withdraw()`

Tests:

* [x] Any account with either staked and/or unstaked tokens can withdraw all staked and/or unstaked tokens, after `emergencyManager` executes `releasedAllStakes(...)`
  * [x] Tokens transferred back to account from the staking contract
* [x] Intended state changes & logs
* [x] Cannot execute this function for accounts without any staked or unstaked tokens

Results:
```javascript
---------- Test Unstaking #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.181055620000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.037521948000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.030188904000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.023614951000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xf36f003bf6b8a41378519df1e14ca03507cc9859        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xbe2e055d925bb9c6739a5147aa3416ed06178d64        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0xc940a4b5ab1ff96e1bd9ac23cb3619d05eaf1ef2        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Unstaking #1 - user1 -> staking.unstake(10)
PASS Test Unstaking #1 - user2 -> staking.unstake(200)
PASS Test Unstaking #1 - user3 -> staking.unstake(3000) - Expecting failure
testUnstaking1_1Tx status=0x1 Success gas=500000 gasUsed=79572 costETH=0.012970236 costUSD=1.33346996316 @ ETH/USD=102.81 gasPrice=163 gwei block=73028 txIx=0 txId=0x9181f2a61f76812eac41b66d066349bd3154a175808f0ddccd6f70426b196df8 @ 1584240819 Sun, 15 Mar 2020 02:53:39 UTC
testUnstaking1_2Tx status=0x1 Success gas=500000 gasUsed=64584 costETH=0.010527192 costUSD=1.08230060952 @ ETH/USD=102.81 gasPrice=163 gwei block=73028 txIx=2 txId=0x8bf9b365862d64d57a08f1cd8c6f517aed686467fabdcbe4e868be7b1a9d7ea5 @ 1584240819 Sun, 15 Mar 2020 02:53:39 UTC
testUnstaking1_3Tx status=0x0 Failure gas=500000 gasUsed=24253 costETH=0.003953239 costUSD=0.40643250159 @ ETH/USD=102.81 gasPrice=163 gwei block=73028 txIx=1 txId=0x9a578c66515628fba24a6d276db9146b5df018e5dda101edf4a127dd399a6126 @ 1584240819 Sun, 15 Mar 2020 02:53:39 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xf36f
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000

stakingContractAddress=0xbe2e055d925bb9c6739a5147aa3416ed06178d64
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf36f
stakingContract.approvedStakingContracts[0]=0xc940a4b5ab1ff96e1bd9ac23cb3619d05eaf1ef2
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=390
stakingContract.getStakeBalanceOf(user1:0xa44a)=90
stakingContract.getUnstakeStatus(user1:0xa44a)=10, cooldownEndTime=1584250819
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=200, cooldownEndTime=1584250819
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
Unstaked 0 #73028 stakeOwner=user1:0xa44a, amount=10, totalStakedAmount=90
Unstaked 1 #73028 stakeOwner=user2:0xa55a, amount=200, totalStakedAmount=0

stakingContractAddress=0xc940a4b5ab1ff96e1bd9ac23cb3619d05eaf1ef2
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf36f
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

---------- Release All Stakes #2 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.185877975000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0       -0.004822355000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.037521948000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.030188904000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.023614951000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xf36f003bf6b8a41378519df1e14ca03507cc9859        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xbe2e055d925bb9c6739a5147aa3416ed06178d64        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0xc940a4b5ab1ff96e1bd9ac23cb3619d05eaf1ef2        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Release All Stakes #2 - emergencyManager -> staking.releaseAllStakes()
releaseAllStakes2_1Tx status=0x1 Success gas=500000 gasUsed=29585 costETH=0.004822355 costUSD=0.49578631755 @ ETH/USD=102.81 gasPrice=163 gwei block=73032 txIx=0 txId=0xa976501b7b139daba4ef8dff4d57ef67dea187dce914c772046b821b08bff6c8 @ 1584240823 Sun, 15 Mar 2020 02:53:43 UTC

stakingContractAddress=0xbe2e055d925bb9c6739a5147aa3416ed06178d64
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf36f
stakingContract.approvedStakingContracts[0]=0xc940a4b5ab1ff96e1bd9ac23cb3619d05eaf1ef2
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=true
stakingContract.getTotalStakedTokens=390
stakingContract.getStakeBalanceOf(user1:0xa44a)=90
stakingContract.getUnstakeStatus(user1:0xa44a)=10, cooldownEndTime=1584250819
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=200, cooldownEndTime=1584250819
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
ReleasedAllStakes 0 #73032 {}

stakingContractAddress=0xc940a4b5ab1ff96e1bd9ac23cb3619d05eaf1ef2
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf36f
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

---------- Test Withdraw #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.200252945000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0       -0.004822355000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.042795324000000000      250000.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.034701722000000000      250000.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.028203727000000000      250000.000000000000000000           0.000000000000000000 user3
 7 0xf36f003bf6b8a41378519df1e14ca03507cc9859        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xbe2e055d925bb9c6739a5147aa3416ed06178d64        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking
 9 0xc940a4b5ab1ff96e1bd9ac23cb3619d05eaf1ef2        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Withdraw #1 - user1 -> staking.withdraw()
PASS Test Withdraw #1 - user2 -> staking.withdraw()
PASS Test Withdraw #1 - user3 -> staking.withdraw()
testWithdraw1_1Tx status=0x1 Success gas=500000 gasUsed=32352 costETH=0.005273376 costUSD=0.54215578656 @ ETH/USD=102.81 gasPrice=163 gwei block=73036 txIx=0 txId=0xf6ac2eed62d48a9e7e8cb3d6d17f7e7a6a6a6955fa14a1841747bfcaccbc5f2f @ 1584240827 Sun, 15 Mar 2020 02:53:47 UTC
testWithdraw1_2Tx status=0x1 Success gas=500000 gasUsed=27686 costETH=0.004512818 costUSD=0.46396281858 @ ETH/USD=102.81 gasPrice=163 gwei block=73036 txIx=2 txId=0x1b3b260d3642e923cfd1f42e75d6298d220c4367b0be6a9151e4585cc3e99f4c @ 1584240827 Sun, 15 Mar 2020 02:53:47 UTC
testWithdraw1_3Tx status=0x1 Success gas=500000 gasUsed=28152 costETH=0.004588776 costUSD=0.47177206056 @ ETH/USD=102.81 gasPrice=163 gwei block=73036 txIx=1 txId=0xbeeb4fb429e2e59bd46334307827d00910e516d7f993d5b2d9bf00f1aa62a4f3 @ 1584240827 Sun, 15 Mar 2020 02:53:47 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xf36f
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Transfer 0 #73036 from=Staking:0xbe2e to=user1:0xa44a tokens=100
token0.Transfer 1 #73036 from=Staking:0xbe2e to=user3:0xa66a tokens=300
token0.Transfer 2 #73036 from=Staking:0xbe2e to=user2:0xa55a tokens=200

stakingContractAddress=0xbe2e055d925bb9c6739a5147aa3416ed06178d64
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf36f
stakingContract.approvedStakingContracts[0]=0xc940a4b5ab1ff96e1bd9ac23cb3619d05eaf1ef2
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=true
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
Withdrew 0 #73036 stakeOwner=user1:0xa44a, amount=100, totalStakedAmount=0
Withdrew 1 #73036 stakeOwner=user3:0xa66a, amount=300, totalStakedAmount=0
Withdrew 2 #73036 stakeOwner=user2:0xa55a, amount=200, totalStakedAmount=0

stakingContractAddress=0xc940a4b5ab1ff96e1bd9ac23cb3619d05eaf1ef2
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf36f
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

#### `withdraw()` During The Cooldown Period

Scenario:

* `cooldownPeriodInSec` is set to 10000
* `user1` has 100 tokens staked, and 0 tokens unstaked in the cooldown period
* `user2` has 180 tokens staked, and 20 tokens unstaked in the cooldown period
* `user3` has 0 tokens staked, and 300 tokens unstaked in the cooldown period
* `user1`, `user2` and `user3` execute `withdraw()` - expecting failure

Tests:

* [x] Any account 0 unstaked tokens, or non-0 unstaked tokens within the cooldown period cannot withdraw
* [x] Intended state changes & logs

Results:
```javascript
---------- Test Unstaking #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.177100425000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078930415000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.024549756000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.032631948000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.030186948000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xfc166243cef775f982be01f320109a91bc560a48        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xb24dec3c8673728d0050a964be58774f6161226b        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x3d948c604db626484c76a10f7c5aa834b09946ba        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Unstaking #1 - user2 -> staking.unstake(20)
PASS Test Unstaking #1 - user3 -> staking.unstake(300)
testUnstaking1_2Tx status=0x1 Success gas=500000 gasUsed=79584 costETH=0.012972192 costUSD=1.33367105952 @ ETH/USD=102.81 gasPrice=163 gwei block=74078 txIx=0 txId=0xcef17fc1a0b249827f8ecb8a08c64c17d6c657013fee1605b33423e21c945479 @ 1584241869 Sun, 15 Mar 2020 03:11:09 UTC
testUnstaking1_3Tx status=0x1 Success gas=500000 gasUsed=64584 costETH=0.010527192 costUSD=1.08230060952 @ ETH/USD=102.81 gasPrice=163 gwei block=74078 txIx=1 txId=0xbc492ac2adc96b70743392f89fb3e7e87135f88f1f7c5286f0ebb39ae4c807c8 @ 1584241869 Sun, 15 Mar 2020 03:11:09 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xfc16
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000

stakingContractAddress=0xb24dec3c8673728d0050a964be58774f6161226b
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xfc16
stakingContract.approvedStakingContracts[0]=0x3d948c604db626484c76a10f7c5aa834b09946ba
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=280
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=180
stakingContract.getUnstakeStatus(user2:0xa55a)=20, cooldownEndTime=1584251869
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=300, cooldownEndTime=1584251869
Unstaked 0 #74078 stakeOwner=user2:0xa55a, amount=20, totalStakedAmount=180
Unstaked 1 #74078 stakeOwner=user3:0xa66a, amount=300, totalStakedAmount=0

stakingContractAddress=0x3d948c604db626484c76a10f7c5aa834b09946ba
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xfc16
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

---------- Test Withdraw #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.189230559000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078930415000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.028502832000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.036720477000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.034275477000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xfc166243cef775f982be01f320109a91bc560a48        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xb24dec3c8673728d0050a964be58774f6161226b        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x3d948c604db626484c76a10f7c5aa834b09946ba        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Withdraw #1 - user1 -> staking.withdraw() - Expecting failure - no unstaked amount
PASS Test Withdraw #1 - user2 -> staking.withdraw() - Expecting failure - in cooldown period
PASS Test Withdraw #1 - user3 -> staking.withdraw() - Expecting failure - in cooldown period
testWithdraw1_1Tx status=0x0 Failure gas=500000 gasUsed=24252 costETH=0.003953076 costUSD=0.40641574356 @ ETH/USD=102.81 gasPrice=163 gwei block=74082 txIx=0 txId=0x6ea25a12d55c64d94686c96f202a7eeb1629a118f3337f27713874da8f6f541b @ 1584241873 Sun, 15 Mar 2020 03:11:13 UTC
testWithdraw1_2Tx status=0x0 Failure gas=500000 gasUsed=25083 costETH=0.004088529 costUSD=0.42034166649 @ ETH/USD=102.81 gasPrice=163 gwei block=74082 txIx=2 txId=0xd0410b23322bbd50b2279bd0e2d96b1463839185c50473747aa8f948b3fc38e4 @ 1584241873 Sun, 15 Mar 2020 03:11:13 UTC
testWithdraw1_3Tx status=0x0 Failure gas=500000 gasUsed=25083 costETH=0.004088529 costUSD=0.42034166649 @ ETH/USD=102.81 gasPrice=163 gwei block=74082 txIx=1 txId=0x5bab59ea65cfe75606e8da116875f3d9d6919a2c56c067f3f1b6a09f16950b0f @ 1584241873 Sun, 15 Mar 2020 03:11:13 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xfc16
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000

stakingContractAddress=0xb24dec3c8673728d0050a964be58774f6161226b
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xfc16
stakingContract.approvedStakingContracts[0]=0x3d948c604db626484c76a10f7c5aa834b09946ba
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=280
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=180
stakingContract.getUnstakeStatus(user2:0xa55a)=20, cooldownEndTime=1584251869
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=300, cooldownEndTime=1584251869

stakingContractAddress=0x3d948c604db626484c76a10f7c5aa834b09946ba
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=10000
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xfc16
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

#### `migrationManager` Can Lock Staking Contract Using `notifier`

NOTE: Orbs have stated that `notifier` will be unused and set to `0x0000000000000000000000000000000000000000` in this initial deployment, and a new notifier contracts will be audited before being used with this contract.

Scenario:

* `cooldownPeriodInSec` is set to 1
* `user1` has 100 tokens staked, and 0 tokens unstaked in the cooldown period
* `user2` has 200 tokens staked, and 0 tokens unstaked in the cooldown period
* `user3` has 300 tokens staked, and 0 tokens unstaked in the cooldown period
* `migrationManager` executes `staking.setStakeChangeNotifier("0x0000000000000000000000000000000000000001")`, an invalid address
* `user1`, `user2` and `user3` cannot execute `unstake(...)`, and therefore `withdraw(...)`

Tests:

* [x] Any account staked tokens cannot unstake or withdraw if `notifier` is set to an invalid address

Results:
```javascript
---------- Test Staking #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.153604953000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.019661712000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.024551712000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.019661712000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0x18fcb68f05d3d1f07eb1188c801ae69b45b21904        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xf7b8de4484d33d9a64d220f83d28d9a03fa73ec4        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x7eb71decdcb22ca6049d60933cec23451659ac7c        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Staking #1 - user1 -> staking.stake(100)
PASS Test Staking #1 - user2 -> staking.stake(200)
PASS Test Staking #1 - user3 -> staking.stake(300)
testStaking1_1Tx status=0x1 Success gas=500000 gasUsed=76656 costETH=0.012494928 costUSD=1.28460354768 @ ETH/USD=102.81 gasPrice=163 gwei block=8711 txIx=1 txId=0xf4b7862c267ba92d0ed77fdc12529b596b2dc30f7b5de4e496d3298b3ca63f56 @ 1584394588 Mon, 16 Mar 2020 21:36:28 UTC
testStaking1_2Tx status=0x1 Success gas=500000 gasUsed=106656 costETH=0.017384928 costUSD=1.78734444768 @ ETH/USD=102.81 gasPrice=163 gwei block=8711 txIx=0 txId=0x19490d990be6d347233264136f8edee9fc83d359c9cdd24de19a86fbe703d935 @ 1584394588 Mon, 16 Mar 2020 21:36:28 UTC
testStaking1_3Tx status=0x1 Success gas=500000 gasUsed=76656 costETH=0.012494928 costUSD=1.28460354768 @ ETH/USD=102.81 gasPrice=163 gwei block=8711 txIx=2 txId=0x7af179d76420e3290d82af1d9b4211105d2e842e21ee7436737d4d4d11190958 @ 1584394588 Mon, 16 Mar 2020 21:36:28 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0x18fc
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Transfer 0 #8711 from=user2:0xa55a to=Staking:0xf7b8 tokens=200
token0.Transfer 1 #8711 from=user1:0xa44a to=Staking:0xf7b8 tokens=100
token0.Transfer 2 #8711 from=user3:0xa66a to=Staking:0xf7b8 tokens=300

stakingContractAddress=0xf7b8de4484d33d9a64d220f83d28d9a03fa73ec4
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x18fc
stakingContract.approvedStakingContracts[0]=0x7eb71decdcb22ca6049d60933cec23451659ac7c
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=600
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=200
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
Staked 0 #8711 stakeOwner=user2:0xa55a, amount=200, totalStakedAmount=200
Staked 1 #8711 stakeOwner=user1:0xa44a, amount=100, totalStakedAmount=100
Staked 2 #8711 stakeOwner=user3:0xa66a, amount=300, totalStakedAmount=300

stakingContractAddress=0x7eb71decdcb22ca6049d60933cec23451659ac7c
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x18fc
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

---------- Test Blocking #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.160971575000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.018167980000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.019661712000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.024551712000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.019661712000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0x18fcb68f05d3d1f07eb1188c801ae69b45b21904        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xf7b8de4484d33d9a64d220f83d28d9a03fa73ec4        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x7eb71decdcb22ca6049d60933cec23451659ac7c        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Blocking #1 - migrationManager -> staking.setStakeChangeNotifier(0x0000000000000000000000000000000000000001)
testBlocking1_1Tx status=0x1 Success gas=500000 gasUsed=45194 costETH=0.007366622 costUSD=0.75736240782 @ ETH/USD=102.81 gasPrice=163 gwei block=8715 txIx=0 txId=0x4de05386606434463f04734a4550883992bc115e637f121cbb9cfca7bbdf7c01 @ 1584394592 Mon, 16 Mar 2020 21:36:32 UTC

stakingContractAddress=0xf7b8de4484d33d9a64d220f83d28d9a03fa73ec4
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x18fc
stakingContract.approvedStakingContracts[0]=0x7eb71decdcb22ca6049d60933cec23451659ac7c
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000001
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=600
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=200
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
StakeChangeNotifierUpdated 0 #8715 {"notifier":"0x0000000000000000000000000000000000000001"}

stakingContractAddress=0x7eb71decdcb22ca6049d60933cec23451659ac7c
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x18fc
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

---------- Test Unstaking #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.200709671000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.018167980000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.032906440000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.037798396000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.032908396000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0x18fcb68f05d3d1f07eb1188c801ae69b45b21904        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xf7b8de4484d33d9a64d220f83d28d9a03fa73ec4        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x7eb71decdcb22ca6049d60933cec23451659ac7c        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Unstaking #1 - user1 -> staking.unstake(10) - Expecting failure due to invalid notifier
PASS Test Unstaking #1 - user2 -> staking.unstake(20) - Expecting failure due to invalid notifier
PASS Test Unstaking #1 - user3 -> staking.unstake(30) - Expecting failure due to invalid notifier
testUnstaking1_1Tx status=0x0 Failure gas=500000 gasUsed=81256 costETH=0.013244728 costUSD=1.36169048568 @ ETH/USD=102.81 gasPrice=163 gwei block=8718 txIx=1 txId=0x4786a36106452904bb31c05b96136bc2ad58ba8c078ce535d2c5d10e1c857437 @ 1584394595 Mon, 16 Mar 2020 21:36:35 UTC
testUnstaking1_2Tx status=0x0 Failure gas=500000 gasUsed=81268 costETH=0.013246684 costUSD=1.36189158204 @ ETH/USD=102.81 gasPrice=163 gwei block=8718 txIx=0 txId=0x522a9a8966d45d6656ed87e1da713267884a0ebb5c3b0c58e6ef7bad9b8c6dd9 @ 1584394595 Mon, 16 Mar 2020 21:36:35 UTC
testUnstaking1_3Tx status=0x0 Failure gas=500000 gasUsed=81268 costETH=0.013246684 costUSD=1.36189158204 @ ETH/USD=102.81 gasPrice=163 gwei block=8718 txIx=2 txId=0x9c4001239fdcfe2a197b0db83842eff2c8f427acd0a7c5a6adc58a55588a3442 @ 1584394595 Mon, 16 Mar 2020 21:36:35 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0x18fc
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000

stakingContractAddress=0xf7b8de4484d33d9a64d220f83d28d9a03fa73ec4
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x18fc
stakingContract.approvedStakingContracts[0]=0x7eb71decdcb22ca6049d60933cec23451659ac7c
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000001
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=600
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=200
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

stakingContractAddress=0x7eb71decdcb22ca6049d60933cec23451659ac7c
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x18fc
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

---------- Test Withdraw #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.212568899000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.018167980000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.036859516000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.041751472000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.036861472000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0x18fcb68f05d3d1f07eb1188c801ae69b45b21904        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0xf7b8de4484d33d9a64d220f83d28d9a03fa73ec4        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x7eb71decdcb22ca6049d60933cec23451659ac7c        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Withdraw #1 - user1 -> staking.withdraw() - Expecting failure due to invalid notifier
PASS Test Withdraw #1 - user2 -> staking.withdraw() - Expecting failure due to invalid notifier
PASS Test Withdraw #1 - user3 -> staking.withdraw() - Expecting failure due to invalid notifier
testWithdraw1_1Tx status=0x0 Failure gas=500000 gasUsed=24252 costETH=0.003953076 costUSD=0.40641574356 @ ETH/USD=102.81 gasPrice=163 gwei block=8722 txIx=1 txId=0xa8b6ab27205a77354cab8d44e997bccc50190cd189441c9cf90cdb3efa39e375 @ 1584394599 Mon, 16 Mar 2020 21:36:39 UTC
testWithdraw1_2Tx status=0x0 Failure gas=500000 gasUsed=24252 costETH=0.003953076 costUSD=0.40641574356 @ ETH/USD=102.81 gasPrice=163 gwei block=8722 txIx=0 txId=0x8b94eef60e65c26c844ef9127cffc3a5fbfcfbcab6cf89ae2e5436a57e03a909 @ 1584394599 Mon, 16 Mar 2020 21:36:39 UTC
testWithdraw1_3Tx status=0x0 Failure gas=500000 gasUsed=24252 costETH=0.003953076 costUSD=0.40641574356 @ ETH/USD=102.81 gasPrice=163 gwei block=8722 txIx=2 txId=0x9ab30a6a9236e55f37733afa4e1bf514e847be3db87ab4cff5bf6ea75a9c70f7 @ 1584394599 Mon, 16 Mar 2020 21:36:39 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0x18fc
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000

stakingContractAddress=0xf7b8de4484d33d9a64d220f83d28d9a03fa73ec4
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x18fc
stakingContract.approvedStakingContracts[0]=0x7eb71decdcb22ca6049d60933cec23451659ac7c
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000001
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=600
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=200
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0

stakingContractAddress=0x7eb71decdcb22ca6049d60933cec23451659ac7c
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=1
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0x18fc
stakingContract.approvedStakingContracts[0]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=0
stakingContract.getStakeBalanceOf(user1:0xa44a)=0
stakingContract.getUnstakeStatus(user1:0xa44a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user2:0xa55a)=0
stakingContract.getUnstakeStatus(user2:0xa55a)=0, cooldownEndTime=0
stakingContract.getStakeBalanceOf(user3:0xa66a)=0
stakingContract.getUnstakeStatus(user3:0xa66a)=0, cooldownEndTime=0
```

<br />

<hr />

## Notes

### Admin Keys

Account `migrationManager` can execute:

* `setMigrationManager(...)`
* `setStakeChangeNotifier(...)`
* `addMigrationDestination(...)`
* `removeMigrationDestination(...)`

Account `emergencyManager` can execute:

* `setEmergencyManager(...)`
* `stopAcceptingNewStakes(...)`
* `releaseAllStakes()`

<br />

### States

`acceptingNewStakes`

`releasingAllStakes`

### Check

* `totalStakedTokens` - should not include unstaked tokens in cooldown period or pending withdrawal
* Check that can unstake and withdraw tokens if not `acceptingNewStakes`
* [x] If `releaseAllStakes()` is called before `stopAcceptingNewStakes()`, `stopAcceptingNewStakes()` cannot be executed. But this does not affect the result of the modifier `onlyWhenAcceptingNewStakes()` as both variables are checked in `require(acceptingNewStakes && !releasingAllStakes, ...)`
* Check migration during cooldown period
* Can a sequence of calls within a single tx cause any unexpected changes?
* Can `migrationManager` set a notifier that transfers away a user's staked/unstaked tokens?
* Can a user with staked/unstaked tokens withdraw/migrate more tokens than they stake
* `migrationManager` could add new staking contract `IMigratableStakingContract` - users should check the new staking contract before migrating their tokens
* Can `totalStakedTokens` and individual `stakes[account]` be unbalanced?

* Admin can set invalid accepted migration contract, or invalid notifier

### Assumptions

* ORBs token contract at [0xff56cc6b1e6ded347aa0b7676c85ab0b3d08b0fa](https://etherscan.io/address/0xff56cc6b1e6ded347aa0b7676c85ab0b3d08b0fa#code)
* `notifier` will be set to 0x0000000000000000000000000000000000000000

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Orbs - Mar 1 2020. The MIT Licence.
