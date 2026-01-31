# AGENTS.md - Bonero Build Guide

## Build & Run

Bonero is a Monero v0.18.4.5 fork. Build with:

```bash
# Dependencies (Ubuntu/Debian)
sudo apt-get install build-essential cmake pkg-config \
    libboost-all-dev libssl-dev libzmq3-dev libunbound-dev \
    libsodium-dev libhidapi-dev libudev-dev libusb-1.0-0-dev \
    libreadline-dev libexpat1-dev libpgm-dev qttools5-dev-tools

# Dependencies (Arch Linux)
sudo pacman -S cmake boost openssl zeromq unbound libsodium \
    hidapi libusb readline expat qt5-tools

# Initialize submodules
git submodule update --init --force --recursive

# Build
make -j$(nproc)

# Binaries will be in build/release/bin/
```

## Validation

Run these after implementing to get immediate feedback:

- Build: `make -j$(nproc)`
- Unit tests: `ctest --test-dir build/Linux/master/release --output-on-failure`
- Specific test suite: `ctest --test-dir build/Linux/master/release -R <suite_name>`

## Binaries

After build, binaries are in `build/release/bin/`:
- `bonerod` - Full node daemon
- `bonero-wallet-cli` - Command-line wallet
- `bonero-wallet-rpc` - Wallet RPC server
- `bonero-blockchain-import` - Import blockchain
- `bonero-blockchain-export` - Export blockchain

## Operational Notes

- Source is in `src/`
- Configuration: `src/cryptonote_config.h`
- Data directory: `~/.bonero` (Linux), `~/Library/Application Support/bonero` (macOS)
- Config file: `bonero.conf`

## Key Files to Modify

- `src/cryptonote_config.h` - Network parameters, address prefixes, ports
- `src/hardforks/hardforks.cpp` - Hardfork schedule
- `src/checkpoints/checkpoints.cpp` - Blockchain checkpoints
- `src/p2p/net_node.inl` - Seed nodes
- `CMakeLists.txt` - Build configuration
- `src/daemon/CMakeLists.txt` - Daemon binary name
- `src/simplewallet/CMakeLists.txt` - Wallet binary names

## Network Configuration

| Network   | P2P Port | RPC Port | ZMQ Port | Address Prefix |
|-----------|----------|----------|----------|----------------|
| Mainnet   | 18880    | 18881    | 18882    | 'B' (66)       |
| Testnet   | 28880    | 28881    | 28882    | 'T' (136)      |
| Stagenet  | 38880    | 38881    | 38882    | 'S' (86)       |
