// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ERC721.sol";

contract ApeTest is ERC721 {

    uint public MAX_APES = 10000;

    //构造函数, 当有继承关系,且父合约也有构造函数, 那么需要添加上父合约的构造函数 
    constructor (string memory name, string memory symbol) ERC721(name, symbol){
    }

    //重写_baseURI函数
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }

    //这里还可以添加函数修改器进行权限控制
    function mint(address to, uint tokenId) external {
        require(tokenId<10000 && tokenId>0, "tokenId out of range");
        _mint(to, tokenId);
    }
}