pragma solidity ^0.5.0;

import './FarmerRole.sol';
import './ManufacturerRole.sol';
import './RetailerRole.sol';
import './ConsumerRole.sol';

contract AccessControl is FarmerRole, ManufacturerRole, RetailerRole, ConsumerRole {
    
    constructor() public {
        
    }
    
}