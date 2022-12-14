// SPDX-License-Identifier: MIT


pragma solidity ^0.8.7;

/* 触发fallback() 还是 receive()?

           接收ETH
              |
         msg.data是空？
            /  \
          是    否
          /      \
receive()存在?   fallback()
        / \
       是  否
      /     \
receive()  fallback   
    */

contract part3{

    event receiveEvent(address indexed from, uint256 value);
    event fallbackEvent(address indexed from, uint256 value, bytes data);

    receive() external payable {
        emit receiveEvent(msg.sender, msg.value);
    }

    fallback() external payable {
        emit fallbackEvent(msg.sender, msg.value, msg.data);
    }

    function test() external view returns (address a, address b){
        a = address(this);
        b = msg.sender;
    }

    function test2() external view returns (uint){
        return msg.sender.balance;
    }
}

//工厂合约
contract Account{
    address public bank;
    address public owner;

    constructor (address _owner) payable{
        owner = _owner;
    }

}

contract AccountFactory{
    Account[] public accounts;

    function createAccount(address _owner) external payable {
        //new 返回一个合约地址, 声明为Account类型
        Account account = new Account{value: 10}(_owner);
        accounts.push(account);
    }
}