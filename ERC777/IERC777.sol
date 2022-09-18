// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
 */
interface IERC777 {
    /**
     * @dev 记录操作者铸造给'to' 'amount'个代币, 同时记录了'data', 'operatorData' 数据
     */
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev 记录'operator'将'from'的代币燃烧'amount'个代币
     *
     * 记录了'data', 'operatorData'数据
     */
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev 记录'operator'被授权'tokenHolder'账户的代币
     */
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev 释放'tokenHolder'对'operator'的授权取消
     */
    event RevokedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev 返回代币名称
     */
    function name() external view returns (string memory);

    /**
     * @dev 返回代币符号
     */
    function symbol() external view returns (string memory);

    /**
     * @dev 返回标记中不可整除的最小部分。这意味着所有的令牌操作(创建，移动和销毁)必须拥有是这个数的倍数的数量。
     * 通常是1
     */
    function granularity() external view returns (uint256);

    /**
     * @dev 返回当前存在的代币总供应量
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev 返回'owner'的代币余额
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev 发送'amount'个代币到'recipient'账户
     *
     * If send or receive hooks are registered for the caller and `recipient`,
     * the corresponding functions will be called with `data` and empty
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * 释放一个{send}事件
     *
     * - 发起方余额必须大于'amount'
     * - 'recipient' 不能是0地址
     * - 如果'recipient' 是合约, 那么必须实现 {IERC777Recipient}接口
     */
    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev 从发起者账户销毁'amount'个代币, 减少总供应量
     *
     * If a send hook is registered for the caller, the corresponding function
     * will be called with `data` and empty `operatorData`. See {IERC777Sender}.
     *
     * 释放一个{Burned} 事件.
     *
     * - 发起方余额必须大鱼'amount'
     */
    function burn(uint256 amount, bytes calldata data) external;

    /**
     * @dev 返回一个账户是否是'tokenHolder'的授权者, 可以代表owner send和burn代币
     *
     */
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    /**
     * @dev 授权'operator'为发起者的授权者
     *
     *
     * 释放一个 {AuthorizedOperator} 事件.
     *
     * - `operator` 不能是发起者
     */
    function authorizeOperator(address operator) external;

    /**
     * @dev 撤销发起者账户对'operator'的授权
     *
     *
     * 释放一个 {RevokedOperator} 事件.
     *
     *
     * - `operator` 不能是发起者账户
     */
    function revokeOperator(address operator) external;

    /**
     * @dev 返回默认授权者账户集合, 即使{authorizeOperator}没有授权过这些账户
     *
     * 这个集合是不可变的, 但是个别账户会撤销他们的授权, 在 {isOperatorFor} 会返回false
     */
    function defaultOperators() external view returns (address[] memory);

    /**
     * @dev 转移'amount' 数量的token从'sender'到'recipient'. 发起者必须是'sender'的授权者
     *
     * If send or receive hooks are registered for `sender` and `recipient`,
     * the corresponding functions will be called with `data` and
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * 释放一个 {Sent} 事件.
     *
     * Requirements
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have at least `amount` tokens.
     * - the caller must be an operator for `sender`.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    /**
     * @dev 从'account'账户销毁'amount'数量的token, 减少总供应量, 发起者必须是'account'的授权者
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `data` and `operatorData`. See {IERC777Sender}.
     *
     * 释放一个 {Burned} 事件.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * - the caller must be an operator for `account`.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
}