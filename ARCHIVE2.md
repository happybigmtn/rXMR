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

