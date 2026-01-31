# UR_Foundry — Unrugable.com Foundry Testing Package

Professional Foundry testing package for Unrugable.com smart contracts.

## Contents

| Item | Description |
|------|--------------|
| `test/` | Test files and contract sources (UnrugableToken, UR_Factory) |
| `test-results/` | JSON report documentation and structure |
| `../COMPREHENSIVE_TEST_REPORT.md` | Full professional test report (in parent) |
| `foundry.toml` | Foundry configuration |

## Running Tests

Tests are run from the **parent unrugable directory** (which has `lib/` with forge-std and OpenZeppelin):

```bash
cd ~/unrugable

# Full maximum run (10M fuzz + invariants) — may OOM with 8 parallel
./run-max-tests.sh

# Factory invariants only (3 parallel, ~12 cores)
./run-factory-invariants-3x.sh

# Sequential run (lower memory)
./run-both-reports.sh
```

## Test Coverage

- **Unit Tests:** 12 tests (UnrugableToken + UR_Factory)
- **Fuzz Tests:** 10M runs per fuzz test (20M+ total)
- **Invariant Tests:** 1M token + 1.5M factory runs, depth 20
- **Total:** 230M+ test scenarios

## Report Structure

- **[COMPREHENSIVE_TEST_REPORT.md](../COMPREHENSIVE_TEST_REPORT.md)** - Foundry test report
- **[UR_Comprehensive_report.md](../UR_Comprehensive_report.md)** - Combined Certora + Foundry report
