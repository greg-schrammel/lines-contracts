// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

library Errors {
    string internal constant WrongPrice = "it's 0.01 ETH each";
    string internal constant InvalidKey = "invalid key";
}

contract Lines is ERC721, ReentrancyGuard, Ownable {

  uint256 public constant PRICE = 10000000 gwei;

  constructor (string memory _customBaseURI) ERC721("line", "-") {
    customBaseURI = _customBaseURI;
  }

  // base uri
  string private customBaseURI;
  function changeBaseURI(string memory _customBaseURI) external onlyOwner {
    customBaseURI = _customBaseURI;
  }
  function _baseURI() internal view virtual override returns (string memory) { return customBaseURI; }

  // keys
  mapping(bytes32 => address) internal keys;
  function setKeys(bytes32[] calldata _hashes) external onlyOwner {
    for (uint56 i = 0; i < _hashes.length; i++) {
        keys[_hashes[i]] = address(1);
    }
  }

  // processors
  mapping (uint256 => bytes32[]) public processors;
  uint256 private processorsCount = 0;
  function addProcessor(bytes32[] calldata _processor) public returns (uint256) {
    processors[processorsCount] = _processor;
    return processorsCount++;
  }

  function mint(string calldata key) external payable nonReentrant {
    require(msg.value == PRICE, Errors.WrongPrice);
    require(keys[keccak256(abi.encodePacked(key))] == address(1), Errors.InvalidKey);
    
    keys[keccak256(abi.encodePacked(key))] = tx.origin;
    uint256 seed = uint256(uint160(tx.origin));
    
    _safeMint(_msgSender(), seed);
  }

  function withdraw() public {
    uint256 balance = address(this).balance;
    payable(owner()).transfer(balance);
  }

  // opensea free listing
  address private constant openseaProxyAddress = 0xa5409ec958C83C3f309868babACA7c86DCB077c1;
  // rinkeby 0xf57b2c51ded3a29e6891aba85459d600256cf317

  function isApprovedForAll(address owner, address operator) override public view returns (bool) {
    if (openseaProxyAddress == operator) return true;
    return super.isApprovedForAll(owner, operator);
  }

}





// contract Lines is ERC721, ReentrancyGuard, Ownable {
//   using Counters for Counters.Counter;

//   constructor (string memory customBaseURI_) ERC721("line", "-") {
//     customBaseURI = customBaseURI_;
//   }

//   mapping (uint8 => bytes32) public processors;
//   function addProcessor(bytes32 processorCode);

//   uint256 public constant PRICE = 10000000000000000;
//   Counters.Counter private supplyCounter;

//   mapping(bytes32 => bool) private hashes;

//   function setKeys(bytes32[] calldata _hashes) external onlyOwner {
//     for (uint56 i = 0; i < _hashes.length; i++) {
//         hashes[_hashes[i]] = true;
//     }
//   }

//   function mint(string calldata key) external payable nonReentrant {
//     // require(supplyCounter.current() < MAX_SUPPLY, "sorry we sold out");
//     require(msg.value == PRICE, "it's 0.01 ETH each");
   
//     require(hashes[keccak256(abi.encode(key))] == true, "invalid key");
//     uint160 seed = uint160(tx.origin);
//     _safeMint(_msgSender(), seed);

//     supplyCounter.increment();
//   }

//   string private customBaseURI;

//   function setBaseURI(string memory customBaseURI_) external onlyOwner {
//     customBaseURI = customBaseURI_;
//   }

//   function _baseURI() internal view virtual override returns (string memory) {
//     return customBaseURI;
//   }

//   function withdraw() public {
//     uint256 balance = address(this).balance;

//     payable(owner()).transfer(balance);
//   }

//   // rinkeby 0xf57b2c51ded3a29e6891aba85459d600256cf317
//   address private constant openseaProxyAddress = 0xa5409ec958C83C3f309868babACA7c86DCB077c1;

//   function isApprovedForAll(address owner, address operator)
//     override
//     public
//     view
//     returns (bool)
//   {
//     if (openseaProxyAddress == operator) return true;
//     return super.isApprovedForAll(owner, operator);
//   }
// }
