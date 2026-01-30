# Unrugable Foundry Test Results

This folder contains JSON reports from maximum-coverage Foundry test runs.

## Report Structure

Reports are generated from the parent `unrugable` directory. Run tests from the repo root:

```bash
cd ~/unrugable
./run-max-tests.sh          # Full parallel run (fuzz 10M + invariants)
./run-factory-invariants-3x.sh  # Factory invariants only (3 parallel)
```

## Latest Reports (Jan 2026)

| Report Type | File Pattern | Runs | Status |
|-------------|--------------|------|--------|
| Fuzz (10M) | `fuzz-maximum-YYYYMMDD_HHMMSS.json` | 10,000,000 per test | ✅ |
| Invariant Token | `invariant-token-{1,2,3,4}-YYYYMMDD_HHMMSS.json` | 250k × 4 = 1M | ✅ |
| Invariant Factory | `invariant-factory-{1,2,3,a,b,c}-YYYYMMDD_HHMMSS.json` | 250k × 6 = 1.5M | ✅ |

## File Locations

JSON reports are stored in `../test-reports/` (parent unrugable directory). To copy latest reports here:

```bash
cp ../test-reports/fuzz-maximum-20260129_180144.json .
cp ../test-reports/invariant-token-{1,2,3,4}-20260129_180144.json .
cp ../test-reports/invariant-factory-{1,2,3}-20260129_180144.json .
cp ../test-reports/invariant-factory-{a,b,c}-20260130_084419.json .
```
