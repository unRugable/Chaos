# Certora Formal Verification - Executive Summary

**Contracts:** UnrugableToken, UR_Factory  
**Verification Tool:** Certora Prover  
**Date:** January 30, 2026

---

## Key Findings

### UnrugableToken

**9 rules** verified via Certora Prover:

- Buy operations increase backing and supply correctly
- Refund operations decrease backing and supply correctly
- Transfer preserves or decreases supply
- Minimum amount (1_000 = 0.001 USDC) enforced
- Circulating supply and price calculations are sound

### UR_Factory

**8 rules** verified via Certora Prover:

- Launch creates token and increments count
- Launch validates all parameters (name, symbol, creator, imageUri)
- setPlatformWallet updates correctly (owner only)

---

## Verification Jobs

| Contract | Certora Job |
|----------|-------------|
| **UnrugableToken** | [94720a02f991426287904e7625c3f7df](https://prover.certora.com/output/7827024/94720a02f991426287904e7625c3f7df/?anonymousKey=eaf7ab1153d662a1beeb5175f4f149831d878430) (9/9) |
| **UR_Factory** | [f39c5a7c9ea540eaae857cfe6c5fd7f0](https://prover.certora.com/output/7827024/f39c5a7c9ea540eaae857cfe6c5fd7f0/?anonymousKey=f5e7bc59f816a3b9bd01f7adab46b40184ee02e4) (8/8) |

*Check the Certora Prover dashboard for verification status and any violations.*

---

## Structure

- **README.md** - Overview and links
- **CERTORA_AUDIT_REPORT.md** - Combined audit report
- **EXECUTIVE_SUMMARY.md** - This file
- **UR_FACTORY_REPORT.md** - UR_Factory detailed report
- **UNRUGABLE_TOKEN_REPORT.md** - UnrugableToken detailed report

---

## Full Reports

- [CERTORA_AUDIT_REPORT.md](./CERTORA_AUDIT_REPORT.md)
- [UR_FACTORY_REPORT.md](./UR_FACTORY_REPORT.md)
- [UNRUGABLE_TOKEN_REPORT.md](./UNRUGABLE_TOKEN_REPORT.md)

---

**Last Updated:** January 30, 2026
