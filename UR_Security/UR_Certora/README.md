# UnRugable - Certora Formal Verification

**Contracts:** UnrugableToken, UR_Factory  
**Verification Tool:** Certora Prover  
**Solidity Version:** 0.8.20 (Certora copy; production uses 0.8.31)  
**Report Date:** January 30, 2026  
**Specification:** `unrugable-token.spec`, `unrugable-factory.spec`

This directory contains the **Certora Prover formal verification** reports for the UnRugable production contracts.

## Overview

UnRugable uses formal verification via Certora Prover, which uses **mathematical proofs** to verify properties hold for **ALL possible inputs and states**.

### Verification Jobs

| Contract | Certora Job | Report |
|----------|-------------|--------|
| **UR_Factory** | [f39c5a7c9ea540eaae857cfe6c5fd7f0](https://prover.certora.com/output/7827024/f39c5a7c9ea540eaae857cfe6c5fd7f0/?anonymousKey=f5e7bc59f816a3b9bd01f7adab46b40184ee02e4) (8/8) | [UR_FACTORY_REPORT.md](./UR_FACTORY_REPORT.md) |
| **UnrugableToken** | [94720a02f991426287904e7625c3f7df](https://prover.certora.com/output/7827024/94720a02f991426287904e7625c3f7df/?anonymousKey=eaf7ab1153d662a1beeb5175f4f149831d878430) (9/9) | [UNRUGABLE_TOKEN_REPORT.md](./UNRUGABLE_TOKEN_REPORT.md) |

### Full Reports

- **[CERTORA_AUDIT_REPORT.md](./CERTORA_AUDIT_REPORT.md)** - Combined audit report (UnrugableToken + UR_Factory)
- **[EXECUTIVE_SUMMARY.md](./EXECUTIVE_SUMMARY.md)** - Executive summary
- **[UR_FACTORY_REPORT.md](./UR_FACTORY_REPORT.md)** - UR_Factory detailed report
- **[UNRUGABLE_TOKEN_REPORT.md](./UNRUGABLE_TOKEN_REPORT.md)** - UnrugableToken detailed report

## Directory Structure

```
UR_Certora/
├── README.md                 # This file
├── CERTORA_AUDIT_REPORT.md   # Combined audit report
├── EXECUTIVE_SUMMARY.md      # Executive summary
├── UR_FACTORY_REPORT.md      # UR_Factory verification report
└── UNRUGABLE_TOKEN_REPORT.md # UnrugableToken verification report
```

## Related Documentation

- **Foundry Tests:** [../UR_Foundry/COMPREHENSIVE_TEST_REPORT.md](../UR_Foundry/COMPREHENSIVE_TEST_REPORT.md)
- **Combined Report:** [../UR_Comprehensive_report.md](../UR_Comprehensive_report.md) (Certora + Foundry)
- **Contract Source:** [../../UnRugable.sol](../../UnRugable.sol)

---

**Last Updated:** January 30, 2026
