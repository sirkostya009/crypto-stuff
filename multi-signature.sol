// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract MultiSignature {
    address[] public owners;
    mapping(address => bool) public isOwner;

    mapping(address => mapping(uint => bool)) public confirmations;
    Payment[] public payments;

    event PaymentCreated(uint indexed paymentId, address indexed to, uint amount);
    event PaymentConfirmed(uint indexed paymentId, address indexed by);
    event PaymentSent(uint indexed paymentId, address indexed to, uint amount);

    struct Payment {
        address to;
        uint amount;
        bool executed;
        uint numConfirmations;
    }

    modifier onlyOwners() {
        require(isOwner[msg.sender], "this function is owner only");
        _;
    }

    constructor(address[] memory _owners) {
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "owner cannot be 0x0");
            require(!isOwner[owner], "owner already exists");
            isOwner[owner] = true;
            owners.push(owner);
        }
    }

    function makePayment(address to, uint amount) public onlyOwners returns (uint) {
        require(amount > 0 && amount <= address(this).balance, "cannot afford that");
        payments.push(Payment(to, amount, false, 0));
        uint paymentId = payments.length;
        confirmations[msg.sender][paymentId] = true;
        emit PaymentCreated(paymentId, to, amount);
        return paymentId;
    }

    function confirmPayment(uint paymentId) public onlyOwners {
        require(!confirmations[msg.sender][paymentId], "payment already confirmed");
        Payment storage payment = payments[paymentId];
        require(address(this).balance >= payment.amount, "not enough balance");
        require(!payment.executed, "payment already executed");

        payment.numConfirmations++;
        confirmations[msg.sender][paymentId] = true;
        emit PaymentConfirmed(paymentId, msg.sender);

        if (payment.numConfirmations >= (owners.length / 2 + owners.length % 2)) {
            payment.executed = true;
            (bool sent,) = payable(payment.to).call{value: payment.amount}("");
            require(sent, "failed to send ether");
            emit PaymentSent(paymentId, payment.to, payment.amount);
            payment.numConfirmations = 0;
            for (uint i = 0; i < owners.length; ++i) {
                confirmations[owners[i]][paymentId] = false;
            }
        }
    }

    receive() external payable { }
}
