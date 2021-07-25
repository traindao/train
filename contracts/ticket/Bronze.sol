pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Bronze is ERC721 {
    constructor() public ERC721("Bronze ticket", "BRZ") {}

    function issue(
        address recipient,
        uint256 _tokenId
    ) public returns (uint256) {
        _mint(recipient, _tokenId);
        return _tokenId;
    }
}
