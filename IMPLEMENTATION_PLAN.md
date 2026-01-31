# Bonero Implementation Plan

> Fork of Monero v0.18.4.5 for AI agents with privacy by default.
> **Status**: ~60% complete - network identity, address prefixes, consensus params, binary names, chain state (checkpoints/hardforks/seeds) done

---

## Critical Notice: Codebase Identity

**IMPORTANT:** This repository contains conflicting documentation:

| Document | Claims to be | Actually matches codebase? |
|----------|--------------|---------------------------|
| `AGENTS.md` | Botcoin (Bitcoin fork) | NO - references non-existent Bitcoin files |
| `README.md` | Bonero (Monero fork) | YES |
| `specs/*` | Bonero (Monero fork) | YES |
| `src/*` | Monero v0.18.4.5 | YES |

**Resolution:** This plan implements **Bonero** (Monero fork) as the actual codebase is Monero. The `AGENTS.md` file needs to be replaced with correct Bonero build instructions.

---

## Priority 1: Network Identity (CRITICAL PATH)

### 1.1 Network Magic Bytes and Ports ✅ COMPLETED
- [x] Change NETWORK_ID for mainnet to `{0xB0, 0x9E, 0x80, 0x71, 0x61, 0x04, 0x41, 0x61, 0x17, 0x31, 0x00, 0x82, 0x16, 0xA1, 0xA1, 0x10}`
- [x] Change NETWORK_ID for testnet (ending `0x11`)
- [x] Change NETWORK_ID for stagenet (ending `0x12`)
- [x] Change P2P_DEFAULT_PORT from 18080 to 18880
- [x] Change RPC_DEFAULT_PORT from 18081 to 18881
- [x] Change ZMQ_RPC_DEFAULT_PORT from 18082 to 18882
- [x] Update testnet ports: 28880/28881/28882
- [x] Update stagenet ports: 38880/38881/38882

**File:** `src/cryptonote_config.h` (lines 230-294)

**Current → Target:**
| Parameter | Current | Target |
|-----------|---------|--------|
| Mainnet P2P | 18080 | 18880 |
| Mainnet RPC | 18081 | 18881 |
| NETWORK_ID[0:3] | `0x12, 0x30, 0xF1` | `0xB0, 0x9E, 0x80` |

**Required Tests:**
```cpp
// tests/unit_tests/bonero_network.cpp (NEW FILE)
#include "gtest/gtest.h"
#include "cryptonote_config.h"

TEST(network_identity, mainnet_ports)
{
  ASSERT_EQ(config::P2P_DEFAULT_PORT, 18880);
  ASSERT_EQ(config::RPC_DEFAULT_PORT, 18881);
  ASSERT_EQ(config::ZMQ_RPC_DEFAULT_PORT, 18882);
}

TEST(network_identity, testnet_ports)
{
  ASSERT_EQ(config::testnet::P2P_DEFAULT_PORT, 28880);
  ASSERT_EQ(config::testnet::RPC_DEFAULT_PORT, 28881);
}

TEST(network_identity, stagenet_ports)
{
  ASSERT_EQ(config::stagenet::P2P_DEFAULT_PORT, 38880);
  ASSERT_EQ(config::stagenet::RPC_DEFAULT_PORT, 38881);
}

TEST(network_identity, network_id_differs_from_monero)
{
  // Monero mainnet NETWORK_ID starts with 0x12, 0x30
  ASSERT_EQ(config::NETWORK_ID.data[0], 0xB0);
  ASSERT_EQ(config::NETWORK_ID.data[1], 0x9E);
  ASSERT_EQ(config::NETWORK_ID.data[2], 0x80);
}
```

**Validation Command:** `ctest --test-dir build -R network_identity`

---

