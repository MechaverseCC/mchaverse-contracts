//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MM is ERC20("MetaMecha", "MM") {
    constructor() {
        _mint(msg.sender,20e26);
    }

}
