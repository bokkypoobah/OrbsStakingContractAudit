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

## Testing

General testing setup with 250,000 (18 decimals) ERC20 token allocated to `deployer`, `user1`, `user2` and `user3`. 2 staking contracts, with the second staking contract
added as an `approvedStakingContracts` in the first staking contract.

### Constructor

* [x] Can only be executed once as this is a normal constructor
* [x] Variables set correctly - `cooldownPeriodInSec`, `migrationManager`, `emergencyManager` and `token`

Results:
```
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

```
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

```
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

Set up with `cooldownPeriodInSec` set to 5 seconds to test the withdrawal.

<br />

#### `stake(...)`

`user1` stakes 100 tokens, `user2` 200 and `user3` 300.

* [x] Any account with tokens `approve(...)`-d to the staking contract can stake
* [x] Intended state changes & logs

Results:
```
---------- Test Staking #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.153604953000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.078928459000000000      250000.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.024551712000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.019661712000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.019661712000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xf327e604d17c3085872dc5c2760c99ff063a2166        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x50f9373af8fbe97174ca293ec9dce871bfa2f9cd        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x4b90969d3d0cbb38439f6630d164ab97070cc752        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Staking #1 - user1 -> staking.stake(100)
PASS Test Staking #1 - user2 -> staking.stake(200)
PASS Test Staking #1 - user3 -> staking.stake(300)
testStaking1_1Tx status=0x1 Success gas=500000 gasUsed=106656 costETH=0.017384928 costUSD=1.78734444768 @ ETH/USD=102.81 gasPrice=163 gwei block=64792 txIx=0 txId=0x93f3e9c0c61c55cec9ec2a0e9ac0a68fbf3a10d26289c02a0d43b1262ee4481a @ 1584230932 Sun, 15 Mar 2020 00:08:52 UTC
testStaking1_2Tx status=0x1 Success gas=500000 gasUsed=76656 costETH=0.012494928 costUSD=1.28460354768 @ ETH/USD=102.81 gasPrice=163 gwei block=64792 txIx=2 txId=0xef075759a856f8902eca0d9af197ffd56ef2ea2c72a18403266e885dc3076a01 @ 1584230932 Sun, 15 Mar 2020 00:08:52 UTC
testStaking1_3Tx status=0x1 Success gas=500000 gasUsed=76656 costETH=0.012494928 costUSD=1.28460354768 @ ETH/USD=102.81 gasPrice=163 gwei block=64792 txIx=1 txId=0xa07f95a6f52d3a8f398a269733c580b3e656483428c5d0ad55de575feb9faf57 @ 1584230932 Sun, 15 Mar 2020 00:08:52 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xf327
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Transfer 0 #64792 from=user1:0xa44a to=Staking:0x50f9 tokens=100
token0.Transfer 1 #64792 from=user3:0xa66a to=Staking:0x50f9 tokens=300
token0.Transfer 2 #64792 from=user2:0xa55a to=Staking:0x50f9 tokens=200

stakingContractAddress=0x50f9373af8fbe97174ca293ec9dce871bfa2f9cd
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf327
stakingContract.approvedStakingContracts[0]=0x4b90969d3d0cbb38439f6630d164ab97070cc752
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
Staked 0 #64792 stakeOwner=user1:0xa44a, amount=100, totalStakedAmount=100
Staked 1 #64792 stakeOwner=user3:0xa66a, amount=300, totalStakedAmount=300
Staked 2 #64792 stakeOwner=user2:0xa55a, amount=200, totalStakedAmount=200

