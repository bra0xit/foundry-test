// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MyERC20Contract} from "../src/contracts/erc20-1/MyERC20Contract.sol";

contract ERC20TokensExercise1Test is Test {
    MyERC20Contract myContract;
    address deployer;
    address user1;
    address user2;
    address user3;

    uint256 constant DEPLOYER_MINT = 100000 ether;
    uint256 constant USERS_MINT = 5000 ether;
    uint256 constant FIRST_TRANSFER = 100 ether;
    uint256 constant SECOND_TRANSFER = 1000 ether;

    function setUp() public {
        deployer = address(this); // In Foundry, the deploying address is `address(this)`
        user1 = address(1); // Mock user addresses
        user2 = address(2);
        user3 = address(3);

        // Contract deployment
        myContract = new MyERC20Contract(); // Assuming no constructor arguments

        // Minting
        vm.prank(deployer); // Impersonate deployer
        myContract.mint(deployer, DEPLOYER_MINT);

        myContract.mint(user1, USERS_MINT);
        myContract.mint(user2, USERS_MINT);
        myContract.mint(user3, USERS_MINT);

        // Check Minting
        assertEq(myContract.balanceOf(deployer), DEPLOYER_MINT);
        assertEq(myContract.balanceOf(user1), USERS_MINT);
        assertEq(myContract.balanceOf(user2), USERS_MINT);
        assertEq(myContract.balanceOf(user3), USERS_MINT);
    }

    function testTransfer() public {
        // First transfer
        vm.prank(user2); // Impersonate user2
        myContract.transfer(user3, FIRST_TRANSFER);

        // Approval & Allowance test
        vm.prank(user3); // Impersonate user3
        myContract.approve(user1, SECOND_TRANSFER);
        assertEq(myContract.allowance(user3, user1), SECOND_TRANSFER);

        // Second transfer
        vm.prank(user1); // Impersonate user1
        myContract.transferFrom(user3, user1, SECOND_TRANSFER);

        // Checking balances after transfer
        assertEq(myContract.balanceOf(user1), USERS_MINT + SECOND_TRANSFER);
        assertEq(myContract.balanceOf(user2), USERS_MINT - FIRST_TRANSFER);
        assertEq(
            myContract.balanceOf(user3),
            USERS_MINT + FIRST_TRANSFER - SECOND_TRANSFER
        );
    }
}
