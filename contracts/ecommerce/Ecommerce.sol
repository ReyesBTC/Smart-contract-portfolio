// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9; 

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; //using OpenZeppelin's ERC721 token standard for unique items (NFTs)

contract Ecommerce is ERC721 {
  using Counters for Counters.Counter;
  //Counters is a library. Counter is the struct inside the libreary. this is a library function.
  Counters.Counter private _productId;
  //this makes that datatype into a variable. 

  struct Product {
    string name;
    uint256 productId;
    address payable seller;
    uint256 price; 
    bool forSale;
    string description;
    string image;
    string thumbnail;
  }

  struct SellerProfile {
   string  userName;
   address payable sellerId;
   uint16  age;
   uint256 joined;
   bool active;
   uint256[] sellerProductList; // Store productIds instead of Product structs. Then I can call the Product type Struct with productID and return that. 
  }

  // Variables 
  address public ownerOf;

  mapping(address => SellerProfile) public SellerRegistry;
  mapping(uint256 => SellerProfile) public ProductIdToSellerProfile;
  mapping(uint256 => Product) public ProductIdtoProduct;
  // I know I have to make them lowercase. 
  //Array of all products to return all forsale products. for user to look through items comfortly. 
  uint256[] public allProductIDs;
  //uint256[] public emptyProductArray; // but then every time a product is pushed into it, youll see all sellers products on every sellersprofile. 

  //Fee
  uint256 public registeredSellerFee = 1; // 1%
  uint256 public unregisteredSellerFee = 2; // 2% 

  //Events
  event ProductListed(uint256 productid, address indexed seller, uint256 price);
  event ProductSold(uint256 productid, address indexed seller, address indexed buyer, uint256 price);
  event ProductDelisted(uint256 indexed productid, address indexed seller);
  event ProductUpdated(uint256 indexed productid, address indexed seller, string name, uint256 price, bool forSale, string description, string image, string thumbnail);
  event SellerRegistered(address indexed seller, string userName, uint16 age, uint256 joined);
  event FeePaid(address indexed seller, uint256 fee);

// In Solidity, the indexed keyword is used in the declaration of an event. Up to three parameters can be marked as indexed. Indexed parameters are a special kind of parameter which will not be stored in the data part of the log, but in the topics array, making it possible to filter for specific parameters more efficiently.

constructor() ERC721("Ecommerse", "ECE") { ownerOf = msg.sender; } // initialize ERC721 token with name and symbol

//Given Parameters 
// registerSeller [DONE] -
// getSerllerInfo [DONE] -
// listProduct    [DONE](ERC721) - 
// listProduct Unregistered [DONE](ERC721) -
// getOwnerOfProduct [DONE] -
// getifForSale     [CHECK] -
// removeListing    [CHECK] -
// getPruductforUnregSeller [DONE] searchProductById takes care of all product searches. User doesnt need to know if a product is listed by a regirstered seller or not. 
// getProduct       [DONE]
// addFee           [DONE] - Only sellers should pay. 
// purchaseProduct  [DONE](ERC721)
// upDateListing    [DONE]


function withdraw() public payable {
    require(msg.sender == ownerOf, "Only the contract owner can withdraw funds");
    payable(ownerOf).transfer(address(this).balance);
}

function registerSeller(SellerProfile memory _sellerInfo) public {
    //require to be 18 years old. 
    require(_sellerInfo.age >= 18, "Must be 18 years or older");
    //require to be registered.
    require(!SellerRegistry[msg.sender].active, "Seller already registered");  

    SellerRegistry[msg.sender] = SellerProfile({
      userName: _sellerInfo.userName,
      sellerId: payable (msg.sender), //payable so we can send money to the seller. 
      age: _sellerInfo.age,
      joined: block.timestamp,
      active: true,
      sellerProductList: _sellerInfo.sellerProductList
    });
    //emit event to show that seller was registered.
  emit SellerRegistered(msg.sender, _sellerInfo.userName, _sellerInfo.age, block.timestamp);
}

function getSellerInfo(address _sellerAddress) public view returns (SellerProfile memory) {
    return SellerRegistry[_sellerAddress];
    //TEST by making sure it returns greater than default 00x address. 
    // SellerProfile memory _profile = SellerRegistry[_sellerAddress];
    //adding everying to a variable so we can return everything as variable.example. 
  //   return SellerProfile({
  //   userName: profile.userName,
  //   sellerId: profile.sellerId,
  //   age: profile.age,
  //   joined: profile.joined,
  //   active: profile.active,
  //   products: profile.products
  // });
} 

function listProductRegistered(Product memory _newProduct) public payable {
  require(SellerRegistry[msg.sender].active, "Seller not registered" );
    _productId.increment();
    uint256 productID = _productId.current();

    uint256 fee = _newProduct.price * registeredSellerFee / 100;
    require(msg.value >= fee, "Insufficient funds");
    // it statment based on requires. to make sure it fails and returns "Insufficient funds"
    //event emitting that fee was paid for accounting purposes. 
    payable(address(this)).transfer(fee);
    // Figure out logic to handle that Ether, such as transferring it to another address or storing it in the contract.

    emit FeePaid(msg.sender, fee);

  //Creating the Product Struct & mapping the Product Type Struct so its searchable with the key of productID (uint256)
  ProductIdtoProduct[productID] = Product({
    name: _newProduct.name,
    productId: productID,
    //expect it to have 0 >
    seller: payable (msg.sender), 
    price: _newProduct.price,
    forSale: _newProduct.forSale,
    //will use for TESTING. call function get data expect that somthing comes up. 
    description: _newProduct.description,
    image: _newProduct.image,
    thumbnail: _newProduct.thumbnail
  });
   //Need to check if I need to put this SellerProfile into a variable saved in storage before mapping it... 

    SellerProfile storage _seller = SellerRegistry[msg.sender]; //Getting sellerProfile. has to be storage becuase we will push productID into array inside SellerProfile and making a perm change on the blockchain. 
    ProductIdToSellerProfile[productID] = _seller; // mapps the SellerProfile to the product ID. Can see whos selling a product with key of productID. 
    _seller.sellerProductList.push(productID); // pushing productID into sellerProfile struct. (thats why it has to be storage for this variable.)
    _mint(msg.sender, productID); // mint new token for product and assining the seller(msg.sender) as owner. 
    emit ProductListed(productID, msg.sender, _newProduct.price); // emit
    allProductIDs.push(productID); // After creating a new product, add its ID to the array of all product IDsert
}

function listProductUnRegistered(Product memory _newProduct) public payable {
   require(!SellerRegistry[msg.sender].active, "Seller is registered");
       _productId.increment();
       uint256 productID = _productId.current();
   uint256 fee = _newProduct.price * unregisteredSellerFee / 100;
   require(msg.value >= fee, "Insufficient funds");
   emit FeePaid(msg.sender, fee);
    payable(address(this)).transfer(fee);
   // <address payable>.transfer(uint256 amount)
    //send given amount of Wei to Address, reverts on failure, forwards 2300 gas stipend, not adjustable
   // Figure out logic to handle that Ether, such as transferring it to another address or storing it in the contract.

    //Here im creating the a new struct of Type Product & mapping the Product Struct so its searchavle with thte key of productID (uint256).
     ProductIdtoProduct[productID] = Product({
      name: _newProduct.name,
      productId: productID,
      seller: payable(msg.sender),
      price: _newProduct.price,
      forSale: _newProduct.forSale,
      //will use for testing. 
      description: _newProduct.description,
      image: _newProduct.image,
      thumbnail: _newProduct.thumbnail
    });
    //Need to check if I need to put this SellerProfile into a variable saved in storage before mapping it... 

     _mint(msg.sender, productID); // mint new token for product
    emit ProductListed(productID, msg.sender, _newProduct.price); // emit 
    allProductIDs.push(productID); // After creating a new product, add its ID to the array of all product IDs
}

function getProduct(uint256 _productID) public view returns(Product memory){
  require(ProductIdtoProduct[_productID].seller != address(0), "Product does not exist"); //checks to see if the struct returned is a default value. 
  require(ProductIdtoProduct[_productID].forSale, "Not for Sale");
  return ProductIdtoProduct[_productID];
  //Check that this workds. create TEST. Trying to get a Product Struct with productId. All pruducts should be searchable this way. 

  //make another function to get product even if they arent forsaleforsale false too. 
}

function getOwnerOfProduct(uint256 _productID) public view returns(address) {
  require(ProductIdtoProduct[_productID].seller != address(0), "Product does not exist"); //checks to see if the struct returned is a default value. 
  return ProductIdToSellerProfile[_productID].sellerId;
  // Will only get address becuase not all addresses will have a seller profile. 
  //TEST that it returns an address > than default value. 

}

function removeListing(uint256 _productID) public {
    // Check if the product exists
    require(ProductIdtoProduct[_productID].seller != address(0), "Product does not exist"); 
    // Check if the function caller is the seller of the product
    require(ProductIdtoProduct[_productID].seller == msg.sender, "Not the seller"); 
    // Check if the product is currently for sale
    require(ProductIdtoProduct[_productID].forSale, "Already not for sale"); 

    // Set the product's forSale status to false
    ProductIdtoProduct[_productID].forSale = false; 

    // Loop through the allProductIDs array to find the product to remove
    for (uint256 i = 0; i < allProductIDs.length; i++) {
        // If the product is found
        if (allProductIDs[i] == _productID) {
            // Replace it with the last element in the array
            allProductIDs[i] = allProductIDs[allProductIDs.length - 1];
            //allProductIDs.length - 1 is the index of the last element in the array. In programming, array indices start at 0, so an array with n elements has indices ranging from 0 to n - 1.
            // Remove the last element from the array
            allProductIDs.pop();
            // Exit the loop
            break;
        }
    }

    // Emit an event to indicate that the product has been delisted
    emit ProductDelisted(_productID, msg.sender); 
  }

// Function to remove from platform altogether. 

function getIfForSale(uint256 _productID) public view returns(bool) {
  require(ProductIdtoProduct[_productID].seller != address(0), "Product does not exist"); //checks to see if the struct returned is a default value. 
  return ProductIdtoProduct[_productID].forSale;
    //TESTING return a boolean that is True for the input. 
}

// Buy an item
function purchaseProduct(uint256 _productID) public payable {
  // Check if the product exists
  require(ProductIdtoProduct[_productID].seller != address(0), "Product does not exist"); 
  // Check if the product is for sale
  require(ProductIdtoProduct[_productID].forSale, "Not for Sale");
  // Check if the buyer is not the owner of the product
  require(ProductIdtoProduct[_productID].seller != msg.sender, "Owner cannot buy their own product");
  // Get the product
  Product memory _product = ProductIdtoProduct[_productID]; // get item
  // Check if the buyer sent enough funds
  require(msg.value >= _product.price, "Not enough funds sent"); 
  // Transfer funds to the seller
  _product.seller.transfer(_product.price); 
  // Transfer ownership of the product
  _transfer(_product.seller, msg.sender, _productID); 
  // Emit an event to indicate that the product has been sold
  emit ProductSold(_productID, _product.seller, msg.sender, _product.price); 
}


function getAllProductsForSale() public view returns(Product[] memory) {
  //loop through all products and return only those that are for sale. 
  Product[] memory forSaleProducts = new Product[](allProductIDs.length); // create a new array to hold all the products that are for sale. 
  uint256 count = 0;
  for (uint256 i = 0; i < allProductIDs.length; i++) {
    if (ProductIdtoProduct[allProductIDs[i]].forSale) {
      forSaleProducts[count] = ProductIdtoProduct[allProductIDs[i]];
      count++;
    }
  }
  return forSaleProducts;
}

  function getAllProducts() public view returns(Product[] memory) {
    //loop through all products and return only those that are for sale. 
    Product[] memory allProducts = new Product[](allProductIDs.length); // create a new array to hold all the products that are for sale. 
    uint256 count = 0;
    for (uint256 i = 0; i < allProductIDs.length; i++) {
        allProducts[count] = ProductIdtoProduct[allProductIDs[i]];
        count++;
    }
    return allProducts;
  }

  function getAllProductsForSaleBySeller(address _seller) public view returns(Product[] memory) {
    //loop through all products and return only those that are for sale. 
    Product[] memory forSaleProducts = new Product[](SellerRegistry[_seller].sellerProductList.length); // create a new array to hold all the products that are for sale. 
    uint256 count = 0;
    for (uint256 i = 0; i < SellerRegistry[_seller].sellerProductList.length; i++) {
      if (ProductIdtoProduct[SellerRegistry[_seller].sellerProductList[i]].forSale) {
        forSaleProducts[count] = ProductIdtoProduct[SellerRegistry[_seller].sellerProductList[i]];
        count++;
      }
    }
    return forSaleProducts;
  }


  //Update Listing learn how to update a listing. (Still working on this)
  function upDateListing(Product memory _updatedInfo, uint256 _productID) public returns(string memory) {
    require(msg.sender == ProductIdtoProduct[_productID].seller, "Only the seller can update the listing"); // Only allow the seller to update the listing
    Product storage _product = ProductIdtoProduct[_productID];
     //storage because we are updating info that is stored on the blockchain.
    _product.name = _updatedInfo.name;
    _product.price = _updatedInfo.price;
    _product.forSale = _updatedInfo.forSale;
    _product.description = _updatedInfo.description;
    _product.image =  _updatedInfo.image;
    _product.thumbnail =  _updatedInfo.thumbnail;
    //this should update the old Product struct stored on the block chain with what they inputed in the paramaters and leaves the fields that need to stay the same, the same. 
    emit ProductUpdated(_productID, msg.sender, _updatedInfo.name, _updatedInfo.price, _updatedInfo.forSale, _updatedInfo.description, _updatedInfo.image, _updatedInfo.thumbnail);
    return "Listing Updated";
  }
}