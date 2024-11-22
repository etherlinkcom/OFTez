// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test} from "forge-std/Test.sol";
import {OFTezProxy, hashTicket} from "../src/OFTezProxy.sol";
import {KernelMock} from "../src/KernelMock.sol";

contract BaseTest is Test {
    OFTezProxy public token;
    KernelMock public kernel;
    address public delegate; 
    address public owner;
    address public lzEndpoint = 0xec28645346D781674B4272706D8a938dB2BAA2C6;
    address public alice = vm.addr(0x1);
    address public bob = vm.addr(0x2);
    uint256 public ticketHash;
    bytes22 public ticketer = bytes22("some ticketer");
    bytes22 public wrongTicketer = bytes22("some other ticketer");
    bytes public content = abi.encodePacked("forged content");
    bytes public wrongContent = abi.encodePacked("another forged content");
    bytes public receiver = bytes("some receiver % entrypoint");
    bytes22 public receiver22 = bytes22("some receiver % entryp");
    bytes22 public proxy22 = bytes22("0000000000000000000000");

    function setUp() public {
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        delegate = msg.sender; 
        kernel = new KernelMock();
        token = new OFTezProxy(
            ticketer, content, address(kernel), "Token", "TKN", 18, lzEndpoint, delegate, owner
        );
        ticketHash = hashTicket(ticketer, content);
    }
}
