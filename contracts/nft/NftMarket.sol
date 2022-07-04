//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @notice
contract NftMarket is Ownable, ReentrancyGuard, ERC721Holder {
    using SafeERC20 for IERC20;
    using Address for address payable;
    using Counters for Counters.Counter;

    address private team;
    address private gameCoin;
    uint256 private tradingFee = 500;
    uint256 private constant BASE_POINT = 10000;
    bool stopSwitch = false;

    Counters.Counter private _orderId;

    struct OrderInfo {
        uint256 id;
        uint256 status;  
        address nft;
        uint256 tokenId;
        uint256 price; 
        address owner; 
    }

    mapping(uint256 => OrderInfo) orders;
    mapping(address => OrderInfo[]) private userOrders;

    constructor(address _gameCoin, address _team) {
        gameCoin = _gameCoin;
        team = _team;
    }

    function getOrders() external view returns (OrderInfo[] memory) {
        OrderInfo[] memory orderList = new OrderInfo[](_orderId.current());
        for (uint256 i = 0; i < orderList.length; i++) {
            orderList[i] = orders[i+1];
        }
        return orderList;
    }

    function getUserOrders(address user) external view returns (OrderInfo[] memory) {
        return userOrders[user];
    }

   
    function list(
        address _nft,
        uint256 _tokenId,
        uint256 _price
    ) public nonReentrant {
        require(!stopSwitch, "The list function has been suspended");
        IERC721(_nft).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );
        
    }

    
    function unList(uint256 orderId) public nonReentrant {
        OrderInfo memory order = orders[orderId];
        require(order.owner == msg.sender, "The caller is not the owner!");
        IERC721(order.nft).safeTransferFrom(
            address(this),
            msg.sender,
            order.tokenId
        );
        uint256 arrayLength = userOrders[msg.sender].length;
        for (uint256 i = 0; i < arrayLength; i++) {
            if (userOrders[msg.sender][i].id == orderId) {
                userOrders[msg.sender][i].status = 3;
                break;
            }
        }
    }

    function buy(uint256 orderId) public nonReentrant {
        OrderInfo memory order = orders[orderId];
        uint256 fee = (order.price * tradingFee) / BASE_POINT;
        IERC20(gameCoin).safeTransferFrom(
            msg.sender,
            order.owner,
            order.price - fee
        );
        IERC20(gameCoin).safeTransferFrom(msg.sender, team, fee);
        IERC721(order.nft).safeTransferFrom(
            address(this),
            msg.sender,
            order.tokenId
        );
        orders[orderId].status = 2;
        uint256 arrayLength = userOrders[msg.sender].length;
        for (uint256 i = 0; i < arrayLength; i++) {
            if (userOrders[msg.sender][i].id == orderId) {
                userOrders[msg.sender][i].status = 2;
                break;
            }
        }
    }

    function emergencyStop(bool _switch) public nonReentrant onlyOwner {
        stopSwitch = _switch;
    }
}
