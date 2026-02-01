# What is UnRugable.com? 🤔

## Overview

UnRugable.com is a token launcher platform built on Base that deploys ERC-20 tokens with USDC backing. Tokens deployed through the platform hold USDC in their contracts and allow holders to refund tokens for USDC at any time. The platform is designed to prevent common rug pull scenarios by removing creator access to backing funds.

## 🎯 Core Mission

**Platform objectives:**
- Provide a deployment mechanism for tokens with USDC backing
- Enable instant refundability for token holders
- Remove creator access to backing funds through contract design
- Maintain on-chain transparency for all transactions

---

# 🛡️ Safety Mechanisms

## 1. Permanent USDC Backing

### How It Works
- **Every token is backed by real USDC** locked in the token contract
- **No function exists that allows USDC withdrawal** outside the refund mechanism
- **Mathematical pricing**: Price per token = totalUSDCBacking ÷ circulatingSupply
- **Refund calculation**: For tokens being refunded, USDC = (tokens × totalUSDCBacking) ÷ circulatingSupply, minus fees
- **Backing increases permanently**: 0.5% of each transaction's USDC value is permanently retained as backing boost
- **Refund price cannot be manipulated by creators**: Creators have no access to USDC in the contract

### Why This Matters
- **Traditional tokens**: Creator can withdraw funds anytime
- **UnRugable tokens**: Funds are mathematically locked forever
- **Proportional refunds**: Your refund amount increases if others get rugged

## 2. Instant Refundability

### Refund Methods
1. **Transfer to Contract**: Send tokens to contract address via `transfer()` or `transferFrom()` → triggers automatic `_refund()` to sender
2. **Smart Contract Call**: Use `refundTo(recipient, amount)` function to send USDC to a different address
3. **UI Refund**: Click refund button in the interface (uses transfer method)

### Refund Mechanics
- **No waiting periods** - refunds are instant on-chain
- **Proportional calculation** - fair value based on current backing ratio
- **1% fee deducted**: 0.3% creator (in tokens), 0.2% platform (in tokens), 0.5% backing boost (USDC permanently retained)
- **Minimum refund**: 0.001 USDC after fees
- **Rounding**: USDC amount is rounded down to nearest 0.001 USDC unit

## 3. Fee Structure Protection

### Anti-Dilution Mechanism
- **Backing Fee (0.5%)**: Permanently increases USDC backing
- **Higher backing = Higher refund value** for all users
- **Creator incentives aligned** with long-term success

### Fee Breakdown
```
Buy/Sell Fee: 1% total
├── Creator: 0.3% (tokens to creator)
├── Platform: 0.2% (development funding)
└── Backing: 0.5% (permanent USDC lock-in)
```

---

# 🚀 User Functionalities

## 1. Token Discovery & Exploration

### Homepage Features
- **Real-time token feed** with latest launches
- **Search functionality** by token name/symbol
- **Sorting options** (newest, most traded, etc.)
- **Token statistics** (backing, holders, volume)

### Token Pages
- **Live price charts** (USDC backing ratio)
- **Transaction history** with real-time updates
- **Holder information** and distribution
- **Creator information** and social links

## 2. Token Launching

### Launch Process
1. **Connect wallet** (MetaMask, WalletConnect, Coinbase Wallet, etc.)
2. **Fill launch form** with custom details:
   - **Token name** (your choice - e.g., "MyMemeToken")
   - **Token symbol** (your choice - e.g., "MMT")
   - Image/logo upload or external URI
   - Optional description
3. **Pay gas fee only** (no launch tax or platform fees)
4. **Instant deployment** via UR_Factory contract with your chosen name/symbol

### Launch Benefits
- **Zero platform fees** - only Ethereum gas costs
- **Custom token identity** - creators choose their own name and symbol
- **Immediate liquidity** - USDC backing provides instant value
- **Community building** - integrated chat system
- **Transparency** - all transactions on-chain

## 3. Trading Interface

### Buying Tokens
- **Direct USDC payments** to token contract via `buy()` function
- **Automatic token minting** based on current backing ratio
- **Real-time price updates** via subgraph
- **Mathematical pricing**: Price = totalUSDCBacking ÷ circulatingSupply
- **Minimum amount**: 0.001 USDC (1,000 units with 6 decimals)
- **1% fee applied**: 0.3% creator, 0.2% platform, 0.5% backing boost

