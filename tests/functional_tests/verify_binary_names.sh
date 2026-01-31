#!/bin/bash
# Build verification test - verifies all Bonero binaries are present with correct names
# Required by IMPLEMENTATION_PLAN.md Priority 2.1: Binary Names
#
# Usage: ./tests/functional_tests/verify_binary_names.sh [build_dir]
# Example: ./tests/functional_tests/verify_binary_names.sh build/release/bin

BUILD_DIR="${1:-build/release/bin}"
BUILD_ROOT="$(cd "$(dirname "$BUILD_DIR")" && pwd)"
CMAKE_CACHE="$BUILD_ROOT/CMakeCache.txt"
BUILD_DEBUG_UTILITIES="OFF"

if [[ -f "$CMAKE_CACHE" ]]; then
  cache_flag=$(grep -m1 "^BUILD_DEBUG_UTILITIES:BOOL=" "$CMAKE_CACHE" | cut -d= -f2)
  if [[ -n "$cache_flag" ]]; then
    BUILD_DEBUG_UTILITIES="$cache_flag"
  fi
fi

# All expected Bonero binaries (renamed from Monero)
expected_binaries=(
  "bonerod"
  "bonero-wallet-cli"
  "bonero-wallet-rpc"
  "bonero-blockchain-import"
  "bonero-blockchain-export"
  "bonero-blockchain-mark-spent-outputs"
  "bonero-blockchain-usage"
  "bonero-blockchain-ancestry"
  "bonero-blockchain-depth"
  "bonero-blockchain-stats"
  "bonero-blockchain-prune-known-spent-data"
  "bonero-blockchain-prune"
  "bonero-gen-trusted-multisig"
  "bonero-gen-ssl-cert"
)

if [[ "$BUILD_DEBUG_UTILITIES" == "ON" ]]; then
  expected_binaries+=(
    "bonero-utils-deserialize"
    "bonero-utils-object-sizes"
    "bonero-utils-dns-checks"
  )
fi

# Monero binaries that should NOT exist (to verify complete rename)
forbidden_binaries=(
  "monerod"
  "monero-wallet-cli"
  "monero-wallet-rpc"
  "monero-blockchain-import"
  "monero-blockchain-export"
)

echo "Verifying Bonero binary names in: $BUILD_DIR"
echo "=============================================="

errors=0
found=0

# Check expected Bonero binaries exist
for binary in "${expected_binaries[@]}"; do
  if [[ -f "$BUILD_DIR/$binary" ]]; then
    echo "PASS: Found $binary"
    ((found++))
  else
    echo "FAIL: Missing binary: $binary"
    ((errors++))
  fi
done

echo ""
echo "Checking for forbidden Monero binaries..."

# Check forbidden Monero binaries do NOT exist
for binary in "${forbidden_binaries[@]}"; do
  if [[ -f "$BUILD_DIR/$binary" ]]; then
    echo "FAIL: Found forbidden Monero binary: $binary"
    ((errors++))
  fi
done

echo ""
echo "=============================================="
echo "Summary: Found $found/${#expected_binaries[@]} expected binaries"

if [[ $errors -eq 0 ]]; then
  echo "PASS: All expected binaries present, no forbidden binaries found"
  exit 0
else
  echo "FAIL: $errors error(s) found"
  exit 1
fi
