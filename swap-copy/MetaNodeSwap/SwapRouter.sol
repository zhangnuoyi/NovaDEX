// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.24;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ISwapRouter.sol";
import "./interfaces/IPool.sol";
import "./interfaces/IPoolManager.sol";

contract SwapRouter is ISwapRouter {
    IPoolRouter public poolManager;
    constructor(address _poolManager) {
        poolManager = IPoolManager(_poolManager);
    }


    function parseRevertReason(bytes memory data) public pure returns (
            int256,int256
        ) {
            if(data.length != 64){
                if(data.length <68){
                    revert("Invalid revert reason");
                }
             assembly {
                reason := add(reason, 0x04)
            }
             revert(abi.decode(reason, (string)));
            }
        return abi.decode(reason, (int256,int256));
    }



}