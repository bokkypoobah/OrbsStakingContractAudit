// BK Ok
pragma solidity 0.5.16;


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
// BK Ok. Referenced in StakingContract
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    // BK Ok - Internal pure function
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        // BK Ok
        uint256 c = a + b;
        // BK Ok
        require(c >= a, "SafeMath: addition overflow");

        // BK Ok
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    // BK Ok - Internal pure function
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        // BK Ok - "overflow" => "underflow"
        require(b <= a, "SafeMath: subtraction overflow");
        // BK Ok
        uint256 c = a - b;

        // BK Ok
        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    // BK NOTE - This function is unused
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    // BK NOTE - This function is unused
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    // BK NOTE - This function is unused
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}




/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
// BK NOTE - https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// BK Ok - Interface
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    // BK NOTE - function totalSupply() public view returns (uint256)
    // BK Ok
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    // BK NOTE - function balanceOf(address _owner) public view returns (uint256 balance)
    // BK Ok
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    // BK NOTE - function transfer(address _to, uint256 _value) public returns (bool success)
    // BK Ok
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    // BK NOTE - function allowance(address _owner, address _spender) public view returns (uint256 remaining)
    // BK Ok
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    // BK NOTE - function approve(address _spender, uint256 _value) public returns (bool success)
    // BK Ok
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    // BK NOTE - function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
    // BK Ok
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    // BK NOTE - event Transfer(address indexed _from, address indexed _to, uint256 _value)
    // BK Ok
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    // BK NOTE - event Approval(address indexed _owner, address indexed _spender, uint256 _value)
    // BK Ok
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// @title An interface for staking contracts which support stake migration.
// BK Ok
interface IMigratableStakingContract {
    /// @dev Returns the address of the underlying staked token.
    /// @return IERC20 The address of the token.
    // BK Ok
    function getToken() external view returns (IERC20);

    /// @dev Stakes ORBS tokens on behalf of msg.sender. This method assumes that the user has already approved at least
    /// the required amount using ERC20 approve.
    /// @param _stakeOwner address The specified stake owner.
    /// @param _amount uint256 The number of tokens to stake.
    // BK Ok
    function acceptMigration(address _stakeOwner, uint256 _amount) external;

    // BK Ok - Event
    event AcceptedMigration(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
}

/// @title An interface for staking contracts.
// BK Ok
interface IStakingContract {
    /// @dev Stakes ORBS tokens on behalf of msg.sender. This method assumes that the user has already approved at least
    /// the required amount using ERC20 approve.
    /// @param _amount uint256 The amount of tokens to stake.
    // BK Ok
    function stake(uint256 _amount) external;

    /// @dev Unstakes ORBS tokens from msg.sender. If successful, this will start the cooldown period, after which
    /// msg.sender would be able to withdraw all of his tokens.
    /// @param _amount uint256 The amount of tokens to unstake.
    // BK Ok
    function unstake(uint256 _amount) external;

    /// @dev Requests to withdraw all of staked ORBS tokens back to msg.sender. Stake owners can withdraw their ORBS
    /// tokens only after previously unstaking them and after the cooldown period has passed (unless the contract was
    /// requested to release all stakes).
    // BK Ok
    function withdraw() external;

    /// @dev Restakes unstaked ORBS tokens (in or after cooldown) for msg.sender.
    // BK Ok
    function restake() external;

    /// @dev Distributes staking rewards to a list of addresses by directly adding rewards to their stakes. This method
    /// assumes that the user has already approved at least the required amount using ERC20 approve. Since this is a
    /// convenience method, we aren't concerned about reaching block gas limit by using large lists. We assume that
    /// callers will be able to properly batch/paginate their requests.
    /// @param _totalAmount uint256 The total amount of rewards to distributes.
    /// @param _stakeOwners address[] The addresses of the stake owners.
    /// @param _amounts uint256[] The amounts of the rewards.
    // BK Ok
    function distributeRewards(uint256 _totalAmount, address[] calldata _stakeOwners, uint256[] calldata _amounts) external;

    /// @dev Returns the stake of the specified stake owner (excluding unstaked tokens).
    /// @param _stakeOwner address The address to check.
    /// @return uint256 The total stake.
    // BK Ok
    function getStakeBalanceOf(address _stakeOwner) external view returns (uint256);

    /// @dev Returns the total amount staked tokens (excluding unstaked tokens).
    /// @return uint256 The total staked tokens of all stake owners.
    // BK Ok
    function getTotalStakedTokens() external view returns (uint256);

    /// @dev Returns the time that the cooldown period ends (or ended) and the amount of tokens to be released.
    /// @param _stakeOwner address The address to check.
    /// @return cooldownAmount uint256 The total tokens in cooldown.
    /// @return cooldownEndTime uint256 The time when the cooldown period ends (in seconds).
    // BK Ok
    function getUnstakeStatus(address _stakeOwner) external view returns (uint256 cooldownAmount,
        uint256 cooldownEndTime);

