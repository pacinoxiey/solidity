// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";

//引入library库
import "../utils/Strings.sol";
import "../utils/Address.sol";

contract ERC721 is IERC721Metadata, IERC721{

    using Strings for uint256; // 使用String库，
    using Address for address; // 使用Address库, 添加了判断是否是合约方法

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
    function ownerOf(uint256 tokenId) public view override returns (address owner){
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
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "not owner nor approved");
        _safeTransfer(owner, from, to, tokenId, data);
    }

    //不带data的转账
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        address owner = _owners[tokenId];
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "not owner nor approved");
        _safeTransfer(owner, from, to, tokenId, "");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _transfer(owner, from, to, tokenId);
    }

    //授权, tokenId必须属于发起者, 或者被授权
    function approve(address to, uint256 tokenId) external override {
        address owner = _owners[tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    //添加批量授权得映射, 释放事件
    function setApprovalForAll(address operator, bool _approved) external override {
        _operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function getApproved(uint256 tokenId) external view override returns (address operator) {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    //获取是否全部授权
    function isApprovedForAll(address owner, address operator) external view override returns (bool){
        return _operatorApprovals[owner][operator];
    }

    
    function interfaceId() external pure returns(bytes4){
        return type(IERC721).interfaceId;
    }

    //私有方法-------------------------------------------------------------------------------
    //判断操作者是否是拥有者或者被授权
    function _isApprovedOrOwner(address owner, address spender, uint tokenId)
    private view returns(bool) {
        return (spender == owner || _tokenApprovals[tokenId] == spender
        || _operatorApprovals[owner][spender]);
    } 

    /**
     * 安全转账，安全地将 tokenId 代币从 from 转移到 to，会检查合约接收者是否了解 ERC721 协议，以防止代币被永久锁定。调用了_transfer函数和_checkOnERC721Received函数。条件：
     * from 不能是0地址.
     * to 不能是0地址.
     * tokenId 代币必须存在，并且被 from拥有.
     * 如果 to 是智能合约, 他必须支持 IERC721Receiver-onERC721Received.
     */
    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        _transfer(owner, from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "not ERC721Receiver");
    }

    /*
     * 转账函数。通过调整_balances和_owner变量将 tokenId 从 from 转账给 to，同时释放Tranfer事件。
     * 条件:
     * 1. tokenId 被 from 拥有
     * 2. to 不是0地址
     */
    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        require(from == owner, "not owner");
        require(to != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address owner, address to, uint tokenId) private{
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // _checkOnERC721Received：函数，用于在 to 为合约的时候调用IERC721Receiver-onERC721Received, 以防 tokenId 被不小心转入黑洞。
    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            return
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                ) == IERC721Receiver.onERC721Received.selector;
        } else {
            return true;
        }
    }

    //铸造函数
    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0), "tokenId is zero");

        _balances[to] +=1;
        _owners[tokenId] = to;
    }

    // 销毁函数，通过调整_balances和_owners变量来销毁tokenId，同时释放Tranfer事件。条件：tokenId存在。
    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner of token");

        _approve(owner, address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }
}