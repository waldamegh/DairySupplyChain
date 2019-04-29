pragma solidity ^0.5.0;

import './FarmerRole.sol';
import './DistributorRole.sol';
import './RetailerRole.sol';
import './ConsumerRole.sol';

contract AccessControl is FarmerRole, DistributorRole, RetailerRole, ConsumerRole {
    
    constructor() public {
        
    }
    
}