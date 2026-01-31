# Bonero Implementation Plan

> Fork of Monero v0.18.4.5 for AI agents with privacy by default.
> **Status**: 0% complete - base cloned, specs ready

---

## Phase 1: Network Parameters

### 1.1 Network ID
- [ ] Change network magic bytes in `src/cryptonote_config.h` to Bonero values
- [ ] Update NETWORK_ID for mainnet: `{0xB0, 0x9E, 0x80, ...}`
- [ ] Update NETWORK_ID for testnet and stagenet

### 1.2 Ports
- [ ] Change P2P_DEFAULT_PORT to 18880 in `src/cryptonote_config.h`
- [ ] Change RPC_DEFAULT_PORT to 18881
- [ ] Update testnet ports (28880/28881)
- [ ] Update stagenet ports (38880/38881)

### 1.3 Seed Nodes
- [ ] Remove Monero seed nodes from `src/p2p/net_node.inl`
- [ ] Add placeholder Bonero seed nodes

---

## Phase 2: Address Prefixes

### 2.1 Mainnet Addresses
- [ ] Set CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX to 66 ('B')
- [ ] Set CRYPTONOTE_PUBLIC_INTEGRATED_ADDRESS_BASE58_PREFIX to 67
- [ ] Set CRYPTONOTE_PUBLIC_SUBADDRESS_BASE58_PREFIX to 98 ('Bo')

### 2.2 Testnet/Stagenet
- [ ] Set testnet prefixes (136, 137, 146)
- [ ] Set stagenet prefixes (86, 87, 108)

---

## Phase 3: Branding

### 3.1 Binary Names
- [ ] Change project name in CMakeLists.txt to "bonero"
- [ ] Rename binary targets from monero* to bonero*

### 3.2 User Agent
- [ ] Change version string to "Bonero" in src/version.cpp.in

### 3.3 Data Directory
- [ ] Change default data dir from .bitmonero to .bonero in src/common/util.cpp

### 3.4 Currency Name
- [ ] Change display name from XMR to BON

---

## Phase 4: Genesis Block

### 4.1 Genesis Transaction
- [ ] Create new genesis message: "Bonero Genesis - 2026"
- [ ] Generate new genesis tx

### 4.2 Genesis Block
- [ ] Mine genesis block for mainnet
- [ ] Update GENESIS_TX and GENESIS_NONCE in cryptonote_config.h

---

## Phase 5: Testing

- [ ] Build and run unit tests
- [ ] Test wallet creation (address starts with 'B')
- [ ] Test P2P on new ports

---

## Phase 1.5: Block Time & Emission (NEW)

### 1.5.1 Block Time
- [ ] Change DIFFICULTY_TARGET_V2 from 120 to 60 in `src/cryptonote_config.h`
- [ ] Change DIFFICULTY_BLOCKS_COUNT_V2 to 1440 (maintain 24h window)

### 1.5.2 Emission Adjustment
- [ ] Modify `get_block_reward()` in `src/cryptonote_basic/cryptonote_basic_impl.cpp`
- [ ] Change emission shift from 2^-19 to 2^-20 (halves reward)
- [ ] Change tail emission from 0.6 to 0.3 BON/block

**Rationale**: 60s blocks match Botcoin; halved rewards maintain same emission schedule.