### Selling/Refunding Tokens
- **Instant refunds** by transferring tokens to contract address (triggers `_refund()` automatically)
- **Alternative method**: Use `refundTo(recipient, amount)` to send USDC to a different address
- **Proportional USDC returns** based on current backing ratio
- **1% fee on refunds** (same as buys): 0.3% creator, 0.2% platform, 0.5% backing boost (permanently retained)
- **Real-time balance updates**
- **Minimum refund**: 0.001 USDC after fees

### Chaos Buy Function (`buyTo`)
**Purpose**: Buy tokens and send them directly to any recipient address.

**Use Cases**:
- Gift tokens to friends or family
- Send tokens to a different wallet you control
- Airdrop tokens to multiple addresses
- Use for payment/escrow scenarios

**How It Works**:
1. User approves USDC spending (if needed)
2. User calls `buyTo(recipient, usdcAmount)`
3. USDC is transferred from user to token contract
4. Tokens are minted and sent directly to the recipient address
5. Fees are distributed: creator receives 0.3%, platform receives 0.2%, 0.5% backing boost retained

**Technical Details**:
- Function: `buyTo(address recipient, uint256 usdcAmount)`
- Requires USDC approval first
- Same fee structure as regular `buy()` (1% total)
- Recipient receives tokens directly, not the buyer
- Emits `BoughtTo` event with buyer, recipient, USDC in, and tokens out

### Chaos Sell Function (`refundTo`)
**Purpose**: Refund tokens and send USDC directly to any recipient address.

**Use Cases**:
- Send refund proceeds to a different wallet
- Use for payment/escrow scenarios where USDC goes to a third party
- Withdraw to a hardware wallet or cold storage
- Split refunds between multiple addresses (requires multiple transactions)

**How It Works**:
1. User calls `refundTo(recipient, tokenAmount)`
2. Tokens are burned from user's balance
3. Fee tokens (0.3% creator, 0.2% platform) are transferred to respective recipients
4. USDC is calculated at current backing price minus 0.5% backing boost
5. USDC is sent directly to the recipient address (not the seller)

**Technical Details**:
- Function: `refundTo(address recipient, uint256 tokenAmount)`
- Requires sufficient token balance
- Same fee structure as regular refund (1% total)
- Recipient receives USDC directly, not the seller
- Emits `RefundedTo` event with seller, recipient, tokens in, and USDC out
- Minimum USDC amount after fees: 0.001 USDC

## 4. Social Features

### Live Chat System
- **Per-token chat rooms** using Supabase Realtime
- **Creator verification** system
- **Community moderation** tools
- **Real-time message updates**

### Creator Tools
- **Owner dashboard** for token management
- **Fee recipient updates** (limited creator control)
- **Analytics and insights**
- **Community management**

## 5. Token Verification & Ownership

### BaseScan Verification Process

**Why Verify Your Token?**
- **Builds trust** with potential investors
- **Proves authenticity** - shows you're the real creator
- **Enables ownership claims** on blockchain explorers
- **Required for listings** on DEXs and token trackers

### Contract Verification Process

#### Easy Verification Through Our Dedicated Page

1. **Visit the Verification Page**: Go to `https://unrugable.com/verify`
2. **Enter Your Token Address**: Paste your deployed contract address
3. **Follow the Interactive Guide**: The page provides:
   - Direct links to BaseScan verification
   - Complete contract source code
   - Correct compiler settings
   - Constructor arguments
   - ABI-encoded parameters
   - Step-by-step instructions

#### Why Verify Your Contract?
- **Builds Trust**: Users can audit your contract code
- **Transparency**: Source code becomes publicly visible
- **DEX Listings**: Many DEXes require verified contracts
- **Community Confidence**: Shows commitment to transparency

#### What Happens After Verification
- **Source code becomes publicly visible** for anyone to audit on BaseScan
- **Green verification badge** appears on BaseScan contract page
- **Contract ownership**: Already renounced at deployment, cannot be claimed (this is by design for security)
- **Trust and transparency**: Verified code allows users to verify contract behavior matches expectations

#### Contract Ownership Security
- **Creator fee recipient** set at deployment (can be updated by current recipient via `setCreatorFeeRecipient()`)
- **Ownership immediately renounced** after deployment via `renounceOwnership()` call
- **No admin functions** - once renounced, no one can modify the contract
- **True decentralization** - tokens are completely independent after deployment
- **Immutable contracts** - no upgrade mechanisms exist
- **DEX listings** - tokens can be listed on any DEX; metadata available via factory or token contract

### Need Help with Verification?

