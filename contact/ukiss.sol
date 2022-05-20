// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts@4.5.0/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.5.0/proxy/utils/Initializable.sol";


contract UKissStorageV1{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    uint256 internal maxMint;           //mint max value of Ukiss
    uint256 internal hasMint;           //aleadly mint value of Ukiss
}

/*
 * UKiss Token
 * total: 100000000 UKISS
 * mutilMint : excute only once and need MINTER_ROLE
*/
contract UKiss is UKissStorageV1, Initializable, ERC20Upgradeable,PausableUpgradeable, AccessControlUpgradeable,ERC20PermitUpgradeable,ERC20VotesUpgradeable {

    using SafeMath for uint256;

    function initialize() initializer public {
        __ERC20_init("UKISS", "ukiss");
        __Pausable_init();
        __AccessControl_init();
        __ERC20Permit_init("UKISS");
        __ERC20Votes_init();

        maxMint = 100000000*1e18;
        hasMint = 0;

        // Deployer Role
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Mint Role
        _grantRole(MINTER_ROLE, msg.sender);

        // Pauser Role
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    //mint ukiss
    function mutilMint(address[] memory _addresses,uint256[] memory _amounts) external onlyRole(MINTER_ROLE){
        require(_addresses.length > 0 && _amounts.length > 0 && _addresses.length == _amounts.length,"UKiss: Address length and amounts length do not match");
        require(hasMint < maxMint,"UKiss: Mint more than totalSupply");
        for(uint256 i = 0; i < _addresses.length; i++){
            require(_addresses[i] != address(0) && _addresses[i] != address(this),"UKiss: Address cannot be 0 address or this contract address");
            require(_amounts[i] > 0,"UKiss: Mint value must be greater than 0");
            uint256 mintVal = _amounts[i]*1e18;
            require((hasMint + mintVal) <= maxMint,"UKiss: Mint more than totalSupply");
            _mint(_addresses[i], mintVal);
            hasMint = hasMint + mintVal;
        }
    }

    function pause() public virtual onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public virtual onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal
    whenNotPaused
    override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.
    function _afterTokenTransfer(address from, address to, uint256 amount)
    internal
    override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
    internal
    override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
    internal
    override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._burn(account, amount);
    }

}