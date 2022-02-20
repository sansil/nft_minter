pragma solidity ^0.8.1;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import {Base64} from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint8 max_mints = 150;

    string svgPartOne =
        "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 -0.5 38 9' shape-rendering='crispEdges'><path stroke='#222034' d='M2 2h1M3 2h32M3  3h1M2 3h1M35 3h1M3 4h1M2 4h1M35 4h1M3  5h1M2 5h1M35 5h1M3 6h32M3'/><path stroke='#323c39' d='M3 3h32'/><path stroke='#494d4c' d='M3 4h32M3 5h32'/><svg x='3' y='2.5' width='32' height='3'><rect fill='";
    string svgPartTwo = "' width='";
    string svgPartThree = "' height='3'/></svg></svg>";

    uint256[] widths = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 32];
    string[] colors = [
        "red",
        "blue",
        "green",
        "yellow",
        "orange",
        "purple",
        "gray",
        "cyan",
        "teal",
        "brown",
        "white"
    ];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("HPlifeNFT", "HPlife") {
        console.log("This is my NFT contract. Woah!");
    }

    modifier canMint() {
        require(_tokenIds.current() < max_mints);
        _;
    }

    function nftsLeft() public view returns (uint256) {
        return max_mints - _tokenIds.current();
    }

    function pickRandomColor(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("COLOR", Strings.toString(tokenId)))
        );
        rand = rand % colors.length;
        return colors[rand];
    }

    function pickRandomWidth(uint256 tokenId) public view returns (uint256) {
        uint256 rand = random(
            string(abi.encodePacked("WIDTH", Strings.toString(tokenId)))
        );
        rand = rand % widths.length;
        return widths[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function makeAnEpicNFT() public canMint {
        uint256 newItemId = _tokenIds.current();
        uint256 randomWidth = pickRandomWidth(newItemId);
        // normalice to 100 hp bar
        string memory combinedWord = string(
            abi.encodePacked(Strings.toString((randomWidth * 100) / 32), " HP")
        );

        string memory randomColor = pickRandomColor(newItemId);

        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                randomColor,
                svgPartTwo,
                Strings.toString(randomWidth),
                svgPartThree
            )
        );
        console.log(finalSvg);

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A collection of HP bars.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        // Update your URI!!!
        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );
        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}
