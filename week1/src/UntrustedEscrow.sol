// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


// Untrusted escrow. Create a contract where a buyer can put an arbitrary ERC20 token into a contract and a seller can withdraw it 3 days later.
// Based on your readings above, what issues do you need to defend against? Create the safest version of this that you can while guarding against issues that you cannot control.
// Does your contract handle fee-on transfer tokens or non-standard ERC20 tokens.
contract UntrustedEscrow is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public token;

    address public seller;

    uint256 public depositTime;

    uint256 public immutable duration = 3 days;

    uint256 public balanceBefore;

    event Deposit(address indexed seller, address buyer, address indexed token, uint256 amount);
    event Withdraw(address indexed seller, address indexed token, uint256 amount);
    constructor() Ownable(msg.sender) {}

    function deposit(address _seller, address _token, uint256 _amount) public {
        token = IERC20(_token);
        seller = _seller;
        balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        depositTime = block.timestamp;

        emit Deposit(seller, msg.sender, _token, _amount);
    }

    function withdraw() public nonReentrant  {
        require(block.timestamp > depositTime + duration, "Cannot withdraw before 3 days");

        uint256 balance = token.balanceOf(address(this));

        uint256 transferValue = balance - balanceBefore;
        token.safeTransfer(msg.sender, transferValue);

        emit Withdraw(seller, address(token), transferValue);
    }
}
