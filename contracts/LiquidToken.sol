// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidToken is ERC20, Ownable {
    constructor() ERC20("Liquid Staking Token", "LST") {}

    // Only the owner (Staking contract) can call the mint function
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Only the owner (Staking contract) can call the burn function
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
