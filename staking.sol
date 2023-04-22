// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakeZIMAX is Ownable,ReentrancyGuard  {
      using SafeMath for uint256;

    IERC20 public zmxToken; 

    uint256 public sixMonthApy=3325;
    uint256 public oneYearApy=7610;
    uint256 public twoYearApy=9840;
    uint256 public counter;
    uint256 public totalStaked;

    struct Staked {
        uint256 amount;
        uint256 stakedDuration;
        uint256 stakedStartingTime;
        uint256 unstakedTiming;
        uint256 rewardAmount;
        bool claimed;

    }
   mapping(address =>uint256[]) public userStakeId; 
   mapping(address => mapping(uint256 => Staked)) public stake;
   event StakeZMX(address indexed staker,uint256 indexed id,uint256 amount);
   event UnStakeZMX(address indexed staker,uint256 indexed id,uint256 amount);

   constructor(IERC20 _zmxToken)
    {
        zmxToken=_zmxToken;
    }


    function stakeZIMAX(uint256 _duration, uint256 _amount) external returns(bool){
        require(_duration==6 || _duration==1 || _duration==2 ,"invalid duration");
        require(zmxToken.balanceOf(msg.sender)>=_amount,"less token bal.");
        uint256 id= counter;
        address staker= msg.sender;
        userStakeId[staker].push(id); // Update Id in Map
        uint256 unstakeTiming;
        uint256 rewardAmount;
        (unstakeTiming,rewardAmount) = calculateUnstakeTime(_duration,_amount);
        Staked storage s = stake[staker][id];

        s.amount = _amount;
        s.stakedDuration = _duration;
        s.stakedStartingTime =block.timestamp;
        s.unstakedTiming = unstakeTiming; 
        s.rewardAmount= rewardAmount;
        s.claimed=false;

        totalStaked+= _amount;
        counter++;
        
        zmxToken.transferFrom(msg.sender,address(this),_amount);
        emit StakeZMX(staker,id,_amount);

        return true;
    }
    function calculateUnstakeTime(uint256 _duration,uint256 _amount) public view returns(uint256,uint256){
        if(_duration==6){
            uint256 sixMonthTime = block.timestamp + (365 days)/2;   // calculate 6 month
            uint256 calculateSixReward= _amount + (_amount*sixMonthApy)/10_000;
            return (sixMonthTime ,calculateSixReward);
        }
        if(_duration==1){
             uint256 oneYearTime = block.timestamp + (365 days);     // calculate 1 year
            uint256 calculateOneReward= _amount + (_amount*oneYearApy)/10_000;

            return (oneYearTime,calculateOneReward);
        }
        if(_duration==2){
            uint256 twoYearTime = block.timestamp + ((365 days) * 2);  // calculate 2 year
            uint256 calculateTwoReward= _amount + (_amount*twoYearApy)/10_000;

            return (twoYearTime,calculateTwoReward);
            
        }
        return (0,0);
    }

    function unStakeZIMAX(uint256 _id) external returns(bool){
        address staker= msg.sender;
        Staked storage s = stake[staker][_id];
        require(s.claimed==false,"Already claimed");
        require(block.timestamp >= s.unstakedTiming,"Time is not completed.");
        require(zmxToken.balanceOf(address(this))>=s.rewardAmount,"Less pool bal.");
        require(isIdExist(_id,msg.sender)== true,"Invalid Id");
     
        s.claimed=true;
        deleteUserIds(staker,_id);
        totalStaked-= s.amount;
        uint256 totalAmount= s.rewardAmount;
        zmxToken.transfer(staker,totalAmount);
        emit UnStakeZMX(msg.sender,_id,totalAmount);
        return true;
    }

    function isIdExist(uint256 id,address unstaker) internal view returns(bool){
        uint256[] memory arr = userStakeId[unstaker];
        uint256 ids= id;
        for(uint256 j=0;j<arr.length;j++){
            if(arr[j]==ids)
            return true;
        }
        return false;
    }

    function deleteUserIds(address _account, uint256 Ids) internal returns(bool) {
        uint256[] storage array = userStakeId[_account];

        if(array.length == 1){
            array.pop();
            return true;
        }
        uint256 index;
        
        for (uint256 i = 1; i < array.length; i++) {
            if(array[i]==Ids){
                index = i;
                break;
            }
        
        }
        array[index] = array[array.length-1];
        array.pop();

        return true;
    }
    function getUserStakeId(address _account) external view returns(uint256[] memory){
        return userStakeId[_account];
    }

    function withdrawZmxToken(uint256 _amount) external onlyOwner returns(bool){
        require(zmxToken.balanceOf(address(this))>=_amount,"less pool bal.");
        zmxToken.transfer(msg.sender,_amount);
        return true;
    }
    function withdrawNativeToken(uint256 _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }
    function updateSixMonthApy(uint256 _sixMonthApy) external onlyOwner{
        sixMonthApy=_sixMonthApy;
    }
    function updateOneYearApy(uint256 _oneYearApy) external onlyOwner{
        oneYearApy=_oneYearApy;
    }
    function updatetTwoYearApy(uint256 _twoYearApy) external onlyOwner{
        twoYearApy=_twoYearApy;
    }


    receive() external payable{}


}

