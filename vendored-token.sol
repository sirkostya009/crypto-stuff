// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./token-owned.sol";

// 0x950ce74A3c6c73d4812B04314931A360e2d01719
contract VendoredToken is Token, Owned {
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;

    address public vendor;

    string public name     = "Vendored Token";
    uint8  public decimals = 18;
    string public symbol   = "VTKN";

    event Minted(uint256 amount);

    constructor(uint256 _initialAmount) {
        owner = msg.sender;
        balances[owner] = _initialAmount;
        totalSupply = _initialAmount;
    }

    function setVendor(address newVendor) public ownerOnly {
        vendor = newVendor;
    }

    function mint(uint amount) public ownerOnly {
        totalSupply += amount;
        balances[vendor] += amount;
        emit Minted(amount);
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value, "token balance is lower than the value requested");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
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
