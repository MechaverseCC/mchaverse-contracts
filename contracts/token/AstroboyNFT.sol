//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../libraries/ERC4907.sol";

contract AstroboyNFT is ERC4907, ERC721Enumerable, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public immutable maxSupply;
    Counters.Counter private tokenIds;
    string private baseURI;
    

    constructor(uint256 _maxSupply) ERC4907("MC Astroboy NFT", "MCAstro") {
        maxSupply = _maxSupply;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC4907, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC4907, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory _baseUri) public onlyOwner {
        baseURI = _baseUri;
    }

    

    function createNFT(address to) public onlyOwner returns (uint256) {
        require(totalSupply() < maxSupply, "MCAstro: the limit has been reached");
        return _mintNFT(to);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "MCAstro: URI query for nonexistent token");
        return
            string(
                abi.encodePacked(baseURI, tokenId.toString(), ".json")
            );
    }

    function _mintNFT(address to) private returns (uint256) {
        tokenIds.increment();
        uint256 newItemId = tokenIds.current();
        _safeMint(to, newItemId);
        return newItemId;
    }
}
