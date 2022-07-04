//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MWC is ERC20("Meta Mecha War", "MWC") {
    constructor() {
        _mint(msg.sender,2e26);
    }

}