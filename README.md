# DAOFABEscrow
1. DAOFAB Escrow with multi-signature scheme deployed to Rinkeby testnet   
2. Escrow code can be found at /compound/supply-examples/solidity-contracts/LFGLobalEscrow.sol  

## Multi-Signature Scheme
--------------------------------------------------------------------------------------------
The agent may elect to employ a multi-signature scheme or promulgate a multi-signature mandate by adding parties to the
senders or receivers group represented as an array of addresses through the invocation of the addSender or addReceiver method. Each member of the senders or receivers
group/array can choose to provide his/her signature to either sign or release the funds, which is then recorded in the respective mapping. 
Once there are two or more addresses contained in either the senders or receivers array/group, the sender or receiver then becomes
the representative of his/her respective group, and the sign to RELEASE and sign to REVERT functions have their requirement of obtaining
the confirmations/signatures of all members of their group is activated. That is to say, the representative sender or receiver can neither sign to release
nor revert the funds without the confirmations/signatures to sign or release of every member in the senders group/array for the sender or the receivers group/array
for the receiver. If the members of the senders or receivers group cannot come to an agreement, the representative sender or receiver can call a dispute. 

---------------------------------------------------------------------------------------------

## Deployment
--------------------------------------------------------------------------------------------
Escrow is called MyContract in the deployment below
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
----------------------------------------------------------------------------------------------------------------

## Changelog
---------------------------------------------------------------------------------------------------------------------------
Missing features that were added following completion of the code review were:  
 i) setting the boolean variable disputed back to false after the agent has rendered a judgment 
 upon review of the agreement's terms and conditions  

 ii) a multi-signature approach or a signing mandate that requires the authorization of a group of signatories representing 
 either the sender or receiver to approve the release or reversal of funds.  

 iii) the agent has the authority to add parties to the senders or receivers group  

 iv) agent should be able to sign twice in cases where either the sender or receiver refuses to sign or is unable to sign
 due to a lack of consensus in the sending or receiving group.  
 
 added if statement here  
 if (msg.sender != e.agent) {  
 require(e.signed[msg.sender] == Sign.NULL, "msg sender should not have signed already");   
 }  

 v) could use a modifier to define the variable e as a representation of the escrow with its respective referenceId beforehand i.e  
    Record storage e = _escrow[_referenceId];  
    _;  

 vi) on line 256 _trustedParty was not defined, and so the variable was changed to _agent  

 vii) renamed function amount() to funds() for greater clarity 
 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
