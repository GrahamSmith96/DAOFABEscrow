// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

// import "../Ownable.sol";
// import "./compound-supply-examples/solidity-contracts/MyContracts.sol";
// import "../utils/Context.sol";

/*Missing features that were added following completion of the code review were:
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
 
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface CEth {
    function mint() external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);
}





contract LFGlobalEscrow is Ownable { 
 
// the Sign enum denotes the intention of the signatory 
 enum Sign { 
 NULL, 
 REVERT, 
 RELEASE 
 } 

// the Record data structure stores information concerning the transaction marked by a referenceId  
 struct Record { 
 string referenceId; 
 address payable owner; 
 address payable sender; 
 address payable receiver; 
 address payable agent; 
 uint256 fund; 
 bool disputed; 
 bool finalized; 
  
    // this mapping determines whether the address belongs to a signer
 mapping(address => bool) signer;
    // this mapping determines whether owner of the address wishes to release or revert the funds.  
 mapping(address => Sign) signed;



 // array containing the addresses of each member of the sender group
 address[] senders;

 // array containing the addresses of each member of the receiver group
 address[] receivers;

 // this represents the number of signatures required to satisfy the multi-signature mandate for the sending party
 uint256 senderSignatures;
 // this represents the number of signatures required to satisfy the multi-signature mandate for the receiving party
 uint256 receiverSignatures;
 // this counts the number of signatures to release the funds
 uint256 releaseCount;
// this counts the number of signatures to revert 
 uint256 revertCount; 
    
 uint256 lastTxBlock; 
 }

  // the respective escrow is bound to a string
 mapping(string => Record) _escrow;
 // this function identifies the address of the owner of the escrow
 function owner(string memory _referenceId) public view returns 
(address payable) { 
 return _escrow[_referenceId].owner; 
 }

 // this function identifies the sender to the escrow
 function sender(string memory _referenceId) public view returns 
(address payable) { 
 return _escrow[_referenceId].sender;
 }

 // this function identifies the receiver from the escrow
 function receiver(string memory _referenceId) public view returns (address payable) { 
 return _escrow[_referenceId].receiver; 
 } 

 function senders(string memory _referenceId) public view returns(address[] memory) {
     return _escrow[_referenceId].senders;
 }

 function receivers(string memory _referenceId) public view returns(address[] memory) {
     return _escrow[_referenceId].receivers;
 }

 // the agent is the arbiter that adjudicates disputes between the sender and the receiver
 function agent(string memory _referenceId) public view returns (address payable) { 
 return _escrow[_referenceId].agent; 
 }
 
 function funds(string memory _referenceId) public view returns (uint256) { 
 return _escrow[_referenceId].fund; 
 } 
  
 function isDisputed(string memory _referenceId) public view returns (bool) { 
 return _escrow[_referenceId].disputed; 
 } 
  
 function isFinalized(string memory _referenceId) public view returns (bool) { 
 return _escrow[_referenceId].finalized; 
 } 
  
 function lastBlock(string memory _referenceId) public view returns (uint256) { 
 return _escrow[_referenceId].lastTxBlock; 
 } 
  
 function isSigner(string memory _referenceId, address _signer)  public view returns (bool) { 
 return _escrow[_referenceId].signer[_signer];  } 
  
  //shows whether the signer wants to release or revert
 function getSignedAction(string memory _referenceId, address _signer) public view returns (Sign) { 
 return _escrow[_referenceId].signed[_signer];  } 
  
 function releaseCount(string memory _referenceId) public view
returns (uint256) { 
 return _escrow[_referenceId].releaseCount; 
 } 
  
 function revertCount(string memory _referenceId) public view returns (uint256) { 
 return _escrow[_referenceId].revertCount; 
 } 
  
 event Initiated(string referenceId, address payer, uint256 amount, address payee, address trustedParty, uint256 lastBlock);  //event OwnershipTransferred(string referenceIdHash, address  oldOwner, address newOwner, uint256 lastBlock); 
 event Signature(string referenceId, address signer, Sign action,  uint256 lastBlock); 
 event Finalized(string referenceId, address winner, uint256 lastBlock); 
 event Disputed(string referenceId, address disputer, uint256 lastBlock); 
 event Withdrawn(string referenceId, address payee, uint256 amount, uint256 lastBlock); 
  
  
 modifier multisigcheck(string memory _referenceId) {
 Record storage e = _escrow[_referenceId]; //e is the record of the referenceId; 
 require(!e.finalized, "Escrow should not be finalized");
 require(e.signer[msg.sender], "msg sender should be eligible to sign");

 /* agent should be able to sign twice in cases where either the sender or receiver refuses to sign or is unable to sign
 due to a lack of consensus in the sending or receiving group.
 */
 if (msg.sender != e.agent) {
 require(e.signed[msg.sender] == Sign.NULL, "msg sender should not have signed already"); 
 }

 _;


 if(e.releaseCount >= 2) { 
 transferOwnership(e); 
 }else if(e.revertCount >= 2) { 
 finalize(e); 
 }else if(e.releaseCount == 1 && e.revertCount == 1) {  dispute(e); 
 } 
 }

 //should maybe use constructor instead of init
 
 /*If the multiple signature approach is used, the _receiver address is the entity that acts on behalf of the receiving group, and the same
 is to be said for the _sender address. Both the _sender and the _receiver require the signatures of all the members of their respective
 group (senders or receivers) to sign the transaction */

 function init(string memory _referenceId, address payable _receiver, address payable _agent) public payable {
 require(msg.sender != address(0), "Sender should not be null"); 
 require(_receiver != address(0), "Receiver should not be null"); 
 require(_agent != address(0), "Trusted Agent should not be null"); 
  
 emit Initiated(_referenceId, msg.sender, msg.value, _receiver, _agent, 0); 
  
 Record storage e = _escrow[_referenceId]; 
 e.referenceId = _referenceId; 
 e.owner = payable(msg.sender); 
 e.sender = payable(msg.sender); 
 e.receiver = _receiver; 
 e.agent = _agent; 
 e.fund = msg.value; 
 e.disputed = false; 
 e.finalized = false; 
 e.lastTxBlock = block.number; 
  
 e.releaseCount = 0; 
 e.revertCount = 0;
 e.senderSignatures = 0; // for the multi-signature mandate
 e.receiverSignatures = 0; //same as above 
  
 _escrow[_referenceId].signer[msg.sender] = true;  _escrow[_referenceId].signer[_receiver] = true;  _escrow[_referenceId].signer[_agent] = true;  }

 //only the agent can add a sender to the sending group
 function addSender(address _sender, string memory _referenceId) public {
     Record storage e = _escrow[_referenceId];
     require(msg.sender == e.agent);
     e.senders.push(_sender);
     e.senderSignatures++;
 }
 //only the agent can add a receiver to the receiving group
 function addReceiver(address _receiver, string memory _referenceId) public {
     Record storage e = _escrow[_referenceId];
     require(msg.sender == e.agent);
     e.receivers.push(_receiver);
     e.receiverSignatures++;
 }

