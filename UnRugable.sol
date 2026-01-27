// SPDX-License-Identifier: BUSL-1.1

/*
Business Source License 1.1

Parameters
Licensor:              UnRugable.com
Licensed Work:         UnRugable Smart Contract Code
Additional Use Grant:  You may make use of the Licensed Work for auditing, testing, 
                       and non-production purposes only.
Change Date:           2030-12-30
Change License:        Apache License, Version 2.0

For information about alternative licensing arrangements for the Licensed Work,
please contact unrugable.com

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMPORTANT DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SCOPE OF LICENSE:
This license applies ONLY to the UnRugable.com platform smart contract code and 
infrastructure. It does NOT apply to tokens created using the UnRugable.com factory.

TOKEN CREATOR RIGHTS:
- Tokens deployed via UnRugable.com factory are independent works created by their 
  respective token creators
- Token creators retain full ownership and rights to their token names, symbols, 
  branding, and associated intellectual property
- Token creators are solely responsible for their tokens and any claims related to them
- UnRugable.com claims no ownership over user-created tokens

PLATFORM CODE RESTRICTIONS:
- Unauthorized copying, modification, or deployment of the UnRugable.com smart contract 
  code is strictly prohibited without proper licensing
- This includes creating competing platforms or services using this code
- Violations may result in legal action

NO WARRANTIES:
This software is provided "AS IS" without warranty of any kind. UnRugable.com makes 
no representations about the suitability, reliability, or accuracy of this software.
Use at your own risk.

Full license text: https://mariadb.com/bsl11/
*/

pragma solidity ^0.8.31;

/// @title Minimal ERC-20 interface (transfer/approve/allowance)
/// @notice Subset used by `UnrugableToken` to interact with the USDC token contract.
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

/// @dev Provides information about the current execution context (msg.sender).
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

library Math {
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0;
            uint256 prod1;
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / denominator;
            }
            require(denominator > prod1, "Math: mulDiv overflow");
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, twos)
                prod0 := div(prod0, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;
            uint256 inverse = (3 * denominator) ^ 2;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            result = prod0 * inverse;
            return result;
        }
    }
}

