// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9; 

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; //using OpenZeppelin's ERC721 token standard for unique items (NFTs)

contract Ecommerce is ERC721 {
  using Counters for Counters.Counter;
  //Counters is a library. Counter is the struct inside the libreary. this is a library function.
  Counters.Counter private _productId;
  //this makes that datatype into a variable. 

  address owner;

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
  // Each argument represents a piece of data that will be included when the event is emitted. These arguments can be of any type that's valid in Solidity, including custom types like structs.

// In Solidity, the indexed keyword is used in the declaration of an event. Up to three parameters can be marked as indexed. Indexed parameters are a special kind of parameter which will not be stored in the data part of the log, but in the topics array, making it possible to filter for specific parameters more efficiently.

constructor() ERC721("Ecommerse", "ECE") { owner = msg.sender; } // initialize ERC721 token with name and symbol

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

function registerSeller(SellerProfile memory _sellerInfo) public {
  require(!SellerRegistry[msg.sender].active, "Already registered");

  // uint256[] storage emptyProductArray = new uint256[](0);
  // you cant copy a memory so it has to be storage array of struct Product to a storage location, which is currently not supported in Solidity. See if I can put this directly into the sellerProductList.

  SellerRegistry[msg.sender] = SellerProfile({
    userName:  _sellerInfo.userName,
    sellerId: payable(msg.sender),
    active: _sellerInfo.active,
    age: _sellerInfo.age,
    joined: _sellerInfo.joined,
    sellerProductList: new uint256[](0) // and this has to be a dynamic array so it cant be initialized inside a funciton. 
    // Empty array w/ no products to push (Learn to initialize an empty array) but isnt an array inside a function only exist in memory? so how is it added to the state variable mapping thats storage?. Default is en empty array so ill leave it out and let it initialize as default. 
  });
   //SellerRegistry[msg.sender] =
  emit SellerRegistered(msg.sender, _sellerInfo.userName, _sellerInfo.age, _sellerInfo.joined);
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
   payable(owner).transfer(msg.value);
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
    allProductIDs.push(productID); // After creating a new product, add its ID to the array of all product IDs

}

function listProductUnRegistered(Product memory _newProduct) public payable {
   require(!SellerRegistry[msg.sender].active, "Seller is registered");
       _productId.increment();
       uint256 productID = _productId.current();
   uint256 fee = _newProduct.price * unregisteredSellerFee / 100;
   require(msg.value >= fee, "Insufficient funds");
   emit FeePaid(msg.sender, fee);
    payable(owner).transfer(msg.value);
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
  require(ProductIdtoProduct[_productID].seller != address(0), "Product does not exist"); //checks to see if the struct returned is a default value. 
  require(ProductIdtoProduct[_productID].seller == msg.sender, "Not the seller"); // Only the seller/owner can 'removelisting' . 
  require(ProductIdtoProduct[_productID].forSale, "Already not for sale"); //

   ProductIdtoProduct[_productID].forSale = false; 
    //TESTING return a boolean that is False. 
  emit ProductDelisted(_productID, msg.sender); // Emit the event
    //Check fenction for expected results. 
}

// Function to remove from platform altogether. 

function getIfForSale(uint256 _productID) public view returns(string memory) {
  require(ProductIdtoProduct[_productID].seller != address(0), "Product does not exist"); //checks to see if the struct returned is a default value. 
  require(ProductIdtoProduct[_productID].forSale, "Not for sale");
    //TESTING return a boolean that is True for the input. 
  return "Yes";
}

 // Buy an item
    function purchaseProduct(uint256 _productID) public payable {
      require(ProductIdtoProduct[_productID].seller != address(0), "Product does not exist"); //checks to see if the struct returned is a default value. 
      require(ProductIdtoProduct[_productID].forSale, "Not for Sale");
        Product memory _product = ProductIdtoProduct[_productID]; // get item
      require(msg.value >= _product.price, "Not enough funds sent"); // require enough ether sent to contract. 
        _product.seller.transfer(_product.price); // transfer funds to seller.
        _transfer(_product.seller, msg.sender, _productID); // _transfer ownership of the token LOOK up ERC721 _transfer(address from, address to, uint256 tokenId) _transer function. // helper function info on openzzeplin. 
        emit ProductSold(_productID, _product.seller, msg.sender, _product.price); // emit event
    }

  // function getAllProductsForSale() public view returns(Product[] memory) {
  // uint256 productCount = 0;
  // uint256[] productForSale;

  // // First count how many products are for sale
  // for (uint i = 0; i < allProductIDs.length; i++) {
  //   //if (ProductIdtoProduct[allProductIDs[i]].forSale) {
  //   //if the .forsale == true we add 1 to the counter. 
  //   uint256 productID = allProdictID[i];
  //   Product memory product = ProductIdtoProduct[productID];
  //   if(product.forsale) {
  //     productForSale.push(product);
  //   }
  //     }
  //     //productCount++;
    

  //  Product[] memory productsForSale = new Product[](productCount);
  //   uint256 counter = 0;
  //   // creating a varable type arrray in memory inside the function so we can push everything into it and then return it. 

  //    // Then retrieve all products that are for sale
  //   for (uint i = 0; i < allProductIDs.length; i++) {
  //     if (ProductIdtoProduct[allProductIDs[i]].forSale) {
  //       productsForSale[counter] = ProductIdtoProduct[allProductIDs[i]];
  //       counter++;
  //     }
  // }
  //   return productForSale;
  // }
    //I would actully use the events i created for this to all be done in the front end. but for the sake of learning, its all onchain. Instead of returning the data directly from the function, i would use the emitted events with the necessary data whenever a product is listed or delisted. Off-chain services or front-end interfaces could then listen for these events and update their own databases accordingly.

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