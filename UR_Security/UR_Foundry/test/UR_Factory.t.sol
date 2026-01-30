// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./UR_Factory.sol"; // use the unflattened factory+token you just added

contract UR_FactoryTest is Test {
    address platform = address(0x1001);
    address usdc     = address(0x2002); // dummy address for tests
    address creator  = address(0xC1);

    UR_Factory factory;

    function setUp() public {
        factory = new UR_Factory(platform, usdc);
    }

    // Helper to ensure we always have a non-empty, bounded-length string
    function _sanitizeString(
        string memory s,
        uint256 maxLen,
        string memory fallbackValue
    ) internal pure returns (string memory) {
        bytes memory b = bytes(s);
        if (b.length == 0) {
            return fallbackValue;
        }
        if (b.length > maxLen) {
            bytes memory trimmed = new bytes(maxLen);
            for (uint256 i = 0; i < maxLen; i++) {
                trimmed[i] = b[i];
            }
            return string(trimmed);
        }
        return s;
    }

    function testLaunchWiresTokenParamsAndRenouncesOwnership() public {
        string memory name = "Unrugable Chaos";
        string memory symbol = "URCHAOS";
        string memory image = "ipfs://image";

        address tokenAddr = factory.launch(
            name,
            symbol,
            creator,
            image
        );

        UnrugableToken token = UnrugableToken(tokenAddr);

        // factory wiring
        assertEq(address(token.USDC()), usdc, "USDC address mismatch");
        assertEq(token.creatorFeeRecipient(), creator, "creator fee recipient mismatch");
        assertEq(token.devFeeRecipient(), platform, "dev fee recipient mismatch");

        // ownership should be renounced
        assertEq(token.owner(), address(0), "token owner should be zero");
    }

    function testLaunchRevertsOnEmptyName() public {
        vm.expectRevert("Name required");
        factory.launch("", "SYM", creator, "img");
    }

    function testLaunchRevertsOnEmptySymbol() public {
        vm.expectRevert("Symbol required");
        factory.launch("Name", "", creator, "img");
    }

    function testLaunchRevertsOnZeroCreator() public {
        vm.expectRevert("Invalid creator");
        factory.launch("Name", "SYM", address(0), "img");
    }

    function testLaunchRevertsOnEmptyImageUri() public {
        vm.expectRevert("Image URI required");
        factory.launch("Name", "SYM", creator, "");
    }

    function testLaunchCreatesTokenAndStoresInfo() public {
        string memory name = "Unrugable Chaos";
        string memory symbol = "URCHAOS";
        string memory image = "ipfs://image";

        address tokenAddr = factory.launch(
            name,
            symbol,
            creator,
            image
        );

        assertTrue(tokenAddr != address(0), "Token address should not be zero");

        // Token count updated
        assertEq(factory.tokenCount(), 1);

        // TokenInfo stored correctly
        (address token,
         address creatorStored,
         string memory nameStored,
         string memory symbolStored,
         string memory imageStored,
         uint256 totalSupplyStored,
         uint256 createdAtStored) = factory.tokenInfo(tokenAddr);

        assertEq(token, tokenAddr);
        assertEq(creatorStored, creator);
        assertEq(nameStored, name);
        assertEq(symbolStored, symbol);
        assertEq(imageStored, image);
        assertEq(totalSupplyStored, 0);
        assertGt(createdAtStored, 0);
    }

    function testGetTokensByCreator() public {
        address token1 = factory.launch("A", "A", creator, "img1");
        address token2 = factory.launch("B", "B", creator, "img2");

        address[] memory tokens = factory.getTokensByCreator(creator);
        assertEq(tokens.length, 2);
        assertEq(tokens[0], token1);
        assertEq(tokens[1], token2);
    }

    function testGetAllTokensPagination() public {
        address token1 = factory.launch("A", "A", creator, "img1");
        address token2 = factory.launch("B", "B", creator, "img2");
        address token3 = factory.launch("C", "C", creator, "img3");

        (address[] memory page1, ) = factory.getAllTokens(0, 2);
        assertEq(page1.length, 2);
        assertEq(page1[0], token1);
        assertEq(page1[1], token2);

        (address[] memory page2, ) = factory.getAllTokens(2, 2);
        assertEq(page2.length, 1);
        assertEq(page2[0], token3);
    }

    // ---------- Fuzz tests ----------

    function testFuzz_LaunchStoresCreator(address fuzzCreator) public {
        vm.assume(fuzzCreator != address(0));

        address tokenAddr = factory.launch("Name", "SYM", fuzzCreator, "img");

        (, address creatorStored, , , , , ) = factory.tokenInfo(tokenAddr);
        assertEq(creatorStored, fuzzCreator);
    }

    function testFuzz_LaunchNameAndSymbol(string memory name, string memory symbol) public {
        // Sanitize strings instead of rejecting too many inputs with vm.assume
        string memory safeName = _sanitizeString(name, 32, "N");
        string memory safeSymbol = _sanitizeString(symbol, 16, "S");

        address tokenAddr = factory.launch(safeName, safeSymbol, creator, "img");

        (, , string memory storedName, string memory storedSymbol, , , ) =
            factory.tokenInfo(tokenAddr);

        assertEq(storedName, safeName);
        assertEq(storedSymbol, safeSymbol);
    }
}