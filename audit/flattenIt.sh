#!/bin/sh

scripts/solidityFlattener.pl --contractsdir=contracts --mainsol=StakingContract.sol --outputsol=flattened/StakingContract_flattened.sol --verbose --remapdir "@openzeppelin/contracts/=openzeppelin-solidity-v2.3.0/"
