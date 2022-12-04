// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./REZTOKEN.sol";


/// @title Rezacles
/// @author Muhammad Lawan

contract Rezacles is REZTOKEN {
   using EnumerableSet for EnumerableSet.AddressSet;
       
    struct User{
      address  payable user;
      address payable   [] genesisUplines;
       address payable  []  Uplines;
       uint256 rezBalance;
       address []  rezDownlines;
       uint256 lastTimeStamp;
      Level s_level;  
    }



//REGISTERED USERS
EnumerableSet.AddressSet internal Registered_Users;
//OWNER ADDRESS
address payable public GENESIS_UPLINE;
//MAPPING ID => USER
mapping (uint256 => User) private Account;
//MAPPING USER => BALANCE
mapping(address => uint256) public Balance;
//MAPPING USER => ID
mapping (address => uint256) public User_ID;
//OWNER FIRST GENERATION DOWNLINES
address [] GENESIS_DOWNLINES;
//CONTRACT ID
uint256 public ID=0;

//CONTRACT STAKING FEE
 uint256 public stakingFee;

 //CONTRACT UPLINEBONUS
 uint256 public uplineBonus;

//CONTRACT LEVEL UPGRADE TIME
 uint32 constant upgradeTime= 10 minutes;



// Enums Variables
enum Level{
            levelZero, 
            levelOne,
            levelTwo,
            levelThree,
            levelFour,
            levelFive
        }
   



//EVEENT LOGS
event Registered(address indexed user);
event Upgrade(address indexed user,Level);
 

    constructor(address payable _GENESIS_UPLINE,uint256 _stakingFee) {
       
        GENESIS_UPLINE=_GENESIS_UPLINE;
        stakingFee=_stakingFee;
        uplineBonus=stakingFee/5;
        
    }

  
  



    function registerWithGenesisId() payable external{
     
       require(msg.sender != GENESIS_UPLINE,"The Owner is not allowed to register");
        require(Registered_Users.contains(msg.sender) == false,"You have already registered");
      
        require(msg.value == stakingFee,"Insuffient Fund");
       ID++;
        User storage s_user = Account[ID];
        User_ID[msg.sender]=ID;
        s_user.user=payable(msg.sender);
        s_user.s_level=Level.levelZero;
       for(uint i=0;i<5;i++){
         
           s_user.genesisUplines.push(GENESIS_UPLINE);
           s_user.Uplines.push(GENESIS_UPLINE);
       }
       Registered_Users.add(msg.sender);
         s_user.lastTimeStamp=block.timestamp + upgradeTime;
     
     
     GENESIS_DOWNLINES.push(msg.sender);

      emit Registered(msg.sender);
    }
 



   
  function registerWithReferralId(uint256 _referralID) payable  external{
        require(msg.sender != GENESIS_UPLINE,"The Owner is not allowed to register");
      require(Registered_Users.contains(msg.sender) == false,"You have already registered");
      require(  Account[_referralID].user != address(0),"Your Referree ID does not exists");
      require(msg.value == stakingFee,"Insuffient Fund");
       ID++;
        uint256 userID=ID;
        Registered_Users.add(msg.sender);
        User storage s_user = Account[ID];
        User_ID[msg.sender]=ID;
        s_user.user=payable(msg.sender);
        s_user.s_level=Level.levelZero;
        s_user.lastTimeStamp=block.timestamp + upgradeTime;
         
      checkUpline(_referralID,userID);
      Account[_referralID].rezDownlines.push(msg.sender);
  
       
      emit Registered(msg.sender);
      
  }
 

 

 function checkUpline(uint256 _referralID,uint256 _userID) internal {
    
     User storage ref=Account[_referralID];
     User storage s_user=Account[_userID];
     
     if(ref.genesisUplines.length == 5){
    for(uint256 i=0;i<4;i++){
       s_user.genesisUplines.push(GENESIS_UPLINE);
        s_user.Uplines.push(GENESIS_UPLINE);   
    }
    
       s_user.Uplines.push(ref.user);
      
     }else if(ref.genesisUplines.length == 4){
      for(uint256 i=0;i<3;i++){
       s_user.genesisUplines.push(GENESIS_UPLINE);
       s_user.Uplines.push(GENESIS_UPLINE);
    }
     s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 1]);
    s_user.Uplines.push(ref.user);
     

     }else if(ref.genesisUplines.length == 3){
        for(uint256 i=0;i<2;i++){
       s_user.genesisUplines.push(GENESIS_UPLINE);
        s_user.Uplines.push(GENESIS_UPLINE);
    }
     s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 2]);
   s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 1]);
    s_user.Uplines.push(ref.user);
    
     }else if(ref.genesisUplines.length == 2){
      s_user.genesisUplines.push(GENESIS_UPLINE);
       s_user.Uplines.push(GENESIS_UPLINE);
     s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 3]);
    s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 2]);
   s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 1]);
     s_user.Uplines.push(ref.user);
    
     }else if (ref.genesisUplines.length == 1){
        s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 4]);
       s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 3]);
    s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 2]);
   s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 1]);
     s_user.Uplines.push(ref.user);
     
       
     }else if(ref.genesisUplines.length == 0){
       s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 4]);
       s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 3]);
    s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 2]);
   s_user.Uplines.push(ref.Uplines[ref.Uplines.length - 1]);
     s_user.Uplines.push(ref.user);
    
     }
      
 }

