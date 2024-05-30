const { Web3, providers } = require("web3");
const web3 = new Web3(new providers.http.HttpProvider(`https://sepolia.drpc.org`));

// 1
function balanceOf(address) {
  return web3.eth.getBalance(address);
}

// 2
function sendEth(from, to, value) {
  return web3.eth.sendTransaction({
    from,
    to,
    value: web3.utils.toWei(value, "ether")
  });
}

// 3
function deployContract(abi, bytecode, from, args) {
  const contract = new web3.eth.Contract(abi);
  const deploy = contract.deploy({ data: bytecode, arguments: args });
  return deploy.send({ from });
}

// 4
function allocateERC20Tokens(owner, contractAddress, receivers) {
  const contract = new web3.eth.Contract([{
    constant: false,
    inputs: [
      { name: "_to", type: "address" },
      { name: "_value", type: "uint256" }
    ],
    name: "transfer",
    outputs: [{ name: "", type: "bool" }],
    type: "function"
  }], contractAddress);
  return Promise.all(receivers.map(({address, amount}) =>
    contract.methods.transfer(address, amount).call({ from: owner })));
}

allocateERC20Tokens(
  "0xa56d752c6216bcfeB7F58131E67005C4AbDf9370",
  "0xe6594BFBd09312885dc1c97FF10f601F65f4462b",
  [
    { address: "0xfB898A6B741b06031919E6646F1CC6c969440FE1", amount: 100 },
    { address: "0x39795930721f1d96dd91dbc4E6f7bF650d8bb6Ee", amount: 200 }
  ]
).then(console.log);

// 5
function ERC20Balances(contractAddress, addr) {
  const contract = new web3.eth.Contract([{
    constant: true,
    inputs: [{ name: "_owner", type: "address" }],
    name: "balanceOf",
    outputs: [{ name: "balance", type: "uint256" }],
    type: "function"
  }], contractAddress);
  const balanceOf = (address) => contract.methods.balanceOf(address).call();
  return Array.isArray(addr) ? Promise.all(addr.map(balanceOf)) : balanceOf(addr);
}

ERC20Balances(
  "0xe6594BFBd09312885dc1c97FF10f601F65f4462b",
  [
    "0xa56d752c6216bcfeB7F58131E67005C4AbDf9370",
    "0xfB898A6B741b06031919E6646F1CC6c969440FE1",
    "0x39795930721f1d96dd91dbc4E6f7bF650d8bb6Ee"
  ]
).then(console.log);

module.exports = { sendEth, balanceOf, deployContract, ERC20Balances };
