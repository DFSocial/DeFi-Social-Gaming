/**
 *Submitted for verification at BscScan.com on 2021-02-19
*/

pragma solidity >=0.7.0;

//BAY CONTRACT 25-12-2020

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

interface Token {
    function transfer(address, uint) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns  (bool success);
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor()  {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

contract Lock_Liquidity is Ownable{
    using SafeMath for uint;
    
    
    uint256 public constant month_1  = 30 days;
    
    uint256 public total_prize = 50000000000000000000 ;
    uint256 public constant minAmount = 4000000000000000000 ;
    
    address public constant tokenAddress = 0x75de745a333a47Fe786e8DbBf3E9440d3d5Bc809;
    address public constant LPtokenAddress = 0x0A88Bd9Bb4Ad2625d693b521D18485EA020FEB0D;
    
    
    
    mapping (address => uint) public deposited; 
    mapping (address => uint) public time_lock;
    
    
  function lockLiquidity(uint amountToLock) public returns (bool){
      require(amountToLock > minAmount, "Min is 4 LP");
      require(deposited[msg.sender] == 0, "You already locked liquidity");
      require(total_prize.sub(amountToLock.div(10)) >= 0, "Not enough rewards");
      
      require(Token(LPtokenAddress).transferFrom(msg.sender, address(this), amountToLock), "Not enough allowance");
      
      deposited[msg.sender] = amountToLock;
      time_lock[msg.sender] = block.timestamp;
      
      uint _reward = amountToLock.div(10);
      total_prize = total_prize.sub(_reward);
      
      
      require(Token(tokenAddress).transfer(msg.sender, _reward), "Error sending reward");
      
      
      
      return true;
  }
  
   
  function unlock() public returns (bool){
      require(deposited[msg.sender] > 0, "Nothing to unlock");
      require(block.timestamp.sub(time_lock[msg.sender]) > month_1, "Not yet");
      
      uint _amount = deposited[msg.sender];
      deposited[msg.sender] = 0;
      
      require(Token(LPtokenAddress).transfer(msg.sender, _amount), "Error unlocking tokens");
      
      
      return true;
      
  }
  
  
  
  
  function timeToUnlock(address _addr) public view returns (uint){
        
        uint returnTime = 0;
        
        if(deposited[_addr] > 0){
            returnTime = time_lock[_addr].add(month_1);
        }
       
        return returnTime;
    }
    
    

    
   

    
    
}