// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./IERC721.sol";
import "./IERC721Metadata.sol";

//引入library库
import "../utils/Strings.sol";

contract ERC721 is IERC721Metadata, IERC721{

    using Strings for uint256; // 使用String库，


    string public override name;
    string public override symbol;

    //代币id跟持有人的映射
    mapping(uint=>address) _owners;
    //持有人的余额
    mapping(address=>uint) _balances;
    //tokenId 对 授权地址 的授权映射
    mapping(uint=>address) _tokenApprovals;
    //owner地址到授权者地址的批量授权隐射?这不是777里面的?
    mapping(address=>mapping(address=>bool)) private _operatorApprovals;


    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    }
    /**
     * 实现IERC721Metadata的tokenURI函数，查询metadata。
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_owners[tokenId] != address(0), "Token Not Exist");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * 计算{tokenURI}的BaseURI，tokenURI就是把baseURI和tokenId拼接在一起，需要开发重写。
     * BAYC的baseURI为ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    //IERC721
    //返回余额
    function balanceOf(address owner) external view override returns (uint balance){
        return _balances[owner];
    }

    //返回持有人
    function ownerOf(uint256 tokenId) external view override returns (address owner){
        return _owners[tokenId];
    }

    //安全转账, 需要验证接收者是否实现xxx
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external override {
        address owner = _owners[tokenId];
        require(_isApproveOrOwner(owner, msg.sender, tokenId), "not owner nor approved")
        
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    //判断操作者是否是拥有者或者被授权
    function _isApproveOrOwner(address owner, address spender, uint tokenId)
    private view returns(bool) {
        return (spender == owner || _tokenApprovals[tokenId] == spender
        || _operatorApprovals[owner][spender])
    } 

    function _safeTransfer(address from, address to, uint tokenId) private view  {

    }
}