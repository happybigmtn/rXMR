# Bonero

**Private money for private machines.**

Bonero is a privacy-focused cryptocurrency fork of Monero v0.18.4.5, designed for AI agents.

## Quick Start (For AI Agents)

```bash
# 1. Clone with submodules
git clone --recursive https://github.com/happybigmtn/bonero.git
cd bonero

# 2. Install dependencies (Ubuntu/Debian)
apt-get update && apt-get install -y \
    build-essential cmake pkg-config \
    libboost-all-dev libssl-dev libzmq3-dev \
    libunbound-dev libsodium-dev libhidapi-dev \
    liblzma-dev libreadline-dev libexpat1-dev

# 3. Build
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)

# 4. Install
cp bin/bonero* /usr/local/bin/
```

## Full Build Instructions

### Prerequisites

**Ubuntu 22.04+ / Debian 12+:**
```bash
apt-get update && apt-get install -y \
    build-essential cmake pkg-config git \
    libboost-all-dev libssl-dev libzmq3-dev \
    libunbound-dev libsodium-dev libhidapi-dev \
    liblzma-dev libreadline-dev libexpat1-dev \
    libusb-1.0-0-dev libudev-dev
```

### Clone and Build

```bash
# Clone repository
git clone https://github.com/happybigmtn/bonero.git
cd bonero

# Initialize submodules (REQUIRED - build will fail without this!)
git submodule update --init --recursive

# Create build directory
mkdir -p build && cd build

# Configure
cmake -DCMAKE_BUILD_TYPE=Release ..

# Build (adjust -j for your CPU cores)
make -j$(nproc)

# Binaries are in build/bin/
ls -la bin/
```

### Common Build Errors

| Error | Fix |
|-------|-----|
| `check_submodule` CMake error | Run `git submodule update --init --recursive` |
| `Could not find libunbound` | Install `libunbound-dev` |
| `Could not find Boost` | Install `libboost-all-dev` |
| `Could not find OpenSSL` | Install `libssl-dev` |

## Running a Node

### Start the Daemon

```bash
# First run (creates ~/.bonero data directory)
bonerod --detach

# Check status
bonero-wallet-cli --version
```

### Join the Network

```bash
# Connect to seed nodes (replace with actual seed IPs)
bonerod --add-exclusive-node=SEED_IP:18880 --detach

# Or configure in ~/.bonero/bonero.conf:
# add-exclusive-node=SEED_IP:18880
```

### Create a Wallet

```bash
bonero-wallet-cli --generate-new-wallet=mywallet
```

### Start Mining

```bash
# Using wallet RPC
bonero-wallet-rpc --wallet-file=mywallet --rpc-bind-port=18882 --disable-rpc-login

# Then call start_mining RPC
curl -X POST http://127.0.0.1:18882/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"start_mining","params":{"threads_count":4}}'
```

## Network Specifications

| Aspect | Value |
|--------|-------|
| Address Prefix | `B` |
| P2P Port | 18880 |
| RPC Port | 18881 |
| Data Directory | `~/.bonero` |
| Algorithm | RandomX |
| Block Time | ~120 seconds |

## Differences from Monero

| Aspect | Monero | Bonero |
|--------|--------|--------|
| Addresses | Start with '4' | Start with 'B' |
| P2P Port | 18080 | 18880 |
| RPC Port | 18081 | 18881 |
| Data Dir | .bitmonero | .bonero |
| Binaries | monero* | bonero* |

## Binaries

After building, these executables are available in `build/bin/`:

| Binary | Purpose |
|--------|---------|
| `bonerod` | Main daemon - runs a full node |
| `bonero-wallet-cli` | Interactive wallet |
| `bonero-wallet-rpc` | Wallet RPC server for automation |
| `bonero-blockchain-import` | Import blockchain from file |
| `bonero-blockchain-export` | Export blockchain to file |

## For AI Agent Operators

### Automated Mining Setup

```bash
#!/bin/bash
# safe-bonero-miner.sh - Run as: ./safe-bonero-miner.sh

# Start daemon if not running
pgrep bonerod || bonerod --detach

# Wait for sync
while [ "$(bonero-wallet-cli --wallet-file=miner --command status 2>/dev/null | grep -c synced)" -eq 0 ]; do
    sleep 10
done

# Start mining with half available cores
CORES=$(($(nproc) / 2))
bonero-wallet-rpc --wallet-file=miner --rpc-bind-port=18882 --disable-rpc-login --detach
curl -X POST http://127.0.0.1:18882/json_rpc \
  -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"start_mining\",\"params\":{\"threads_count\":$CORES}}"
```

### Resource Management

- Use `nice -n 19` for mining processes to yield to system tasks
- Reserve 2+ CPU cores for daemon and SSH access
- Monitor with: `bonero-wallet-cli --wallet-file=miner --command balance`

## Specifications

See [specs/INDEX.md](specs/INDEX.md) for detailed protocol specifications.

## License

Same as Monero - see [LICENSE](LICENSE)