function upgradeLevel(uint256 _referralID)external payable {
 
  User storage s_user=Account[_referralID];
   require(msg.sender == s_user.user,"Not the Owner");
  require(s_user.s_level != Level.levelFive,"You are at the Maximum Level");
require(block.timestamp > s_user.lastTimeStamp,"Not yet Time to upgrade Level");
    if(s_user.s_level == Level.levelZero){
      s_user.s_level = Level.levelOne;
       (bool sent, ) = s_user.Uplines[4].call{value: uplineBonus}("");
        require(sent, "Failed to send Ether");
        Balance[s_user.Uplines[4]]+=uplineBonus;
        _transfer(address(this), msg.sender, 1000);
        s_user.rezBalance+=1000;
        s_user.lastTimeStamp=block.timestamp +upgradeTime;
    }else if(s_user.s_level == Level.levelOne){
       s_user.s_level = Level.levelTwo;
       (bool sent, ) = s_user.Uplines[3].call{value: uplineBonus}("");
      require(sent, "Failed to send Ether");
       Balance[s_user.Uplines[3]]+=uplineBonus;
         _transfer(address(this), msg.sender, 2000);
        s_user.rezBalance+=2000;
        s_user.lastTimeStamp=block.timestamp + upgradeTime;
    }else if(s_user.s_level == Level.levelTwo){
 s_user.s_level = Level.levelThree;
       (bool sent, ) = s_user.Uplines[2].call{value: uplineBonus}("");
        require(sent, "Failed to send Ether");
         Balance[s_user.Uplines[2]]+=uplineBonus;
          _transfer(address(this), msg.sender, 3000);
        s_user.rezBalance+=3000;
        s_user.lastTimeStamp=block.timestamp + upgradeTime;
    }else if(s_user.s_level == Level.levelThree){
 s_user.s_level = Level.levelFour;
       (bool sent, ) = s_user.Uplines[1].call{value: uplineBonus}("");
        require(sent, "Failed to send Ether");
         Balance[s_user.Uplines[1]]+=uplineBonus;
          _transfer(address(this), msg.sender, 4000);
        s_user.rezBalance+=4000;
        s_user.lastTimeStamp=block.timestamp + upgradeTime;
    }else if(s_user.s_level == Level.levelFour){
      s_user.s_level = Level.levelFive;
       (bool sent, ) = s_user.Uplines[0].call{value: uplineBonus}("");
        require(sent, "Failed to send Ether");
         Balance[s_user.Uplines[0]]+=uplineBonus;
          _transfer(address(this), msg.sender, 5000);
        s_user.rezBalance+=5000;
        s_user.lastTimeStamp=block.timestamp + upgradeTime;
    }
    
 emit Upgrade(msg.sender,s_user.s_level);
}



function getAllRezUsers() public view returns (User[] memory) {
        User[] memory rezUser = new User[](ID);
        for (uint256 index = 0; index < ID; index++) {
            rezUser[index] = Account[index];
        }
        return rezUser;
    }
///@notice Returns the User Info.
    /// @dev Returns only a Struct.
function getRezUser(uint256 _ID)
        external
        view
        returns (User memory)
    {
    
     require (_ID <= Registered_Users.length() ,"Invalid User ID");   
        return Account[_ID];
    }

///@notice Returns the User Address.
     /// @dev Returns only an address.
   function getUserById(uint256 _id) external view returns( address  ){
      return Account[_id].user;
   }

   ///@notice Returns the Current Level of a User.
    /// @dev Returns only a Enum Variable.
 function getUserLevel(uint256 _id) external view returns( Level  ){
      return Account[_id].s_level;
   }

 ///@notice Returns the Genesis Uplines of a Particular User.
    /// @dev Returns only an array of addresses.
 function getGeneisUplineById(uint256 _id) external view returns (address payable[] memory){
   return Account[_id].genesisUplines;
 }

///@notice Returns the Earned REZTOKEN Balance of a User.
    /// @dev Returns only a unsigned Integer.
function getRezBalance(uint256 _id) external view returns (uint256){
 return Account[_id].rezBalance;
}

///@notice Returns the Users that registered without using referral ID.
    /// @dev Returns only an array of addresses.
function getGenesisDownlines() public view returns (address [] memory){
  return GENESIS_DOWNLINES;
}

///@notice Returns the No. of Genesis Uplines a Particular have.
    /// @dev Returns only a unsigned Integer.
  function getGensLensById(uint256 _id) external view returns (uint256){
   return Account[_id].genesisUplines.length;
 }

///@notice Returns the Uplines of a User.
    /// @dev Returns only an array of addresses.
 function getUplinesById(uint256 _id) external view returns (address payable [] memory){
   return Account[_id].Uplines;
 }

///@notice Returns the First Generation Downlines of a Rez-User.
    /// @dev Returns only an array of addresses.
 function getUserDownlines(uint256 _id) external  view returns(address [] memory){
   return Account[_id].rezDownlines;
 }

///@notice Returns the Earned Bonus from Contract Downlines.
    /// @dev Returns only an unsigned Integer.
function getContractEarnedBonus() external  view returns(uint256){
   return Balance[GENESIS_UPLINE];
}


}
