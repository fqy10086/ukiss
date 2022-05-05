// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract UKiss is Initializable, ERC20Upgradeable, AccessControlUpgradeable {

    using SafeMath for uint256;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    function initialize() initializer public {
        __ERC20_init("UKISS", "ukiss");
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }


    //初始化铸币的处理
    function mintInit(address[] memory _addresses,uint256[] memory _amounts) public onlyRole(MINTER_ROLE){
        require(_addresses.length > 0 && _amounts.length > 0 && _addresses.length == _amounts.length,"length not match");
        for(uint256 i = 0; i < _addresses.length; i++){
            require(_addresses[i] != address(0) && _addresses[i] != address(this),"require not this or zero address");
            require(_amounts[i] > 0,"amount must than 0");
            _mint(_addresses[i], _amounts[i]*10**decimals());
        }
    }

}