    /// @dev Migrates the stake of msg.sender from this staking contract to a new approved staking contract.
    /// @param _newStakingContract IMigratableStakingContract The new staking contract which supports stake migration.
    /// @param _amount uint256 The amount of tokens to migrate.
    // BK Ok
    function migrateStakedTokens(IMigratableStakingContract _newStakingContract, uint256 _amount) external;

    // BK Next 5 Ok
    event Staked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Unstaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Withdrew(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event Restaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
    event MigratedStake(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
}

/// @title An interface for notifying of stake change events (e.g., stake, unstake, partial unstake, restate, etc.).
interface IStakeChangeNotifier {
    /// @dev Notifies of stake change event.
    /// @param _stakeOwner address The address of the subject stake owner.
    /// @param _amount uint256 The difference in the total staked amount.
    /// @param _sign bool The sign of the added (true) or subtracted (false) amount.
    /// @param _updatedStake uint256 The updated total staked amount.
    function stakeChange(address _stakeOwner, uint256 _amount, bool _sign, uint256 _updatedStake) external;

    /// @dev Notifies of multiple stake change events.
    /// @param _stakeOwners address[] The addresses of subject stake owners.
    /// @param _amounts uint256[] The differences in total staked amounts.
    /// @param _signs bool[] The signs of the added (true) or subtracted (false) amounts.
    /// @param _updatedStakes uint256[] The updated total staked amounts.
    function stakeChangeBatch(address[] calldata _stakeOwners, uint256[] calldata _amounts, bool[] calldata _signs,
        uint256[] calldata _updatedStakes) external;

    /// @dev Notifies of stake migration event.
    /// @param _stakeOwner address The address of the subject stake owner.
    /// @param _amount uint256 The migrated amount.
    function stakeMigration(address _stakeOwner, uint256 _amount) external;
}

/// @title Orbs staking smart contract.
contract StakingContract is IStakingContract, IMigratableStakingContract {
    // BK Ok
    using SafeMath for uint256;

    // BK Ok
    struct Stake {
        uint256 amount;
        uint256 cooldownAmount;
        uint256 cooldownEndTime;
    }

    // BK Ok
    struct WithdrawResult {
        uint256 withdrawnAmount;
        uint256 stakedAmount;
        uint256 stakedAmountDiff;
    }

    // The version of the smart contract.
    // BK NOTE - Not referenced in this smart contract
    // BK Ok
    uint public constant VERSION = 1;

    // The maximum number of approved staking contracts as migration destinations.
    // BK NOTE - Referenced in addMigrationDestination()
    // BK Ok
    uint public constant MAX_APPROVED_STAKING_CONTRACTS = 10;

    // The mapping between stake owners and their data.
    mapping(address => Stake) internal stakes;

    // Total amount of staked tokens (not including unstaked tokes in cooldown or pending withdrawal).
    uint256 internal totalStakedTokens;

    // The period (in seconds) between a stake owner's request to stop staking and being able to withdraw them.
    uint256 public cooldownPeriodInSec;

    // The address responsible for managing migration to a new staking contract.
    // BK Ok
    // BK NOTE - Set in constructor() and setMigrationManager()
    address public migrationManager;

    // The address responsible for emergency operations and graceful return of staked tokens back to their owners.
    address public emergencyManager;

    // The list of staking contracts that are approved by this contract. It would be only allowed to migrate a stake to
    // one of these contracts.
    // BK NOTE - Written by approvedStakingContracts() and removeMigrationDestination(). Read by findApprovedStakingContractIndex()
    IMigratableStakingContract[] public approvedStakingContracts;

    // The address of the contract responsible for publishing stake change notifications.
    IStakeChangeNotifier public notifier;

    // The address of the ORBS token.
    // BK Ok
    IERC20 internal token;

    // Represents whether the contract accepts new staking requests. Please note, that even when it's turned off,
    // it'd be still possible to unstake or withdraw tokens.
    //
    // Note: This can be turned off only once by the emergency manager of the contract.
    bool public acceptingNewStakes = true;

    // Represents whether this staking contract allows releasing all unstaked tokens unconditionally. When it's turned
    // on, stake owners could release their staked tokens, without explicitly requesting to unstake them, and their
    // previously unstaked tokens, regardless of the cooldown period. This also stops the contract from accepting new
    // stakes.
    //
    // Note: This can be turned off only once by the emergency manager of the contract.
    bool public releasingAllStakes = false;

    // BK Next 7 Ok
    event MigrationManagerUpdated(address indexed migrationManager);
    event MigrationDestinationAdded(IMigratableStakingContract indexed stakingContract);
    event MigrationDestinationRemoved(IMigratableStakingContract indexed stakingContract);
    event EmergencyManagerUpdated(address indexed emergencyManager);
    event StakeChangeNotifierUpdated(IStakeChangeNotifier indexed notifier);
    event StoppedAcceptingNewStake();
    event ReleasedAllStakes();

    // BK Ok - Modifier for setMigrationManager(), setStakeChangeNotifier(), addMigrationDestination() and removeMigrationDestination()
    modifier onlyMigrationManager() {
        // BK Ok
        require(msg.sender == migrationManager, "StakingContract: caller is not the migration manager");

        _;
    }

    // BK Ok - Modifier for setEmergencyManager(), stopAcceptingNewStakes() and releaseAllStakes()
    modifier onlyEmergencyManager() {
        require(msg.sender == emergencyManager, "StakingContract: caller is not the emergency manager");

        _;
    }

    // BK Ok - Modifier for stake(), restake(), acceptMigration(), distributeRewards() and stopAcceptingNewStakes()
    modifier onlyWhenAcceptingNewStakes() {
        require(acceptingNewStakes && !releasingAllStakes, "StakingContract: not accepting new stakes");

        _;
    }

    // BK Ok - Modifier for withdrawReleasedStakes()
    modifier onlyWhenStakesReleased() {
        require(releasingAllStakes, "StakingContract: not releasing all stakes");

        _;
    }

    // BK Ok - Modifier for migrateStakedTokens() and releaseAllStakes()
    modifier onlyWhenStakesNotReleased() {
        require(!releasingAllStakes, "StakingContract: releasing all stakes");

        _;
    }

    /// @dev Initializes the staking contract.
    /// @param _cooldownPeriodInSec uint256 The period (in seconds) between a stake owner's request to stop staking and being
    /// able to withdraw them.
    /// @param _migrationManager address The address responsible for managing migration to a new staking contract.
    /// @param _emergencyManager address The address responsible for emergency operations and graceful return of staked
    /// tokens back to their owners.
    /// @param _token IERC20 The address of the ORBS token.
    // BK Ok - Can only be called once per contract deployment
    constructor(uint256 _cooldownPeriodInSec, address _migrationManager, address _emergencyManager, IERC20 _token) public {
        require(_cooldownPeriodInSec > 0, "StakingContract::ctor - cooldown period must be greater than 0");
        // BK Ok
        require(_migrationManager != address(0), "StakingContract::ctor - migration manager must not be 0");
        require(_emergencyManager != address(0), "StakingContract::ctor - emergency manager must not be 0");
        // BK Ok
        require(address(_token) != address(0), "StakingContract::ctor - ORBS token must not be 0");

        cooldownPeriodInSec = _cooldownPeriodInSec;
        // BK Ok
        migrationManager = _migrationManager;
        emergencyManager = _emergencyManager;
        // BK Ok
        token = _token;
    }

    /// @dev Sets the address of the migration manager.
    /// @param _newMigrationManager address The address of the new migration manager.
    // BK NOTE - External function, can only be called by migrationManager
    // BK Ok - Can only be executed by `migrationManager`
    function setMigrationManager(address _newMigrationManager) external onlyMigrationManager {
        // BK Ok
        require(_newMigrationManager != address(0), "StakingContract::setMigrationManager - address must not be 0");
        // BK Ok
        require(migrationManager != _newMigrationManager,
            "StakingContract::setMigrationManager - address must be different than the current address");

        // BK Ok
        migrationManager = _newMigrationManager;

        // BK Ok - event MigrationManagerUpdated(address indexed migrationManager);
        emit MigrationManagerUpdated(_newMigrationManager);
    }

    /// @dev Sets the address of the emergency manager.
    /// @param _newEmergencyManager address The address of the new emergency manager.
    // BK Ok - Can only be executed by `emergencyManager`
    function setEmergencyManager(address _newEmergencyManager) external onlyEmergencyManager {
        // BK Ok
        require(_newEmergencyManager != address(0), "StakingContract::setEmergencyManager - address must not be 0");
        require(emergencyManager != _newEmergencyManager,
            "StakingContract::setEmergencyManager - address must be different than the current address");

        emergencyManager = _newEmergencyManager;

        // BK Ok - event EmergencyManagerUpdated(address indexed emergencyManager);
        emit EmergencyManagerUpdated(_newEmergencyManager);
    }

    /// @dev Sets the address of the stake change notifier contract.
    /// @param _newNotifier IStakeChangeNotifier The address of the new stake change notifier contract.
    ///
    /// Note: it's allowed to reset the notifier to a zero address.
    // BK Ok - External function, can only be called by `migrationManager`
    function setStakeChangeNotifier(IStakeChangeNotifier _newNotifier) external onlyMigrationManager {
        // BK Ok
        require(notifier != _newNotifier,
            "StakingContract::setStakeChangeNotifier - address must be different than the current address");

        // BK Ok
        notifier = _newNotifier;

        // BK Ok - event StakeChangeNotifierUpdated(IStakeChangeNotifier indexed notifier);
        emit StakeChangeNotifierUpdated(notifier);
    }

    /// @dev Adds a new contract to the list of approved staking contracts migration destinations.
    /// @param _newStakingContract IMigratableStakingContract The new contract to add.
    // BK Ok - External function, can only be called by migrationManager
    function addMigrationDestination(IMigratableStakingContract _newStakingContract) external onlyMigrationManager {
        // BK Ok
        require(address(_newStakingContract) != address(0),
            "StakingContract::addMigrationDestination - address must not be 0");

        // BK Ok
        uint length = approvedStakingContracts.length;
        // BK Ok - (length + 1) <= 10
        require(length + 1 <= MAX_APPROVED_STAKING_CONTRACTS,
            "StakingContract::addMigrationDestination - can't add more staking contracts");

        // Check for duplicates.
        // BK Ok
        for (uint i = 0; i < length; ++i) {
            // BK Ok
            require(approvedStakingContracts[i] != _newStakingContract,
                "StakingContract::addMigrationDestination - can't add a duplicate staking contract");
        }

        // BK Ok
        approvedStakingContracts.push(_newStakingContract);

        // BK Ok - event MigrationDestinationAdded(IMigratableStakingContract indexed stakingContract);
        emit MigrationDestinationAdded(_newStakingContract);
    }

    /// @dev Removes a contract from the list of approved staking contracts migration destinations.
    /// @param _stakingContract IMigratableStakingContract The contract to remove.
    // BK Ok - External function, can only be called by migrationManager
    function removeMigrationDestination(IMigratableStakingContract _stakingContract) external onlyMigrationManager {
        // BK Ok
        require(address(_stakingContract) != address(0),
            "StakingContract::removeMigrationDestination - address must not be 0");

        // Check for existence.
        // BK Ok
        (uint i, bool exists) = findApprovedStakingContractIndex(_stakingContract);
        // BK Ok
        require(exists, "StakingContract::removeMigrationDestination - staking contract doesn't exist");

        // Swap the requested element with the last element and then delete it using pop/
        // BK Ok
        approvedStakingContracts[i] = approvedStakingContracts[approvedStakingContracts.length - 1];
        // BK Ok
        approvedStakingContracts.pop();

        // BK Ok - event MigrationDestinationRemoved(IMigratableStakingContract indexed stakingContract);
        emit MigrationDestinationRemoved(_stakingContract);
    }

    /// @dev Stakes ORBS tokens on behalf of msg.sender. This method assumes that the user has already approved at least
    /// the required amount using ERC20 approve.
    /// @param _amount uint256 The amount of tokens to stake.
    // BK NOTE - function stake(uint256 _amount) external;
    function stake(uint256 _amount) external onlyWhenAcceptingNewStakes {
        address stakeOwner = msg.sender;

        uint256 totalStakedAmount = stake(stakeOwner, _amount);

        // BK NOTE - event Staked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
        emit Staked(stakeOwner, _amount, totalStakedAmount);

        // Note: we aren't concerned with reentrancy since:
        //   1. At this point, due to the CEI pattern, a reentrant notifier can't affect the effects of this method.
        //   2. The notifier is set and managed by the migration manager.
        stakeChange(stakeOwner, _amount, true, totalStakedAmount);
    }

    /// @dev Unstakes ORBS tokens from msg.sender. If successful, this will start the cooldown period, after which
    /// msg.sender would be able to withdraw all of his tokens.
    /// @param _amount uint256 The amount of tokens to unstake.
    // BK NOTE - function unstake(uint256 _amount) external;
    function unstake(uint256 _amount) external {
        require(_amount > 0, "StakingContract::unstake - amount must be greater than 0");

        address stakeOwner = msg.sender;
        Stake storage stakeData = stakes[stakeOwner];
        uint256 stakedAmount = stakeData.amount;
        uint256 cooldownAmount = stakeData.cooldownAmount;
        uint256 cooldownEndTime = stakeData.cooldownEndTime;

        require(_amount <= stakedAmount, "StakingContract::unstake - can't unstake more than the current stake");

        // If any tokens in cooldown are ready for withdrawal - revert. Stake owner should withdraw their unstaked
        // tokens first.
        require(cooldownAmount == 0 || cooldownEndTime > now,
            "StakingContract::unstake - unable to unstake when there are tokens pending withdrawal");

        // Update the amount of tokens in cooldown. Please note that this will also restart the cooldown period of all
        // tokens in cooldown.
        stakeData.amount = stakedAmount.sub(_amount);
        stakeData.cooldownAmount = cooldownAmount.add(_amount);
        stakeData.cooldownEndTime = now.add(cooldownPeriodInSec);

        totalStakedTokens = totalStakedTokens.sub(_amount);

        uint256 totalStakedAmount = stakeData.amount;

        // BK NOTE - event Unstaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
        emit Unstaked(stakeOwner, _amount, totalStakedAmount);

        // Note: we aren't concerned with reentrancy since:
        //   1. At this point, due to the CEI pattern, a reentrant notifier can't affect the effects of this method.
        //   2. The notifier is set and managed by the migration manager.
        stakeChange(stakeOwner, _amount, false, totalStakedAmount);
    }

    /// @dev Requests to withdraw all of staked ORBS tokens back to msg.sender. Stake owners can withdraw their ORBS
    /// tokens only after previously unstaking them and after the cooldown period has passed (unless the contract was
    /// requested to release all stakes).
    // BK NOTE - function withdraw() external;
    function withdraw() external {
        address stakeOwner = msg.sender;

        // BK NOTE - struct WithdrawResult {
        // BK NOTE -     uint256 withdrawnAmount;
        // BK NOTE -     uint256 stakedAmount;
        // BK NOTE -     uint256 stakedAmountDiff;
        // BK NOTE - }
        WithdrawResult memory res = withdraw(stakeOwner);

        // BK NOTE - event Withdrew(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
        emit Withdrew(stakeOwner, res.withdrawnAmount, res.stakedAmount);

        // Trigger staking state change notifications only if the staking amount was changed.
        if (res.stakedAmountDiff == 0) {
            return;
        }

        // Note: we aren't concerned with reentrancy since:
        //   1. At this point, due to the CEI pattern, a reentrant notifier can't affect the effects of this method.
        //   2. The notifier is set and managed by the migration manager.
        stakeChange(stakeOwner, res.stakedAmountDiff, false, res.stakedAmount);
    }

    /// @dev Restakes unstaked ORBS tokens (in or after cooldown) for msg.sender.
    // BK NOTE - function restake() external;
    function restake() external onlyWhenAcceptingNewStakes {
        address stakeOwner = msg.sender;
        Stake storage stakeData = stakes[stakeOwner];
        uint256 cooldownAmount = stakeData.cooldownAmount;

        require(cooldownAmount > 0, "StakingContract::restake - no unstaked tokens");

        stakeData.amount = stakeData.amount.add(cooldownAmount);
        stakeData.cooldownAmount = 0;
        stakeData.cooldownEndTime = 0;

        totalStakedTokens = totalStakedTokens.add(cooldownAmount);

        uint256 totalStakedAmount = stakeData.amount;

        // BK NOTE - event Restaked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
        emit Restaked(stakeOwner, cooldownAmount, totalStakedAmount);

        // Note: we aren't concerned with reentrancy since:
        //   1. At this point, due to the CEI pattern, a reentrant notifier can't affect the effects of this method.
        //   2. The notifier is set and managed by the migration manager.
        stakeChange(stakeOwner, cooldownAmount, true, totalStakedAmount);
    }

    /// @dev Stakes ORBS tokens on behalf of msg.sender. This method assumes that the user has already approved at least
    /// the required amount using ERC20 approve.
    /// @param _stakeOwner address The specified stake owner.
    /// @param _amount uint256 The amount of tokens to stake.
    // BK NOTE - function acceptMigration(address _stakeOwner, uint256 _amount) external;
    // BK NOTE - msg.sender will be the new instance of this contract
    // BK NOTE - If an account executes this directly, the effects are the same as executing stake(uint256), & different events emitted
    function acceptMigration(address _stakeOwner, uint256 _amount) external onlyWhenAcceptingNewStakes {
        uint256 totalStakedAmount = stake(_stakeOwner, _amount);

        // BK NOTE - event AcceptedMigration(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
        emit AcceptedMigration(_stakeOwner, _amount, totalStakedAmount);

        // Note: we aren't concerned with reentrancy since:
        //   1. At this point, due to the CEI pattern, a reentrant notifier can't affect the effects of this method.
        //   2. The notifier is set and managed by the migration manager.
        stakeChange(_stakeOwner, _amount, true, totalStakedAmount);
    }

    /// @dev Migrates the stake of msg.sender from this staking contract to a new approved staking contract.
    /// @param _newStakingContract IMigratableStakingContract The new staking contract which supports stake migration.
    /// @param _amount uint256 The amount of tokens to migrate.
    // BK NOTE - function migrateStakedTokens(IMigratableStakingContract _newStakingContract, uint256 _amount) external;
    function migrateStakedTokens(IMigratableStakingContract _newStakingContract, uint256 _amount) external
        onlyWhenStakesNotReleased {
        // BK Ok
        require(isApprovedStakingContract(_newStakingContract),
            "StakingContract::migrateStakedTokens - migration destination wasn't approved");
        require(_amount > 0, "StakingContract::migrateStakedTokens - amount must be greater than 0");

        address stakeOwner = msg.sender;
        Stake storage stakeData = stakes[stakeOwner];
        uint256 stakedAmount = stakeData.amount;

        require(stakedAmount > 0, "StakingContract::migrateStakedTokens - no staked tokens");
        require(_amount <= stakedAmount, "StakingContract::migrateStakedTokens - amount exceeds staked token balance");

        stakeData.amount = stakedAmount.sub(_amount);

        totalStakedTokens = totalStakedTokens.sub(_amount);

        // BK Ok
        require(_newStakingContract.getToken() == token,
            "StakingContract::migrateStakedTokens - staked tokens must be the same");
        require(token.approve(address(_newStakingContract), _amount),
            "StakingContract::migrateStakedTokens - couldn't approve transfer");

        // BK NOTE - event MigratedStake(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
        emit MigratedStake(stakeOwner, _amount, stakeData.amount);

        _newStakingContract.acceptMigration(stakeOwner, _amount);

        // Note: we aren't concerned with reentrancy since:
        //   1. At this point, due to the CEI pattern, a reentrant notifier can't affect the effects of this method.
        //   2. The notifier is set and managed by the migration manager.
        stakeMigration(stakeOwner, _amount);
    }

    /// @dev Distributes staking rewards to a list of addresses by directly adding rewards to their stakes. This method
    /// assumes that the user has already approved at least the required amount using ERC20 approve. Since this is a
    /// convenience method, we aren't concerned about reaching block gas limit by using large lists. We assume that
    /// callers will be able to batch/paginate their requests properly.
    /// @param _totalAmount uint256 The total amount of rewards to distributes.
    /// @param _stakeOwners address[] The addresses of the stake owners.
    /// @param _amounts uint256[] The amounts of the rewards.
    // BK NOTE - function distributeRewards(uint256 _totalAmount, address[] calldata _stakeOwners, uint256[] calldata _amounts) external;
    // BK TODO - Check if sum(_amounts) can overflow to _totalAmount
    // BK TODO - Check duplicate _stakeOwners
    function distributeRewards(uint256 _totalAmount, address[] calldata _stakeOwners, uint256[] calldata _amounts) external
        onlyWhenAcceptingNewStakes {
        require(_totalAmount > 0, "StakingContract::distributeRewards - total amount must be greater than 0");

        uint256 stakeOwnersLength = _stakeOwners.length;
        uint256 amountsLength = _amounts.length;

        require(stakeOwnersLength > 0 && amountsLength > 0,
            "StakingContract::distributeRewards - lists can't be empty");
        require(stakeOwnersLength == amountsLength,
            "StakingContract::distributeRewards - lists must be of the same size");

        // Transfer all the tokens to the smart contract and update the stake owners list accordingly.
        require(token.transferFrom(msg.sender, address(this), _totalAmount),
            "StakingContract::distributeRewards - insufficient allowance");

        bool[] memory signs = new bool[](amountsLength);
        uint256[] memory totalStakedAmounts = new uint256[](amountsLength);

        uint256 expectedTotalAmount = 0;
        for (uint i = 0; i < stakeOwnersLength; ++i) {
            address stakeOwner = _stakeOwners[i];
            uint256 amount = _amounts[i];

            require(stakeOwner != address(0), "StakingContract::distributeRewards - stake owner can't be 0");
            require(amount > 0, "StakingContract::distributeRewards - amount must be greater than 0");

            Stake storage stakeData = stakes[stakeOwner];
            stakeData.amount = stakeData.amount.add(amount);

            expectedTotalAmount = expectedTotalAmount.add(amount);

            uint256 totalStakedAmount = stakeData.amount;
            signs[i] = true;
            totalStakedAmounts[i] = totalStakedAmount;

            // BK NOTE - event Staked(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
            emit Staked(stakeOwner, amount, totalStakedAmount);
        }

        require(_totalAmount == expectedTotalAmount, "StakingContract::distributeRewards - incorrect total amount");

        totalStakedTokens = totalStakedTokens.add(_totalAmount);

        // Note: we aren't concerned with reentrancy since:
        //   1. At this point, due to the CEI pattern, a reentrant notifier can't affect the effects of this method.
        //   2. The notifier is set and managed by the migration manager.
        stakeChangeBatch(_stakeOwners, _amounts, signs, totalStakedAmounts);
    }

    /// @dev Returns the stake of the specified stake owner (excluding unstaked tokens).
    /// @param _stakeOwner address The address to check.
    /// @return uint256 The stake of the stake owner.
    // BK NOTE - function getStakeBalanceOf(address _stakeOwner) external view returns (uint256);
    // BK Ok - External view function
    function getStakeBalanceOf(address _stakeOwner) external view returns (uint256) {
        // BK Ok
        return stakes[_stakeOwner].amount;
    }

    /// @dev Returns the total amount staked tokens (excluding unstaked tokens).
    /// @return uint256 The total staked tokens of all stake owners.
    // BK NOTE - function getTotalStakedTokens() external view returns (uint256);
    // BK Ok - External view function
    function getTotalStakedTokens() external view returns (uint256) {
        // BK Ok
        return totalStakedTokens;
    }

    /// @dev Returns the time that the cooldown period ends (or ended) and the amount of tokens to be released.
    /// @param _stakeOwner address The address to check.
    /// @return cooldownAmount uint256 The total tokens in cooldown.
    /// @return cooldownEndTime uint256 The time when the cooldown period ends (in seconds).
    // BK NOTE - function getUnstakeStatus(address _stakeOwner) external view returns (uint256 cooldownAmount, uint256 cooldownEndTime);
    // BK Ok - External view function
    function getUnstakeStatus(address _stakeOwner) external view returns (uint256 cooldownAmount,
        uint256 cooldownEndTime) {
        Stake memory stakeData = stakes[_stakeOwner];
        cooldownAmount = stakeData.cooldownAmount;
        cooldownEndTime = stakeData.cooldownEndTime;
    }

    /// @dev Returns the address of the underlying staked token.
    /// @return IERC20 The address of the token.
    // BK NOTE - function getToken() external view returns (IERC20);
    // BK Ok - External view function
    function getToken() external view returns (IERC20) {
        // BK Ok
        return token;
    }

    /// @dev Requests the contract to stop accepting new staking requests.
    // BK Ok - External function that can only be executed by `emergencyManager`
    function stopAcceptingNewStakes() external onlyEmergencyManager onlyWhenAcceptingNewStakes {
        // BK Ok
        acceptingNewStakes = false;

        // BK Ok - event StoppedAcceptingNewStake();
        emit StoppedAcceptingNewStake();
    }

    /// @dev Requests the contract to release all stakes.
    // BK Ok - External function that can only be executed by `emergencyManager`
    function releaseAllStakes() external onlyEmergencyManager onlyWhenStakesNotReleased {
        // BK Ok
        releasingAllStakes = true;

        // BK Ok - event ReleasedAllStakes();
        emit ReleasedAllStakes();
    }

    /// @dev Requests withdraw of released tokens for a list of addresses.
    /// @param _stakeOwners address[] The addresses of the stake owners.
    // BK TODO - Check what happens with dodgy data
    function withdrawReleasedStakes(address[] calldata _stakeOwners) external onlyWhenStakesReleased {
        uint256 stakeOwnersLength = _stakeOwners.length;
        uint256[] memory stakedAmountDiffs = new uint256[](stakeOwnersLength);
        bool[] memory signs = new bool[](stakeOwnersLength);
        uint256[] memory totalStakedAmounts = new uint256[](stakeOwnersLength);

        for (uint i = 0; i < stakeOwnersLength; ++i) {
            address stakeOwner = _stakeOwners[i];

            // BK NOTE - struct WithdrawResult {
            // BK NOTE -     uint256 withdrawnAmount;
            // BK NOTE -     uint256 stakedAmount;
            // BK NOTE -     uint256 stakedAmountDiff;
            // BK NOTE - }
            WithdrawResult memory res = withdraw(stakeOwner);
            stakedAmountDiffs[i] = res.stakedAmountDiff;
            signs[i] = false;
            totalStakedAmounts[i] = res.stakedAmount;

            // BK NOTE - event Withdrew(address indexed stakeOwner, uint256 amount, uint256 totalStakedAmount);
            emit Withdrew(stakeOwner, res.withdrawnAmount, res.stakedAmount);
        }

        // Note: we aren't concerned with reentrancy since:
        //   1. At this point, due to the CEI pattern, a reentrant notifier can't affect the effects of this method.
        //   2. The notifier is set and managed by the migration manager.
        stakeChangeBatch(_stakeOwners, stakedAmountDiffs, signs, totalStakedAmounts);
    }

    /// @dev Returns whether a specific staking contract was approved as a migration destination.
    /// @param _stakingContract IMigratableStakingContract The staking contract to look for.
    /// @return exists bool The approval status.
    // BK NOTE - Called by migrateStakedTokens()
    // BK Ok - Public view function
    function isApprovedStakingContract(IMigratableStakingContract _stakingContract) public view returns (bool exists) {
        // BK Ok
        (, exists) = findApprovedStakingContractIndex(_stakingContract);
    }

    /// @dev Returns whether stake change notification is enabled.
    // BK NOTE - Called by stakeChange(), stakeChangeBatch() and stakeMigration
    // BK Ok - View internal function
    function shouldNotifyStakeChange() view internal returns (bool) {
        return address(notifier) != address(0);
    }

    /// @dev Notifies of stake change events.
    /// @param _stakeOwner address The address of the subject stake owner.
    /// @param _amount int256 The difference in the total staked amount.
    /// @param _sign bool The sign of the added (true) or subtracted (false) amount.
    /// @param _updatedStake uint256 The updated total staked amount.
    function stakeChange(address _stakeOwner, uint256 _amount, bool _sign, uint256 _updatedStake) internal {
        if (!shouldNotifyStakeChange()) {
            return;
        }

        // BK TODO - Check what happens if an invalid notifier is specified
        notifier.stakeChange(_stakeOwner, _amount, _sign, _updatedStake);
    }

    /// @dev Notifies of multiple stake change events.
    /// @param _stakeOwners address[] The addresses of subject stake owners.
    /// @param _amounts uint256[] The differences in total staked amounts.
    /// @param _signs bool[] The signs of the added (true) or subtracted (false) amounts.
    /// @param _updatedStakes uint256[] The updated total staked amounts.
    function stakeChangeBatch(address[] memory _stakeOwners, uint256[] memory _amounts, bool[] memory _signs,
        uint256[] memory _updatedStakes) internal {
        if (!shouldNotifyStakeChange()) {
            return;
        }

        notifier.stakeChangeBatch(_stakeOwners, _amounts, _signs, _updatedStakes);
    }

    /// @dev Notifies of stake migration event.
    /// @param _stakeOwner address The address of the subject stake owner.
    /// @param _amount uint256 The migrated amount.
    function stakeMigration(address _stakeOwner, uint256 _amount) internal {
        if (!shouldNotifyStakeChange()) {
            return;
        }

        notifier.stakeMigration(_stakeOwner, _amount);
    }

    /// @dev Stakes amount of ORBS tokens on behalf of the specified stake owner.
    /// @param _stakeOwner address The specified stake owner.
    /// @param _amount uint256 The amount of tokens to stake.
    /// @return totalStakedAmount uint256 The total stake of the stake owner.
    // BK NOTE - Called by stake() and acceptMigration()
    // BK Ok - Private function callable by any account with tokens approved to this contract
    function stake(address _stakeOwner, uint256 _amount) private returns (uint256 totalStakedAmount) {
        require(_stakeOwner != address(0), "StakingContract::stake - stake owner can't be 0");
        require(_amount > 0, "StakingContract::stake - amount must be greater than 0");

        Stake storage stakeData = stakes[_stakeOwner];
        stakeData.amount = stakeData.amount.add(_amount);

        totalStakedTokens = totalStakedTokens.add(_amount);

        totalStakedAmount = stakeData.amount;

        // Transfer the tokens to the smart contract and update the stake owners list accordingly.
        require(token.transferFrom(msg.sender, address(this), _amount),
            "StakingContract::stake - insufficient allowance");
    }

    /// @dev Requests to withdraw all of staked ORBS tokens back to the specified stake owner. Stake owners can withdraw
    /// their ORBS tokens only after previously unstaking them and after the cooldown period has passed (unless the
    /// contract was requested to release all stakes).
    /// @return res WithdrawResult The result of the withdraw operation.
    // BK NOTE - Called by withdraw() and withdrawReleasedStakes()
    // BK NOTE - struct WithdrawResult {
    // BK NOTE -     uint256 withdrawnAmount;
    // BK NOTE -     uint256 stakedAmount;
    // BK NOTE -     uint256 stakedAmountDiff;
    // BK NOTE - }
    function withdraw(address _stakeOwner) private returns (WithdrawResult memory res) {
        require(_stakeOwner != address(0), "StakingContract::withdraw - stake owner can't be 0");

        Stake storage stakeData = stakes[_stakeOwner];
        res.stakedAmount = stakeData.amount;
        res.withdrawnAmount = stakeData.cooldownAmount;
        res.stakedAmountDiff = 0;

        if (!releasingAllStakes) {
            require(res.withdrawnAmount > 0, "StakingContract::withdraw - no unstaked tokens");
            require(stakeData.cooldownEndTime <= now, "StakingContract::withdraw - tokens are still in cooldown");
        } else {
            // If the contract was requested to release all stakes - allow to withdraw all staked and unstaked tokens.
            res.withdrawnAmount = res.withdrawnAmount.add(res.stakedAmount);
            res.stakedAmountDiff = res.stakedAmount;

            require(res.withdrawnAmount > 0, "StakingContract::withdraw - no staked or unstaked tokens");

            stakeData.amount = 0;

            totalStakedTokens = totalStakedTokens.sub(res.stakedAmount);

            res.stakedAmount = 0;
        }

        stakeData.cooldownAmount = 0;
        stakeData.cooldownEndTime = 0;

        require(token.transfer(_stakeOwner, res.withdrawnAmount),
            "StakingContract::withdraw - couldn't transfer stake");
    }

    /// @dev Returns an index of an existing approved staking contract.
    /// @param _stakingContract IMigratableStakingContract The staking contract to look for.
    /// @return index uint The index of the located staking contract (in the case that it was found).
    /// @return exists bool The search result.
    // BK NOTE - Called by removeMigrationDestination() and isApprovedStakingContract()
    // BK Ok - Private view function
    function findApprovedStakingContractIndex(IMigratableStakingContract _stakingContract) private view returns
        (uint index, bool exists) {
        // BK Ok
        uint length = approvedStakingContracts.length;
        // BK Ok
        for (index = 0; index < length; ++index) {
            // BK Ok
            if (approvedStakingContracts[index] == _stakingContract) {
                // BK Ok
                exists = true;
                // BK Ok
                return (index, exists);
            }
        }

        // BK OK - Should return (index = length, exist = false)
        exists = false;
    }
}
