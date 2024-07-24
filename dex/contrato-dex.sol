// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SimpleDEX is ReentrancyGuard {
    IERC20 public token1;
    IERC20 public token2;
    
    uint256 public reserve1;
    uint256 public reserve2;

    constructor(address _token1, address _token2) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
    }

    function addLiquidity(uint256 amount1, uint256 amount2) external nonReentrant {
        require(amount1 > 0 && amount2 > 0, "Invalid amounts");

        token1.transferFrom(msg.sender, address(this), amount1);
        token2.transferFrom(msg.sender, address(this), amount2);

        reserve1 += amount1;
        reserve2 += amount2;
    }

    function removeLiquidity(uint256 amount1, uint256 amount2) external nonReentrant {
        require(amount1 <= reserve1 && amount2 <= reserve2, "Insufficient liquidity");

        reserve1 -= amount1;
        reserve2 -= amount2;

        token1.transfer(msg.sender, amount1);
        token2.transfer(msg.sender, amount2);
    }

    function swap(uint256 amountIn, address fromToken, address toToken) external nonReentrant {
        require(fromToken == address(token1) || fromToken == address(token2), "Invalid fromToken");
        require(toToken == address(token1) || toToken == address(token2), "Invalid toToken");
        require(fromToken != toToken, "fromToken and toToken must be different");

        IERC20 from = IERC20(fromToken);
        IERC20 to = IERC20(toToken);
        
        uint256 amountOut;
        if (fromToken == address(token1)) {
            require(amountIn <= reserve1, "Insufficient reserve");
            amountOut = (amountIn * reserve2) / reserve1;
            reserve1 += amountIn;
            reserve2 -= amountOut;
        } else {
            require(amountIn <= reserve2, "Insufficient reserve");
            amountOut = (amountIn * reserve1) / reserve2;
            reserve2 += amountIn;
            reserve1 -= amountOut;
        }

        from.transferFrom(msg.sender, address(this), amountIn);
        to.transfer(msg.sender, amountOut);
    }
}
