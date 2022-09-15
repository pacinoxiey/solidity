// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * 1.struct结构体
 * 2.memory和storage的区别
 * 3.constant 常量, immutable 不可变量
 */

contract part2{

    //constant 必须声明时初始化, 不可改变
    bytes32 public constant CONSTANT_BYTE = "xiey";
    string public constant CONSTANT_STRING = "xiey";
    //可以在构造函数里修改, 然后不可改变, string类型必须直接初始化, 否则报错
    bytes32 public immutable IMMUTABLE_BYTE = "xiey";
    uint256 public immutable IMMUTABLE_TEST;
    // string public immutable IMMUTABLE_STRING = "xiey";error
    constructor (uint256 _IMMUTABLE_TEST) {
        // CONSTANT_STRING =  "modify";
        IMMUTABLE_TEST = _IMMUTABLE_TEST;
    }

    struct Apple{
        string  color;
        uint8  weight;
    }


    Apple apple;
    //实例化一个'apple', string这里必须指明存储类型
    function createApple(string memory color, uint8 weight) public {
        Apple storage _apple = apple;
        _apple.color = color;
        _apple.weight = weight;

        color = "green";//不会对apple起作用, memory内存变量的修改只作用于自己
        _apple.color = "yello";//对apple起作用, storage存储变量的改变, 会修改指向这个变量的值
    }

    function getApple() external view returns (Apple memory _apple){
        _apple = apple;
    }
}