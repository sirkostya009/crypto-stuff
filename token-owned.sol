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
