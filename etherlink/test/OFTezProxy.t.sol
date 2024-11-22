// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {BaseTest} from "./Base.t.sol";
import {OFTezProxy, hashTicket} from "../src/OFTezProxy.sol";

contract OFTezProxyTest is BaseTest {
    function test_BridgeCanMintToken() public {
        assertEq(token.balanceOf(alice), 0);
        kernel.inboxDeposit(address(token), alice, 100, ticketer, content);
        assertEq(token.balanceOf(alice), 100);
        assertEq(token.totalSupply(), 100);
    }

    function test_RevertWhen_AliceTriesMintToken() public {
        vm.prank(alice);
        vm.expectRevert(
            "OFTezProxy: only kernel allowed to deposit / withdraw tokens"
        );
        token.deposit(alice, 100, ticketHash);
    }

    function test_BridgeCanBurnToken() public {
        kernel.inboxDeposit(address(token), bob, 1, ticketer, content);
        assertEq(token.totalSupply(), 1);
        vm.prank(bob);
        kernel.withdraw(address(token), receiver, 1, ticketer, content);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.totalSupply(), 0);
    }

    function test_RevertWhen_AliceTriesBurnToken() public {
        kernel.inboxDeposit(address(token), alice, 1, ticketer, content);
        vm.prank(alice);
        vm.expectRevert(
            "OFTezProxy: only kernel allowed to deposit / withdraw tokens"
        );
        token.withdraw(alice, 1, ticketHash);
    }

    function test_RevertWhen_TicketerIsWrongOnMint() public {
        vm.expectRevert("OFTezProxy: wrong ticket hash");
        kernel.inboxDeposit(address(token), alice, 100, wrongTicketer, content);
    }

    function test_RevertWhen_ContentIsWrongOnMint() public {
        vm.expectRevert("OFTezProxy: wrong ticket hash");
        kernel.inboxDeposit(address(token), alice, 100, ticketer, wrongContent);
    }

    function test_RevertWhen_TicketerIsWrongOnBurn() public {
        vm.expectRevert("OFTezProxy: wrong ticket hash");
        vm.prank(address(kernel));
        uint256 wrongTokenHash = hashTicket(wrongTicketer, content);
        token.withdraw(alice, 1, wrongTokenHash);
    }

    function test_RevertWhen_ContentIsWrongOnBurn() public {
        vm.expectRevert("OFTezProxy: wrong ticket hash");
        vm.prank(address(kernel));
        uint256 wrongTokenHash = hashTicket(ticketer, wrongContent);
        token.withdraw(alice, 100, wrongTokenHash);
    }

    function test_ShouldReturnCorrectDecimals() public {
        assertEq(token.decimals(), 18);
        OFTezProxy anotherToken = new OFTezProxy(
            ticketer,
            content,
            address(kernel),
            "Another token",
            "ATKN",
            6,
            lzEndpoint, 
            delegate,
            owner
        );
        assertEq(anotherToken.decimals(), 6);
    }

    function test_ShouldReturnCorrectTokenHash() public {
        assertEq(token.getTicketHash(), ticketHash);
        OFTezProxy anotherToken = new OFTezProxy(
            ticketer,
            content,
            address(kernel),
            "Another token",
            "ATKN",
            6,
            lzEndpoint, 
            delegate,
            owner
        );
        uint256 anotherTokenHash = hashTicket(ticketer, content);
        assertEq(anotherToken.getTicketHash(), anotherTokenHash);
    }

    function test_ShouldCalculateCorrectTicketHash() pure public {
        bytes22 ticketer = bytes22("some ticketer");
        bytes memory content = abi.encodePacked("forged content");
        uint256 expectedHash =
            73262422851238627501129965791220701988577749077266918980111107915199512083078;
        assertEq(hashTicket(ticketer, content), expectedHash);
    }
}
