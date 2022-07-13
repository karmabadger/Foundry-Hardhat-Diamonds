// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { IERC173 } from "../interfaces/IERC173.sol";

import "@forge-std/Test.sol";

contract OwnershipFacet is IERC173 {
  function transferOwnership(address _newOwner) external override {
    LibDiamond.enforceIsContractOwner();
    LibDiamond.setContractOwner(_newOwner);
  }

  function owner() external view override returns (address owner_) {
    console.log("owner");
    address owner = LibDiamond.diamondStorage().contractOwner;
    console.log("owner: ", owner);
    owner_ = LibDiamond.contractOwner();
  }
}
