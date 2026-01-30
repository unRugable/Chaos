// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/access/Ownable2Step.sol";
import "openzeppelin/security/ReentrancyGuard.sol";
import "openzeppelin/utils/math/Math.sol";

/**
 * @title UnrugableToken — Pure Eternal Edition with RefundTo (USDC Backed)
 * @notice The final, simplest, fairest, unruggable meme token with refundTo functionality
 * @dev 1% fee on buy & refund → 0.5% stays as backing forever
 * @dev Allows users to refund tokens to any address via refundTo()
 * @dev Backed by USDC (6 decimals) on Base Sepolia
 */
contract UnrugableToken is ERC20, Ownable2Step, ReentrancyGuard {
    address public immutable devFeeRecipient;
    address public creatorFeeRecipient;
    
    // USDC on Base Sepolia: 0x036CbD53842c5426634e7929541eC2318f3dCF7e
    IERC20 public immutable USDC;
    uint256 private constant USDC_DECIMALS = 6;
    uint256 private constant TOKEN_DECIMALS = 18;

    uint256 private _holderCount;
    uint256 private _totalTransfers;

    uint256 private constant CREATOR_FEE_BPS = 30;   // 0.30%
    uint256 private constant DEV_FEE_BPS     = 20;   // 0.20%
    uint256 private constant BACKING_FEE_BPS = 50;   // 0.50%
    uint256 private constant TOTAL_FEE_BPS   = 100;  // 1.00%
    uint256 private constant BPS_DIVISOR     = 10_000;

    // MIN_AMOUNT = 0.01 USDC = 10,000 (6 decimals)
    uint256 public constant MIN_AMOUNT = 10_000; // 0.01 USDC

    uint256 public totalUSDCBacking;

    event Bought(address indexed buyer, uint256 usdcIn, uint256 tokensOut);
    event BoughtTo(address indexed buyer, address indexed recipient, uint256 usdcIn, uint256 tokensOut);
    event Refunded(address indexed seller, uint256 tokensIn, uint256 usdcOut);
    event RefundedTo(address indexed seller, address indexed recipient, uint256 tokensIn, uint256 usdcOut);
    event CreatorFeeRecipientUpdated(address indexed old, address indexed newRecipient);
    event BackingIncreased(uint256 previousBacking, uint256 newBacking);
    event BackingDecreased(uint256 previousBacking, uint256 newBacking);

    constructor(
        address _creator,
        address _devFeeRecipient,
        address _usdc,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        require(_creator != address(0) && _devFeeRecipient != address(0) && _usdc != address(0), "Zero address");
        creatorFeeRecipient = _creator;
        devFeeRecipient = _devFeeRecipient;
        USDC = IERC20(_usdc);
        _holderCount = 0;
    }

    /**
     * @notice Buy tokens with USDC
     * @param usdcAmount Amount of USDC to spend (6 decimals)
     */
    function buy(uint256 usdcAmount) external nonReentrant {
        require(usdcAmount >= MIN_AMOUNT, "Too small");
        require(USDC.transferFrom(msg.sender, address(this), usdcAmount), "USDC transfer failed");
        _buy(msg.sender, usdcAmount);
    }

    /**
     * @notice Buy tokens with USDC and send them to a specified recipient (gift/donation)
     * @param recipient Address to receive the minted tokens
     * @param usdcAmount Amount of USDC to spend (6 decimals)
     */
    function buyTo(address recipient, uint256 usdcAmount) external nonReentrant {
        require(recipient != address(0), "Zero address");
        require(usdcAmount >= MIN_AMOUNT, "Too small");
        require(USDC.transferFrom(msg.sender, address(this), usdcAmount), "USDC transfer failed");
        uint256 tokensToUser = _buy(recipient, usdcAmount);
        emit BoughtTo(msg.sender, recipient, usdcAmount, tokensToUser);
    }

    function _buy(address buyer, uint256 usdcAmount) internal returns (uint256 tokensToUser) {
        // Calculate tokens at backing price
        uint256 tokensAtBackingPrice = _calculateTokensForUSDC(usdcAmount);
        require(tokensAtBackingPrice > 0, "Zero tokens");
        
        // Buy Price = BackingPrice - 0.5%
        uint256 buyPriceTokens = tokensAtBackingPrice - Math.mulDiv(tokensAtBackingPrice, BACKING_FEE_BPS, BPS_DIVISOR);
        
        // From Buy Price: 0.3% creator + 0.2% dev = 0.5% total
        // User gets: Buy Price - 0.5% (total 1% fee: 0.5% backing + 0.5% fees)
        uint256 creatorFee = Math.mulDiv(buyPriceTokens, CREATOR_FEE_BPS, BPS_DIVISOR);
        uint256 devFee     = Math.mulDiv(buyPriceTokens, DEV_FEE_BPS,     BPS_DIVISOR);
        tokensToUser = buyPriceTokens - creatorFee - devFee;

        uint256 oldBacking = totalUSDCBacking;
        totalUSDCBacking += usdcAmount;
        emit BackingIncreased(oldBacking, totalUSDCBacking);

        // Mint only what gets distributed - 0.5% backing fee tokens are NOT minted
        if (tokensToUser > 0) {
            _mint(buyer, tokensToUser);
        }
        if (creatorFee > 0) {
            _mint(creatorFeeRecipient, creatorFee);
        }
        if (devFee > 0) {
            _mint(devFeeRecipient, devFee);
        }
        // The 0.5% backing fee (tokensAtBackingPrice - buyPriceTokens) is never minted
        // This creates the backing boost effect

        emit Bought(buyer, usdcAmount, tokensToUser);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        if (to == address(this)) { _refund(msg.sender, amount); return true; }
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        if (to == address(this)) { _refund(from, amount); return true; }
        return super.transferFrom(from, to, amount);
    }

    /**
     * @notice Refund tokens to a specified address
     * @param recipient Address to receive the USDC from the refund
     * @param tokenAmount Amount of tokens to refund
     */
    function refundTo(address recipient, uint256 tokenAmount) external nonReentrant {
        require(recipient != address(0), "Zero address");
        require(tokenAmount > 0, "Zero tokens");
        require(balanceOf(msg.sender) >= tokenAmount, "Insufficient balance");

        // Step 1: Refund amount - 0.5% (in tokens) = tokens for USDC calculation
        // 0.5% = 0.3% creator + 0.2% dev (in tokens)
        uint256 creatorFeeTokens = Math.mulDiv(tokenAmount, CREATOR_FEE_BPS, BPS_DIVISOR);
        uint256 devFeeTokens     = Math.mulDiv(tokenAmount, DEV_FEE_BPS,     BPS_DIVISOR);
        uint256 tokenFee = creatorFeeTokens + devFeeTokens; // 0.5% total
        uint256 tokensForUSDCCalc = tokenAmount - tokenFee;
        
        // Step 2: Calculate USDC value for net tokens
        uint256 usdcAtBackingPrice = _calculateUSDCForTokens(tokensForUSDCCalc);
        require(usdcAtBackingPrice > 0, "Zero value");
        
        // Step 3: Backing value refund - 0.5% (in USDC) = user gets
        uint256 backingBoostUSDC = Math.mulDiv(usdcAtBackingPrice, BACKING_FEE_BPS, BPS_DIVISOR);
        uint256 usdcNet = usdcAtBackingPrice - backingBoostUSDC;

        require(usdcNet >= MIN_AMOUNT, "Too small");
        require(USDC.balanceOf(address(this)) >= usdcAtBackingPrice, "Insufficient backing");

        // Step 4: Update backing - subtract only what user gets (backingBoostUSDC stays as backing boost)
        uint256 oldBacking = totalUSDCBacking;
        totalUSDCBacking -= usdcNet; // backingBoostUSDC stays in contract
        emit BackingDecreased(oldBacking, totalUSDCBacking);

        // Step 5: Burn tokens directly from seller - no tokens to contract
        _burn(msg.sender, tokenAmount);

        // Step 6: Distribute 0.5% token fee: 0.3% creator + 0.2% dev (in tokens)
        
        if (creatorFeeTokens > 0) {
            _mint(creatorFeeRecipient, creatorFeeTokens);
        }
        if (devFeeTokens > 0) {
            _mint(devFeeRecipient, devFeeTokens);
        }

        // Step 7: backingBoostUSDC (0.5% of usdcAtBackingPrice) stays in contract as backing boost
        // This creates the backing boost effect on sells, just like on buys

        // Step 8: Send user payout to specified recipient
        // Round down to 5th decimal (10,000 = 0.01 USDC) to ensure refunds go through
        uint256 usdcToSend = (usdcNet / 10_000) * 10_000; // Round down to 0.01 USDC precision
        require(USDC.transfer(recipient, usdcToSend), "USDC send failed");

        emit RefundedTo(msg.sender, recipient, tokenAmount, usdcNet);
    }

    function _refund(address seller, uint256 tokenAmount) internal nonReentrant {
        require(tokenAmount > 0, "Zero tokens");

        // Step 1: Refund amount - 0.5% (in tokens) = tokens for USDC calculation
        // 0.5% = 0.3% creator + 0.2% dev (in tokens)
        uint256 creatorFeeTokens = Math.mulDiv(tokenAmount, CREATOR_FEE_BPS, BPS_DIVISOR);
        uint256 devFeeTokens     = Math.mulDiv(tokenAmount, DEV_FEE_BPS,     BPS_DIVISOR);
        uint256 tokenFee = creatorFeeTokens + devFeeTokens; // 0.5% total
        uint256 tokensForUSDCCalc = tokenAmount - tokenFee;
        
        // Step 2: Calculate USDC value for net tokens
        uint256 usdcAtBackingPrice = _calculateUSDCForTokens(tokensForUSDCCalc);
        require(usdcAtBackingPrice > 0, "Zero value");
        
        // Step 3: Backing value refund - 0.5% (in USDC) = user gets
        uint256 backingBoostUSDC = Math.mulDiv(usdcAtBackingPrice, BACKING_FEE_BPS, BPS_DIVISOR);
        uint256 usdcNet = usdcAtBackingPrice - backingBoostUSDC;

        require(usdcNet >= MIN_AMOUNT, "Too small");
        require(USDC.balanceOf(address(this)) >= usdcAtBackingPrice, "Insufficient backing");

        // Step 4: Update backing - subtract the full usdcAtBackingPrice since all USDC leaves
        // (usdcNet goes to user, backingBoostUSDC goes to creator/dev as fees)
        uint256 oldBacking = totalUSDCBacking;
        totalUSDCBacking -= usdcAtBackingPrice;
        emit BackingDecreased(oldBacking, totalUSDCBacking);

        // Step 5: Burn tokens directly from seller - no tokens to contract
        _burn(seller, tokenAmount);

        // Step 6: Distribute 0.5% token fee: 0.3% creator + 0.2% dev (in tokens)
        
        if (creatorFeeTokens > 0) {
            _mint(creatorFeeRecipient, creatorFeeTokens);
        }
        if (devFeeTokens > 0) {
            _mint(devFeeRecipient, devFeeTokens);
        }

        // Step 7: Distribute 0.5% backing boost USDC: 0.3% creator + 0.2% dev (in USDC)
        uint256 creatorFeeUSDC = Math.mulDiv(backingBoostUSDC, CREATOR_FEE_BPS, BPS_DIVISOR);
        uint256 devFeeUSDC     = Math.mulDiv(backingBoostUSDC, DEV_FEE_BPS,     BPS_DIVISOR);
        
        if (creatorFeeUSDC > 0) { 
            require(USDC.transfer(creatorFeeRecipient, creatorFeeUSDC), "Creator fee failed"); 
        }
        if (devFeeUSDC > 0) { 
            require(USDC.transfer(devFeeRecipient, devFeeUSDC), "Dev fee failed"); 
        }

        // Step 8: Send user payout
        // Round down to 5th decimal (10,000 = 0.01 USDC) to ensure refunds go through
        uint256 usdcToSend = (usdcNet / 10_000) * 10_000; // Round down to 0.01 USDC precision
        require(USDC.transfer(seller, usdcToSend), "USDC send failed");

        emit Refunded(seller, tokenAmount, usdcNet);
    }

    // ─────────────────────────────── PRICING (PURE) ───────────────────────────────
    /**
     * @notice Calculate tokens for USDC amount
     * @dev Bootstrap: 1 USDC = 1 token (accounting for 6 vs 18 decimals)
     * @dev After bootstrap: price = totalUSDCBacking / circulatingSupply
     */
    function _calculateTokensForUSDC(uint256 usdcAmount) internal view returns (uint256) {
        uint256 circulating = totalSupply() - balanceOf(address(this));
        if (circulating == 0) {
            // First buy: 1 USDC (6 decimals) = 1 token (18 decimals)
            // Convert: usdcAmount (6 decimals) * 1e18 / 1e6 = usdcAmount * 1e12 tokens
            return (usdcAmount * 1e18) / 1e6;
        }
        // Use CURRENT backing, not backing + new USDC
        // Price = current backing / current supply
        // Convert USDC (6 decimals) to token decimals (18) for calculation
        uint256 price = (totalUSDCBacking * 1e18) / circulating;
        return (usdcAmount * 1e18) / price; // ← ZERO PREMIUM
    }

    /**
     * @notice Calculate USDC for token amount
     * @dev Returns USDC amount in 6 decimals
     */
    function _calculateUSDCForTokens(uint256 tokenAmount) internal view returns (uint256) {
        uint256 circulating = totalSupply() - balanceOf(address(this));
        if (circulating == 0) return 0;
        // Calculate: tokenAmount * totalUSDCBacking / circulating
        // Result is in USDC decimals (6)
        return Math.mulDiv(tokenAmount, totalUSDCBacking, circulating);
    }

    // ─────────────────────────────── VIEW HELPERS ───────────────────────────────
    function calculateTokensForUSDC(uint256 usdcAmount) external view returns (uint256) { 
        return _calculateTokensForUSDC(usdcAmount); 
    }
    function calculateNetTokensForUSDC(uint256 usdcAmount) external view returns (uint256) {
        uint256 gross = _calculateTokensForUSDC(usdcAmount);
        return gross - Math.mulDiv(gross, TOTAL_FEE_BPS, BPS_DIVISOR);
    }
    function calculateUSDCForTokens(uint256 tokenAmount) external view returns (uint256) { 
        return _calculateUSDCForTokens(tokenAmount); 
    }
    function calculateNetUSDCForTokens(uint256 tokenAmount) external view returns (uint256) {
        uint256 gross = _calculateUSDCForTokens(tokenAmount);
        uint256 realExitFee = Math.mulDiv(gross, CREATOR_FEE_BPS + DEV_FEE_BPS, BPS_DIVISOR);
        return gross - realExitFee;
    }
    /**
     * @notice Get price per token in USDC (6 decimals)
     * @dev Returns USDC amount (6 decimals) per 1 token (18 decimals)
     */
    function getPricePerToken() external view returns (uint256) {
        uint256 circulating = totalSupply() - balanceOf(address(this));
        return circulating == 0 ? 0 : (totalUSDCBacking * 1e18) / circulating;
    }
    function circulatingSupply() external view returns (uint256) { return totalSupply() - balanceOf(address(this)); }
    function holderCount() external view returns (uint256) { return _holderCount; }
    function totalTransfers() external view returns (uint256) { return _totalTransfers; }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        if (amount == 0) return;
        if (from != address(0) && from != address(this) && balanceOf(from) == amount) _holderCount -= 1;
        if (to != address(0) && to != address(this) && balanceOf(to) == 0 && amount > 0) _holderCount += 1;
        _totalTransfers += 1;
        super._beforeTokenTransfer(from, to, amount);
    }

    function setCreatorFeeRecipient(address newRecipient) external {
        require(msg.sender == creatorFeeRecipient, "Not creator");
        require(newRecipient != address(0), "Zero addr");
        address old = creatorFeeRecipient;
        creatorFeeRecipient = newRecipient;
        emit CreatorFeeRecipientUpdated(old, newRecipient);
    }
}

