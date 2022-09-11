// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    
    // 自动生成一个getter方法, 实现balanceOf函数, 所以要用override
    mapping(address => uint256) public override balanceOf;
    // 实现allowance方法
    mapping(address => mapping(address=>uint256)) public override allowance;
    //返回货币总数量
    uint256 public override totalSupply;
    //名称
    string public name;
    //符号
    string public symbol;

    //合约使用的小数位数
    uint256 public decimals = 18;

    //部署合约使用构造函数, 初始化基础数据
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol= _symbol;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool){
        balanceOf[from] -=amount;
        allowance[from][msg.sender] -=amount;//从调用者的授权额度中扣除, 调用者可以把这部分授权转账给任意账户
        balanceOf[to] +=amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev 调用者账户给'spender'授权'amount'数量的代币
     */
    function approve(address spender, uint256 amount) external override returns (bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev 调用者账户给'to'转账'amount'数量的代币
     */
    function transfer (address to, uint256 amount) external override returns (bool){
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    //铸造代币
    function mint(uint256 amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply+=amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    //销毁代币
    function burn(uint256 amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply+=amount;
        emit Transfer(msg.sender, address(0), amount);
    }




}