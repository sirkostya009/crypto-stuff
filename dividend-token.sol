// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./iterable-balances.sol";

interface Token {
    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender  , uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// 0x7133d4cf0A69a092c978dc1C2cEA5B9737dbe87C
contract BillsGreensDividendsToken is Token {
    using Iterable for IterableBalances;

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    IterableBalances private balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;

    string public name = "Bills, Greens, Dividends";
    uint8 public decimals = 18;
    string public symbol = "BGDT";

    event Paid(address payable indexed to, uint256 amount);

    constructor(uint256 _initialAmount) {
        balances.set(msg.sender, _initialAmount);
        totalSupply = _initialAmount;
    }

    receive() external payable {
        uint total = msg.value;

        for (uint i = 0; i < balances.keys.length; i++) {
            address payable key = payable(balances.keys[i]);
            uint amount = (balances.get(key) / totalSupply) * total;
            (bool ok, bytes memory data) = key.call{value: amount}("dividend");
            require(ok, "woopsie-daisy");
            emit Paid(key, amount);
        }
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balances.get(msg.sender) >= _value, "token balance is lower than the value requested");
        balances.set(msg.sender, balances.get(msg.sender) - _value);
        balances.set(_to, balances.get(_to) + _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances.get(_from) >= _value && allowance >= _value, "token balance or allowance is lower than amount requested");
        balances.set(_to, balances.get(_to) + _value);
        balances.set(_from, balances.get(_from) - _value);
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances.get(_owner);
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