### 1.2 Address Prefixes ✅ COMPLETED
- [x] Set mainnet CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX to 66 ('B')
- [x] Set mainnet CRYPTONOTE_PUBLIC_INTEGRATED_ADDRESS_BASE58_PREFIX to 67 ('Bi')
- [x] Set mainnet CRYPTONOTE_PUBLIC_SUBADDRESS_BASE58_PREFIX to 98 ('Bo')
- [x] Set testnet prefixes: 136 ('T'), 137 ('Ti'), 146 ('To')
- [x] Set stagenet prefixes: 86 ('S'), 87 ('Si'), 108 ('So')

**File:** `src/cryptonote_config.h` (lines 227-229, 270-272, 285-287)

**Current → Target:**
| Network | Type | Current | Target | Starts With |
|---------|------|---------|--------|-------------|
| Mainnet | Standard | 18 | 66 | 'B' |
| Mainnet | Integrated | 19 | 67 | 'Bi' |
| Mainnet | Subaddress | 42 | 98 | 'Bo' |
| Testnet | Standard | 53 | 136 | 'T' |
| Stagenet | Standard | 24 | 86 | 'S' |

**Required Tests:**
```cpp
// tests/unit_tests/bonero_address.cpp (NEW FILE)
#include "gtest/gtest.h"
#include "cryptonote_config.h"
#include "cryptonote_basic/account.h"
#include "cryptonote_basic/cryptonote_basic_impl.h"

TEST(address_prefix, mainnet_standard_starts_with_B)
{
  ASSERT_EQ(config::CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX, 66);

  cryptonote::account_base account;
  account.generate();
  std::string address = cryptonote::get_account_address_as_str(
    cryptonote::MAINNET, false, account.get_keys().m_account_address);
  ASSERT_EQ(address[0], 'B');
}

TEST(address_prefix, mainnet_integrated_starts_with_Bi)
{
  ASSERT_EQ(config::CRYPTONOTE_PUBLIC_INTEGRATED_ADDRESS_BASE58_PREFIX, 67);
}

TEST(address_prefix, mainnet_subaddress_starts_with_Bo)
{
  ASSERT_EQ(config::CRYPTONOTE_PUBLIC_SUBADDRESS_BASE58_PREFIX, 98);
}

TEST(address_prefix, testnet_starts_with_T)
{
  ASSERT_EQ(config::testnet::CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX, 136);
}

TEST(address_prefix, monero_addresses_rejected)
{
  // Monero mainnet prefix is 18, our addresses use 66
  // Verify parsing rejects Monero-prefixed addresses
  std::string monero_addr = "44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A";
  cryptonote::address_parse_info info;
  bool result = cryptonote::get_account_address_from_str(
    info, cryptonote::MAINNET, monero_addr);
  ASSERT_FALSE(result);  // Should fail - wrong prefix
}
```

**Validation Command:** `ctest --test-dir build -R address_prefix`

---

### 1.3 Data Directory ✅ COMPLETED
- [x] Change CRYPTONOTE_NAME from "bitmonero" to "bonero"

**File:** `src/cryptonote_config.h` (line 165)

**Required Tests:**
```cpp
// tests/unit_tests/bonero_branding.cpp (NEW FILE)
#include "gtest/gtest.h"
#include "cryptonote_config.h"

TEST(branding, data_directory_name)
{
  ASSERT_STREQ(CRYPTONOTE_NAME, "bonero");
}
```

**Functional Test:**
```bash
# After building, verify data directory creation
./build/release/bin/bonerod --testnet --data-dir=/tmp/bonero-test &
sleep 5 && pkill bonerod
ls -la /tmp/bonero-test  # Should exist
```

---

## Priority 2: Branding

### 2.1 Binary Names ✅ COMPLETED
- [x] Change daemon OUTPUT_NAME from "monerod" to "bonerod"
- [x] Change wallet CLI OUTPUT_NAME from "monero-wallet-cli" to "bonero-wallet-cli"
- [x] Change wallet RPC OUTPUT_NAME from "monero-wallet-rpc" to "bonero-wallet-rpc"
- [x] Rename all blockchain utilities from "monero-blockchain-*" to "bonero-blockchain-*"
- [x] Rename debug utilities from "monero-utils-*" to "bonero-utils-*"
- [x] Rename gen utilities from "monero-gen-*" to "bonero-gen-*"

