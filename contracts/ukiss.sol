// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts@4.5.0/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC20/extensions/ERC20VotesComp.sol";

// UKiss
contract UKissFixedSupply is ERC20Burnable, ERC20Permit, ERC20VotesComp {
    /**
     * @dev Mints `initialSupply` amount of token and transfers them to `owner`.
     *
     * See {ERC20-constructor}.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address owner
    ) ERC20(name, symbol) ERC20Permit(name) {
        _mint(owner, initialSupply);
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20, ERC20Votes) {
        return ERC20Votes._mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override(ERC20, ERC20Votes) {
        return ERC20Votes._burn(account, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20,ERC20Votes) {
        return ERC20Votes._afterTokenTransfer(from, to, amount);
    }

    function getChainId() external view returns (uint256) {
        return block.chainid;
    }
}