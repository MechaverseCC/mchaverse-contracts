//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MechHero is ERC721Enumerable, ERC721Burnable, AccessControl {
    using Strings for uint256;
    using Counters for Counters.Counter;
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public immutable maxSupply;
    mapping(uint256 => string) public tokenIdHeroRareLevel;
    Counters.Counter private tokenIds;
    string private baseURI;
    string[] private RareLevel = ["N", "R", "SR", "SSR"];

    modifier onlyGovernor() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Caller is not the governor"
        );
        _;
    }
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Caller is not the minter");
        _;
    }

    constructor(uint256 _maxSupply)
        ERC721("MechHero", "MECH_HERO")
    {
        maxSupply = _maxSupply;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function _setBaseURI(string memory _baseUri) public onlyGovernor {
        baseURI = _baseUri;
    }

    function grantMinter(address minter) public onlyGovernor {
        _setupRole(MINTER_ROLE, minter);
    }

    function revokeMinter(address minter) public onlyGovernor {
        revokeRole(MINTER_ROLE, minter);
    }

    function createHeroNFT(address to, uint256 level)
        public
        onlyMinter
        returns (uint256)
    {
        require(totalSupply() < maxSupply, "The limit has been reached");
        uint256 tokenId = _mintHeroNFT(to);
        tokenIdHeroRareLevel[tokenId] = RareLevel[level];
        return tokenId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Enumerable, ERC721) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "URI query for nonexistent token"
        );

        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    function _mintHeroNFT(address to) private returns (uint256) {
        tokenIds.increment();
        uint256 newItemId = tokenIds.current();
        _safeMint(to, newItemId);
        return newItemId;
    }
}