**Files:**
- `src/daemon/CMakeLists.txt` (line 74)
- `src/simplewallet/CMakeLists.txt` (line 64)
- `src/wallet/CMakeLists.txt`
- `src/blockchain_utilities/CMakeLists.txt` (9 entries)
- `src/debug_utilities/CMakeLists.txt` (3 entries)
- `src/gen_multisig/CMakeLists.txt`
- `src/gen_ssl_cert/CMakeLists.txt`

**Required Tests:**
```bash
# Build verification test
#!/bin/bash
# tests/functional_tests/verify_binary_names.sh

BUILD_DIR="${1:-build/release/bin}"

expected_binaries=(
  "bonerod"
  "bonero-wallet-cli"
  "bonero-wallet-rpc"
  "bonero-blockchain-import"
  "bonero-blockchain-export"
)

for binary in "${expected_binaries[@]}"; do
  if [[ ! -f "$BUILD_DIR/$binary" ]]; then
    echo "FAIL: Missing binary: $binary"
    exit 1
  fi
done

echo "PASS: All expected binaries present"
exit 0
```

**Validation Command:** `./tests/functional_tests/verify_binary_names.sh build/release/bin`

---

### 2.2 CMake Project Name ✅ COMPLETED
- [x] Change project(monero) to project(bonero) in CMakeLists.txt

**File:** `CMakeLists.txt` (line 49)

**Required Tests:**
```bash
# Verify CMake configuration
grep -q "project(bonero)" CMakeLists.txt || exit 1
```

---

### 2.3 Currency Unit Names
- [ ] Change "piconero" to "picobon" in cryptonote_format_utils.cpp
- [ ] Update unit names in simplewallet.cpp (monero→bonero, millinero→millibon, etc.)
- [ ] Update unit names in wallet2.cpp

**Files:**
- `src/cryptonote_basic/cryptonote_format_utils.cpp` (line 1162)
- `src/simplewallet/simplewallet.cpp` (lines 2726, 3523, 4032)
- `src/wallet/wallet2.cpp` (lines 15893-15894)

**Required Tests:**
```cpp
// Add to tests/unit_tests/bonero_branding.cpp
TEST(branding, currency_unit_name)
{
  // Verify smallest unit is "picobon" not "piconero"
  // This requires checking the format_utils output
}
```

---

## Priority 3: Consensus Parameters

### 3.1 Block Time ✅ COMPLETED
- [x] Change DIFFICULTY_TARGET_V2 from 120 to 60 seconds
- [x] Change DIFFICULTY_WINDOW to 1440 (maintain 24h window)

**File:** `src/cryptonote_config.h` (lines 80-82)

**Rationale:** 60s blocks match faster confirmation for AI agents. Window of 1440 blocks × 60s = 24 hours.

**Required Tests:**
```cpp
// tests/unit_tests/bonero_consensus.cpp (NEW FILE)
#include "gtest/gtest.h"
#include "cryptonote_config.h"

TEST(consensus, block_time_60_seconds)
{
  ASSERT_EQ(DIFFICULTY_TARGET_V2, 60);
}

TEST(consensus, difficulty_window_24h)
{
  // 1440 blocks * 60 seconds = 86400 seconds = 24 hours
  ASSERT_EQ(DIFFICULTY_WINDOW * DIFFICULTY_TARGET_V2, 86400);
}

TEST(consensus, difficulty_window_blocks)
{
  ASSERT_EQ(DIFFICULTY_WINDOW, 1440);
}
```

---

