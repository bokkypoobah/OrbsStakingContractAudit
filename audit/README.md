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

* `constructor()`
  * [x] CHECK Cannot be initialised more than once
  * [x] CHECK & TESTED Variables set as expected
* `migrationManager` admin functions - `setMigrationManager(...)`, `setStakeChangeNotifier(...)`, `addMigrationDestination(...)` and `removeMigrationDestination(...)`
  * [x] CHECK & TESTED Can only be executed by `migrationManager`
  * [x] CHECK & TESTED Intended state changes & logs
* `emergencyManager` admin functions - `setEmergencyManager(...)`, `stopAcceptingNewStakes()`, `releaseAllStakes()`
  * [x] CHECK & TESTED Can only be executed by `emergencyManager`
  * [x] CHECK & TESTED Intended state changes & logs
  * NOTE: If `releaseAllStakes()` is executed before `stopAcceptingNewStakes()` is executed, `stopAcceptingNewStakes()` can never be executed. This does not matter as the modifier `onlyWhenAcceptingNewStakes()` checks both conditions.


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