//check if address belongs to the senders group 
function isSender(address _addr, string memory _referenceId) private view returns(bool) {
     Record storage e = _escrow[_referenceId];
        for(uint i = 0; i < e.senders.length; i++) {
            if(e.senders[i] == _addr) {
                return true;
            }
        }
        return false;
    }

 //check if address belongs to the receivers group 
function isReceiver(address _addr, string memory _referenceId) private view returns(bool) {
     Record storage e = _escrow[_referenceId];
        for(uint i = 0; i < e.receivers.length; i++) {
            if(e.receivers[i] == _addr) {
                return true;
            }
        }
        return false;
    }
 //one member of either the sending or receiving group signs to release the funds
function signToRelease(string memory _referenceId) public {
     Record storage e = _escrow[_referenceId];
     require(e.signed[msg.sender] == Sign.NULL, "msg sender should not have signed already"); 
        if(isSender(msg.sender, _referenceId)) {
            e.signed[msg.sender] = Sign.RELEASE; 
        }
        else if(isReceiver(msg.sender, _referenceId)) {
            e.signed[msg.sender] = Sign.RELEASE;
        }
 }
 
 //one member of either the sending or receiving group signs to revert the funds
 function signToRevert(string memory _referenceId) public {
     Record storage e = _escrow[_referenceId];
     require(e.signed[msg.sender] == Sign.NULL, "msg sender should not have signed already"); 
        if(isSender(msg.sender, _referenceId)) {
            e.signed[msg.sender] = Sign.REVERT; 
        }
        else if(isReceiver(msg.sender, _referenceId)) {
            e.signed[msg.sender] = Sign.REVERT;
        }
 }
 

 //count the number of senders who have signed to release the funds
 function getSenderReleaseCount(string memory _referenceId) public view returns(uint) {
        Record storage e = _escrow[_referenceId];
        uint count;
        for(uint i = 0; i < e.senders.length; i++) {
            if(e.signed[e.senders[i]] == Sign.RELEASE) {
                count++;
            }
        }
        return count;
    }
 //count the number of senders who have signed to revert the funds
 function getSenderRevertCount(string memory _referenceId) public view returns(uint) {
        Record storage e = _escrow[_referenceId];
        uint count;
        for(uint i = 0; i < e.senders.length; i++) {
            if(e.signed[e.senders[i]] == Sign.REVERT) {
                count++;
            }
        }
        return count;
    }
 //count the number of receivers who have signed to release the funds
 function getReceiverReleaseCount(string memory _referenceId) public view returns(uint) {
        Record storage e = _escrow[_referenceId];
        uint count;
        for(uint i = 0; i < e.receivers.length; i++) {
            if(e.signed[e.senders[i]] == Sign.RELEASE) {
                count++;
            }
        }
        return count;
    }
 //count the number of receivers who have signed to revert the funds
 function getReceiverRevertCount(string memory _referenceId) public view returns(uint) {
        Record storage e = _escrow[_referenceId];
        uint count;
        for(uint i = 0; i < e.receivers.length; i++) {
            if(e.signed[e.senders[i]] == Sign.REVERT) {
                count++;
            }
        }
        return count;
    }

 function senderIsConfirmed(string memory _referenceId) public view returns(bool) {
        Record storage e = _escrow[_referenceId];
        return (getSenderReleaseCount(_referenceId) >= e.senderSignatures || getSenderRevertCount(_referenceId) >= e.senderSignatures ? true:false);
 }

 function receiverIsConfirmed(string memory _referenceId) public view returns(bool) {
        Record storage e = _escrow[_referenceId];
        return (getReceiverReleaseCount(_referenceId) >= e.receiverSignatures || getReceiverRevertCount(_referenceId) >= e.receiverSignatures ? true:false);
 }
 
 /* If there is more than 1 member in either the senders or receivers group, the representative of its respective group signs to release the funds.
    The signatures of every member of a group are required for the representative to be able to sign.
 */
 function release(string memory _referenceId) public multisigcheck(_referenceId) {
 
 Record storage e = _escrow[_referenceId];

 if(msg.sender == e.sender && e.senderSignatures >= 2) {
     require(senderIsConfirmed(_referenceId));
     
 }

 if(msg.sender == e.receiver && e.receiverSignatures >= 2) {
     require(receiverIsConfirmed(_referenceId));
 }

  
 emit Signature(_referenceId, msg.sender, Sign.RELEASE, e.lastTxBlock); 
  
 e.signed[msg.sender] = Sign.RELEASE; 
 e.releaseCount++;
 // the dispute ends once the agent decides whether to release or refund the funds 
 if(msg.sender == e.agent) {
     e.disputed = false; 
 } 
 } 
 /* If there is more than 1 member in either the senders or receivers group, the representative of its respective group signs to release the funds.
    The signatures of every member of a group are required for the representative to be able to sign.
 */
 function reverse(string memory _referenceId) public multisigcheck(_referenceId) { 
 Record storage e = _escrow[_referenceId];

 if(msg.sender == e.sender && e.senderSignatures >= 2) {
     require(senderIsConfirmed(_referenceId));
     
 }

 if(msg.sender == e.receiver && e.receiverSignatures >= 2) {
     require(receiverIsConfirmed(_referenceId));
 }
  
 emit Signature(_referenceId, msg.sender, Sign.REVERT,  e.lastTxBlock); 
  
 e.signed[msg.sender] = Sign.REVERT; 
 e.revertCount++;
 // the dispute ends once the agent decides whether to release or refund the funds 
 if(msg.sender == e.agent) {
     e.disputed = false; 
 } 
 }

 // the representative of the sending group or receiving group may also call a dispute if there is a conflict of interest within their own group
 function dispute(string memory _referenceId) public {  Record storage e = _escrow[_referenceId]; 
 require(!e.finalized, "Escrow should not be finalized");
 require(msg.sender == e.sender || msg.sender == e.receiver,  "Only sender or receiver can call dispute"); 
  
 dispute(e); 
 } 
  
 function transferOwnership(Record storage e) internal { e.owner = e.receiver; 
 finalize(e); 
 e.lastTxBlock = block.number; 
 } 
  
 function dispute(Record storage e) internal { 
 emit Disputed(e.referenceId, msg.sender, e.lastTxBlock);  e.disputed = true; 
 e.lastTxBlock = block.number; 
 } 
  
 function finalize(Record storage e) internal { 
 require(!e.finalized, "Escrow should not be finalized");   
 emit Finalized(e.referenceId, e.owner, e.lastTxBlock);   
 e.finalized = true; 
 } 
  
 function withdraw(string memory _referenceId, uint256 _amount)  public { 
 Record storage e = _escrow[_referenceId]; 
 require(e.finalized, "Escrow should be finalized before withdrawal"); 
 require(msg.sender == e.owner, "only owner can withdraw funds"); 
 require(_amount <= e.fund, "cannot withdraw more than the deposit"); 
  
 emit Withdrawn(_referenceId, msg.sender, _amount,  e.lastTxBlock); 
  
 e.fund = e.fund - _amount; 
 e.lastTxBlock = block.number; 

 //removed the require here and used the transfer method as it is more up to date 
 e.owner.transfer(_amount); 
 }

 //integration with the Compound protocol

    event MyLog(string, uint256);

    function supplyEthToCompound(address payable _cEtherContract)
        public
        payable
        returns (bool)
    {
        // Create a reference to the corresponding cToken contract
        CEth cToken = CEth(_cEtherContract);

        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit MyLog("Exchange Rate (scaled up by 1e18): ", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit MyLog("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);

        cToken.mint{value: msg.value, gas: 250000}();
        return true;
    }

    function redeemCEth(
        uint256 amount,
        bool redeemType,
        address _cEtherContract
    ) public returns (bool) {
        // Create a reference to the corresponding cToken contract
        CEth cToken = CEth(_cEtherContract);

        // `amount` is scaled up by 1e18 to avoid decimals

        uint256 redeemResult;

        if (redeemType == true) {
            // Retrieve your asset based on a cToken amount
            redeemResult = cToken.redeem(amount);
        } else {
            // Retrieve your asset based on an amount of the asset
            redeemResult = cToken.redeemUnderlying(amount);
        }

        // Error codes are listed here:
        // https://compound.finance/docs/ctokens#ctoken-error-codes
        emit MyLog("If this is not 0, there was an error", redeemResult);

        return true;
    }

    // This is needed to receive ETH when calling `redeemCEth`
    receive() external payable {

    }
  
}
