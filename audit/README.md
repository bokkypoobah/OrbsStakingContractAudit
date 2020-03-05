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

* **VERY LOW IMPORTANCE** Add a function that will report back the length of the `approvedStakingContracts` array

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

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Orbs - Mar 1 2020. The MIT Licence.
