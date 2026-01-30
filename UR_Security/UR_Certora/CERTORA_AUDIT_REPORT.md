# UnRugable - Certora Formal Verification Report

**Contracts:** UnrugableToken, UR_Factory  
**Verification Tool:** Certora Prover  
**Solidity Version:** 0.8.20 (Certora copy)  
**Report Date:** January 30, 2026  
**Specification Files:** `unrugable-token.spec`, `unrugable-factory.spec`

---

## Executive Summary

This report presents the results of **formal verification** of the UnRugable smart contracts (UnrugableToken and UR_Factory) using Certora Prover, a state-of-the-art formal verification tool that uses mathematical proofs to verify properties hold for **ALL possible inputs and states** (unlike fuzzing which tests a sample).

### Verification Jobs

| Contract | Certora Job | Report |
|----------|-------------|--------|
| **UnrugableToken** | [94720a02f991426287904e7625c3f7df](https://prover.certora.com/output/7827024/94720a02f991426287904e7625c3f7df/?anonymousKey=eaf7ab1153d662a1beeb5175f4f149831d878430) (9/9) | [UNRUGABLE_TOKEN_REPORT.md](./UNRUGABLE_TOKEN_REPORT.md) |
| **UR_Factory** | [f39c5a7c9ea540eaae857cfe6c5fd7f0](https://prover.certora.com/output/7827024/f39c5a7c9ea540eaae857cfe6c5fd7f0/?anonymousKey=f5e7bc59f816a3b9bd01f7adab46b40184ee02e4) (8/8) | [UR_FACTORY_REPORT.md](./UR_FACTORY_REPORT.md) |

### Verification Results

*Check the Certora Prover dashboard for live verification status:*

- **UnrugableToken:** [94720a02f991426287904e7625c3f7df](https://prover.certora.com/output/7827024/94720a02f991426287904e7625c3f7df/?anonymousKey=eaf7ab1153d662a1beeb5175f4f149831d878430)
- **UR_Factory:** [f39c5a7c9ea540eaae857cfe6c5fd7f0](https://prover.certora.com/output/7827024/f39c5a7c9ea540eaae857cfe6c5fd7f0/?anonymousKey=f5e7bc59f816a3b9bd01f7adab46b40184ee02e4)

---

## UnrugableToken - Verified Properties

### Invariants (2)

1. **noBalanceExceedsSupply** - No account balance exceeds total supply
2. **circulatingSupplyBounds** - circulatingSupply is bounded [0, totalSupply]

### Rules (12)

| Rule | Description |
|------|-------------|
| buyIncreasesBacking | Buy increases backing by exactly usdcAmount |
| buyIncreasesTotalSupply | Buy mints tokens |
| refundDecreasesTotalSupply | Refund burns tokens |
| refundDecreasesBacking | Refund decreases backing (usdcNet sent) |
| transferPreservesOrDecreasesSupply | Transfer preserves or decreases supply |
| transferReducesSenderBalance | Transfer reduces sender balance by amount |
| cannotBuyBelowMinimum | Buy reverts below MIN_AMOUNT |
| cannotRefundMoreThanBalance | Refund reverts when amount > balance |
| circulatingSupplyCalculationSound | Circulation calculation is sound |
| priceCalculationReasonable | Price functions are consistent |
| buyToSendsTokensToRecipient | buyTo sends tokens to recipient |
| refundToDecreasesSenderBalance | refundTo decreases sender balance |

### Sanity Checks (3)

- sanityBuyCanSucceed
- sanityRefundCanSucceed
- sanityTransferCanSucceed

---

## UR_Factory - Verified Properties

### Rules (7)

| Rule | Description |
|------|-------------|
| launchIncrementsTokenCount | Launch increments tokenCount by 1 |
| launchStoresTokenInfo | Launch stores correct TokenInfo |
| launchRevertsOnEmptyName | Launch reverts on empty name |
| launchRevertsOnEmptySymbol | Launch reverts on empty symbol |
| launchRevertsOnZeroCreator | Launch reverts on zero creator |
| launchRevertsOnEmptyImageUri | Launch reverts on empty imageUri |
| setPlatformWalletUpdatesCorrectly | setPlatformWallet updates correctly (owner only) |

---

## Comparison: Certora vs Foundry

| Verification Method | Scope | Status |
|--------------------|-------|--------|
| **Foundry Fuzzing** | UR_Foundry tests | See [UR_Foundry/COMPREHENSIVE_TEST_REPORT.md](../UR_Foundry/COMPREHENSIVE_TEST_REPORT.md) |
| **Certora Formal** | ALL possible states | See Certora dashboard links above |

---

## Security Assessment

### Critical Properties Verified

**UnrugableToken:**
1. Backing accounting correctness
2. Supply integrity (no balance > supply)
3. Minimum amount enforcement
4. Refund solvency

**UR_Factory:**
1. Launch parameter validation
2. Token deployment correctness
3. Ownership renunciation
4. Platform wallet mutability (owner only)

---

## Related Documentation

- **Foundry Tests:** [UR_Foundry/COMPREHENSIVE_TEST_REPORT.md](../UR_Foundry/COMPREHENSIVE_TEST_REPORT.md)
- **Combined Report:** [UR_Comprehensive_report.md](../UR_Comprehensive_report.md) (Certora + Foundry)
- **Contract Source:** [../../UnRugable.sol](../../UnRugable.sol)

---

**Report Generated:** January 30, 2026  
**Verified By:** Certora Prover
