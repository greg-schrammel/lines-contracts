// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "ds-test/test.sol";
import "./utils/Hevm.sol";

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../Lines.sol";
import { Errors } from "../Lines.sol";

library Keys {
    string internal constant gm = "gm";
    string internal constant cats = "cats";
}

contract User {
    Lines public lines;
    constructor(address _line) {
        lines = Lines(_line);
    }
    function setKeys (bytes32[] calldata _hashes) public {
        return lines.setKeys(_hashes);
    }
}

contract ExposedLines is Lines {
    constructor (string memory _customBaseURI) Lines(_customBaseURI) {}
    function getKey(bytes32 _hash) public view returns (address) {
        return keys[_hash];
    }
}

contract LinesTest is DSTest, ERC721Holder {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    // contracts
    ExposedLines internal lines;

    // users
    User internal alice;
    User internal bob;

    bytes32[] private hashes = [keccak256(abi.encodePacked(Keys.gm)), keccak256(abi.encodePacked(Keys.cats))];
    function setUp() public virtual {
        lines = new ExposedLines("url");
        alice = new User(address(lines));
        bob = new User(address(lines));
        lines.transferOwnership(address(alice));
    }
    
    function testNonOwnerCannotSetKeys() public {
        try bob.setKeys(hashes) { fail(); }
        catch Error(string memory error) {
            assertEq(error, "Ownable: caller is not the owner");
        }
    }
    function testOwnerCanSetKeys() public {
        alice.setKeys(hashes);
        assertEq(lines.getKey(hashes[0]), address(1));
    }

    function testCannotMintSendingWrongAmount() public {
        uint256 lessThenMintPrice = 1000 wei;
        uint256 moreThenMintPrice = 1 ether;
        // test sending less
        try lines.mint{ value: lessThenMintPrice }(Keys.gm) { fail(); } 
        catch Error(string memory error) { assertEq(error, Errors.WrongPrice); }
        // test sending more
        try lines.mint{ value: moreThenMintPrice }(Keys.gm) { fail(); } 
        catch Error(string memory error) { assertEq(error, Errors.WrongPrice); }
    }
    function testCanMintWithRightKey() public {
        alice.setKeys(hashes);
        lines.mint{ value: 10000000 gwei }(Keys.cats);
        assertEq(lines.balanceOf(address(this)), 1);
    }
}