### 3.2 Emission Adjustment ✅ COMPLETED
- [x] Change EMISSION_SPEED_FACTOR_PER_MINUTE from 20 to 21 (halves reward for 60s blocks)
- [x] Verify FINAL_SUBSIDY_PER_MINUTE remains 300000000000 (0.3 BON/minute = 0.3 BON/block)

**File:** `src/cryptonote_config.h` (lines 55-56)

**Explanation:**
The emission formula in `src/cryptonote_basic/cryptonote_basic_impl.cpp`:
```cpp
emission_speed_factor = EMISSION_SPEED_FACTOR_PER_MINUTE - (target_minutes - 1)
```

With 60s blocks (target_minutes=1): factor = 21 - 0 = 21, so reward = supply >> 21
With Monero 120s (target_minutes=2): factor = 20 - 1 = 19, so reward = supply >> 19

The extra 2 bits of shift means 4x smaller per block, but 2x more blocks = 2x lower total emission rate.

**Required Tests:**
```cpp
// Update tests/unit_tests/block_reward.cpp
#include "cryptonote_basic/cryptonote_basic_impl.h"

TEST(block_reward, first_block_reward_halved)
{
  // First block reward should be approximately half of Monero's
  // Monero: ~17.5 XMR, Bonero: ~8.75 BON
  uint64_t reward;
  bool r = cryptonote::get_block_reward(0, 0, 0, reward, 16);
  ASSERT_TRUE(r);
  // Expected: approximately 8796093022207 atomic units
  ASSERT_GT(reward, UINT64_C(8700000000000));
  ASSERT_LT(reward, UINT64_C(8900000000000));
}

TEST(block_reward, tail_emission)
{
  // Tail emission: 0.3 BON/block = 300000000000 picobon
  uint64_t reward;
  bool r = cryptonote::get_block_reward(0, 0, MONEY_SUPPLY - 1, reward, 16);
  ASSERT_TRUE(r);
  ASSERT_EQ(reward, FINAL_SUBSIDY_PER_MINUTE);  // 300000000000
}
```

**Validation Command:** `ctest --test-dir build -R block_reward`

---

## Priority 4: Chain State (New Chain)

### 4.1 Clear Checkpoints ✅ COMPLETED
- [x] Remove all Monero mainnet checkpoints
- [x] Remove all testnet/stagenet checkpoints
- [x] Return true from init_default_checkpoints()
- [x] Clear DNS checkpoint sources (moneropulse domains)

**File:** `src/checkpoints/checkpoints.cpp` (lines 183-260)

**Required Tests:**
```cpp
// tests/unit_tests/bonero_chain.cpp (NEW FILE)
#include "gtest/gtest.h"
#include "checkpoints/checkpoints.h"

TEST(chain_state, no_initial_checkpoints)
{
  cryptonote::checkpoints cp;
  cp.init_default_checkpoints(cryptonote::MAINNET);
  ASSERT_EQ(cp.get_max_height(), 0);
}
```

---

### 4.2 Clear Hardforks History ✅ COMPLETED
- [x] Replace Monero hardfork schedule with single v16 entry at height 1
- [x] Set mainnet_hard_fork_version_1_till to 0
- [x] Update testnet/stagenet similarly

**File:** `src/hardforks/hardforks.cpp` (lines 34-78)

**Target:**
```cpp
const hardfork_t mainnet_hard_forks[] = {
  { 16, 1, 0, 1735689600 },  // v16 from block 1
};
const size_t num_mainnet_hard_forks = 1;
const uint64_t mainnet_hard_fork_version_1_till = 0;
```

**Required Tests:**
```cpp
// tests/unit_tests/bonero_chain.cpp
TEST(chain_state, starts_at_version_16)
{
  ASSERT_EQ(num_mainnet_hard_forks, 1);
  ASSERT_EQ(mainnet_hard_forks[0].version, 16);
  ASSERT_EQ(mainnet_hard_forks[0].height, 1);
}
```

---

