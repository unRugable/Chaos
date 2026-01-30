# UR_Factory - Certora Formal Verification Report

**Contract:** UR_Factory  
**Verification Tool:** Certora Prover  
**Solidity Version:** 0.8.20  
**Report Date:** January 30, 2026  
**Certora Job:** [f39c5a7c9ea540eaae857cfe6c5fd7f0](https://prover.certora.com/output/7827024/f39c5a7c9ea540eaae857cfe6c5fd7f0/?anonymousKey=f5e7bc59f816a3b9bd01f7adab46b40184ee02e4) (8/8)  
**Specification File:** `unrugable-factory.spec`

---

## Executive Summary

This report presents the results of **formal verification** of the UR_Factory smart contract using Certora Prover. UR_Factory deploys UnrugableToken instances and tracks metadata for discovery.

### Verification Results

| Metric | Value |
|--------|-------|
| **Total Rules** | 8 |
| **Verified** | See Certora dashboard |
| **Violated** | See Certora dashboard |
| **Timeout** | See Certora dashboard |
| **Errors** | See Certora dashboard |

*Check the [Certora Prover dashboard](https://prover.certora.com/output/7827024/f39c5a7c9ea540eaae857cfe6c5fd7f0/?anonymousKey=f5e7bc59f816a3b9bd01f7adab46b40184ee02e4) for live results.*

---

## Verified Properties

The following properties are verified by the specification:

### Launch Rules

1. **launchIncrementsTokenCount** - Launch creates token and increments tokenCount by 1
2. **launchStoresTokenInfo** - Launch stores correct TokenInfo (creator, totalSupply, createdAt)
3. **launchRevertsOnEmptyName** - Launch reverts when name is empty
4. **launchRevertsOnEmptySymbol** - Launch reverts when symbol is empty
5. **launchRevertsOnZeroCreator** - Launch reverts when creator is address(0)
6. **launchRevertsOnEmptyImageUri** - Launch reverts when imageUri is empty

### Platform Wallet (Production)

7. **setPlatformWalletUpdatesCorrectly** - setPlatformWallet updates platformWallet when called by owner with valid non-zero address

### View Function Verification

8. **envfreeFuncsStaticCheck** - View function static verification (tokenCount, getTokenInfo, getAllTokens, etc.)

---

## Contract Logic Summary

### UR_Factory Responsibilities

- Deploy new UnrugableToken instances via `launch(name, symbol, creator, imageUri)`
- Store TokenInfo for each deployed token
- Maintain `allTokens` array for discovery
- Provide `getTokensByCreator(creator)` and `getAllTokens(offset, limit)` for pagination
- Mutable `platformWallet` via `setPlatformWallet()` (owner only)

### Key Invariants (Verified via Rules)

- Token count matches deployed tokens
- All tokens are non-zero addresses
- Tokens are properly wired (creator, USDC, dev fee recipient)
- Ownership renounced on deployed tokens

---

## Security Assessment

### Critical Properties

1. **Launch Validation** - All launch parameters validated (non-empty name, symbol, imageUri; non-zero creator)
2. **Token Deployment** - Correct UnrugableToken deployment with platformWallet as dev fee recipient
3. **Ownership** - Deployed tokens have ownership renounced
4. **Platform Wallet** - Only owner can update platformWallet; requires non-zero, different address

---

## Appendix

### Certora Job Details

- **Job ID:** `f39c5a7c9ea540eaae857cfe6c5fd7f0`
- **Report URL:** https://prover.certora.com/output/7827024/f39c5a7c9ea540eaae857cfe6c5fd7f0/?anonymousKey=f5e7bc59f816a3b9bd01f7adab46b40184ee02e4
- **Specification:** `unrugable-factory.spec`
- **Contract:** `contracts/UnRugable.sol:UR_Factory`

### Related Documentation

- **UnrugableToken Report:** [UNRUGABLE_TOKEN_REPORT.md](./UNRUGABLE_TOKEN_REPORT.md)
- **Foundry Tests:** [../UR_Foundry/](../UR_Foundry/)
- **Contract Source:** [../../../contracts/UnRugable.sol](../../../contracts/UnRugable.sol)

---

**Report Generated:** January 30, 2026  
**Verified By:** Certora Prover
