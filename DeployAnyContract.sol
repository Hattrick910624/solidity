// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

contract testContract1{
    address public owner = msg.sender;

    function setOwner (address _owner) public {
        require(msg.sender == owner , "not owner");
       owner = _owner;
    }
}

contract testContract2{
    address public owner = msg.sender;
    uint public value = msg.value;
    uint public x;
    uint public y;

    constructor (uint _x , uint _y) payable {
        x = _x;
        y = _y;
    }
}

contract proxy{
     event Deploy (address);

     fallback () external payable {}

    function deploy (bytes memory _code) external payable returns(address addr) {
        assembly{
          addr := create(callvalue() , add(_code , 0x20) , mload(_code))
        }
        require(addr != address(0) , "deploy failed");

        emit Deploy(addr);
    }

    function excute (address _target , bytes memory _data) external payable {
        (bool success , ) = _target.call{value: msg.value }(_data);
        require(success , "failed");
    }
}

contract Helper{
    function getBytesCode1 () external pure returns (bytes memory){
        bytes memory bytescode = type(testContract1).creationCode;
        return bytescode;
    }
    
    function getBytesCode2 (uint _x , uint _y) external pure returns (bytes memory){
        bytes memory bytescode = type(testContract2).creationCode;
        return abi.encodePacked(bytescode , abi.encode(_x, _y));
    }

    function getCallData (address _owner) external pure returns (bytes memory) {
        return abi.encodeWithSignature("setOwner(address)" , _owner);
    }
}