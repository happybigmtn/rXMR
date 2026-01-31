# Implementation Plan Archive

## Review Signoff (2026-01-30) - SIGNED OFF

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
| Network | Type | Current | Target | Note |
|---------|------|---------|--------|------|
| Mainnet | Standard | 18 | 66 | Base58 tag (does not directly map to first character) |
| Mainnet | Integrated | 19 | 67 | Base58 tag (does not directly map to first character) |
| Mainnet | Subaddress | 42 | 98 | Base58 tag (does not directly map to first character) |
| Testnet | Standard | 53 | 136 | Base58 tag (does not directly map to first character) |
| Stagenet | Standard | 24 | 86 | Base58 tag (does not directly map to first character) |

**Required Tests:**
```cpp
// tests/unit_tests/bonero_address.cpp (NEW FILE)
#include "gtest/gtest.h"
#include "common/base58.h"
#include "cryptonote_config.h"
#include "cryptonote_basic/account.h"
#include "cryptonote_basic/cryptonote_basic_impl.h"

TEST(address_prefix, mainnet_standard_encodes_prefix)
{
  ASSERT_EQ(config::CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX, 66);

  cryptonote::account_base account;
  account.generate();
  std::string address = cryptonote::get_account_address_as_str(
    cryptonote::MAINNET, false, account.get_keys().m_account_address);
  uint64_t tag = 0;
  std::string data;
  ASSERT_TRUE(tools::base58::decode_addr(address, tag, data));
  ASSERT_EQ(tag, config::CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX);
}

TEST(address_prefix, mainnet_integrated_prefix_67)
{
  ASSERT_EQ(config::CRYPTONOTE_PUBLIC_INTEGRATED_ADDRESS_BASE58_PREFIX, 67);
}

TEST(address_prefix, mainnet_subaddress_prefix_98)
{
  ASSERT_EQ(config::CRYPTONOTE_PUBLIC_SUBADDRESS_BASE58_PREFIX, 98);
}

TEST(address_prefix, testnet_prefix_136)
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

**Validation Command:** `build/Linux/master/release/tests/unit_tests/unit_tests --gtest_filter=address_prefix.*`

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

- [x] Change daemon OUTPUT_NAME from "monerod" to "bonerod"

- [x] Change wallet CLI OUTPUT_NAME from "monero-wallet-cli" to "bonero-wallet-cli"