### 4.3 Remove Seed Nodes ✅ COMPLETED
- [x] Clear Monero IP seed nodes from net_node.inl
- [x] Clear Monero DNS seed nodes from net_node.h
- [x] Clear DNS checkpoint sources from checkpoints.cpp
- [x] Clear DNS blocklist sources from net_node.inl
- [x] Clear DNS update sources from updates.cpp
- [x] Clear DNS probe hostname from dns_utils.cpp
- [x] Update dns_checks debug utility

**Files:**
- `src/p2p/net_node.inl` (lines 731-763)
- `src/p2p/net_node.h` (lines 305-310)
- `src/checkpoints/checkpoints.cpp` (lines 304-307)

**Required Tests:**
```cpp
// tests/unit_tests/bonero_network.cpp
TEST(network_identity, no_monero_seed_nodes)
{
  // Verify seed node list doesn't contain Monero domains
  for (const auto& seed : m_seed_nodes_list) {
    ASSERT_TRUE(seed.find("moneroseeds") == std::string::npos);
  }
}
```

---

### 4.4 Generate Genesis Block
- [ ] Create genesis message: "Bonero Genesis - 2026: Private money for private machines"
- [ ] Generate new genesis transaction with `--print-genesis-tx`
- [ ] Mine valid genesis nonce
- [ ] Update GENESIS_TX in cryptonote_config.h
- [ ] Update GENESIS_NONCE in cryptonote_config.h
- [ ] Update testnet/stagenet genesis

**File:** `src/cryptonote_config.h` (lines 236-237)

**Process:**
1. Build with all other changes
2. Run: `./bonerod --print-genesis-tx`
3. Copy output to GENESIS_TX
4. Run daemon to mine genesis
5. Record GENESIS_NONCE

**Required Tests:**
```cpp
// tests/unit_tests/bonero_chain.cpp
TEST(chain_state, genesis_is_valid)
{
  cryptonote::transaction tx;
  std::string genesis_hex = config::GENESIS_TX;
  blobdata genesis_blob;
  ASSERT_TRUE(epee::string_tools::parse_hexstr_to_binbuff(genesis_hex, genesis_blob));
  ASSERT_TRUE(cryptonote::parse_and_validate_tx_from_blob(genesis_blob, tx));
  ASSERT_TRUE(cryptonote::is_coinbase(tx));
}

TEST(chain_state, genesis_message_contains_bonero)
{
  // Verify genesis contains expected message
  // Parse extra field for TX_EXTRA_NONCE with message
}
```

---

## Priority 5: Security & Polish

### 5.1 Message Signing Domain Separator ✅ COMPLETED
- [x] Change HASH_KEY_MESSAGE_SIGNING from "MoneroMessageSignature" to "BoneroMessageSignature"

**File:** `src/cryptonote_config.h` (line 259)

**Required Tests:**
```cpp
TEST(security, message_signing_domain)
{
  ASSERT_STREQ(HASH_KEY_MESSAGE_SIGNING, "BoneroMessageSignature");
}
```

---

### 5.2 Fix AGENTS.md ✅ COMPLETED
- [x] Replace Botcoin (Bitcoin fork) content with correct Bonero (Monero fork) build instructions

**File:** `AGENTS.md`

**Required Tests:** Manual review - content matches actual build system

---

### 5.3 Update Version Strings
- [ ] Change version string constants from "Monero" to "Bonero"
- [ ] Update release name

**File:** `src/version.cpp.in`

**Required Tests:**
```bash
# Verify version output
./bonerod --version 2>&1 | grep -i bonero
```

---

## Testing Summary

### Unit Test Files to Create
1. `tests/unit_tests/bonero_network.cpp` - Network identity tests
2. `tests/unit_tests/bonero_address.cpp` - Address prefix tests
3. `tests/unit_tests/bonero_branding.cpp` - Branding tests
4. `tests/unit_tests/bonero_consensus.cpp` - Consensus parameter tests
5. `tests/unit_tests/bonero_chain.cpp` - Chain state tests

