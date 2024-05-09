// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BaseAssignment.sol";
import "./INFTminter.sol";

// TODO: inherit BaseAssignment and implement INFTminter.

contract NFTminter_template is ERC721URIStorage, BaseAssignment, INFTminter {
    // Use strings methods directly on variables.
    using Strings for uint256;
    using Strings for address;

    uint256 private _nextTokenId;
    uint256 private _totalSupply;
    uint256 private _price = 0.0001 ether;
    uint256 private constant INITIAL_PRICE = 0.0001 ether;
    uint256 private constant MAX_MINT_COST = 0.05 ether;
    uint256 private constant BURN_FEE = 0.0001 ether;

    bool private _isSaleActive = true;

    // Other variables as needed ...

    constructor()
        BaseAssignment(0x43E66d5710F52A2D0BFADc5752E96f16e62F6a11)
        ERC721("Token", "TKN")
    {
    }

    // mint a nft and send to _address
    function mint(address _address) public payable returns (uint256) {
        // Check if sale is active
        require(_isSaleActive, "Sale is not active");

        uint256 tokenId = _nextTokenId++;
        _totalSupply++;

        // Return token URI
        string memory tokenURI = getTokenURI(tokenId, _address);

        // Mint ...
        require(_price <= MAX_MINT_COST, "Price exceeds maximum minting cost");
        _mint(_address, tokenId);
        _price *= 2;

        // Set encoded token URI to token
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }

    function getTotalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function burn(uint256 tokenId) external payable override {
        // Check if caller is the owner of the token
        require(ownerOf(tokenId) == msg.sender, "Caller is not the owner of the token");

        // Check if the correct burn fee is paid
        require(msg.value >= BURN_FEE, "Insufficient burn fee");

        // Burn the token
        _burn(tokenId);

        // Decrease total supply
        _totalSupply--;

        // Reset the price to 0.0001 ETH
        _price = 0.0001 ether;

    }

    function pauseSale() external override {
        require(isValidator(msg.sender) || msg.sender == getOwner(), "Only the owner or validator can pause the sale");
        _isSaleActive = false;
    }

    function activateSale() external override {
        require(isValidator(msg.sender) || msg.sender == getOwner(), "Only the owner or validator can activate the sale");
        _isSaleActive = true;
    }

    function getSaleStatus() external view override returns (bool) {
        return _isSaleActive;
    }

    function withdraw(uint256 amount) external override {
        require(isValidator(msg.sender) || msg.sender == getOwner(), "Only the owner or validator can withdraw funds");
        sendViaCall(payable(msg.sender), amount);
    }

    function sendViaCall(address payable _to, uint256 amount) internal {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function getPrice() external view override returns (uint256) {
        return _price;
    }

    function getIPFSHash() external pure override returns (string memory) {
        return "QmZKP49Tn1S4rqY3uet1rmMz5DkkpKBpfBcuUTdsjBVBrw";
    }

    /*=============================================
    =                   HELPER                  =
    =============================================*/

    // Get tokenURI for token id
    function getTokenURI(uint256 tokenId, address newOwner)
        public
        view
        returns (string memory)
    {

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "My beautiful artwork #',
            tokenId.toString(),
            '"', 
            '"hash": "',
            // TODO: hash
            "QmZKP49Tn1S4rqY3uet1rmMz5DkkpKBpfBcuUTdsjBVBrw",
            '",', 
            '"by": "',
            // TODO: owner,
            getOwner(),
            '",', 
            '"new_owner": "',
            newOwner,
            '"', 
            "}"
        );

        // Encode dataURI using base64 and return
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    // Get tokenURI for token id using string.concat.
    function getTokenURI2(
        uint256 tokenId,
        address newOwner
    ) public pure returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "My beautiful artwork #',
            tokenId.toString(),
            '"',
            '"hash": "',
            // TODO: hash
            "QmZKP49Tn1S4rqY3uet1rmMz5DkkpKBpfBcuUTdsjBVBrw",
            '",',
            '"by": "',
            // TODO: owner,
            "0x400EA3C2332a7D82be2a74a47319C412b7b53e86",
            '",',
            '"new_owner": "',
            newOwner,
            '"',
            "}"
        );

        // Encode dataURI using base64 and return
        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            );
    }

    // Not actually needed by assignment, but you can try it out
    // to learn about strings.
    function strlen(string memory s) public pure returns (uint) {
        uint len;
        uint i = 0;
        uint bytelength = bytes(s).length;
        for (len = 0; i < bytelength; len++) {
            bytes1 b = bytes(s)[i];
            if (b < 0x80) {
                i += 1;
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
        }
        return len;
    }

}
