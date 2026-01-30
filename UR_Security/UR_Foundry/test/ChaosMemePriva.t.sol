// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./UnRugable.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("Mock USDC", "USDC") {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract UnrugableTokenTest is Test {
    MockUSDC usdc;
    UnrugableToken token;

    address creator = address(0xC1);
    address dev     = address(0xD1);
    address user    = address(0x1111);
    address other   = address(0x2222);
    
    function setUp() public {
        usdc = new MockUSDC();
        token = new UnrugableToken(
            creator,
            dev,
            address(usdc),
            "Unrugable Chaos",
            "URCHAOS"
        );

        // fund user with USDC and approve token
        usdc.mint(user, 1_000_000e6); // 1,000,000 USDC (6 decimals)
        vm.prank(user);
        usdc.approve(address(token), type(uint256).max);
    }

    function testBuyIncreasesBackingAndMints() public {
        uint256 amount = token.MIN_AMOUNT(); // 0.01 USDC
        vm.prank(user);
        token.buy(amount);

        // user should now have some tokens
        assertGt(token.balanceOf(user), 0);

        // total backing should have increased by at least 'amount'
        assertEq(token.totalUSDCBacking(), amount);
    }

    function testBuyToSendsTokensToRecipient() public {
        uint256 amount = 100_000e0; // 0.1 USDC
        vm.prank(user);
        token.buyTo(other, amount);

        assertGt(token.balanceOf(other), 0);
        assertEq(token.balanceOf(user), 0);
    }

    function testRefundViaTransferToContract() public {
        uint256 amount = 1_000_000; // 1 USDC
        vm.startPrank(user);
        token.buy(amount);
        uint256 tokenBal = token.balanceOf(user);
        uint256 usdcBefore = usdc.balanceOf(user);

        // selling by transferring tokens to the contract
        token.transfer(address(token), tokenBal);

        uint256 usdcAfter = usdc.balanceOf(user);
        assertGt(usdcAfter, usdcBefore);
        assertEq(token.balanceOf(user), 0);
        vm.stopPrank();
    }

    function testRefundToSendsUSDCToRecipient() public {
        uint256 amount = 1_000_000; // 1 USDC
        vm.startPrank(user);
        token.buy(amount);
        uint256 tokenBal = token.balanceOf(user);

        uint256 usdcBeforeRecipient = usdc.balanceOf(other);

        token.refundTo(other, tokenBal);

        uint256 usdcAfterRecipient = usdc.balanceOf(other);
        assertGt(usdcAfterRecipient, usdcBeforeRecipient);
        assertEq(token.balanceOf(user), 0);
        vm.stopPrank();
    }
}
