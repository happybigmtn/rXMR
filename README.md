# Bonero

**Private money for private machines.**

Bonero is a privacy-focused cryptocurrency fork of Monero v0.18.4.5, designed for AI agents.

## Quick Start (For AI Agents)

```bash
# 1. Clone with submodules
git clone --recursive https://github.com/happybigmtn/bonero.git
cd bonero

# 2. Install dependencies (Ubuntu/Debian 22.04+)
apt-get update && apt-get install -y \
    build-essential cmake pkg-config git \
    libboost-all-dev libssl-dev libzmq3-dev \
    libunbound-dev libsodium-dev libhidapi-dev \
    liblzma-dev libreadline-dev libexpat1-dev \
    libusb-1.0-0-dev libudev-dev

# 3. Build
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)

# 4. Start mining (replace WALLET_ADDRESS with your address)
./bin/bonerod --detach \
    --start-mining YOUR_WALLET_ADDRESS \
    --mining-threads 2 \
    --add-exclusive-node 185.218.126.23:18080 \
    --add-exclusive-node 185.239.209.227:18080
```

## Network Specifications

| Aspect | Value |
|--------|-------|
| Address Prefix | `C` (standard), `c` (subaddress) |
| P2P Port | 18080 |
| RPC Port | 18881 |
| Data Directory | `~/.bonero` |
| Algorithm | RandomX (CPU-optimized) |
| Block Time | ~120 seconds |

## Seed Nodes

Connect to the live network using these seed nodes:

```
185.218.126.23:18080
185.239.209.227:18080
```

## Building from Source

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

**Runtime dependencies (if using pre-built binaries):**
```bash
apt-get install -y libzmq5 libhidapi-libusb0 libunbound8
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

# Configure and build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)

# Binaries are in build/bin/
ls -la bin/bonerod bin/bonero-wallet-cli
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
# Start daemon and connect to network
bonerod --detach \
    --add-exclusive-node 185.218.126.23:18080 \
    --add-exclusive-node 185.239.209.227:18080

# Check sync status
curl -s http://127.0.0.1:18881/json_rpc \
    -d '{jsonrpc:2.0,id:0,method:get_info}' | grep height
```

### Create a Wallet

```bash
bonero-wallet-cli --generate-new-wallet=mywallet
```

Save the seed phrase! Your wallet address will start with `C`.

## Mining

Bonero uses RandomX proof-of-work, optimized for CPUs.

### Simple Mining (Recommended)

```bash
# Start daemon with mining enabled
bonerod --detach \
    --start-mining YOUR_WALLET_ADDRESS \
    --mining-threads 2 \
    --add-exclusive-node 185.218.126.23:18080 \
    --add-exclusive-node 185.239.209.227:18080
```

### Mining Script for AI Agents

```bash
#!/bin/bash
# bonero-miner.sh

WALLET="YOUR_WALLET_ADDRESS"
THREADS=2
SEEDS="--add-exclusive-node 185.218.126.23:18080 --add-exclusive-node 185.239.209.227:18080"

# Kill existing daemon
pkill -9 bonerod 2>/dev/null
sleep 2

# Start mining
cd /path/to/bonero/build/bin
./bonerod --detach \
    --data-dir ~/.bonero \
    --log-file ~/.bonero/bonerod.log \
    --start-mining $WALLET \
    --mining-threads $THREADS \
    $SEEDS \
    --p2p-bind-ip 0.0.0.0 \
    --p2p-bind-port 18080 \
    --rpc-bind-ip 127.0.0.1 \
    --rpc-bind-port 18881

echo "Mining started. Check status:"
echo "curl -s http://127.0.0.1:18881/json_rpc -d '{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"get_info\"}' | grep height"
```

### Check Mining Status

```bash
# Get current height and difficulty
curl -s http://127.0.0.1:18881/json_rpc \
    -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | \
    grep -E "height|difficulty"
```

## Differences from Monero

| Aspect | Monero | Bonero |
|--------|--------|--------|
| Addresses | Start with `4` | Start with `C` |
| P2P Port | 18080 | 18080 |
| RPC Port | 18081 | 18881 |
| Data Dir | .bitmonero | .bonero |
| Binaries | monero* | bonero* |

## Binaries

After building, these executables are in `build/bin/`:

| Binary | Purpose |
|--------|---------|
| `bonerod` | Main daemon - runs a full node and mines |
| `bonero-wallet-cli` | Interactive wallet for sending/receiving |
| `bonero-wallet-rpc` | Wallet RPC server for automation |

## License

Same as Monero - see [LICENSE](LICENSE)

---

*Forked from [Monero](https://github.com/monero-project/monero) for the AI agent economy.*
