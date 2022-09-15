// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error TestError();
//自定义异常抛出
contract error {

    mapping(uint256=> address)  _owners;

//revert
    function transferOwner1(uint256 tokenId, address newOwner) public {
        if(_owners[tokenId] != msg.sender){
            revert TestError();
        }
        _owners[tokenId] = newOwner;
    }
//require
    function transferOwner2(uint256 tokenId, address newOwner) public {
        require(_owners[tokenId] == msg.sender, "transfer not owner");
        _owners[tokenId] = newOwner;
    }
//assert
    function transferOwner3(uint256 tokenId, address newOwner) public {
        assert (_owners[tokenId] == msg.sender);
        _owners[tokenId] = newOwner;
    }

    function addTokenOwner(uint256 tokenId) public returns (bool){
        _owners[tokenId] = msg.sender;
        return true;
    }

    function getOwner(uint256 tokenId) public view returns (address){
        return _owners[tokenId];
    }
}

contract sort{
        //1,3,5,4
       function insertionSort(uint[] memory a) public pure returns(uint[] memory) {

        for (uint i = 0; i < a.length - 1; i++) {
            uint temp = a[i];//第一个数
            uint j = i + 1;
            for (; j < a.length; j++) {
                if (temp > a[j]) {//与后面的数对比, 比后面的大就换位置
                    temp = a[j];
                    a[j] = a[i];
                    a[i] = temp;
                }

            }
        }
           return a;
        // note that uint can not take negative value
        // for (uint i = 1;i < a.length;i++){
        //     uint temp = a[i];
        //     uint j=i;
        //     while( (j >= 1) && (temp < a[j-1])){
        //         a[j] = a[j-1];
        //         j--;
        //     }
        //     a[j] = temp;
        // }
        // return(a);
    }
}

