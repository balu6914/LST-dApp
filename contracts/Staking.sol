// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./LiquidToken.sol"; // Import the LiquidToken contract

contract Staking is Ownable {
    LiquidStakingToken public token;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public stakingRewards;
    uint256 public totalStaked;
    uint256 public rewardRate = 100; // Example reward rate (in basis points, or 1%)
    uint256 public rewardInterval = 30 days; // Reward calculation interval

    address[] public stakers;

    constructor(address initialOwner) Ownable(initialOwner) {
        token = new LiquidStakingToken(initialOwner);
    }

    // Function to allow users to deposit ETH and receive liquid staking tokens
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");

        if (stakedAmount[msg.sender] == 0) {
            stakers.push(msg.sender);
        }

        stakedAmount[msg.sender] += msg.value;
        totalStaked += msg.value;

        // Mint an equivalent amount of LST tokens to the user
        token.mint(msg.sender, msg.value);
    }

    // Function to calculate staking rewards based on a simple reward formula
    function calculateRewards(address staker) public view returns (uint256) {
        uint256 staked = stakedAmount[staker];
        uint256 reward = (staked * rewardRate) / 10000;
        return reward;
    }

    // Function to distribute rewards to users
    function distributeRewards() external onlyOwner {
        for (uint256 i = 0; i < stakers.length; i++) {
            address staker = stakers[i];
            uint256 reward = calculateRewards(staker);
            stakingRewards[staker] += reward;
            token.mint(staker, reward);
        }
    }

    // Function to allow users to redeem their staked ETH by burning their LST tokens
    function redeem(uint256 tokenAmount) external {
        require(token.balanceOf(msg.sender) >= tokenAmount, "Insufficient token balance");
        uint256 ethAmount = tokenAmount;

        require(stakedAmount[msg.sender] >= ethAmount, "Insufficient staked balance");

        // Burn the LST tokens from the user
        token.burn(msg.sender, tokenAmount);

        // Update the user's staked balance and total staked amount
        stakedAmount[msg.sender] -= ethAmount;
        totalStaked -= ethAmount;

        // Transfer the equivalent ETH back to the user
        payable(msg.sender).transfer(ethAmount);
    }
}
