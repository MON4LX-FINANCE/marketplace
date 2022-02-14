//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage{

    ///@dev auto-increment per token
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //address of the marketplace
    //https://rwema.io

    address contractAddress;

    constructor(address marketplaceAddress) ERC721("Rwema Tokens", "RWMT"){
        contractAddress = marketplaceAddress;
    }

    ///@notice create new token
    ///@param tokenURI: token URI
    function createToken(string memory tokenURI) public returns(uint) {
        
        ///@dev set new token id to be minted
        _tokenIds.increment(); 
        uint newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId); //mint the token
        _setTokenURI(newItemId, tokenURI);//generate token URI
        setApprovalForAll(contractAddress, true);//generate transaction permission

        //return token id 
        return newItemId;
    }
}