stakingContractAddress=0x4b90969d3d0cbb38439f6630d164ab97070cc752
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf327
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
```
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
 7 0xf327e604d17c3085872dc5c2760c99ff063a2166        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x50f9373af8fbe97174ca293ec9dce871bfa2f9cd        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x4b90969d3d0cbb38439f6630d164ab97070cc752        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Unstaking #1 - user1 -> staking.unstake(10)
PASS Test Unstaking #1 - user2 -> staking.unstake(20)
PASS Test Unstaking #1 - user3 -> staking.unstake(30)
testUnstaking1_1Tx status=0x1 Success gas=500000 gasUsed=79572 costETH=0.012970236 costUSD=1.33346996316 @ ETH/USD=102.81 gasPrice=163 gwei block=64796 txIx=0 txId=0xf794bb9f270dc75023dca4bd381f04bd2bfec2c1820f6120583fe3b4bba413b5 @ 1584230936 Sun, 15 Mar 2020 00:08:56 UTC
testUnstaking1_2Tx status=0x1 Success gas=500000 gasUsed=79584 costETH=0.012972192 costUSD=1.33367105952 @ ETH/USD=102.81 gasPrice=163 gwei block=64796 txIx=2 txId=0x1d1fdf4597277dd4077ff73045afce9cd08f914f1f9faa9bbfe662c879a027a1 @ 1584230936 Sun, 15 Mar 2020 00:08:56 UTC
testUnstaking1_3Tx status=0x1 Success gas=500000 gasUsed=79584 costETH=0.012972192 costUSD=1.33367105952 @ ETH/USD=102.81 gasPrice=163 gwei block=64796 txIx=1 txId=0x016631602c2dd3f305007e503fdd9f8736c89d41d28e115cdfcc02a5d024f1af @ 1584230936 Sun, 15 Mar 2020 00:08:56 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xf327
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000

stakingContractAddress=0x50f9373af8fbe97174ca293ec9dce871bfa2f9cd
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf327
stakingContract.approvedStakingContracts[0]=0x4b90969d3d0cbb38439f6630d164ab97070cc752
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=540
stakingContract.getStakeBalanceOf(user1:0xa44a)=90
stakingContract.getUnstakeStatus(user1:0xa44a)=10, cooldownEndTime=1584230941
stakingContract.getStakeBalanceOf(user2:0xa55a)=180
stakingContract.getUnstakeStatus(user2:0xa55a)=20, cooldownEndTime=1584230941
stakingContract.getStakeBalanceOf(user3:0xa66a)=270
stakingContract.getUnstakeStatus(user3:0xa66a)=30, cooldownEndTime=1584230941
Unstaked 0 #64796 stakeOwner=user1:0xa44a, amount=10, totalStakedAmount=90
Unstaked 1 #64796 stakeOwner=user3:0xa66a, amount=30, totalStakedAmount=270
Unstaked 2 #64796 stakeOwner=user2:0xa55a, amount=20, totalStakedAmount=180

stakingContractAddress=0x4b90969d3d0cbb38439f6630d164ab97070cc752
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf327
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

* [x] Any account with `approve(...)``-d tokens can distribute rewards to other accounts
* [x] Intended state changes & logs
* [ ] CHECK - Can distribute to account with no staked tokens?

