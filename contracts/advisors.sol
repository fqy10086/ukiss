// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts@4.5.0/utils/math/SafeMath.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/security/ReentrancyGuardUpgradeable.sol";


contract AdvisorsTokenVestingStorageV1{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    uint256 public lastTime;                //last release time,Unit s
    uint256 public nextTime;                //next release time,Unit s

    address internal token;                 //UKiss Token
    address internal releasedAddress;       //advisors released address
    uint8   internal releaseTimes;          //total number of releases
    uint256 internal start;                 //TGE time,Unit s
    uint256 internal afterTgeDuration;      //clift 6 months after TGE,Unit s
    uint256 internal remainDuration;        //ockin period in seconds,Unit s
    uint256 internal duration;              //vesting period,Unit s
    uint256[7] internal releasedArr;        //main release list
    uint256[50] private __gap;              //
}

// Clift 6 months after TGE, then release 4%; followed by 16% every 6 months;
contract AdvisorsTokenVesting is AdvisorsTokenVestingStorageV1, Initializable,ContextUpgradeable,PausableUpgradeable, AccessControlUpgradeable,ReentrancyGuardUpgradeable{
    using SafeMath for uint256;

    event AdvisorsReleased(address indexed from,address indexed to,uint256 amount);

    function initialize(address _token,address _owner,uint256 _start)public initializer{
        require(_token != address(0) && _token != address(this),"Advisors: Token address cannot be 0 address or this contract address");
        require(_owner != address(0) && _owner != address(this),"Advisors: Owner address cannot be 0 address or this contract address");

        __Context_init_unchained();
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        token = _token;
        releasedAddress = _owner;
        start = _start;

        afterTgeDuration = 15768000; //6 mouth
        remainDuration = 15768000; //6 mouth
        duration = 15768000; // 6 mouth
        releaseTimes = 0;
        lastTime = 0;
        nextTime = start.add(afterTgeDuration);

        releasedArr = [200000000000000000000000,800000000000000000000000,800000000000000000000000,
        800000000000000000000000,800000000000000000000000,800000000000000000000000,800000000000000000000000];
    }

    
    function release() external whenNotPaused() nonReentrant{
        uint256 _time = block.timestamp;
        require(releasedAddress == msg.sender,"Advisors: Not owner");
        require(releaseTimes < releasedArr.length,"Advisors: Release has ended");
        require(_time >= nextTime,"Advisors: Current time is less than next release time");

        uint256 currentReleased = releasedArr[releaseTimes];
        require(currentReleased > 0,"Advisors: Release must be greater than 0");

        uint256 bs = IERC20(token).balanceOf(address(this));
        require(bs >= currentReleased,"Advisors: Contract balance is less than current release");

        SafeERC20.safeTransfer(IERC20(token),msg.sender,currentReleased);

        lastTime = _time;
        if (releaseTimes == 0){
            nextTime = nextTime.add(remainDuration);
        }else{
            nextTime = nextTime.add(duration);
        }
        releaseTimes = releaseTimes + 1;

        emit AdvisorsReleased(address(this),msg.sender,currentReleased);
    }

    function pause() public virtual onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public virtual onlyRole(PAUSER_ROLE) {
        _unpause();
    }


    function unReleased() public view returns(uint256){
        require(releasedAddress == msg.sender,"Advisors: Not owner");
        uint256 rs = 0;
        for(uint256 i = releaseTimes;i < releasedArr.length;i++){
            rs = rs.add(releasedArr[i]);
        }
        return rs;
    }

    function released() public view returns(uint256){
        require(releasedAddress == msg.sender,"Advisors: Not owner");
        uint256 rs = 0;
        for(uint256 i = 0;i < releaseTimes;i++){
            rs = rs.add(releasedArr[i]);
        }
        return rs;
    }
}