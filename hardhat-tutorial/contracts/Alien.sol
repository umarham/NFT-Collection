//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract Alien is ERC721Enumerable, Ownable {
    string _baseTokenURI;

    uint256 public _price = 0.01 ether;
    //_paused is used to pause the contract in case of emergency
    bool public _paused;
    uint256 public maxTokenIds = 20;
    uint256 public tokenIds;
    IWhitelist whitelist;


    //bpplean to keep tract of when presale started
    bool public presaleStarted;

    //timestamp
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused {
        require(!_paused, "contract currently paused");
        _;
    }

    constructor (string memory baseURI, address whitelistContract) ERC721("Alien", "ALN") {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    //@dev startpresale starts a presale for whitelisted addresses

    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }

    //@dev presalemint allow users to mint one nft per transaction during the presale
    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceeded maximum Alien supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }


    //@dev mint allows an user to mint one NFT per transaction after the presale has ended
    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceed maximum Alien supply");
        require(msg.value >= _price, "Ether sent is not correct");
        _safeMint(msg.sender, tokenIds);
    }


    function _baseURI() internal view  virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // setpaused makes the contract paused or unpaused
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    // withdraw sends all the ether in the contract to the owner of the contract
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}

    fallback() external payable {}

}