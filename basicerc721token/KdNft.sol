// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract KnowledgeDance is ERC721, ERC721Burnable, ERC721Enumerable, Ownable {
    uint256 public mintRate = 0.01 ether;
    uint public maximumSupply = 10;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("KnowledgeDanceNft", "KdNft") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmdmmCSZM4gZJYTN7PaZYCT5TzKmHwy4B4fzEpxsP9Gp6R/";
    }

    function safeMint(address to) public payable {
        require(totalSupply() < maximumSupply, "Mint exhausted.");
        require(msg.value > mintRate, "Insufficient ether sent.");
        _tokenIdCounter.increment(); //start from 1 instead of 0.
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
    }

     // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function withdraw () public onlyOwner{
        require(address(this).balance > 0,"0 ether available for withdrawal.");
        payable(owner()).transfer(address(this).balance);
    }
}