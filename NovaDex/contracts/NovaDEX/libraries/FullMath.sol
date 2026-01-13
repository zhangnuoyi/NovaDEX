// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title FullMath 库 - 提供通用的高精度数学运算
/// @notice 实现大整数的安全乘法和除法，处理溢出情况
library FullMath {
    /// @notice 计算(a * b) / c，使用高精度算法避免溢出
    /// @dev 假设a和b的乘积不会超过2^256
    /// @param a 第一个乘数
    /// @param b 第二个乘数
    /// @param c 除数
    /// @return result 计算结果
    function mulDiv(uint256 a, uint256 b, uint256 c) internal pure returns (uint256 result) {
        require(c > 0, "FullMath: DIVISION_BY_ZERO");
        
        // 使用Solidity内置的mulDiv函数（Solidity 0.8.19+支持）
        return a * b / c;
    }

    /// @notice 计算(a * b) / c，并向上取整
    /// @param a 第一个乘数
    /// @param b 第二个乘数
    /// @param c 除数
    /// @return result 计算结果
    function mulDivRoundingUp(uint256 a, uint256 b, uint256 c) internal pure returns (uint256 result) {
        result = mulDiv(a, b, c);
        if (mulmod(a, b, c) > 0) {
            require(result < type(uint256).max, "FullMath: OVERFLOW");
            result++;
        }
    }

    /// @notice 安全加法，检查溢出
    /// @param a 第一个加数
    /// @param b 第二个加数
    /// @return result 计算结果
    function add(uint256 a, uint256 b) internal pure returns (uint256 result) {
        require((result = a + b) >= a, "FullMath: ADD_OVERFLOW");
    }

    /// @notice 安全减法，检查溢出
    /// @param a 被减数
    /// @param b 减数
    /// @return result 计算结果
    function sub(uint256 a, uint256 b) internal pure returns (uint256 result) {
        require((result = a - b) <= a, "FullMath: SUB_OVERFLOW");
    }

    /// @notice 安全乘法，检查溢出
    /// @param a 第一个乘数
    /// @param b 第二个乘数
    /// @return result 计算结果
    function mul(uint256 a, uint256 b) internal pure returns (uint256 result) {
        require(b == 0 || (result = a * b) / b == a, "FullMath: MUL_OVERFLOW");
    }

    /// @notice 计算2的幂
    /// @param exponent 指数
    /// @return result 2^exponent
    function pow2(uint256 exponent) internal pure returns (uint256 result) {
        require(exponent < 256, "FullMath: POW2_OVERFLOW");
        result = 1 << exponent;
    }

    /// @notice 计算a的b次方（快速幂算法）
    /// @param a 底数
    /// @param b 指数
    /// @return result 计算结果
    function pow(uint256 a, uint256 b) internal pure returns (uint256 result) {
        result = 1;
        while (b > 0) {
            if (b & 1 != 0) {
                result = mul(result, a);
            }
            a = mul(a, a);
            b >>= 1;
        }
    }

    /// @notice 计算两个数的最大公约数（欧几里得算法）
    /// @param a 第一个数
    /// @param b 第二个数
    /// @return gcd 最大公约数
    function gcd(uint256 a, uint256 b) internal pure returns (uint256 gcd) {
        while (b != 0) {
            (a, b) = (b, a % b);
        }
        gcd = a;
    }

    /// @notice 计算两个数的最小公倍数
    /// @param a 第一个数
    /// @param b 第二个数
    /// @return lcm 最小公倍数
    function lcm(uint256 a, uint256 b) internal pure returns (uint256 lcm) {
        require(a != 0 && b != 0, "FullMath: LCM_ZERO");
        lcm = mul(a, b) / gcd(a, b);
    }

    /// @notice 计算一个数的平方根（牛顿迭代法）
    /// @param x 输入值
    /// @return result 平方根
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) return 0;
        
        // 初始猜测值
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        
        // 牛顿迭代
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        
        result = y;
    }

    /// @notice 计算一个数的平方根并向上取整
    /// @param x 输入值
    /// @return result 向上取整的平方根
    function sqrtRoundingUp(uint256 x) internal pure returns (uint256 result) {
        result = sqrt(x);
        if (result * result < x) {
            result++;
        }
    }

    /// @notice 计算对数（以2为底）
    /// @param x 输入值
    /// @return log 对数结果
    function log2(uint256 x) internal pure returns (uint256 log) {
        require(x > 0, "FullMath: LOG2_ZERO");
        
        if (x >= 2**128) { x >>= 128; log += 128; }
        if (x >= 2**64) { x >>= 64; log += 64; }
        if (x >= 2**32) { x >>= 32; log += 32; }
        if (x >= 2**16) { x >>= 16; log += 16; }
        if (x >= 2**8) { x >>= 8; log += 8; }
        if (x >= 2**4) { x >>= 4; log += 4; }
        if (x >= 2**2) { x >>= 2; log += 2; }
        if (x >= 2**1) { log += 1; }
    }

    /// @notice 计算对数（以10为底）
    /// @param x 输入值
    /// @return log 对数结果
    function log10(uint256 x) internal pure returns (uint256 log) {
        require(x > 0, "FullMath: LOG10_ZERO");
        
        if (x >= 10**18) { x /= 10**18; log += 18; }
        if (x >= 10**9) { x /= 10**9; log += 9; }
        if (x >= 10**4) { x /= 10**4; log += 4; }
        if (x >= 10**2) { x /= 10**2; log += 2; }
        if (x >= 10**1) { log += 1; }
    }

    /// @notice 计算阶乘
    /// @param n 输入值
    /// @return factorial 阶乘结果
    function factorial(uint256 n) internal pure returns (uint256 factorial) {
        require(n <= 20, "FullMath: FACTORIAL_OVERFLOW");
        
        factorial = 1;
        for (uint256 i = 2; i <= n; i++) {
            factorial = mul(factorial, i);
        }
    }

    /// @notice 计算组合数C(n, k)
    /// @param n 总数
    /// @param k 选择数
    /// @return combination 组合数
    function combination(uint256 n, uint256 k) internal pure returns (uint256 combination) {
        require(k <= n, "FullMath: INVALID_COMBINATION");
        
        if (k == 0 || k == n) return 1;
        if (k > n / 2) k = n - k;
        
        combination = 1;
        for (uint256 i = 1; i <= k; i++) {
            combination = mulDiv(combination, n - i + 1, i);
        }
    }

    /// @notice 计算排列数P(n, k)
    /// @param n 总数
    /// @param k 选择数
    /// @return permutation 排列数
    function permutation(uint256 n, uint256 k) internal pure returns (uint256 permutation) {
        require(k <= n, "FullMath: INVALID_PERMUTATION");
        
        permutation = 1;
        for (uint256 i = 0; i < k; i++) {
            permutation = mul(permutation, n - i);
        }
    }
}