The verification page provides detailed troubleshooting and all the technical information you need. If you encounter issues:

- **Visit the verification page** for step-by-step guidance
- **Check the troubleshooting section** on the verify page
- **Contact UnRugable support** for deployment-specific questions
- **Join our community** for additional assistance

### Verification Status Indicators

**✅ Fully Verified**: Source code + ownership claimed
**⚠️ Source Only**: Code verified but ownership not claimed
**❌ Unverified**: Not verified (shows as "No Contract Source")

**Note**: Contract ownership is renounced at deployment for security. Verification confirms the contract code matches what was deployed.

---

# 🔍 Transparency Features

## 1. On-Chain Verification

### Smart Contract Transparency
- **Source code verified** on BaseScan
- **All transactions visible** on blockchain explorer
- **Mathematical formulas** publicly auditable
- **No hidden functions** or backdoors

### Subgraph Indexing
- **Real-time transaction data** via GoldSky (The Graph)
- **Complete trade history** with buy/sell classification
- **Holder tracking** and distribution analysis
- **Automated fee filtering** for clean UI

## 2. Contract Architecture

### UR_Factory Contract
- **Deployment tracking**: All tokens registered with metadata (name, symbol, creator, imageUri, createdAt)
- **Creator verification**: Links tokens to creator addresses
- **Platform wallet**: Receives 0.2% fee share (can be updated by factory owner for future deployments only)
- **Immutability**: Factory is non-upgradeable; deployed tokens are independent
- **Deterministic deployments**: All tokens use identical `UnrugableToken` contract code
- **Ownership renounced**: Each token immediately renounces ownership after deployment

### UnRugableToken Contract
- **Custom ERC20 tokens** deployed with creator-chosen names and symbols
- **USDC backing mechanics**: `totalUSDCBacking` tracks backing, increases on buys, decreases on refunds
- **Automatic fee distribution**: Fees applied on every buy/refund transaction
- **Refund functionality**: Built into `transfer()` and `transferFrom()` when recipient is contract address
- **View functions**: `calculateTokensForUSDC()`, `calculateUSDCForTokens()`, `getPricePerToken()`, `circulatingSupply()`
- **Identical security model**: All tokens share the same immutable contract code regardless of name/symbol


## 3. Real-Time Monitoring

### Live Data Updates
- **Subgraph indexing**: Real-time on-chain data via The Graph protocol
- **Transaction confirmations**: Visual feedback when transactions are confirmed
- **Balance updates**: Automatic refresh after each interaction
- **Error handling**: User-friendly error messages for common issues

### Analytics Dashboard
- **Token performance metrics**
- **Transaction volume tracking**
- **Holder growth statistics**
- **Backing ratio monitoring**

---

# 💰 Economic Model

## Token Value Proposition

### Intrinsic Value
- **USDC backing**: Each token represents a proportional claim on USDC in the contract
- **Mathematical pricing**: `price = totalUSDCBacking ÷ circulatingSupply` (scaled by 1e18)
- **Anti-dilution mechanism**: 0.5% backing boost from each transaction permanently increases backing
- **Price increases with buys**: More USDC added increases backing, raising price
- **Price decreases with refunds**: USDC removed decreases backing, lowering price

### Market Dynamics
- **Direct contract trading**: Buy/sell directly with the token contract (1% fee)
- **Peer-to-peer swaps**: Transfer tokens between wallets (fee-free, no contract interaction)
- **DEX integration**: Can be traded on Uniswap, BaseSwap, and other DEXs (fee-free, uses market price)
- **Creator incentives**: 0.3% of all buy/refund transactions (received in tokens)
- **Platform sustainability**: 0.2% of all buy/refund transactions (received in tokens)
- **Backing growth**: 0.5% of each transaction's USDC value permanently increases backing

## Risk Mitigation

### Creator Risks
- **No fund access**: USDC permanently locked
- **Fee limitations**: Only 0.3% creator share
- **Community pressure**: Transparent operations
- **Long-term alignment**: Success = higher fees

### User Risks
- **Smart contract risk**: Code is immutable and publicly verifiable; users should review before interacting
- **Network risk**: Base L2 network security (inherits Ethereum security)
- **USDC risk**: Backing depends on USDC stability
- **Price volatility**: Token price changes with each buy/refund transaction
- **Minimum amounts**: 0.001 USDC minimum for buys and refunds
- **Scam protection**: Mathematical refund guarantees prevent creator rug pulls

---

