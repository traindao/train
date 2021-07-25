//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../random/RandomNumberConsumer.sol";

contract Pool {
    using SafeERC20 for IERC20;
    /// token to collect as a fee deposit for transit
    IERC20 token;
    /// ticket NFT addresses
    IERC721 gold;
    IERC721 silver;
    IERC721 bronze;
    IERC721 gov;
    /// Oracle
    IOracle oracle;
    /// Winning range 
    uint256 range;
    /// operator address
    address operator;
    mapping (address => mapping (bytes32 => uint256) ) public claims;

    constructor(IERC721 _gold, IERC721 _silver, IERC721 _bronze, IOracle _oracle, address _operator) {
        gold = _gold;
        silver = _silver;
        bronze = _bronze;
        operator = _operator; 
        oracle = _oracle;
        range = 10000;
    }  

    function claim(IERC721 token, uint256 _tokenId) public returns (bytes32) {
        // require to have nft ticket
        require(token.ownerOf(_tokenId) == msg.sender, "POOL: Not a ticket owner"); 
        // Burn nft
        token.safeTransferFrom(msg.sender, address(this), _tokenId);
        uint256 winning = getWinning(token);
        // run oracle 
        bytes32 requestId = oracle.request();
        claims[msg.sender][requestId] = winning;
        return requestId;
    }

    function open(IERC721 _token, bytes32 _requestId) public {
        uint256 result = oracle.getResult(_requestId);
        uint256 number = result % range;
        uint256 winning = claims[msg.sender][_requestId];
        require(number > winning, "Lost the round");
        uint256 poolTotal = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, poolTotal);
    }

    function getWinning(IERC721 token) private returns (uint256) {
        // Find out the ticket kind
        if (token == gold) {
            return 7000; 
        } else if(token == silver) {
            return 8500;
        } else if (token == bronze) {
            return 9000;
        } else if (token == gov) {
            return 9200;
        }
    }
}
