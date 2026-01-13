// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MetNode is ERC20 {
    uint256 public constant DECIMALS = 18;
    uint256 public constant MAX_SUPPLY = 1000000 * 10 ** DECIMALS;
    constructor() ERC20("MetNodeToken", "MN") {
        _mint(msg.sender, 1000000 * 10 ** DECIMALS);
    }
}
