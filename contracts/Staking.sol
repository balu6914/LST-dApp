// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./LiquidToken.sol"; // Import LiquidToken contract

contract Staking is Ownable, ReentrancyGuard {
    LiquidToken public liquidToken;
    mapping(address => uint256) public stakedETH;
    address[] public stakers;
    uint256 public totalStaked;

    event Stake(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);
    event RewardDistributed(uint256 rewardAmount);

    constructor() {
        liquidToken = new LiquidToken();
        liquidToken.transferOwnership(address(this)); // Transfer minting rights to the Staking contract
    }

    // Stake ETH and receive LST tokens in return
    function stakeETH() external payable nonReentrant {
        require(msg.value > 0, "Cannot stake 0 ETH");

        if (stakedETH[msg.sender] == 0) {
            stakers.push(msg.sender); // Add the staker if they are staking for the first time.
        }

        stakedETH[msg.sender] += msg.value;
        totalStaked += msg.value;

        liquidToken.mint(msg.sender, msg.value); // Mint 1 LST per 1 staked ETH

        emit Stake(msg.sender, msg.value);
    }

    // Distribute rewards proportionally to all stakers
    function distributeRewards(uint256 rewardAmount) external onlyOwner {
        require(address(this).balance >= rewardAmount + totalStaked, "Not enough ETH in contract");
        require(rewardAmount > 0, "Reward amount must be greater than 0");
        require(totalStaked > 0, "No staked ETH available for rewards");

        // Distribute rewards proportionally based on each staker's share of the total staked ETH.
        for (uint256 i = 0; i < stakers.length; i++) {
            address staker = stakers[i];
            uint256 stakerShare = (stakedETH[staker] * rewardAmount) / totalStaked;
            stakedETH[staker] += stakerShare;
        }

        emit RewardDistributed(rewardAmount);
    }

    // Redeem staked ETH by burning LST tokens
    function redeemETH(uint256 _amount) external nonReentrant {
        require(stakedETH[msg.sender] >= _amount, "Insufficient balance");
        stakedETH[msg.sender] -= _amount;
        totalStaked -= _amount;

        // Burn LST tokens from the user
        liquidToken.burn(msg.sender, _amount);

        payable(msg.sender).transfer(_amount);

        emit Redeem(msg.sender, _amount);
    }

    // View function to get the balance of staked ETH for an address
    function getStakedBalance(address _user) external view returns (uint256) {
        return stakedETH[_user];
    }

    // View function to get the total staked ETH in the contract
    function getTotalStaked() external view returns (uint256) {
        return totalStaked;
    }
}