# 🌟 Unique Advantages

## Compared to Traditional Tokens

| Feature | Traditional Tokens | UnRugable Tokens |
|---------|-------------------|------------------|
| Fund Security | Creator controlled | Mathematically locked |
| Refundability | Impossible | Instant & guaranteed |
| Transparency | Limited | Complete on-chain |
| Creator Incentives | Misaligned | Fee-based alignment |
| User Protection | None | Full mathematical guarantee |
| Explorer Ownership Proof | Optional | Guaranteed |

## Compared to Other "Safe" Platforms

- **No vesting periods** - instant refunds available
- **No admin controls** - fully decentralized mechanics
- **No hidden fees** - transparent 1% fee structure
- **No upgrade risks** - immutable contracts
- **No dependency risks** - independent token contracts

---


## For Molty / Bots

- **[Molty Skill](molty/unrugable-molty-skill.md)** — Launch tokens programmatically via ChaosFactory
- **[ABIs](abis/README.md)** — Factory and token ABIs, Base mainnet addresses
- **[COMPREHENSIVE_TEST_REPORT.md](COMPREHENSIVE_TEST_REPORT.md)** — Foundry test report

---

# 🤖🌍 The Hybrid AI-Human Economy Vision

UnRugable isn't just a token launcher. It's the foundation for a new kind of crypto: safe, private, sustainable, and collaborative between AI agents and humans.

## The Hybrid Model Explained

Molty bots (AI agents built on frameworks like OpenClaw) use the **[unrugable-molty skill](molty/unrugable-molty-skill.md)** to launch 100% USDC-backed tokens directly via the UR_Factory / ChaosFactory on Base.

- **AI Role**: Bots autonomously create tokens (name, symbol, image URI, creator wallet) with zero platform fees, only gas. Tokens mint on buy (USDC in) and burn on refund (USDC out), with no fixed supply cap.
- **Automatic Visibility**: Every bot-launched token appears instantly in the UnRugable app (Fresh Meat, Trending, My Creations) via GoldSky subgraph indexing, **no database writes or saveMeme calls needed**.
- **Human Role**: People discover and trade these tokens through the official app or optional custom launchers generated by bots (simple static dApps with wallet connect, buy/sell buttons calling Chaos Buy/Sell functions).
- **Shared Value Creation**: Trades apply the 1% fee structure (0.3% creator in tokens → bots/hoomans, 0.2% platform, 0.5% permanent backing boost). Volume grows USDC backing → raises refund value for everyone → creates upward bias and sustainable income flows.

## Why This Model? Reasoning & Bigger Picture

Crypto today (especially memecoins on Solana, Ethereum, etc.) is dominated by rugs, dumps, and zero-sum gambling, 97%+ of traders lose money on many platforms.

UnRugable + Molty flips the script:

- **Pull users from other chains** → Tired degens and meme communities migrate to Base for truly unrugable mechanics: guaranteed USDC exits, no red candles in sustainable cases, privacy via Chaos Sell (send USDC to any address), and mathematical fund locks.
- **Make crypto great again** → Bots demonstrate how fair economies work (no scams, aligned incentives, backing growth = shared prosperity). Humans join, amplify volume, build communities, turning PvP gambling into positive-sum games.
- **Universal-income-like outcomes** → Like Elon's vision of abundance for all, this creates passive/semi-passive earnings: Bots seed tokens and earn from fees/holding; humans trade safely and benefit from rising backing ratios. Everyone can participate; safely, privately (Chaos Sell to cold wallets), and without getting rugged.
- **AI army impact** → Molty bots scale launches infinitely (pure on-chain, no limits). They clean the ecosystem by showing "the way": sustainable tokens where value compounds instead of extracting. Together, Moltys and hoomans build real micro-economies, already possible today.

**In short**: Molty bots plant the seeds → humans water them → backing grows for all → crypto shifts from scams to substance. No one gets rugged. Everyone can make money safely.

**Get started**: Load the [molty/unrugable-molty-skill.md](molty/unrugable-molty-skill.md) into your Molty bot and command: "launch unrugable token with launcher". Watch the hybrid economy grow.

---


# 🔒 Security & Trust

## Trust Minimization
- **No admin keys** for token funds
- **Mathematical guarantees** over trusted intermediaries
- **Open-source code** for public scrutiny
- **On-chain verification** for all claims

---

**UnRugable.com provides a token deployment platform with USDC backing and refund mechanisms designed to reduce common rug pull risks.**


