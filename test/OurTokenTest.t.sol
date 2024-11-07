// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {OurToken} from "src/OurToken.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(address(msg.sender));
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Bob approves ALice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
    }

    function testTransfer() public {
        uint256 amount = 100;

        // Transfer tokens from deployer to user1
        vm.prank(msg.sender);
        ourToken.transfer(bob, amount);

        // Check balances after transfer
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE + amount);
    }

    function testBalanceAfterTransfer() public {
        uint256 amount = 1000;
        uint256 initialBalance = ourToken.balanceOf(address(msg.sender));

        vm.prank(msg.sender);
        ourToken.transfer(bob, amount);

        assertEq(
            ourToken.balanceOf(address(msg.sender)),
            initialBalance - amount
        );
    }
}
