// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * @dev ERC20 合约接口
 */
interface IERC20 {
    /**
     * @dev 记录转账记录
     */
    event Transfer(address indexed form, address indexed to, uint256 value);

    /**
     * @dev 记录授权记录. owner向spender授权value的额度
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev 返回货币总供给量
     */ 
    function totalSupply() external view returns (uint256);

    /**
     * @dev 返回account的余额
     */
    function balanceOf(address account) external view returns(uint256);

    /**
     * @dev 通过授权, 从from向to转账 amount 数量的代币, 转账会从from的allowance中扣除
     * 同时提交Transfer 事件
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);


    /**
     * @dev 返回'owner'账户给'spender'账户授权的额度
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev 调用者账户给'spender'授权'amount'数量的代币
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev 调用者账户给'to'转账'amount'数量的代币
     */
    function transfer (address to, uint256 amount) external view returns (uint256);
}
