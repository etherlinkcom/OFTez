// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import { OFT } from "@layerzerolabs/lz-evm-oapp-v2/oft/OFT.sol";

/**
 * @title OFTTezEVMProxy Proxy contract for recieving and sending FA Tokens Bridged through Etherlink
 * @notice A ERC20 token contract representing a L1 token on Etherlink.
 * @dev this is ddeployed on other EVM chains ONLY
 */

contract OFTezEVMProxy is OFT { 
    
    uint8 private immutable _decimals;
    /**
     * @param name_ Name of the token.
     * @param symbol_ Symbol of the token.
     * @param decimals_ decimals of the token. 
     * @param lzEndpoint_ Layer Zero endpoint 
     * @param delegate_ Layer Zero delegate address
     * @param owner_ ownable owner
     */
    constructor(string memory name_,
                    string memory symbol_,
                    uint8 decimals_,
                    address lzEndpoint_,
                    address delegate_,
                    address owner_) Ownable(owner_) OFT(name_, symbol_, lzEndpoint_, delegate_){
                _decimals = decimals_; 
    }

    /**
     * @notice Returns the number of decimals the token uses.
     * @return The number of decimals for the token.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }


}