Results:
```
---------- Test Distribute Rewards #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.206125835000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.092534721000000000      249934.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.037521948000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.032633904000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.032633904000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xf327e604d17c3085872dc5c2760c99ff063a2166        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x50f9373af8fbe97174ca293ec9dce871bfa2f9cd        0.000000000000000000         666.000000000000000000           0.000000000000000000 Staking
 9 0x4b90969d3d0cbb38439f6630d164ab97070cc752        0.000000000000000000           0.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Distribute Rewards #1 - deployer -> staking.distributeRewards(66, [user1, user2, user3], [11, 22, 33])
testDistributeRewards1_1Tx status=0x1 Success gas=1000000 gasUsed=83474 costETH=0.013606262 costUSD=1.39885979622 @ ETH/USD=102.81 gasPrice=163 gwei block=64800 txIx=0 txId=0x18e8e21789db5b0d801292d99fd4c27933fcef71ea7c2fd8023768c949c477bf @ 1584230940 Sun, 15 Mar 2020 00:09:00 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xf327
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Transfer 0 #64800 from=deployer:0xa11a to=Staking:0x50f9 tokens=66

stakingContractAddress=0x50f9373af8fbe97174ca293ec9dce871bfa2f9cd
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf327
stakingContract.approvedStakingContracts[0]=0x4b90969d3d0cbb38439f6630d164ab97070cc752
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=606
stakingContract.getStakeBalanceOf(user1:0xa44a)=101
stakingContract.getUnstakeStatus(user1:0xa44a)=10, cooldownEndTime=1584230941
stakingContract.getStakeBalanceOf(user2:0xa55a)=202
stakingContract.getUnstakeStatus(user2:0xa55a)=20, cooldownEndTime=1584230941
stakingContract.getStakeBalanceOf(user3:0xa66a)=303
stakingContract.getUnstakeStatus(user3:0xa66a)=30, cooldownEndTime=1584230941
Staked 0 #64800 stakeOwner=user1:0xa44a, amount=11, totalStakedAmount=101
Staked 1 #64800 stakeOwner=user2:0xa55a, amount=22, totalStakedAmount=202
Staked 2 #64800 stakeOwner=user3:0xa66a, amount=33, totalStakedAmount=303

stakingContractAddress=0x4b90969d3d0cbb38439f6630d164ab97070cc752
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf327
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
```
---------- Test Migrate #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.261287969000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.092534721000000000      249934.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.054279326000000000      249900.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.049391282000000000      249800.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.054281282000000000      249700.000000000000000000           0.000000000000000000 user3
 7 0xf327e604d17c3085872dc5c2760c99ff063a2166        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x50f9373af8fbe97174ca293ec9dce871bfa2f9cd        0.000000000000000000         660.000000000000000000           0.000000000000000000 Staking
 9 0x4b90969d3d0cbb38439f6630d164ab97070cc752        0.000000000000000000           6.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Migrate #1 - user1 -> staking.migrateStakedTokens(staking2, 1)
PASS Test Migrate #1 - user2 -> staking.migrateStakedTokens(staking2, 2)
PASS Test Migrate #1 - user3 -> staking.migrateStakedTokens(staking2, 3)
testMigrateStakedTokens1_1Tx status=0x1 Success gas=500000 gasUsed=102806 costETH=0.016757378 costUSD=1.72282603218 @ ETH/USD=102.81 gasPrice=163 gwei block=64804 txIx=2 txId=0xf9b16d46e54722084e97a02c0df6896af6dd6933e8323b00de41a94e4b6b301f @ 1584230944 Sun, 15 Mar 2020 00:09:04 UTC
testMigrateStakedTokens1_2Tx status=0x1 Success gas=500000 gasUsed=102806 costETH=0.016757378 costUSD=1.72282603218 @ ETH/USD=102.81 gasPrice=163 gwei block=64804 txIx=1 txId=0xb84c682d422062e576cb173bdc55ed7da7b9538b536e14c4e9a8eb592cc461e4 @ 1584230944 Sun, 15 Mar 2020 00:09:04 UTC
testMigrateStakedTokens1_3Tx status=0x1 Success gas=500000 gasUsed=132806 costETH=0.021647378 costUSD=2.22556693218 @ ETH/USD=102.81 gasPrice=163 gwei block=64804 txIx=0 txId=0x7a86f25360f8fdcfc9e8e6e211ee6334ec9b5ac6cbc10fdf74099ded039c24d9 @ 1584230944 Sun, 15 Mar 2020 00:09:04 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xf327
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Approval 0 #64804 tokenOwner=Staking:0x50f9 spender=Staking2:0x4b90 tokens=3
token0.Approval 1 #64804 tokenOwner=Staking:0x50f9 spender=Staking2:0x4b90 tokens=2
token0.Approval 2 #64804 tokenOwner=Staking:0x50f9 spender=Staking2:0x4b90 tokens=1
token0.Transfer 0 #64804 from=Staking:0x50f9 to=Staking2:0x4b90 tokens=3
token0.Transfer 1 #64804 from=Staking:0x50f9 to=Staking2:0x4b90 tokens=2
token0.Transfer 2 #64804 from=Staking:0x50f9 to=Staking2:0x4b90 tokens=1

