// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

import "./owner/Operator.sol";

// UNITE FINANCE
contract UShare is ERC20Burnable, Operator {
    using SafeMath for uint256;

    uint256 public constant FARMING_POOL_REWARD_ALLOCATION = 59500 ether;

    uint256 public constant VESTING_DURATION = 365 days;
    uint256 public startTime;
    uint256 public endTime;

    uint256 public communityFundRewardRate;
    uint256 public team1FundRewardRate;
    uint256 public devFundRewardRate;

    address public communityFund;
    address public team1Fund;
    address public devFund;

    uint256 public communityFundLastClaimed;
    uint256 public team1FundLastClaimed;
    uint256 public devFundLastClaimed;

    bool public rewardPoolDistributed = false;
    bool public isAllocated = false;

    constructor(uint256 _startTime, address _communityFund, address _devFund, address _team1Fund) public ERC20("USHARE", "USHARE") {
        _mint(msg.sender, 1 ether); // mint 1 UNITE Share for initial pools deployment

        startTime = _startTime;
        endTime = startTime + VESTING_DURATION;

        communityFundLastClaimed = startTime;
        team1FundLastClaimed = startTime;
        devFundLastClaimed = startTime;

        require(_devFund != address(0), "Address cannot be 0");
        devFund = _devFund;

        require(_team1Fund != address(0), "Address cannot be 0");
        team1Fund = _team1Fund;

        require(_communityFund != address(0), "Address cannot be 0");
        communityFund = _communityFund;
    }

    function setAllocations(uint256 _communityAllocation, uint256 _devAllocation, uint256 _team1Allocation) external {
        require(_communityAllocation <= 10000 ether, "community allocation too high");
        require(_devAllocation <= 2100 ether, "dev allocation too high");
        require(_team1Allocation <= 2100 ether, "team1 allocation too high");

        isAllocated = true;

        communityFundRewardRate = _communityAllocation.div(VESTING_DURATION);
        team1FundRewardRate = _team1Allocation.div(VESTING_DURATION);
        devFundRewardRate = _devAllocation.div(VESTING_DURATION);
    }

    function setTreasuryFund(address _communityFund) external {
        require(msg.sender == devFund, "!dev");
        communityFund = _communityFund;
    }

    function setDevFund(address _devFund) external {
        require(msg.sender == devFund, "!dev");
        require(_devFund != address(0), "zero");
        devFund = _devFund;
    }

    function setTeam1Fund(address _team1Fund) external {
        require(msg.sender == team1Fund, "!team1");
        require(_team1Fund != address(0), "zero");
        team1Fund = _team1Fund;
    }

    function unclaimedTreasuryFund() public view returns (uint256 _pending) {
        uint256 _now = block.timestamp;
        if (_now > endTime) _now = endTime;
        if (communityFundLastClaimed >= _now) return 0;
        _pending = _now.sub(communityFundLastClaimed).mul(communityFundRewardRate);
    }

    function unclaimedDevFund() public view returns (uint256 _pending) {
        uint256 _now = block.timestamp;
        if (_now > endTime) _now = endTime;
        if (devFundLastClaimed >= _now) return 0;
        _pending = _now.sub(devFundLastClaimed).mul(devFundRewardRate);
    }

    function unclaimedTeam1Fund() public view returns (uint256 _pending) {
        uint256 _now = block.timestamp;
        if (_now > endTime) _now = endTime;
        if (team1FundLastClaimed >= _now) return 0;
        _pending = _now.sub(team1FundLastClaimed).mul(team1FundRewardRate);
    }

    /**
     * @dev Claim pending rewards to community and dev fund
     */
    function claimRewards() external {
        require(isAllocated, "not allocated to funds yet");
        uint256 _pending = unclaimedTreasuryFund();
        if (_pending > 0 && communityFund != address(0)) {
            _mint(communityFund, _pending);
            communityFundLastClaimed = block.timestamp;
        }
        _pending = unclaimedDevFund();
        if (_pending > 0 && devFund != address(0)) {
            _mint(devFund, _pending);
            devFundLastClaimed = block.timestamp;
        }
        _pending = unclaimedTeam1Fund();
        if (_pending > 0 && team1Fund != address(0)) {
            _mint(team1Fund, _pending);
            team1FundLastClaimed = block.timestamp;
        }
    }

    /**
     * @notice distribute to reward pool (only once)
     */
    function distributeReward(address _farmingIncentiveFund) external onlyOperator {
        require(!rewardPoolDistributed, "only can distribute once");
        require(_farmingIncentiveFund != address(0), "!_farmingIncentiveFund");
        rewardPoolDistributed = true;
        _mint(_farmingIncentiveFund, FARMING_POOL_REWARD_ALLOCATION);
    }

    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        _token.transfer(_to, _amount);
    }
}