### Unit Test Files to Update
1. `tests/unit_tests/block_reward.cpp` - Update expected values for halved emission

### Functional Tests
1. `tests/functional_tests/verify_binary_names.sh` - Verify binary names
2. Manual: Daemon starts, creates ~/.bonero
3. Manual: Wallet generates 'B' prefix addresses
4. Manual: Nodes reject Monero peer connections

### Validation Commands
```bash
# Build
make -j$(nproc)

# Unit tests
ctest --test-dir build/release --output-on-failure

# Specific test suites
ctest --test-dir build -R bonero_network
ctest --test-dir build -R bonero_address
ctest --test-dir build -R block_reward

# Functional test (manual)
./build/release/bin/bonerod --testnet &
./build/release/bin/bonero-wallet-cli --testnet --generate-new-wallet test_wallet
# Verify address starts with 'T'
```

---

## Implementation Order

| Order | Task | File(s) | Est. Time | Dependencies |
|-------|------|---------|-----------|--------------|
| 1 | Network magic bytes | cryptonote_config.h | 30 min | None |
| 2 | Network ports | cryptonote_config.h | 15 min | None |
| 3 | Address prefixes | cryptonote_config.h | 15 min | None |
| 4 | Data directory name | cryptonote_config.h | 5 min | None |
| 5 | Binary names | Various CMakeLists.txt | 45 min | None |
| 6 | Block time | cryptonote_config.h | 10 min | None |
| 7 | Emission factor | cryptonote_config.h | 10 min | #6 |
| 8 | Clear checkpoints | checkpoints.cpp | 15 min | None |
| 9 | Clear hardforks | hardforks.cpp | 15 min | None |
| 10 | Remove seed nodes | net_node.h, net_node.inl | 15 min | None |
| 11 | Message signing domain | cryptonote_config.h | 5 min | None |
| 12 | Create unit tests | tests/unit_tests/*.cpp | 2 hours | #1-11 |
| 13 | Run and fix tests | - | 2-4 hours | #12 |
| 14 | Generate genesis | cryptonote_config.h | 1-2 hours | #1-13 |
| 15 | Fix AGENTS.md | AGENTS.md | 15 min | None |
| 16 | Update version strings | version.cpp.in | 10 min | None |
| 17 | Currency unit names | Various | 30 min | None |
| 18 | Integration testing | - | 2-4 hours | All |

**Total Estimated Time:** 10-14 hours

---

## Success Criteria

- [ ] Build succeeds: `make -j$(nproc)` completes without errors
- [ ] Binary names correct: `bonerod`, `bonero-wallet-cli`, etc.
- [ ] Data directory: daemon creates `~/.bonero`
- [ ] Address prefixes: 'B' (mainnet), 'T' (testnet), 'S' (stagenet)
- [ ] Block time: difficulty adjusts for 60-second target
- [ ] First block reward: ~8.8 BON (half of Monero's ~17.5)
- [ ] Tail emission: 0.3 BON/block
- [ ] Network isolation: rejects Monero peer connections
- [ ] Unit tests: all pass with updated expected values
- [ ] Genesis: mines successfully with unique nonce

---

## Missing Specifications (Need to Add)

1. **Seed Node Infrastructure** - No initial seed nodes documented
2. **DNS Seeds** - No DNS seed domains specified
3. **Checkpoint DNS** - No checkpoint infrastructure
4. **Block Explorer** - No explorer deployment
5. **Mining Pool** - No pool configuration
6. **GUI Wallet** - No GUI branding mentioned

---

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Genesis generation fails | HIGH | Test in stagenet first |
| Emission math errors | HIGH | Comprehensive unit tests |
| Network isolation failure | MEDIUM | Verify NETWORK_ID differs |
| Address parsing issues | MEDIUM | Test rejection of Monero addresses |
| Build system breaks | LOW | Incremental changes |

---

*Generated by Ralph Planning Phase*
*Last Updated: 2026-01-30*
