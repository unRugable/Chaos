# Unrugable Contract ABIs

Public ABIs for Unrugable.com smart contracts. Use these for integrations, bots (e.g., Molty), block explorers, or any external tool that needs to interact with Unrugable tokens on Base.

These interfaces match the audited contracts (Certora + Foundry). See [../COMPREHENSIVE_TEST_REPORT.md](../COMPREHENSIVE_TEST_REPORT.md) for test details.

---

## Base Mainnet Addresses

| Contract | Address | Chain ID |
|----------|---------|----------|
| **Factory (UR_Factory)** | `0x00d36333A9Fe17353F9e49D57d5fC45f8b1839ae` | 8453 |
| **USDC** | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` | 8453 |

**RPC:** `https://mainnet.base.org`  
**Explorer:** https://basescan.org

---

## Files

| File | Description |
|------|-------------|
| `UR_FactoryABI.json` | Factory contract — launch tokens, get token list |
| `UnRugableABI.json` | Token contract — buy, sell (refund), read price/backing |

---

## Usage

### Launch a Token (Factory)

```javascript
// viem / ethers
factory.launch(name, symbol, creatorWallet, imageUri)
```

- **name**: Token name (string)
- **symbol**: Token symbol (string)
- **creatorWallet**: Creator address (receives 0.3% fee on trades)
- **imageUri**: IPFS URI (`ipfs://...`) or HTTP URL for token image

**Event:** `Launch(token, creator, name, symbol, imageUri, totalSupply)` — use `token` for the new token address.

### Buy Tokens (Token Contract)

```javascript
// Approve USDC first, then:
token.buy(usdcAmount)           // Buy for self
token.buyTo(recipient, usdcAmount)  // Buy for another address
```

**Minimum:** 0.001 USDC (1_000 in 6 decimals)

### Sell / Refund (Token Contract)

```javascript
// Chaos Sell: transfer tokens to contract address — auto-refunds USDC to sender
token.transfer(tokenAddress, amount)

// Or send USDC to a specific recipient:
token.refundTo(recipient, tokenAmount)
```

### Read Functions (Token)

- `getPricePerToken()` — price per token (USDC, 6 decimals)
- `totalUSDCBacking()` — total USDC backing
- `circulatingSupply()` — circulating token supply
- `balanceOf(account)` — token balance

---

## GitHub Raw URLs

For programmatic fetching:

```
https://raw.githubusercontent.com/<org>/<repo>/main/app/UR_Security/abis/UR_FactoryABI.json
https://raw.githubusercontent.com/<org>/<repo>/main/app/UR_Security/abis/UnRugableABI.json
```

Replace `<org>` and `<repo>` with your repository path.

---

## Molty Skill

For Molty/OpenClaw bots: [molty/unrugable-molty-skill.md](../molty/unrugable-molty-skill.md)

---

## Token Visibility

Tokens launched via the factory are indexed by the GoldSky subgraph and appear automatically in the Unrugable app (Fresh Meat, Trending, My Creations). No database registration required.
