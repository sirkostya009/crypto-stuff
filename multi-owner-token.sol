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

// 0xF7AF288b7702FA708aE4c4F432ac35D317E748B5
contract MultiOwnerToken is Token {
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;

    string public name = "Multi-Owner Token";
    uint8 public decimals = 18;
    string public symbol = "MOTK";

    address[] public owners;
    mapping(address => uint) public votes;

    event NewOwner(address indexed owner);

    constructor(uint256 initialAmount) {
        balances[msg.sender] = initialAmount;
        totalSupply = initialAmount;
        owners.push(msg.sender);
    }

    modifier onlyOwner {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                _;
                return;
            }
        }
        revert("only owners can call this function");
    }

    function voteForNewOwner(address newOwner) public onlyOwner {
        for (uint i = 0; i < owners.length; i++) {
            require(owners[i] != newOwner, "new owner is already an owner");
        }
        votes[newOwner] += 1;
        if (votes[newOwner] >= owners.length / 2) {
            delete votes[newOwner];
            owners.push(newOwner);
            emit NewOwner(newOwner);
        }
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
