pragma solidity ^0.5.0;

import '../AccessControl/AccessControl.sol';
import '../Core/Ownable.sol';

// Define a contract 'Supplychain'
contract SupplyChain is AccessControl, Ownable{

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Milked,                 // 0
    ForSale,                // 1
    Sold,                   // 2
    Shipped,                // 3
    Received,               // 4
    Processed,              // 5
    Packed,                 // 6
    ForSaleByManufacture,   // 7
    SoldByRetailer,         // 8
    ShippedByManufacture,   // 9
    ReceivedByRetailer,     // 10
    ForSaleByRetailer,      // 11
    Purchased               // 12
  }

  State constant defaultState = State.Milked;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
    address payable ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address payable originFarmerID; // Metamask-Ethereum address of the Farmer
    string  originFarmName; // Farmer Name
    string  originFarmInformation;  // Farmer Information
    string  originFarmLatitude; // Farm Latitude
    string  originFarmLongitude;  // Farm Longitude
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address payable manufacturerID;  // Metamask-Ethereum address of the Manufacturer
    address payable retailerID; // Metamask-Ethereum address of the Retailer
    address payable consumerID; // Metamask-Ethereum address of the Consumer
  }

  // Define 13 events with the same 13 state values and accept 'upc' as input argument
  event Milked(uint upc);
  event ForSale(uint upc);
  event Sold(uint upc);
  event Shipped(uint upc);
  event Received(uint upc);
  event Processed(uint upc);
  event Packed(uint upc);
  event ForSaleByManufacture(uint upc);
  event SoldByRetailer(uint upc);
  event ShippedByManufacture(uint upc);
  event ReceivedByRetailer(uint upc);
  event ForSaleByRetailer(uint upc);
  event Purchased(uint upc);

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    items[_upc].consumerID.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of a upc is Milked
  modifier milked(uint _upc) {
    require(items[_upc].itemState == State.Milked);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ForSale
  modifier forSale(uint _upc) {
    require(items[_upc].itemState == State.ForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier sold(uint _upc) {
    require(items[_upc].itemState == State.Sold);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier shipped(uint _upc) {
    require(items[_upc].itemState == State.Shipped);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Received
  modifier received(uint _upc) {
    require(items[_upc].itemState == State.Received);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Processed
  modifier processed(uint _upc) {
    require(items[_upc].itemState == State.Processed);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Packed
  modifier packed(uint _upc) {
    require(items[_upc].itemState == State.Packed);
    _;
  }
  // Define a modifier that checks if an item.state of a upc is ForSale
  modifier forSaleByManufacture(uint _upc) {
    require(items[_upc].itemState == State.ForSaleByManufacture);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier soldByRetailer(uint _upc) {
    require(items[_upc].itemState == State.SoldByRetailer);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier shippedByManufacture(uint _upc) {
    require(items[_upc].itemState == State.ShippedByManufacture);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Received
  modifier receivedByRetailer(uint _upc) {
    require(items[_upc].itemState == State.ReceivedByRetailer);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ForSale
  modifier forSaleByRetailer(uint _upc) {
    require(items[_upc].itemState == State.ForSaleByRetailer);
    _;
  }
  // Define a modifier that checks if an item.state of a upc is Purchased
  modifier purchased(uint _upc) {
    require(items[_upc].itemState == State.Purchased);
    _;
  }

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == owner()) {
      selfdestruct(msg.sender);
    }
  }

  // Define a function 'milkItem' that allows a farmer to mark an item 'Milked'
  function dairyItem(uint _upc, address payable _originFarmerID, string memory _originFarmName, string memory _originFarmInformation, string memory  _originFarmLatitude, string memory  _originFarmLongitude, string memory  _productNotes) public 
  //onlyFarmer()
  {
    // Add the new item as part of Dairy
    items[_upc] = Item({
        sku: sku, 
        upc: _upc, 
        ownerID: _originFarmerID,
        originFarmerID: _originFarmerID,
        originFarmName: _originFarmName,
        originFarmInformation: _originFarmInformation,
        originFarmLatitude: _originFarmLatitude,
        originFarmLongitude: _originFarmLongitude,
        productID: _upc + sku,
        productNotes: _productNotes,
        productPrice: 0,
        itemState: defaultState,
        manufacturerID: address(0),
        retailerID: address(0),
        consumerID: address(0)
    });
    
    // Increment sku
    sku = sku + 1;
    
    // Emit the appropriate event
    emit Milked(_upc);
    
  }

  // Define a function 'sellItem' that allows a farmer to mark an item 'ForSale'
  function sellItem(uint _upc, uint _price) public 
  // Call modifier to check if upc has passed previous supply chain stage
  milked(_upc)
  // Call modifier to verify caller of this function
  verifyCaller(items[_upc].originFarmerID)
  //onlyFarmer()
  {
    // Update the appropriate fields
    items[_upc].itemState = State.ForSale;
    items[_upc].productPrice = _price;
    
    // Emit the appropriate event
    emit ForSale(_upc);
    
  }

  // Define a function 'buyItem' that allows the processor to mark an item 'Sold'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
  // and any excess ether sent is refunded back to the buyer
  function buyItem(uint _upc) public payable 
    // Call modifier to check if upc has passed previous supply chain stage
    forSale(_upc)
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].productPrice)
    // Call modifer to send any excess ether back to buyer
    checkValue(_upc)
    //onlyManufacturer()
  {
    // Update the appropriate fields - ownerID, manufacturerID, itemState
    items[_upc].ownerID = msg.sender;
    items[_upc].manufacturerID = msg.sender;
    items[_upc].itemState = State.Sold;
    
    // Transfer money to farmer
    items[_upc].originFarmerID.transfer(items[_upc].productPrice);
    
    // emit the appropriate event
    emit Sold(_upc);
  }

  // Define a function 'shipItem' that allows the processor to mark an item 'Shipped'
  // Use the above modifers to check if the item is sold
  function shipItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    sold(_upc)
    // Call modifier to verify caller of this function
    verifyCaller(items[_upc].originFarmerID)
    //onlyFarmer()
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Shipped;
    
    // Emit the appropriate event
    emit Shipped(_upc);
    
  }

  // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
  function receiveItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    shipped(_upc) 
    // Access Control List enforced by calling Smart Contract / DApp
    verifyCaller(items[_upc].manufacturerID)
    //onlyManufacturer()
  {
    // Update the appropriate field itemState
    items[_upc].itemState = State.Received;
    
    // Emit the appropriate event
    emit Received(_upc);
    
  }

  // Define a function 'processItem' that allows a processor to mark an item 'Processed'
  function processItem(uint _upc) public 
  // Call modifier to check if upc has passed previous supply chain stage
  received(_upc)
  // Call modifier to verify caller of this function
  verifyCaller(items[_upc].manufacturerID)
  //onlyManufacturer()
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Processed;
    
    // Emit the appropriate event
    emit Processed(_upc);
    
  }

  // Define a function 'packItem' that allows a farmer to mark an item 'Packed'
  function packItem(uint _upc) public 
  // Call modifier to check if upc has passed previous supply chain stage
  processed(_upc)
  // Call modifier to verify caller of this function
  verifyCaller(items[_upc].manufacturerID)
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Packed;
    
    // Emit the appropriate event
    emit Packed(_upc);
    
  }

  // Define a function 'sellItem' that allows a farmer to mark an item 'ForSale'
  function sellItemByManufacture(uint _upc, uint _price) public 
  // Call modifier to check if upc has passed previous supply chain stage
  packed(_upc)
  // Call modifier to verify caller of this function
  verifyCaller(items[_upc].manufacturerID)
  //onlyManufacturer()
  {
    // Update the appropriate fields
    items[_upc].itemState = State.ForSaleByManufacture;
    items[_upc].productPrice = _price;
    
    // Emit the appropriate event
    emit ForSaleByManufacture(_upc);
    
  }

  // Define a function 'buyItem' that allows the processor to mark an item 'Sold'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
  // and any excess ether sent is refunded back to the buyer
  function buyItemByRetailer(uint _upc) public payable 
    // Call modifier to check if upc has passed previous supply chain stage
    forSaleByManufacture(_upc)
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].productPrice)
    // Call modifer to send any excess ether back to buyer
    checkValue(_upc)
    //onlyRetailer()
  {
    // Update the appropriate fields - ownerID, retailerID, itemState
    items[_upc].ownerID = msg.sender;
    items[_upc].retailerID = msg.sender;
    items[_upc].itemState = State.SoldByRetailer;
    
    // Transfer money to farmer
    items[_upc].originFarmerID.transfer(items[_upc].productPrice);
    
    // emit the appropriate event
    emit SoldByRetailer(_upc);
  }

  // Define a function 'shipItem' that allows the processor to mark an item 'Shipped'
  // Use the above modifers to check if the item is sold
  function shipItemByManufacture(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    soldByRetailer(_upc)
    // Call modifier to verify caller of this function
    verifyCaller(items[_upc].manufacturerID)
    //onlyManufacturer()
  {
    // Update the appropriate fields
    items[_upc].itemState = State.ShippedByManufacture;
    
    // Emit the appropriate event
    emit ShippedByManufacture(_upc);
    
  }

  // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
  function receiveItemByRetailer(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    shippedByManufacture(_upc) 
    // Access Control List enforced by calling Smart Contract / DApp
    verifyCaller(items[_upc].retailerID)
    //onlyRetailer()
  {
    // Update the appropriate fields  itemState
    items[_upc].itemState = State.ReceivedByRetailer;
    
    // Emit the appropriate event
    emit ReceivedByRetailer(_upc);
    
  }

  // Define a function 'sellItem' that allows a farmer to mark an item 'ForSale'
  function sellItemByRetailer(uint _upc, uint _price) public 
  // Call modifier to check if upc has passed previous supply chain stage
  receivedByRetailer(_upc)
  // Call modifier to verify caller of this function
  verifyCaller(items[_upc].retailerID)
  //onlyRetailer()
  {
    // Update the appropriate fields
    items[_upc].itemState = State.ForSaleByRetailer;
    items[_upc].productPrice = _price;
    
    // Emit the appropriate event
    emit ForSaleByRetailer(_upc);
    
  }

  // Define a function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
  // Use the above modifiers to check if the item is received
  function purchaseItem(uint _upc) public payable
    // Call modifier to check if upc has passed previous supply chain stage
    forSaleByRetailer(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].productPrice)
    // Call modifer to send any excess ether back to buyer
    checkValue(_upc)
    //onlyConsumer()
  {
    // Update the appropriate fields - ownerID, consumerID, itemState
    items[_upc].ownerID = msg.sender;
    items[_upc].consumerID = msg.sender;
    items[_upc].itemState = State.Purchased;
    
    // Transfer money to farmer
    items[_upc].retailerID.transfer(items[_upc].productPrice);

    // Emit the appropriate event
    emit Purchased(_upc);
    
  }

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originFarmerID,
  string  memory originFarmName,
  string  memory originFarmInformation,
  string  memory originFarmLatitude,
  string  memory originFarmLongitude
  ) 
  {
    // Assign values to the 8 parameters
    Item storage _item = items[_upc];
  
    return ( 
        _item.sku,
        _item.upc,
        _item.ownerID,
        _item.originFarmerID,
        _item.originFarmName,
        _item.originFarmInformation,
        _item.originFarmLatitude,
        _item.originFarmLongitude
    );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  string  memory productNotes,
  uint    productPrice,
  uint    itemState,
  address manufacturerID,
  address retailerID,
  address consumerID
  ) 
  {
    // Assign values to the 9 parameters
    Item storage _item = items[_upc];
  
    return (
        _item.sku,
        _item.upc,
        _item.productID,
        _item.productNotes,
        _item.productPrice,
         uint(_item.itemState),
        _item.manufacturerID,
        _item.retailerID,
        _item.consumerID
    );
  }
}
