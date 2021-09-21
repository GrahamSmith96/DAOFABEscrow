/**
 * Deploys our smart contracts from `/solidity-examples/MyContracts.sol`
 * 
 * There is no need to execute this file if you are only using the JSON RPC 
 *     examples. Be sure to run this after you run the compile script in the
 *     project root directory. This script deploys the contracts to your local
 *     Ganache test net. You can use this code to deploy to main or test nets by
 *     changing the HTTP provider passed to the Web3 constructor, and supplying
 *     a private key for a wallet (that contains ETH on that network).
 */
const Web3 = require('web3');
const web3 = new Web3('https://rinkeby.infura.io/v3/c80e74e81de64813826a06700d4f8455');
const { bytecode } = require('../.build/bytecode.json');
const abi = require('../.build/abi.json');

(async function () {
  // For public test net or main net deployments, use the following:
  //// Your Ethereum wallet private key (use an environment variable reference)
  // const privateKey = '_YOUR_WALLET_PRIVATE_KEY_HERE_';
  // web3.eth.accounts.wallet.add('0x' + privateKey);
  // const myWalletAddress = web3.eth.accounts.wallet[0].address;

  

  // Set up a wallet.
// Don't use this key outside of your local test environment.
  const privateKey = 'f3ffd81467dbd8fe517213d2b81c6b4b80b897de6880c8d68dfbe261a57b23ec';

// Add your Ethereum wallet to the Web3 object
  web3.eth.accounts.wallet.add('0x' + privateKey);
  const myWalletAddress = web3.eth.accounts.wallet[0].address;

  const myContract = new web3.eth.Contract(abi);

  myContract.deploy({
    data: bytecode
  }).send({
    from: myWalletAddress,
    gas: 5000000
  }).then((deployment) => {
    console.log('Your contract was successfully deployed!');
    console.log('The contract can be interfaced with at this address:');
    console.log(deployment.options.address);
  }).catch((err) => {
    console.error(err);
  });
})()