/// @title UnrugableToken
/// @notice USDC-backed ERC-20 token with deterministic mint/refund rules and no admin access to backing.
/// @dev The token contract holds USDC; holders can exit by refunding tokens back to this contract.
/// @dev Fees are enforced by the token logic. Creator/dev fees are taken in tokens; a backing boost
///      reduces USDC paid out on refund and is retained as additional backing.
contract UnrugableToken is ERC20, Ownable2Step, ReentrancyGuard {
    /// @notice Address receiving the protocol (platform) fee share, fixed at deployment.
    address public immutable devFeeRecipient;
    /// @notice Address receiving the creator fee share; can be updated by the current creator fee recipient.
    address public creatorFeeRecipient;

    /// @notice The USDC token used as backing for buys and refunds.
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

    /// @notice Minimum USDC unit used for buys and refunds (0.001 USDC).
    uint256 public constant MIN_AMOUNT = 1_000; // 0.001 USDC

    /// @notice Accounting variable tracking backing used for pricing/refunds.
    /// @dev In normal operation this is increased on buys and decreased by the net USDC sent on refunds.
    uint256 public totalUSDCBacking;

    /// @notice Emitted when USDC is deposited and tokens are minted.
    event Bought(address indexed buyer, uint256 usdcIn, uint256 tokensOut);
    /// @notice Emitted when USDC is deposited and tokens are minted to a recipient.
    event BoughtTo(address indexed buyer, address indexed recipient, uint256 usdcIn, uint256 tokensOut);
    /// @notice Emitted when tokens are refunded for USDC back to the seller.
    event Refunded(address indexed seller, uint256 tokensIn, uint256 usdcOut);
    /// @notice Emitted when tokens are refunded for USDC to a specified recipient.
    event RefundedTo(address indexed seller, address indexed recipient, uint256 tokensIn, uint256 usdcOut);
    /// @notice Emitted when the creator fee recipient is changed.
    event CreatorFeeRecipientUpdated(address indexed old, address indexed newRecipient);
    /// @notice Emitted when total backing increases.
    event BackingIncreased(uint256 previousBacking, uint256 newBacking);
    /// @notice Emitted when total backing decreases (net USDC paid out on refund).
    event BackingDecreased(uint256 previousBacking, uint256 newBacking);

    /// @param _creator Initial creator fee recipient.
    /// @param _devFeeRecipient Platform fee recipient (immutable).
    /// @param _usdc USDC token contract address on the deployment network.
    /// @param name ERC-20 name.
    /// @param symbol ERC-20 symbol.
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

    /// @notice Buy tokens by depositing USDC into the token contract.
    /// @param usdcAmount Amount of USDC to deposit (must be >= `MIN_AMOUNT`).
    function buy(uint256 usdcAmount) external nonReentrant {
        require(usdcAmount >= MIN_AMOUNT, "Too small");
        require(USDC.transferFrom(msg.sender, address(this), usdcAmount), "USDC transfer failed");
        _buy(msg.sender, usdcAmount);
    }

    /// @notice Buy tokens by depositing USDC and minting to `recipient`.
    /// @param recipient Address receiving the minted tokens.
    /// @param usdcAmount Amount of USDC to deposit (must be >= `MIN_AMOUNT`).
    function buyTo(address recipient, uint256 usdcAmount) external nonReentrant {
        require(recipient != address(0), "Zero address");
        require(usdcAmount >= MIN_AMOUNT, "Too small");
        require(USDC.transferFrom(msg.sender, address(this), usdcAmount), "USDC transfer failed");
        uint256 tokensToUser = _buy(recipient, usdcAmount);
        emit BoughtTo(msg.sender, recipient, usdcAmount, tokensToUser);
    }

    function _buy(address buyer, uint256 usdcAmount) internal returns (uint256 tokensToUser) {
        uint256 tokensAtBackingPrice = _calculateTokensForUSDC(usdcAmount);
        require(tokensAtBackingPrice > 0, "Zero tokens");

        uint256 buyPriceTokens = tokensAtBackingPrice - Math.mulDiv(tokensAtBackingPrice, BACKING_FEE_BPS, BPS_DIVISOR);

        uint256 creatorFee = Math.mulDiv(buyPriceTokens, CREATOR_FEE_BPS, BPS_DIVISOR);
        uint256 devFee     = Math.mulDiv(buyPriceTokens, DEV_FEE_BPS,     BPS_DIVISOR);
        tokensToUser = buyPriceTokens - creatorFee - devFee;

        uint256 oldBacking = totalUSDCBacking;
        totalUSDCBacking += usdcAmount;
        emit BackingIncreased(oldBacking, totalUSDCBacking);

        if (tokensToUser > 0) _mint(buyer, tokensToUser);
        if (creatorFee > 0) _mint(creatorFeeRecipient, creatorFee);
        if (devFee > 0) _mint(devFeeRecipient, devFee);

        emit Bought(buyer, usdcAmount, tokensToUser);
    }

    /// @notice Standard ERC-20 transfer.
    /// @dev If `to` is this token contract, the transfer is treated as a refund and USDC is paid out.
    function transfer(address to, uint256 amount) public override returns (bool) {
        if (to == address(this)) { _refund(msg.sender, amount); return true; }
        return super.transfer(to, amount);
    }

    /// @notice Standard ERC-20 transferFrom.
    /// @dev If `to` is this token contract, the transfer is treated as a refund and USDC is paid out.
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        if (to == address(this)) { _refund(from, amount); return true; }
        return super.transferFrom(from, to, amount);
    }

    /// @notice Refund tokens for USDC, sending USDC to `recipient`.
    /// @dev Applies fee rules and rounds the USDC amount down to `MIN_AMOUNT`.
    /// @param recipient Address receiving USDC.
    /// @param tokenAmount Amount of tokens to refund.
    function refundTo(address recipient, uint256 tokenAmount) external nonReentrant {
        require(recipient != address(0), "Zero address");
        require(tokenAmount > 0, "Zero tokens");
        require(balanceOf(msg.sender) >= tokenAmount, "Insufficient balance");

        uint256 creatorFeeTokens = Math.mulDiv(tokenAmount, CREATOR_FEE_BPS, BPS_DIVISOR);
        uint256 devFeeTokens     = Math.mulDiv(tokenAmount, DEV_FEE_BPS,     BPS_DIVISOR);
        uint256 tokensForUSDCCalc = tokenAmount - creatorFeeTokens - devFeeTokens;

        uint256 usdcAtBackingPrice = _calculateUSDCForTokens(tokensForUSDCCalc);
        require(usdcAtBackingPrice > 0, "Zero value");

        uint256 backingBoostUSDC = Math.mulDiv(usdcAtBackingPrice, BACKING_FEE_BPS, BPS_DIVISOR);
        uint256 usdcNet = usdcAtBackingPrice - backingBoostUSDC;
        require(usdcNet >= MIN_AMOUNT, "Too small");
        require(USDC.balanceOf(address(this)) >= usdcNet, "Insufficient backing");

        uint256 oldBacking = totalUSDCBacking;
        totalUSDCBacking -= usdcNet; // 0.5% backing boost stays permanently
        emit BackingDecreased(oldBacking, totalUSDCBacking);

        if (creatorFeeTokens > 0) _transfer(msg.sender, creatorFeeRecipient, creatorFeeTokens);
        if (devFeeTokens > 0)     _transfer(msg.sender, devFeeRecipient,     devFeeTokens);

        uint256 tokensToBurn = tokenAmount - creatorFeeTokens - devFeeTokens;
        _burn(msg.sender, tokensToBurn);

        uint256 usdcToSend = (usdcNet / MIN_AMOUNT) * MIN_AMOUNT;
        require(USDC.transfer(recipient, usdcToSend), "USDC send failed");

        emit RefundedTo(msg.sender, recipient, tokenAmount, usdcNet);
    }

    function _refund(address seller, uint256 tokenAmount) internal nonReentrant {
        require(tokenAmount > 0, "Zero tokens");

        uint256 creatorFeeTokens = Math.mulDiv(tokenAmount, CREATOR_FEE_BPS, BPS_DIVISOR);
        uint256 devFeeTokens     = Math.mulDiv(tokenAmount, DEV_FEE_BPS,     BPS_DIVISOR);
        uint256 tokensForUSDCCalc = tokenAmount - creatorFeeTokens - devFeeTokens;

        uint256 usdcAtBackingPrice = _calculateUSDCForTokens(tokensForUSDCCalc);
        require(usdcAtBackingPrice > 0, "Zero value");

        uint256 backingBoostUSDC = Math.mulDiv(usdcAtBackingPrice, BACKING_FEE_BPS, BPS_DIVISOR);
        uint256 usdcNet = usdcAtBackingPrice - backingBoostUSDC;

        require(usdcNet >= MIN_AMOUNT, "Too small");
        require(USDC.balanceOf(address(this)) >= usdcNet, "Insufficient backing");

        uint256 oldBacking = totalUSDCBacking;
        totalUSDCBacking -= usdcNet; // backing boost stays in contract forever
        emit BackingDecreased(oldBacking, totalUSDCBacking);

        if (creatorFeeTokens > 0) _transfer(seller, creatorFeeRecipient, creatorFeeTokens);
        if (devFeeTokens > 0)     _transfer(seller, devFeeRecipient,     devFeeTokens);

        uint256 tokensToBurn = tokenAmount - creatorFeeTokens - devFeeTokens;
        _burn(seller, tokensToBurn);

        uint256 usdcToSend = (usdcNet / MIN_AMOUNT) * MIN_AMOUNT;
        require(USDC.transfer(seller, usdcToSend), "USDC send failed");

        emit Refunded(seller, tokenAmount, usdcNet);
    }

    function _calculateTokensForUSDC(uint256 usdcAmount) internal view returns (uint256) {
        uint256 circulating = totalSupply() - balanceOf(address(this));
        if (circulating == 0) {
            return (usdcAmount * 1e18) / 1e6;
        }
        uint256 price = (totalUSDCBacking * 1e18) / circulating;
        return (usdcAmount * 1e18) / price;
    }

    function _calculateUSDCForTokens(uint256 tokenAmount) internal view returns (uint256) {
        uint256 circulating = totalSupply() - balanceOf(address(this));
        if (circulating == 0) return 0;
        return Math.mulDiv(tokenAmount, totalUSDCBacking, circulating);
    }

    // View helpers
    /// @notice Quote token output for a given USDC deposit at current backing ratio (pre-fee).
    function calculateTokensForUSDC(uint256 usdcAmount) external view returns (uint256) {
        return _calculateTokensForUSDC(usdcAmount);
    }
    /// @notice Quote token output for a given USDC deposit after the token-side fee logic.
    function calculateNetTokensForUSDC(uint256 usdcAmount) external view returns (uint256) {
        uint256 gross = _calculateTokensForUSDC(usdcAmount);
        return gross - Math.mulDiv(gross, TOTAL_FEE_BPS, BPS_DIVISOR);
    }
    /// @notice Quote USDC value for a given token amount at current backing ratio (pre-fee).
    function calculateUSDCForTokens(uint256 tokenAmount) external view returns (uint256) {
        return _calculateUSDCForTokens(tokenAmount);
    }
    /// @notice Quote USDC returned for a refund of `tokenAmount` after fee rules (before MIN_AMOUNT rounding).
    function calculateNetUSDCForTokens(uint256 tokenAmount) external view returns (uint256) {
        uint256 creatorFeeTokens = Math.mulDiv(tokenAmount, CREATOR_FEE_BPS, BPS_DIVISOR);
        uint256 devFeeTokens = Math.mulDiv(tokenAmount, DEV_FEE_BPS, BPS_DIVISOR);
        uint256 tokensAfterFees = tokenAmount - creatorFeeTokens - devFeeTokens;
        uint256 refundTokens = tokensAfterFees - Math.mulDiv(tokensAfterFees, BACKING_FEE_BPS, BPS_DIVISOR);
        return _calculateUSDCForTokens(refundTokens);
    }
    /// @notice Current backing-derived price per token (scaled by 1e18).
    function getPricePerToken() external view returns (uint256) {
        uint256 circulating = totalSupply() - balanceOf(address(this));
        return circulating == 0 ? 0 : (totalUSDCBacking * 1e18) / circulating;
    }
    /// @notice Circulating supply used in pricing and refunds.
    function circulatingSupply() external view returns (uint256) { return totalSupply() - balanceOf(address(this)); }
    /// @notice Count of non-contract holders tracked by the token.
    function holderCount() external view returns (uint256) { return _holderCount; }
    /// @notice Total transfer count tracked by the token (includes buys/refunds via transfer hooks).
    function totalTransfers() external view returns (uint256) { return _totalTransfers; }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        if (amount == 0) return;
        if (from != address(0) && from != address(this) && balanceOf(from) == amount) _holderCount -= 1;
        if (to != address(0) && to != address(this) && balanceOf(to) == 0 && amount > 0) _holderCount += 1;
        _totalTransfers += 1;
        super._beforeTokenTransfer(from, to, amount);
    }

    /// @notice Update the creator fee recipient address.
    /// @dev Only the current `creatorFeeRecipient` may call.
    /// @param newRecipient New recipient address.
    function setCreatorFeeRecipient(address newRecipient) external {
        require(msg.sender == creatorFeeRecipient, "Not creator");
        require(newRecipient != address(0), "Zero addr");
        address old = creatorFeeRecipient;
        creatorFeeRecipient = newRecipient;
        emit CreatorFeeRecipientUpdated(old, newRecipient);
    }
}

