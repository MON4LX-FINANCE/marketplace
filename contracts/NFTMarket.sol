//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket  is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemSold; //total number of sold NFTs
    
    //owner of the smart contract
    address payable owner; 

    //charge for placing NFT in marketplace
    uint listingPrice = 0.025 ether; 

    constructor() {
        owner = payable(msg.sender);

    }

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }

    //method to access values of MarketItem struct by using interger ID
    mapping(uint => MarketItem) private idMarketItem;

    //log itemsold message
    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint indexed tokenId,
        address seller,
        address owner,
        uint price,
        bool sold  
    );

    ///@notice Set listing price
    function setListingPrice( uint _price ) public returns (uint){
       if(msg.sender == address(this)){ 
           listingPrice = _price;
        }
        return listingPrice;
    }

    ///@notice Get listing price
    function getListingPrice() public view  returns (uint){
        return listingPrice;
    }

    ///@notice Create marketitem function

    function createMarketItem(
        address nftContract, 
        uint tokenId, 
        uint price) public payable nonReentrant{
            require(price > 0, "Price must above zero");
            require(msg.value == listingPrice, "Price should be equal to listing price");

            _itemIds.increment();
            uint itemId = _itemIds.current();

            idMarketItem[itemId] = MarketItem(
                itemId, 
                nftContract, 
                tokenId, 
                payable(msg.sender),//nft seller address
                payable(address(0)),//nft owner address
                price,
                false
            );

            //transfer ownership of the NFT to the contract
            IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId );

            //log this transaction
            emit MarketItemCreated(
                itemId, 
                nftContract, 
                tokenId, 
                msg.sender, 
                address(0), 
                price, 
                false
            );
        }

        ///@notice Create market sale function
        function createMarketSale(
            address nftContract,
            uint itemId) public payable nonReentrant{
                uint price = idMarketItem[itemId].price;
                uint tokenId = idMarketItem[itemId].tokenId;

                require(msg.value == price, "Please submit the asking price to complete your purchase");
                
                //seller payout
                idMarketItem[itemId].seller.transfer(msg.value);

                //transfer ownership of the NFT to the buyer from the contract
                IERC721(nftContract).transferFrom(address(this), msg.sender,  tokenId );

                //mark new buyer as owner
                idMarketItem[itemId].owner = payable(msg.sender);
                //mark item as sold
                idMarketItem[itemId].owner = payable(msg.sender);
                //increment total number of items sold by 1
                _itemSold.increment();
                //pay contract owner listing price
                payable(owner).transfer(listingPrice);
        }

        ///@notice total number of items unsold on our platform
        function fetchMarketItems() public view returns (MarketItem[] memory){
            //total number of nfts on the platform
            uint itemCount = _itemIds.current(); 
            //total number of nfts that are unsold = total nfts ever created - total nfts sold
            uint unsoldItemCount = _itemIds.current() -  _itemSold.current();
            uint currentIndex = 0;

            MarketItem[] memory items = new MarketItem[](unsoldItemCount);
            for(uint i =0; i < itemCount; i++){
                //get unsold nft
                //loop through all nfts ever minted and check if the nft has not been sold
                if(idMarketItem[i+1].owner == address(0)){
                    //yes this item has never been sold
                    uint currentId = idMarketItem[i + 1].itemId;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
                }
            }
            return items; // return array of all unsold nfts
        }

        ///@notice fetch list of NFTS owned/bought by this user
        function fetchMyNFTs() public view returns (MarketItem[] memory){
            uint totalItemCount = _itemIds.current();
            uint itemCount = 0;
            uint currentIndex = 0;

            for(uint i=0; i < totalItemCount; i++){
                //get only nfts that belong to this user
                if(idMarketItem[i+1].owner == msg.sender){
                    itemCount += 1; //total length

                }
            }
            MarketItem[] memory items = new MarketItem[](itemCount);
            for(uint i =0; i < totalItemCount; i++){
                if(idMarketItem[i+1].owner ==msg.sender){
                    uint currentId = idMarketItem[i+1].itemId;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
                }
            }

            return items;
        }

        ///@notice fetch list of NFTS owned/bought by this user
        function fetchNFTSCreated() public view returns (MarketItem[] memory){
            uint totalItemCount = _itemIds.current();
            uint itemCount = 0;
            uint currentIndex = 0;

            for(uint i=0; i < totalItemCount; i++){
                //get only nfts that belong to this user
                if(idMarketItem[i+1].seller == msg.sender){
                    itemCount += 1; //total length

                }
            }
            MarketItem[] memory items = new MarketItem[](itemCount);
            for(uint i =0; i < totalItemCount; i++){
                if(idMarketItem[i+1].seller ==msg.sender){
                    uint currentId = idMarketItem[i+1].itemId;
                    MarketItem storage currentItem = idMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
                }
            }
            return items;
        }

}