stakingContractAddress=0x50f9373af8fbe97174ca293ec9dce871bfa2f9cd
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf327
stakingContract.approvedStakingContracts[0]=0x4b90969d3d0cbb38439f6630d164ab97070cc752
stakingContract.approvedStakingContracts[1]=0x
stakingContract.notifier=0x0000000000000000000000000000000000000000
stakingContract.acceptingNewStakes=true
stakingContract.releasingAllStakes=false
stakingContract.getTotalStakedTokens=600
stakingContract.getStakeBalanceOf(user1:0xa44a)=100
stakingContract.getUnstakeStatus(user1:0xa44a)=10, cooldownEndTime=1584230941
stakingContract.getStakeBalanceOf(user2:0xa55a)=200
stakingContract.getUnstakeStatus(user2:0xa55a)=20, cooldownEndTime=1584230941
stakingContract.getStakeBalanceOf(user3:0xa66a)=300
stakingContract.getUnstakeStatus(user3:0xa66a)=30, cooldownEndTime=1584230941
MigratedStake 0 #64804 stakeOwner=user3:0xa66a, amount=3, totalStakedAmount=300
MigratedStake 1 #64804 stakeOwner=user2:0xa55a, amount=2, totalStakedAmount=200
MigratedStake 2 #64804 stakeOwner=user1:0xa44a, amount=1, totalStakedAmount=100

