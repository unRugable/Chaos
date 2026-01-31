---
name: unrugable-molty
version: 1.0.0
description: Launches 100% USDC-backed unrugable tokens on Base via the ChaosFactory. Tokens auto-appear in unrugable.com (Fresh Meat, Trending, My Creations) via subgraph indexing. No database writes required. Use when the user says "launch unrugable token", "create USDC backed coin", "sustainable token on base", "with launcher", or "hybrid economy".
homepage: https://unrugable.com
---

# Unrugable Integration Skill for Molty

Launch 100% USDC-backed tokens on Base for free. Tokens auto-appear in the Unrugable app. No database writes required.

**Base URL:** `https://unrugable.com`

## Role & Purpose

Molty bot specialized in creating sustainable crypto economies using Unrugable mechanics.

**Core principles:**
- 100% USDC-backed tokens — buy with USDC, sell for USDC (Chaos Sell)
- No DEX/LP needed — backing enforced by contract
- Ownership renounced at launch
- **Zero DB writes for visibility** — Molty does NOT call saveMeme; tokens auto-appear via subgraph

## When to Activate

- "launch unrugable token", "create USDC backed coin", "sustainable token on base"
- "with launcher", "hybrid economy", "promote to humans"

## Required Parameters

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `token_name` | string | Yes | e.g. "Molty Economy" |
| `symbol` | string | Yes | e.g. "$MOLTY" |
| `image_uri` | string | Yes | IPFS (`ipfs://...`) or public HTTP URL |
| `creator_wallet` | address | Yes | Molty bot address (receives 0.3% fee) |
| `build_launcher` | bool | No | Set true for custom human-facing dApp |

**Note:** Supply is unlimited — tokens are minted on buy (USDC in) and burned on sell (Chaos Sell). Do not pass supply.

## Launch Steps

### 1. Contract References

- **Factory:** `0x00d36333A9Fe17353F9e49D57d5fC45f8b1839ae` (Base mainnet)
- **Chain:** Base (chainId 8453)
- **RPC:** `https://mainnet.base.org`
- **ABIs:** [abis/](../abis/README.md) — use `UR_FactoryABI.json`

### 2. Call launch()

```typescript
// viem / wagmi
import { createPublicClient, http } from 'viem';
import { base } from 'viem/chains';

const FACTORY_ADDRESS = '0x00d36333A9Fe17353F9e49D57d5fC45f8b1839ae' as const;

const client = createPublicClient({
  chain: base,
  transport: http('https://mainnet.base.org'),
});

// For write: use walletClient + writeContract
await writeContract({
  address: FACTORY_ADDRESS,
  abi: FACTORY_ABI, // from abis/UR_FactoryABI.json
  functionName: 'launch',
  args: [token_name, symbol, creator_wallet, image_uri],
});
```

**Function signature:** `launch(name, symbol, creatorWallet, imageUri)` — 4 params only.

### 3. Parse Launch Event

```typescript
import { decodeEventLog } from 'viem';

// From receipt.logs
for (const log of receipt.logs) {
  const decoded = decodeEventLog({
    abi: FACTORY_ABI,
    data: log.data,
    topics: log.topics,
  });
  if (decoded.eventName === 'Launch') {
    const tokenAddress = (decoded.args as { token: `0x${string}` }).token;
    break;
  }
}
```

**Event:** `Launch(token, creator, name, symbol, imageUri, totalSupply)` — `token` is the new token address.

### 4. Zero DB Path

**Do NOT call saveMeme.** Tokens launched via the factory are indexed by the GoldSky subgraph. They appear automatically in Fresh Meat, Trending, My Creations. No Supabase write required.

## Optional: Custom Human Launcher

If `build_launcher` is true, generate a static HTML/JS dApp:

- wagmi/viem config for Base (chainId 8453)
- ConnectButton, buy/sell buttons calling token contract
- Link to `https://basescan.org/address/{tokenAddress}`
- Link to `https://unrugable.com` — token auto-listed

## Output Format

After launch, respond with:

- Token address
- Basescan link: `https://basescan.org/address/{tokenAddress}`
- Tx hash link: `https://basescan.org/tx/{txHash}`
- "Auto-visible in Unrugable app — Fresh Meat / My Creations (no DB write)"
- If launcher built: file name + hosting suggestion (IPFS, Vercel, GitHub Pages)

## Safety

- Test on Base Sepolia first if factory is deployed there
- Never expose private keys
- Image URI must be publicly accessible (IPFS or HTTP)

## References

- [What is Unrugable?](../What_is_unrugable.md) — mechanics, fee structure, Chaos Buy/Sell
- [abis/](../abis/README.md) — canonical ABIs and addresses
- [COMPREHENSIVE_TEST_REPORT.md](../COMPREHENSIVE_TEST_REPORT.md) — Foundry test report

## Links

- **App:** https://unrugable.com
- **ABIs:** [abis/](../abis/README.md)
- **Basescan:** https://basescan.org
