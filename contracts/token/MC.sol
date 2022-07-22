//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MC is ERC20("Mechaverse", "MC") {
    constructor() {
        _mint(msg.sender,2e26);
    }

}