# UnrugableToken - Certora Formal Verification Report

**Contract:** UnrugableToken  
**Verification Tool:** Certora Prover  
**Solidity Version:** 0.8.20  
**Report Date:** January 30, 2026  
**Certora Job:** [94720a02f991426287904e7625c3f7df](https://prover.certora.com/output/7827024/94720a02f991426287904e7625c3f7df/?anonymousKey=eaf7ab1153d662a1beeb5175f4f149831d878430)  
**Specification File:** `unrugable-token.spec`  
**Result:** 9/9 passed

---

## Executive Summary

This report presents the results of **formal verification** of the UnrugableToken smart contract using Certora Prover. UnrugableToken is a USDC-backed ERC20 with perpetual backing, 1% fees (0.3% creator, 0.2% dev, 0.5% backing boost), and refundTo/buyTo functionality.

### Verification Results

| Metric | Value |
|--------|-------|
| **Total Rules** | 9 |
| **Verified** | 9 |
| **Violated** | 0 |
| **Timeout** | See Certora dashboard |
| **Errors** | See Certora dashboard |

*[Certora Prover dashboard](https://prover.certora.com/output/7827024/94720a02f991426287904e7625c3f7df/?anonymousKey=eaf7ab1153d662a1beeb5175f4f149831d878430)*

## Verified Properties (9 rules)

### Buy Operations

1. **buyIncreasesBacking** - Buy increases totalUSDCBacking by exactly usdcAmount
2. **buyIncreasesTotalSupply** - Buy mints tokens (supply increases)
3. **buyToSendsTokensToRecipient** - buyTo sends tokens to specified recipient
4. **cannotBuyBelowMinimum** - Buy reverts when usdcAmount < MIN_AMOUNT (1_000)

### Refund Operations

5. **refundDecreasesBacking** - Refund decreases backing (usdcNet sent out; backing boost stays)
6. **cannotRefundMoreThanBalance** - Refund reverts when amount > balance

### View Functions

7. **circulatingSupplyCalculationSound** - circulatingSupply bounds are correct
8. **priceCalculationReasonable** - Price calculation functions are consistent
9. **envfreeFuncsStaticCheck** - View/pure functions verified (circulatingSupply, balanceOf, etc.)

---

## Contract Logic Summary

### Fee Structure (1% total)

- 0.3% creator fee
- 0.2% dev fee
- 0.5% backing boost (stays in contract permanently)

### Key Behaviors

- **MIN_AMOUNT:** 1_000 (0.001 USDC)
- **Refund:** Transfer to contract address triggers automatic refund to sender
- **refundTo:** Direct refunds to any address
- **buyTo:** Gift tokens to any address

---

## Security Assessment

### Critical Properties

1. **Backing Accounting** - Backing increases on buy, decreases on refund (usdcNet only)
2. **Supply Integrity** - No balance exceeds supply; circulating supply bounded
3. **Minimum Enforcement** - Buy reverts below MIN_AMOUNT
4. **Refund Solvency** - Refund only when sufficient backing exists

---

## Appendix

### Certora Job Details

- **Job ID:** `94720a02f991426287904e7625c3f7df`
- **Report URL:** https://prover.certora.com/output/7827024/94720a02f991426287904e7625c3f7df/?anonymousKey=eaf7ab1153d662a1beeb5175f4f149831d878430
- **Specification:** `unrugable-token.spec`
- **Contract:** `contracts/UnRugable.sol:UnrugableToken`

### Related Documentation

- **UR_Factory Report:** [UR_FACTORY_REPORT.md](./UR_FACTORY_REPORT.md)
- **Foundry Tests:** [../UR_Foundry/](../UR_Foundry/)
- **Contract Source:** [../../UnRugable.sol](../../UnRugable.sol)

---

**Report Generated:** January 30, 2026  
**Verified By:** Certora Prover