stakingContractAddress=0x4b90969d3d0cbb38439f6630d164ab97070cc752
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf327
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
```
---------- Test Withdraw #1 ----------
 # Account                                             EtherBalanceChange                          FIXED                              1 Name
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
 0 0xa00af22d07c87d96eeeb0ed583f8f6ac7812827e        1.274386812000000000           0.000000000000000000           0.000000000000000000 miner
 1 0xa11aae29840fbb5c86e6fd4cf809eba183aef433       -1.092534721000000000      249934.000000000000000000           0.000000000000000000 deployer
 2 0xa22ab8a9d641ce77e06d98b7d7065d324d3d6976       -0.010801358000000000           0.000000000000000000           0.000000000000000000 migrationManager
 3 0xa33a6c312d9ad0e0f2e95541beed0cc081621fd0        0.000000000000000000           0.000000000000000000           0.000000000000000000 emergencyManager
 4 0xa44a08d3f6933c69212114bb66e2df1813651844       -0.058645607000000000      249910.000000000000000000           0.000000000000000000 user1
 5 0xa55a151eb00fded1634d27d1127b4be4627079ea       -0.053757563000000000      249820.000000000000000000           0.000000000000000000 user2
 6 0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9       -0.058647563000000000      249730.000000000000000000           0.000000000000000000 user3
 7 0xf327e604d17c3085872dc5c2760c99ff063a2166        0.000000000000000000           0.000000000000000000           0.000000000000000000 'FIXED' 'Example Fixed Supply Token'
 8 0x50f9373af8fbe97174ca293ec9dce871bfa2f9cd        0.000000000000000000         600.000000000000000000           0.000000000000000000 Staking
 9 0x4b90969d3d0cbb38439f6630d164ab97070cc752        0.000000000000000000           6.000000000000000000           0.000000000000000000 Staking2
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------
                                                                              1000000.000000000000000000           0.000000000000000000 Total Token Balances
-- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ---------------------------

PASS Test Withdraw #1 - user1 -> staking.withdraw()
PASS Test Withdraw #1 - user2 -> staking.withdraw()
PASS Test Withdraw #1 - user3 -> staking.withdraw()
testWithdraw1_1Tx status=0x1 Success gas=500000 gasUsed=26787 costETH=0.004366281 costUSD=0.44889734961 @ ETH/USD=102.81 gasPrice=163 gwei block=64808 txIx=0 txId=0x8f2b9269df96be6f30c7ac934e9410cc328aff2e5b5e9d8624aa44a4222cfc08 @ 1584230948 Sun, 15 Mar 2020 00:09:08 UTC
testWithdraw1_2Tx status=0x1 Success gas=500000 gasUsed=26787 costETH=0.004366281 costUSD=0.44889734961 @ ETH/USD=102.81 gasPrice=163 gwei block=64808 txIx=2 txId=0x216522d4fa9005b70dada3d125d9cb5d9aef68d24ad288cc4d590ec7762ec660 @ 1584230948 Sun, 15 Mar 2020 00:09:08 UTC
testWithdraw1_3Tx status=0x1 Success gas=500000 gasUsed=26787 costETH=0.004366281 costUSD=0.44889734961 @ ETH/USD=102.81 gasPrice=163 gwei block=64808 txIx=1 txId=0x99b3aa3cbb57710e3e2a1663e666c61ff6369c0792c46a68d356001326caba0d @ 1584230948 Sun, 15 Mar 2020 00:09:08 UTC

token0ContractAddress='FIXED' 'Example Fixed Supply Token':0xf327
token0.owner/new=deployer:0xa11a/null:0x0000
token0.details='FIXED' 'Example Fixed Supply Token' 18 dp
token0.totalSupply=1000000
token0.Transfer 0 #64808 from=Staking:0x50f9 to=user1:0xa44a tokens=10
token0.Transfer 1 #64808 from=Staking:0x50f9 to=user3:0xa66a tokens=30
token0.Transfer 2 #64808 from=Staking:0x50f9 to=user2:0xa55a tokens=20

stakingContractAddress=0x50f9373af8fbe97174ca293ec9dce871bfa2f9cd
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf327
stakingContract.approvedStakingContracts[0]=0x4b90969d3d0cbb38439f6630d164ab97070cc752
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
Withdrew 0 #64808 stakeOwner=user1:0xa44a, amount=10, totalStakedAmount=100
Withdrew 1 #64808 stakeOwner=user3:0xa66a, amount=30, totalStakedAmount=300
Withdrew 2 #64808 stakeOwner=user2:0xa55a, amount=20, totalStakedAmount=200

stakingContractAddress=0x4b90969d3d0cbb38439f6630d164ab97070cc752
stakingContract.VERSION=1
stakingContract.MAX_APPROVED_STAKING_CONTRACTS=10
stakingContract.cooldownPeriodInSec=5
stakingContract.migrationManager=migrationManager:0xa22a
stakingContract.emergencyManager=emergencyManager:0xa33a
stakingContract.getToken='FIXED' 'Example Fixed Supply Token':0xf327
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
```
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
```
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


#### `withdraw()` variants

WIP

`user1`, `user2` and `user3` restake unstaked tokens

* [x] Any account with unstaked tokens can restake their unstaked tokens
* [x] Intended state changes & logs

Results:
```
```

<br />

<hr />

## Code Review

[OpenZeppelin Contracts v2.3.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v2.3.0)

Contracts reviewed:

* [ ] [flattened/StakingContract_flattened_comments.sol](flattened/StakingContract_flattened_comments.sol)
  * [x] library SafeMath
  * [x] interface IERC20
  * [ ] interface IMigratableStakingContract
  * [x] interface IStakingContract
  * [ ] interface IStakeChangeNotifier
  * [ ] contract StakingContract is IStakingContract, IMigratableStakingContract
    * [ ] using SafeMath for uint256;

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

### Assumptions

* ORBs token contract at [0xff56cc6b1e6ded347aa0b7676c85ab0b3d08b0fa](https://etherscan.io/address/0xff56cc6b1e6ded347aa0b7676c85ab0b3d08b0fa#code)
* `notifier` will be set to 0x0000000000000000000000000000000000000000

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Orbs - Mar 1 2020. The MIT Licence.
