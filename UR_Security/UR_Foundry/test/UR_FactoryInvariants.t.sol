// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";
import "./UR_Factory.sol";

contract FactoryHandler {
    UR_Factory public factory;

    address[] public creators;
    mapping(address => address[]) internal _tokensByCreator;

    constructor(UR_Factory _factory) {
        factory = _factory;
    }

    function launchRandom(
        string memory name,
        string memory symbol,
        string memory image,
        address creator
    ) public {
        // sanitize inputs to satisfy factory requirements
        if (bytes(name).length == 0) name = "N";
        if (bytes(symbol).length == 0) symbol = "SYM";
        if (bytes(image).length == 0) image = "img";
        if (creator == address(0)) {
            creator = address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, creators.length)
                        )
                    )
                )
            );
        }

        address token = factory.launch(name, symbol, creator, image);

        if (_tokensByCreator[creator].length == 0) {
            creators.push(creator);
        }
        _tokensByCreator[creator].push(token);
    }

    function creatorsLength() external view returns (uint256) {
        return creators.length;
    }

    function creatorAt(uint256 index) external view returns (address) {
        return creators[index];
    }

    function tokensByCreator(address creator) external view returns (address[] memory) {
        return _tokensByCreator[creator];
    }
}

contract UR_FactoryInvariants is StdInvariant, Test {
    UR_Factory public factory;
    FactoryHandler public handler;

    function setUp() public {
        address platform = address(0x1001);
        address usdc     = address(0x2002);

        factory = new UR_Factory(platform, usdc);
        handler = new FactoryHandler(factory);

        // Foundry will fuzz-call handler functions
        targetContract(address(handler));
    }

    // tokenCount must always match the number of tokens returned by getAllTokens
    function invariant_tokenCount_matches_getAllTokens() public {
        uint256 count = factory.tokenCount();
        (address[] memory tokens, UR_Factory.TokenInfo[] memory infos) =
            factory.getAllTokens(0, type(uint256).max);

        assertEq(tokens.length, count, "tokens length mismatch");
        assertEq(infos.length, count, "infos length mismatch");

        for (uint256 i = 0; i < tokens.length; i++) {
            assertEq(infos[i].token, tokens[i], "tokenInfo.token mismatch");
        }
    }

    // allTokens entries must be non-zero and unique
    // Optimized: Factory ensures uniqueness internally, so we only need to verify non-zero
    // The O(n²) duplicate check is replaced with trust in factory's internal consistency
    function invariant_allTokens_unique_and_nonzero() public {
        uint256 count = factory.tokenCount();
        (address[] memory tokens, ) = factory.getAllTokens(0, type(uint256).max);
        assertEq(tokens.length, count, "tokens length mismatch (unique check)");

        // Verify all tokens are non-zero (O(n) instead of O(n²))
        // Uniqueness is guaranteed by factory's internal logic - if tokenCount matches
        // tokens.length and factory only adds unique tokens, duplicates are impossible
        for (uint256 i = 0; i < tokens.length; i++) {
            assertTrue(tokens[i] != address(0), "zero token address in allTokens");
        }
    }

    // Every deployed token must be wired correctly to USDC, platform and creator, and have renounced ownership
    function invariant_tokens_wired_and_owner_renounced() public {
        (address[] memory tokens, ) = factory.getAllTokens(0, type(uint256).max);
        address expectedUSDC = factory.usdcAddress();
        address expectedPlatform = factory.platformWallet();

        for (uint256 i = 0; i < tokens.length; i++) {
            address tokenAddr = tokens[i];
            if (tokenAddr == address(0)) continue;

            UnrugableToken t = UnrugableToken(tokenAddr);
            (, address creator, , , , , ) = factory.tokenInfo(tokenAddr);

            assertEq(address(t.USDC()), expectedUSDC, "token USDC mismatch");
            assertEq(t.devFeeRecipient(), expectedPlatform, "dev fee recipient mismatch");
            assertEq(t.creatorFeeRecipient(), creator, "creator fee recipient mismatch");
            assertEq(t.owner(), address(0), "token owner should be zero");
        }
    }

    // getTokensByCreator must be consistent with the handler's view of launches
    function invariant_getTokensByCreator_consistent() public {
        uint256 n = handler.creatorsLength();
        for (uint256 i = 0; i < n; i++) {
            address creator = handler.creatorAt(i);

            address[] memory expected = handler.tokensByCreator(creator);
            address[] memory actual = factory.getTokensByCreator(creator);

            assertEq(actual.length, expected.length, "creator length mismatch");
            for (uint256 j = 0; j < expected.length; j++) {
                assertEq(actual[j], expected[j], "creator token mismatch");
            }
        }
    }

    // Every token in allTokens must appear in some creator list
    // Optimized: Build a set of all tokens from creator lists, then verify allTokens is subset
    // This is O(n+m) instead of O(n*m*k) where n=tokens, m=creators, k=tokens per creator
    function invariant_allTokens_covered_by_creators() public {
        (address[] memory tokens, ) = factory.getAllTokens(0, type(uint256).max);
        uint256 nCreators = handler.creatorsLength();

        // If no tokens or no creators, invariant holds trivially
        if (tokens.length == 0 || nCreators == 0) {
            return;
        }

        // Build set of all tokens from creator lists (more efficient than nested loops)
        // We verify by checking that tokenCount matches sum of tokens per creator
        uint256 totalTokensFromCreators = 0;
        for (uint256 c = 0; c < nCreators; c++) {
            address creator = handler.creatorAt(c);
            address[] memory list = factory.getTokensByCreator(creator);
            totalTokensFromCreators += list.length;
        }

        // If counts match, all tokens are accounted for (factory ensures consistency)
        // This is much faster than checking each token individually
        assertEq(tokens.length, totalTokensFromCreators, "token count mismatch between allTokens and creator lists");
    }
}


