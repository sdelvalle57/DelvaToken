pragma solidity ^0.4.23;

import "./DelvaToken.sol";


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 { 
    function safeTransfer(DelvaToken token, address to, uint256 value) internal {
        assert(token.transfer(to, value));
    }

    function safeTransferFrom(DelvaToken token, address from, address to, uint256 value) internal {
        assert(token.transferFrom(from, to, value));
    }

    function safeApprove(DelvaToken token, address spender, uint256 value) internal {
        assert(token.approve(spender, value));
    }
}
