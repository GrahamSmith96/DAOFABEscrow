# DAOFABEscrow
DAOFAB Escrow with multi-signature scheme 
Deployed to Rinkeby testnet


```
node compound-supply-examples/solidity-contracts/supply-eth-via-solidity.js
Supplied ETH to Compound via MyContract
[
  {
    address: '0xFE54b6433785375807850e5E5DFA4b4e2aD1c0aA',
    blockHash: '0x9faf9c529d9302c1320ff756f9204483ce83770c5456d4f094f092586d69e64f',
    blockNumber: 9329086,
    logIndex: 2,
    removed: false,
    transactionHash: '0x5188fbcdd8daa4f3a6775d8a5b9af1c78678de785e880be40171ac9ddb2f0804',
    transactionIndex: 1,
    id: 'log_d8c80bde',
    returnValues: Result {
      '0': 'Exchange Rate (scaled up by 1e18): ',
      '1': '300437843768789031948053743'
    },
    event: 'MyLog',
    signature: '0x8d1cced004452bd270777a8c670f9f7e7c4fdde56f2db331fe289d39dc2624ad',
    raw: {
      data: '0x0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000f884302542b4630de6ecef000000000000000000000000000000000000000000000000000000000000002345786368616e6765205261746520287363616c65642075702062792031653138293a200000000000000000000000000000000000000000000000000000000000',
      topics: [Array]
    }
  },
  {
    address: '0xFE54b6433785375807850e5E5DFA4b4e2aD1c0aA',
    blockHash: '0x9faf9c529d9302c1320ff756f9204483ce83770c5456d4f094f092586d69e64f',
    blockNumber: 9329086,
    logIndex: 3,
    removed: false,
    transactionHash: '0x5188fbcdd8daa4f3a6775d8a5b9af1c78678de785e880be40171ac9ddb2f0804',
    transactionIndex: 1,
    id: 'log_01821917',
    returnValues: Result {
      '0': 'Supply Rate: (scaled up by 1e18)',
      '1': '95122078017'
    },
    event: 'MyLog',
    signature: '0x8d1cced004452bd270777a8c670f9f7e7c4fdde56f2db331fe289d39dc2624ad',
    raw: {
      data: '0x00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000001625b7b9410000000000000000000000000000000000000000000000000000000000000020537570706c7920526174653a20287363616c6564207570206279203165313829',
      topics: [Array]
    }
  }
]
ETH supplied to the Compound Protocol: 0.999999999853741726
MyContract's cETH Token Balance: 33.28475492

```
