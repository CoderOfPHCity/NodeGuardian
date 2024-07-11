// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/SharkVault.sol";
import "../src/Attack.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SharkVaultTest is Test {
    IERC20 gold;
    IERC20 seagold;
    SharkVault vault;
    Attack attackContract;
    IERC3156FlashLender flashLender;

    address userSeagold = 0x23F4575aDed8a496076F6b2f28B76FF008c0429d;
    address userGold = 0xfCb668c2108782AC6B0916032BD2aF5a1563E65D;
    address daniel = 0xf67AC4799F4C3D3269c48A962A562eA81bB69cdC;

    uint256 constant INTEREST_RATE_PERCENT = 1;

    function setUp() public {
        // Fork the blockchain to a specific state
        vm.createSelectFork("https://rpc-sepolia-eth.nodeguardians.io/");

        // Initialize the SharkVault contract
        vault = new SharkVault(
            IERC20(0x41a23DBF52be3060Fa0910d6AA0F9f2D463E387c),
            IERC20(0x8fd03562Ffa407d478F481be4498A4dccdc4e03f)
        );

        // Fetch the gold and seagold token instances
        gold = vault.gold();
        seagold = vault.seagold();

        // Initialize the flash lender contract
        flashLender = IERC3156FlashLender(0xfCb668c2108782AC6B0916032BD2aF5a1563E65D);

        // Deploy the attack contract
        attackContract = new Attack(address(vault), address(flashLender), address(gold), address(seagold));

        // Start impersonating the userGold for approvals and deposits
        vm.startPrank(userGold);
        gold.approve(address(vault), type(uint256).max);
        gold.transfer(address(attackContract), 100 );  // Transfer gold to the attack contract for initial setup
        vault.depositGold(100 );  // Deposit sufficient gold for collateral
        vm.stopPrank();

        // Start impersonating the userSeagold for approvals and transfers
        vm.startPrank(userSeagold);
        seagold.approve(address(vault), type(uint256).max);
        seagold.transfer(address(vault), 100 );  // Transfer sufficient seagold to the vault
        vm.stopPrank();
    }

    function testFlashLoanReentrancy() public {
        // Execute the attack
        attackContract.attack();

    //     // Validate the final state to ensure no unintended funds transfer
    //     uint256 goldBalance = gold.balanceOf(address(vault));
    //     uint256 seagoldBalance = seagold.balanceOf(address(vault));

    //     // Ensure the vault's gold and seagold balances are as expected
    //     assertEq(goldBalance, 100 ether, "Vault gold balance incorrect");
    //     assertEq(seagoldBalance, 90 ether, "Vault seagold balance incorrect");

    //     // Ensure the attacker's balances are as expected
    //     assertEq(gold.balanceOf(daniel), 0 ether, "Attacker gold balance incorrect");
    //     assertEq(seagold.balanceOf(daniel), 0 ether, "Attacker seagold balance incorrect");
     }
}
