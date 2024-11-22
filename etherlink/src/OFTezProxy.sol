// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "./OFTezEVMProxy.sol";
/**
 * @notice Calculates the hash of the ticket.
 * @param ticketer The L1 ticketer address in its forged form.
 * @param content The ticket content as a micheline expression in its forged form.
 * @return ticketHash The calculated ticket hash as a uint256.
 */
function hashTicket(bytes22 ticketer, bytes memory content)
    pure
    returns (uint256 ticketHash)
{
    ticketHash = uint256(keccak256(abi.encodePacked(ticketer, content)));
}

/**
 * @title OFTTezProxy Proxy contract for bridged FA tokens 
 * @notice A ERC20 token contract representing a L1 token on Etherlink.
 * @dev this is ddeployed on Etherlink ONLY
 */
contract OFTezProxy is OFTezEVMProxy {
    uint256 private immutable _ticketHash;
    address private immutable _kernel;
    uint8 private immutable _decimals;

    /**
     * @notice Constructs the ERC20Proxy.
     * @param ticketer_ Address of the L1 ticketer contract which tickets are
     * allowed to be minted by this ERC20Proxy.
     * @param content_ Content of the L1 ticket allowed to be minted by
     * this ERC20Proxy.
     * @param kernel_ Address of the rollup kernel which has rights for
     * the minting and burning tokens.
     * @param name_ Name of the token.
     * @param symbol_ Symbol of the token.
     * @param decimals_ decimals of the token. 
     * @param lzEndpoint_ Layer Zero endpoint 
     * @param delegate_ Layer Zero delegate address
     * @param owner_ ownable owner
     */
    constructor(
        bytes22 ticketer_,
        bytes memory content_,
        address kernel_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address lzEndpoint_,
        address delegate_,
        address owner_
        ) OFTezEVMProxy(name_, symbol_, decimals_, lzEndpoint_, delegate_, owner_) {
        _ticketHash = hashTicket(ticketer_, content_);
        _kernel = kernel_;
        this;
    }

    /**
     * @notice Ensures the caller is the kernel address.
     */
    modifier onlyKernel() {
        require(
            _kernel == _msgSender(),
            "OFTezProxy: only kernel allowed to deposit / withdraw tokens"
        );
        _;
    }

    /**
     * @notice Ensures the ticket hash equal to the one that was calculated
     * during deployment.
     * @param ticketHash The ticket hash to validate.
     */
    modifier onlyAllowedTicketHash(uint256 ticketHash) {
        require(_ticketHash == ticketHash, "OFTezProxy: wrong ticket hash");
        _;
    }

    /**
     * @notice Mints tokens to a receiver.
     * @notice Only callable by the kernel and fails if ticketHash is incorrect.
     * @param receiver The address to receive the minted tokens.
     * @param amount The amount of tokens to mint.
     * @param ticketHash The ticket hash to check against.
     */
    function deposit(address receiver, uint256 amount, uint256 ticketHash)
        public
        onlyKernel
        onlyAllowedTicketHash(ticketHash)
    {
        _mint(receiver, amount);
    }

    /**
     * @notice Burns tokens from a sender address.
     * @notice Only callable by the kernel and fails if ticketHash is incorrect.
     * @param sender The address from which tokens will be burned.
     * @param amount The amount of tokens to burn.
     * @param ticketHash The ticket hash to check against.
     */
    function withdraw(address sender, uint256 amount, uint256 ticketHash)
        public
        onlyKernel
        onlyAllowedTicketHash(ticketHash)
    {
        _burn(sender, amount);
    }

    /**
     * @notice Returns the ticket hash.
     * @return The ticket hash as a uint256.
     */
    function getTicketHash() public view returns (uint256) {
        return _ticketHash;
    }
}

