// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface Token {
    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)  external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender  , uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

abstract contract Owned {
    address public owner;

    modifier ownerOnly() {
        require(msg.sender == owner, "Owner only");
        _;
    }
}

// 0x10a4E389B4b3Ce7ff3A7eaC28890a1e3d663EC6c
contract BurnerToken is Token, Owned {
    address constant private burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;

    string public name = "Burner Token";
    uint8 public decimals = 18;
    string public symbol = "BRTK";

    uint amountToBurn;
    uint previousBurn;
    uint interval;

    event Burned(uint256 amount);

    constructor(uint256 initialAmount) {
        owner = msg.sender;
        balances[owner] = initialAmount;
        totalSupply = initialAmount;
    }

    function burn() internal {
        if (block.timestamp >= previousBurn + interval * 1 seconds) {
            require(balances[msg.sender] < amountToBurn, "Insufficient balance to burn");
            totalSupply -= amountToBurn;
            balances[msg.sender] -= amountToBurn;
            previousBurn = block.timestamp;
            emit Burned(amountToBurn);
        }
    }

    function setBurn(uint amount, uint _interval) public ownerOnly {
        amountToBurn = amount;
        interval = _interval;
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        burn();
        require(balances[msg.sender] >= _value, "token balance is lower than the value requested");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        burn();
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value, "token balance or allowance is lower than amount requested");
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
