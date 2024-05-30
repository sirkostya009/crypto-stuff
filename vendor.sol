// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./token-owned.sol";

// 0xE61Da61Aa4844a8Ce03f69BC4114FDFcF3e8a723
contract Vendor is Owned {
    Token token;
    uint public tokenPrice;

    event Purschased(address indexed buyer, uint tokens, uint eth);

    constructor(Token _token, uint _tokenPrice) {
        owner = msg.sender;
        token = _token;
        tokenPrice = _tokenPrice;
    }

    function purchase(uint tokens) external payable {
        require(msg.value > 0, "Can't buy 0 tokens");
        require(msg.value == tokens * tokenPrice, "Insufficient funds");
        token.transfer(msg.sender, tokens);
        emit Purschased(msg.sender, tokens, msg.value);
    }

    function setPricePerToken(uint price) external ownerOnly {
        tokenPrice = price;
    }
}
