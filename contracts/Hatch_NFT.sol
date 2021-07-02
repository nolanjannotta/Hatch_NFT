pragma solidity 0.8.0;

import "https://github.com/smartcontractkit/chainlink/blob/2280c334b7c561e01c3f1e64419ceb34f9ace4ce/contracts/src/v0.8/dev/VRFConsumerBase.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/eea376911b32d2c6392496d966e38601c1e762d5/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/3ae911b4421a9f2a4f3483e6fb0a660c31f3fc54/contracts/utils/Counters.sol";

contract HatchNFT is ERC721URIStorage, VRFConsumerBase {
    using Counters for Counters.Counter;
    Counters.Counter public tokenId;
    bytes32 internal keyHash;
    uint256 internal fee;
    uint internal incubationRangeInMinutes;
    
    string[] tempUri = [
    "creature_matadata1", 
    "creature_matadata2",
    "creature_matadata3",
    "creature_matadata4",
    "creature_matadata5",
    "creature_matadata6",
    "creature_matadata7",
    "creature_matadata8",
    "creature_matadata9",
    "creature_matadata10 - (Incubating)"
    ];

    mapping(bytes32 => uint256) public requestIdToTokenId;
    mapping(uint => uint) public tokenIdToHatchTime;
    mapping(uint => uint) public idToIncubationTime;
    mapping(uint => bool) public idToHatched;
    mapping(uint => uint[2]) public IdToRandomNumbers;
    

    constructor(uint _incubationRangeInMinutes) VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709 // LINK Token
        )
        ERC721("HatchNft", "Creature")
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = .1 * 10 ** 18; 
        incubationRangeInMinutes = _incubationRangeInMinutes;
    }

    function createCreature() public {
        tokenId.increment();
        uint _id = tokenId.current();
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestIdToTokenId[requestId] = _id;
        
        string memory initialUri = tempUri[9]; //initally creature is incubating
      
        _safeMint(msg.sender, _id);
        _setTokenURI(_id, initialUri);
  
    }
 
    function hatchNft(uint _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "you cant hatch this NFT");
        require(!idToHatched[_tokenId], "this creature has already hatched");
        require(block.timestamp >= tokenIdToHatchTime[_tokenId], "this creature is not ready to hatch yet :(");
        require(tokenIdToHatchTime[_tokenId] != 0, "this creature is not ready to hatch yet :(");
        
        uint randomCreature = IdToRandomNumbers[_tokenId][1] % 9;
        string memory newUri = tempUri[randomCreature];
        _setTokenURI(_tokenId, newUri);
       
        idToHatched[_tokenId] = true;
    
    }
    
    
    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
        
        uint256 _tokenId = requestIdToTokenId[requestId];
        _expand(randomNumber, _tokenId);
        
        uint incubationMinutes = (IdToRandomNumbers[_tokenId][0] % incubationRangeInMinutes) + 1;
        uint incubationSeconds = incubationMinutes * 60;
        idToIncubationTime[_tokenId] = incubationMinutes;
        tokenIdToHatchTime[_tokenId] = (block.timestamp + incubationSeconds);

    }
    
    function _expand(uint256 _randomValue, uint _tokenId) internal {
        for (uint256 i = 0; i < 2; i++) {
        IdToRandomNumbers[_tokenId][i] = uint256(keccak256(abi.encode(_randomValue, i)));
        }
    }
    
}