/// @title UR_Factory
/// @notice Deploys new `UnrugableToken` instances and tracks basic metadata for discovery.
/// @dev The factory does not custody token backing and does not implement refunds. Each token is self-contained.
contract UR_Factory is Ownable {
    /// @notice Platform fee recipient passed into newly deployed tokens.
    address public platformWallet;
    /// @notice USDC token address used as backing for all deployed tokens (immutable per deployment).
    address public immutable usdcAddress;

    /// @notice List of all token contract addresses deployed by this factory.
    address[] public allTokens;

    /// @notice Token metadata indexed by deployed token address.
    mapping(address => TokenInfo) public tokenInfo;

    /// @notice Metadata recorded at launch time for UI and indexing.
    struct TokenInfo {
        address token;
        address creator;
        string name;
        string symbol;
        string imageUri;
        uint256 totalSupply;
        uint256 createdAt;
    }

    /// @notice Emitted when a new token is deployed.
    event Launch(
        address indexed token,
        address indexed creator,
        string name,
        string symbol,
        string imageUri,
        uint256 totalSupply
    );

    /// @notice Emitted when the platform wallet is updated.
    event PlatformWalletUpdated(address indexed oldWallet, address indexed newWallet);

    /// @param _platformWallet Platform fee recipient for newly deployed tokens.
    /// @param _usdcAddress USDC token address on the deployment network.
    constructor(address _platformWallet, address _usdcAddress) Ownable() {
        require(_platformWallet != address(0), "Invalid platform wallet");
        require(_usdcAddress != address(0), "Invalid USDC address");
        platformWallet = _platformWallet;
        usdcAddress = _usdcAddress;
    }

    /// @notice Update the platform wallet used for future token deployments.
    /// @dev Only callable by the factory owner. Does not affect already-deployed tokens.
    /// @param newPlatformWallet New platform wallet address.
    function setPlatformWallet(address newPlatformWallet) external onlyOwner {
        require(newPlatformWallet != address(0), "Invalid platform wallet");
        require(newPlatformWallet != platformWallet, "Same wallet address");

        address oldWallet = platformWallet;
        platformWallet = newPlatformWallet;

        emit PlatformWalletUpdated(oldWallet, newPlatformWallet);
    }

    /// @notice Deploy a new `UnrugableToken` with the provided metadata.
    /// @dev After deployment, the token immediately renounces ownership to remove privileged control.
    /// @param _name ERC-20 name for the new token.
    /// @param _symbol ERC-20 symbol for the new token.
    /// @param _creatorWallet Creator fee recipient for the new token.
    /// @param _imageUri Off-chain image URI recorded for discovery/UI.
    /// @return token The deployed token contract address.
    function launch(
        string memory _name,
        string memory _symbol,
        address _creatorWallet,
        string memory _imageUri
    ) external returns (address token) {
        require(bytes(_name).length > 0, "Name required");
        require(bytes(_symbol).length > 0, "Symbol required");
        require(_creatorWallet != address(0), "Invalid creator");
        require(bytes(_imageUri).length > 0, "Image URI required");

        UnrugableToken newToken = new UnrugableToken(
            _creatorWallet,
            platformWallet,
            usdcAddress,
            _name,
            _symbol
        );

        token = address(newToken);

        newToken.renounceOwnership();

        tokenInfo[token] = TokenInfo({
            token: token,
            creator: _creatorWallet,
            name: _name,
            symbol: _symbol,
            imageUri: _imageUri,
            totalSupply: 0,
            createdAt: block.timestamp
        });

        allTokens.push(token);

        emit Launch(token, _creatorWallet, _name, _symbol, _imageUri, 0);

        return token;
    }

    function tokenCount() external view returns (uint256) {
        return allTokens.length;
    }

    /// @notice Return all tokens created by a given creator address.
    /// @param creator Creator address used at launch time.
    /// @return tokens Array of token addresses.
    function getTokensByCreator(address creator) external view returns (address[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (tokenInfo[allTokens[i]].creator == creator) count++;
        }
        address[] memory tokens = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (tokenInfo[allTokens[i]].creator == creator) {
                tokens[index++] = allTokens[i];
            }
        }
        return tokens;
    }

    /// @notice Paginated query of deployed tokens and their recorded metadata.
    /// @param offset Starting index into `allTokens`.
    /// @param limit Maximum number of entries to return.
    /// @return tokens Token addresses in the requested range.
    /// @return infos Corresponding `TokenInfo` entries.
    function getAllTokens(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory tokens, TokenInfo[] memory infos)
    {
        uint256 end = offset + limit;
        if (end > allTokens.length) end = allTokens.length;
        uint256 length = end > offset ? end - offset : 0;
        tokens = new address[](length);
        infos = new TokenInfo[](length);
        for (uint256 i = offset; i < end; i++) {
            tokens[i - offset] = allTokens[i];
            infos[i - offset] = tokenInfo[allTokens[i]];
        }
        return (tokens, infos);
    }
}
