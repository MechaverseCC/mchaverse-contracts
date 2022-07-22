//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract MM is ERC20("MetaMecha", "MM"), AccessControl, ERC20Burnable {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    modifier onlyGovernor() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "MM: caller is not the governor"
        );
        _;
    }

    modifier onlyMinter() {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "MM: caller is not the minter"
        );
        _;
    }
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function grantMinter(address minter) public onlyGovernor {  
        _setupRole(MINTER_ROLE, minter);
    }

    function revokeMinter(address minter) public onlyGovernor {
        revokeRole(MINTER_ROLE, minter);
    }

    function mint (address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
    }

}