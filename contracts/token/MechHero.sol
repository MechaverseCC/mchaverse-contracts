//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
* @dev 
*/
contract MechHero is ERC721, ERC721Enumerable, ERC721Burnable, AccessControl {
    using Strings for uint256;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;
    uint256 public immutable maxSupply;
    string private  heroName;
    string private  rareLevel;
    string private baseURI; 
    struct DaoAttribute {
        string heroName;
        string rareLevel;
    }
    mapping(uint256 => DaoAttribute) public tokenIdDaoAttribute;

    modifier onlyGovernor() {
        require( 
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not the governor"
        );
        _;
    }
    modifier onlyMinter() {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "Caller is not the minter"
        );
        _;
    }

    constructor(uint256 _maxSupply, string memory _heroName, string memory _rareLevel)
        ERC721("MechHero", "MECH_HERO")
    {
        maxSupply = _maxSupply;
        heroName = _heroName;
        rareLevel = _rareLevel;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _setBaseURI(string memory baseUri_) public onlyGovernor {
        baseURI = baseUri_;
    }
    
    function grantMinter(address minter) public onlyGovernor {
        _setupRole(MINTER_ROLE, minter);
    }
    function revokeMinter(address minter) public onlyGovernor {
        revokeRole(MINTER_ROLE, minter);
    }
    function createDaoNFT(address to) public onlyMinter returns (uint256) {
        require(totalSupply() < maxSupply, "The limit has been reached");
        uint256 tokenId = _mintDaoNFT(to);
        DaoAttribute memory daoAttribute=DaoAttribute({
            heroName : heroName,
            rareLevel : rareLevel
        });
        tokenIdDaoAttribute[tokenId] = daoAttribute;
        return tokenId;
    }
    function _mintDaoNFT(address to) private returns (uint256) {
        tokenIds.increment();
        uint256 newItemId = tokenIds.current();
        _mint(to, newItemId);
        return newItemId;
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
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
   
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            tokenId > 0 && tokenId <= totalSupply(),
            "URI query for nonexistent token"
        );

        return
            string(
                abi.encodePacked(baseURI,tokenId.toString())
            );
    }

    function tokenOfOwnerPage(
        address owner,
        uint256 pageNumber,
        uint256 pageSize
    ) external view returns (uint256, uint256[] memory) {
        uint256 total = balanceOf(owner);
        uint256 start = pageNumber * pageSize;
        require(start < total, "pageNumber input error");
        uint256 end;
        if (start + pageSize > total) {
            end = total;
        } else {
            end = start + pageSize;
        }
        uint256[] memory _tokenIds = new uint256[](end - start);
        uint256 count = 0;
        for (uint256 i = start; i < end; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(owner, i);
            _tokenIds[count] = tokenId;
            count++;
        }
        return (total, _tokenIds);
    }

}
