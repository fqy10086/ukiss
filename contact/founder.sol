// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts@4.5.0/utils/math/SafeMath.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/security/ReentrancyGuardUpgradeable.sol";

contract FundersTokenVestingStorageV1{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    address internal token;           //UKiss Token
    address internal releaseAddress;  //founders released address
    uint256 internal start;           //TGE time,Unit s
    uint256 internal cliff;           //vesting period,Unit s
    uint256 internal releasedTimes;   //total number of releases
    bool    internal locked = false;  //initParam method excute once lock statu;
    uint256[5] internal yearRelease;  //The number to be released each year

    uint256 public lastTime;          //last release time,Unit s
    uint256 public nextTime;          //next release time,Unit s
}

//Founders vesting. Clift 1 year; Vesting of 20% per year;
contract FundersTokenVesting is FundersTokenVestingStorageV1,Initializable,PausableUpgradeable, AccessControlUpgradeable,ReentrancyGuardUpgradeable{

    using SafeMath for uint256;

    //bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    //address internal token;           //UKiss Token
    //address internal releaseAddress;  //founders released address
    //uint256 internal start;           //TGE time,Unit s
    //uint256 internal cliff;           //vesting period,Unit s
    //uint256 internal releasedTimes;   //total number of releases
    //bool    internal locked = false;  //initParam method excute once lock statu;
    //The number to be released each year
    //uint256[] internal yearRelease;

    //uint256 public lastTime;        //last release time,Unit s
    //uint256 public nextTime;        //next release time,Unit s

    event FundersReleased(address indexed from,address indexed to,uint256 amount);

    function initialize()public initializer{
        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function initParam(address _token,address _owner,uint256 _start) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!locked,"Funders: repeated execute");
        require(_token != address(0) && _token != address(this),"Funders: bad Ukiss token");
        require(_owner != address(0) && _owner != address(this),"Funders: bad release address");

        token = _token;
        releaseAddress = _owner;
        start = _start;

        cliff = 31536000;
        nextTime = start.add(cliff);
        releasedTimes = 0;
        lastTime = 0;
        yearRelease = [3600000000000000000000000,3600000000000000000000000,3600000000000000000000000,
        3600000000000000000000000,3600000000000000000000000];

        locked = true;
    }

    function release() external whenNotPaused() nonReentrant {
        uint256 _time = block.timestamp;
        require(releaseAddress == msg.sender,"Funders: not owner");
        require(releasedTimes < yearRelease.length,"Funders: released times end");
        require(_time >= nextTime,"Funders: release date is not yet reached");

        uint256 currentReleased = yearRelease[releasedTimes];
        require(currentReleased > 0,"Funders: bad release value");

        uint256 bs = IERC20(token).balanceOf(address(this));
        require(bs >= currentReleased,"Funders: inffulunce balance");

        SafeERC20.safeTransfer(IERC20(token),msg.sender,currentReleased);

        lastTime = _time;
        nextTime = nextTime.add(cliff);
        releasedTimes = releasedTimes + 1;

        emit FundersReleased(address(this),msg.sender,currentReleased);
    }

    function pause() public virtual onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public virtual onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function unReleased() public view returns(uint256){
        require(releaseAddress == msg.sender,"Funders: not owner");
        uint256 rs = 0;
        for(uint256 i = releasedTimes;i < yearRelease.length;i++){
            rs = rs.add(yearRelease[i]);
        }
        return rs;
    }

    function released() public view returns(uint256){
        require(releaseAddress == msg.sender,"Funders: not owner");
        uint256 rs = 0;
        for(uint256 i = 0;i < releasedTimes;i++){
            rs = rs.add(yearRelease[i]);
        }
        return rs;
    }
}
