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

//TGE零释放，100% 锁仓一年；接下来每年释放 20%
//Founders vesting. Clift 1 year; Vesting of 20% per year;
contract FundersTokenVesting is Initializable,PausableUpgradeable, AccessControlUpgradeable{

    using SafeMath for uint256;

    //管理者权限
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public start;         //起始时间(s),上线开始时间
    uint256 public cliff;         //单位为秒(s)，锁仓间隔时间1年 = 365*24*60*60
    uint256 public releasedTimes; //累计已的释放次数
    uint256 public lastTime;      //上一次释放时间
    uint256 public nextTime;      //下一次领取时间
    address public token;         //合约地址
    address public releaseAddress; //打币地址
    bool    internal locked = false;//初始化参数锁

    //每年要释放的数量
    uint256[] internal yearRelease;

    event Released(address indexed from,address indexed to,uint256 amount);

    function initialize()public initializer{
		__Pausable_init();
        __AccessControl_init();
        //初始化操作者权限
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); 
	}

    function updateYearRelease(uint256 _idx,uint256 _released)public onlyRole(DEFAULT_ADMIN_ROLE){ 
        require(_idx >= 1 && _idx <= yearRelease.length,"out of length"); 
        uint8 dc = IKiss(token).decimals();
        yearRelease[_idx-1] = _released*10**dc ;
    }

    function getYearRelease(uint256 _idx)public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256){ 
        require(_idx >= 1 && _idx <= yearRelease.length,"out of length"); 
        return yearRelease[_idx-1];
    }

    //初始化参数，并且只能初始化一次
    function initParam(address _token,address _owner,uint256 _start,uint256 _cliff,uint256[] memory _released) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!locked,"param is init");
        require(_token != address(0) && _token != address(this),"address not 0 or this");
        token = _token;
        start = _start;
        cliff = _cliff;
        uint8 dc = IKiss(token).decimals();
        for(uint256 i=0;i<_released.length;i++){
            yearRelease.push(_released[i]*10**dc);
        }
        releasedTimes = 0;
        lastTime = 0;
        nextTime = start.add(cliff);
        //释放调用权限
        _grantRole(PAUSER_ROLE, _owner); 
        releaseAddress = _owner;
        locked = true;
    }

    function release() public onlyRole(PAUSER_ROLE) {
        uint256 _time = block.timestamp;

        require(releaseAddress == msg.sender,"not owner"); 
        require(releasedTimes < yearRelease.length,"released end");
        require(_time >= nextTime,"time has locked");  

        uint256 currentRelased = yearRelease[releasedTimes];
        require(currentRelased > 0,"released than 0");

        uint256 bs = IERC20(token).balanceOf(address(this));
        require(bs >= currentRelased,"balance less");

        SafeERC20.safeTransfer(IERC20(token),msg.sender,currentRelased); 

        lastTime = _time;
        nextTime = nextTime.add(cliff);
        releasedTimes = releasedTimes + 1;
        emit Released(address(this),msg.sender,currentRelased);
    }
}
