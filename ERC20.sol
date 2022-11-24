// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender,uint amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed sender, uint amount);
}

contract Owned {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not owner");
        _;
    }

    function changeOwner(address newOwner) private onlyOwner {
        owner = newOwner;
    }
}

contract ERC20 is IERC20,Owned {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Love Coin";
    string public symbol = "LOVE";
    uint8 public demical = 18;

    mapping(address => bool) frozenAccounts;
    event FrozenFund(address indexed account, bool froze);

    function transfer(address recipient, uint amount) public returns (bool){
        require(!frozenAccounts[recipient], "recipient is froze");

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }

    function approve(address spender,uint amount) external returns (bool){
        allowance[msg.sender][spender] -= amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public returns (bool){
        require(!frozenAccounts[sender],"sender is froze");
        require(!frozenAccounts[recipient],"recipient is froze");

        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, msg.sender, amount);
        return true;
    }

    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function frozen(address frozenAccount,bool freeze) private onlyOwner {
        frozenAccounts[frozenAccount] = freeze;
        emit FrozenFund(frozenAccount, true);
    }

    function airDrop(address[] memory recipients, uint value) private onlyOwner returns (bool) {
        require(recipients.length > 0,"no recipients" );

        for(uint j = 0; j < recipients.length; j++) {
            ERC20.transfer(recipients[j], value);
            ERC20.transferFrom(msg.sender, recipients[j], value);
        }

        return true;
    }  
}





