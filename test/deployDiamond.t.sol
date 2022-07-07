// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "@forge-std/Test.sol";
import "../contracts/Diamond.sol";
import "@contracts/interfaces/IERC173.sol";

contract DiamondDeployer is Test, IDiamondCut {
  //contract types of facets to be deployed
  Diamond diamond;
  DiamondCutFacet dCutFacet;
  DiamondLoupeFacet dLoupe;
  OwnershipFacet ownerF;

  address OWNER;
  address constant NOT_OWNER = 0x0000000000000000000000000000000000000001;
  address constant NEW_OWNER = 0x0000000000000000000000000000000000000002;

  function setUp() public {
    dCutFacet = new DiamondCutFacet();
    diamond = new Diamond(address(this), address(dCutFacet));
    dLoupe = new DiamondLoupeFacet();
    ownerF = new OwnershipFacet();

    OWNER = address(this);

    //build cut struct
    FacetCut[] memory cut = new FacetCut[](2);

    cut[0] = (
      FacetCut({
        facetAddress: address(dLoupe),
        action: FacetCutAction.Add,
        functionSelectors: generateSelectors("DiamondLoupeFacet")
      })
    );

    cut[1] = (
      FacetCut({
        facetAddress: address(ownerF),
        action: FacetCutAction.Add,
        functionSelectors: generateSelectors("OwnershipFacet")
      })
    );

    //upgrade diamond
    IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

    //call a function
    DiamondLoupeFacet(address(diamond)).facetAddresses();
  }

  function testDeployDiamond() public {}

  function testOwner() public {
    // console.log(IERC173(address(this)).owner());
    console.log(
      "selector owner()",
      uint256(uint32(IERC173(address(this)).owner.selector))
    );
    assert(IERC173(address(this)).owner() == address(OWNER));
  }

  function generateSelectors(string memory _facetName)
    internal
    returns (bytes4[] memory selectors)
  {
    string[] memory cmd = new string[](4);
    cmd[0] = "npx";
    cmd[1] = "ts-node";
    cmd[2] = "scripts/genSelectors.ts";
    cmd[3] = _facetName;
    console.log(_facetName);
    bytes memory res = vm.ffi(cmd);
    selectors = abi.decode(res, (bytes4[]));
  }

  function diamondCut(
    FacetCut[] calldata _diamondCut,
    address _init,
    bytes calldata _calldata
  ) external override {}
}
