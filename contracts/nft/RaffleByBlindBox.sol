//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "./IRandom.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./SafeToken.sol";
import "../token/MechHero.sol";
import "../token/BlindBox.sol";
import "./BlindBoxMint.sol";


contract RaffleByBlindBox is AccessControl {
    using SafeToken for address;

    BlindBox private blindBoxContract;
    IRandom private randomContract;
    address[] private NFTAddrArray;                           
    uint256[] private HeroSupply = [20,
                                    20,
                                    20,
                                    200,
                                    200,
                                    1210,
                                    1210];

    mapping(uint256 => uint256) private NFTMinded;

    uint256 private PRECISION = 75e16;
    uint256 seed = 1;
    uint256 private constant Probability_Hero1 = 2000000000000000;
    uint256 private constant Probability_Hero2 = 4000000000000000;
    uint256 private constant Probability_Hero3 = 6000000000000000;
    uint256 private constant Probability_Hero4 = 26000000000000000;
    uint256 private constant Probability_Hero5 = 46000000000000000;
    uint256 private constant Probability_Hero6 = 66000000000000000;
    uint256[] private NFTProbability = [Probability_Hero1,
                                        Probability_Hero2,
                                        Probability_Hero3,
                                        Probability_Hero4,
                                        Probability_Hero5,
                                        Probability_Hero6,
                                        Probability_Hero7];
    modifier onlyGovernor() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            ""
        );
        _;
    }

    constructor(
        address _blindBoxAddress,
        address _randomAddress
    ) {
        blindBoxContract = BlindBox(_blindBoxAddress);
        randomContract = IRandom(_randomAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setHeroNftAddress(address[] memory _addresses) public {
        NFTAddrArray = _addresses;
    }

     function raffle(uint256 tokenId) public payable {
        uint256 total = 0;
        for (uint256 index = 0; index < NFTAddrArray.length; index++) {
            total = total + NFTMinded[index];
        }
        blindBoxContract.burn(tokenId);
        _mintNft();
    }

    function _getRandom() private returns (uint256 random) {
        seed = randomContract.getRandom();
        random =
            uint256(keccak256(abi.encodePacked(block.timestamp, seed))) %
            PRECISION;
        return random;
    }

    function _changePrecision() private {
        uint256 newPrecision = 0;

        for (uint256 index = 0; index < NFTAddrArray.length; index++) {

            if (NFTMinded[index] == HeroSupply[index]) {     
                NFTProbability[index] = 0;
            } else {
                if (index == 0) {
                    newPrecision = newPrecision + NFTProbability[index];
                } else {
                    newPrecision = newPrecision + NFTProbability[index] - NFTProbability[index - 1];
                }
            }
        }
        PRECISION = newPrecision;
    }

    function _mintNft() private {
        uint256 random = _getRandom();
        uint256 index = NFTAddrArray.length;
        uint256 startIndex = 0;
        for (uint256 i = startIndex; i < NFTProbability.length; i++) {
            if (random < NFTProbability[i]) {
                index = i;
                break;
            }
        }
        require(index < NFTAddrArray.length,"this index is error");
        address nftAddr = NFTAddrArray[index];
        MechHero hero = MechHero(nftAddr);
        hero.createDaoNFT(msg.sender);
        NFTMinded[index] = NFTMinded[index] + 1;
        _changePrecision();
    }
}
