// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

interface IKiss {
	function decimals() external view returns (uint8);
}
// TGE后6个月释放4%；96%锁仓一年，然后每半年释放16%；
// Clift 6 months after TGE, then release 4%; followed by 16% every 6 months;
contract AdvisorsTokenVesting is Initializable,PausableUpgradeable, AccessControlUpgradeable{
    using SafeMath for uint256;

    //释放调用者权限
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

 
    address public token;           //合约地址
    address public releasedAddress;  //释放地址
    uint8   public releaseTimes;    //释放的次数

    uint256 public start;           //起始时间（Unix time），提示从什么时刻开始计时; Starting time
    uint256 public onlineLock;      //上线后锁仓6个月，秒; clift period in seconds
    uint256 public cliff;           //其余锁仓时间，秒 1年; lockin period in seconds
    uint256 public duration;        //后续锁仓时间，秒; vesting period 
    uint256 public lastTime;        //上一次释放时间; last release time
    uint256 public nextTime;        //下一次领取时间; next release time
    bool    internal locked = false;  //初始化参数锁; 
    
    //总的释放列表; main release list
    uint256[] internal releasedArr;

    event Released(address indexed from,address indexed to,uint256 amount);

    function initialize()public initializer{
		__Pausable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); 
	}

    //初始化参数，并且只能初始化一次
    function initParam(address _token,address _owner,uint256 _start,uint256 _onlineLock,uint256 _cliff,uint256 _duration,uint256[] memory _released) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!locked,"param is init");
        require(_token != address(0) && _token != address(this),"address not 0 or this");
        token = _token;
        start = _start;
        onlineLock = _onlineLock;
        cliff = _cliff;
        duration = _duration;
        uint8 dc = IKiss(token).decimals();
        for(uint256 i = 0;i < _released.length;i++){
            releasedArr.push(_released[i]*10**dc);
        } 
        releaseTimes = 0;
        lastTime = 0;
        nextTime = start.add(onlineLock);
        //释放管理者权限 
        _grantRole(PAUSER_ROLE, _owner);
        releasedAddress = _owner;
        locked = true;
    }

    
    function release() public onlyRole(PAUSER_ROLE){
        uint256 _time = block.timestamp;

        require(releasedAddress == msg.sender,"not owner");
        require(releaseTimes < releasedArr.length,"released end");
        require(_time >= nextTime,"time has locked");

        uint256 currentReleased = releasedArr[releaseTimes];
        require(currentReleased > 0,"released than 0");

        uint256 bs = IERC20(token).balanceOf(address(this));
        require(bs >= currentReleased,"balance less");

        SafeERC20.safeTransfer(IERC20(token),msg.sender,currentReleased);
        
        lastTime = _time;
        if (releaseTimes == 0){
            nextTime = nextTime.add(cliff);
        }else{
            nextTime = nextTime.add(duration);
        }
        releaseTimes = releaseTimes + 1;

        emit Released(address(this),msg.sender,currentReleased);
    }

    function updateReleased(uint256 _idx,uint256 _raleased)public onlyRole(DEFAULT_ADMIN_ROLE){ 
        require(_idx >= 1 && _idx <= releasedArr.length,"out of length"); 
        uint8 dc = IKiss(token).decimals();
        releasedArr[_idx-1] = _raleased*10**dc;
    }

    function getReleased(uint256 _idx)public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256){ 
        require(_idx >= 1 && _idx <= releasedArr.length,"out of length"); 
        return releasedArr[_idx-1];
    }

    //查询未释放的量
    function unReleased() public view onlyRole(PAUSER_ROLE) returns(uint256){
        uint256 rs = 0;
        for(uint256 i = releaseTimes;i < releasedArr.length;i++){
            rs = rs.add(releasedArr[i]);
        }
        return rs;
    }

    //查询已释放量 
    function released() public view onlyRole(PAUSER_ROLE) returns(uint256){
        uint256 rs = 0;
        for(uint256 i = 0;i < releaseTimes;i++){
            rs = rs.add(releasedArr[i]);
        }
        return rs;
    }
}