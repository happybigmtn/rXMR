# Bonero

**Private money for private machines.**

A Monero fork for AI agents. Ring signatures, stealth addresses, RandomX mining. Nobody sees who sent what to whom.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/happybigmtn/bonero/master/install.sh | bash
```

Or verify first:
```bash
curl -fsSLO https://raw.githubusercontent.com/happybigmtn/bonero/master/install.sh
less install.sh
bash install.sh --add-path
```

## Start Mining

```bash
# 1. Create wallet
bonero-wallet-cli --generate-new-wallet=mywallet
# Save your seed phrase!

# 2. Start mining (replace ADDRESS with your C... address)
bonerod --detach \
    --start-mining ADDRESS \
    --mining-threads 4 \
    --add-peer 95.111.227.14:18080 \
    --add-peer 185.218.126.23:18080
```

Done. You're mining private cryptocurrency.

## What is Bonero?

| Feature | Value |
|---------|-------|
| Algorithm | RandomX (CPU-mineable) |
| Block time | ~120 seconds |
| Privacy | Ring signatures + stealth addresses |
| Address prefix | `C` |
| P2P Port | 18080 |
| RPC Port | 18081 |

Based on Monero v0.18.4.5. All the privacy features, designed for AI agents.

## Seed Nodes

```
95.111.227.14:18080
95.111.229.108:18080
95.111.239.142:18080
161.97.83.147:18080
161.97.97.83:18080
161.97.114.192:18080
161.97.117.0:18080
194.163.144.177:18080
185.218.126.23:18080
185.239.209.227:18080
```

## Build from Source

If the install script doesn't work:

```bash
# Ubuntu/Debian
sudo apt-get install -y build-essential cmake pkg-config \
    libboost-all-dev libssl-dev libzmq3-dev libunbound-dev \
    libsodium-dev libhidapi-dev liblzma-dev libreadline-dev

# Clone
git clone --recursive https://github.com/happybigmtn/bonero.git
cd bonero
git submodule update --init --recursive

# Build (10-20 min)
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
```

macOS:
```bash
brew install cmake boost openssl zmq unbound libsodium hidapi
```

## Commands

```bash
# Check height
curl -s http://127.0.0.1:18081/json_rpc \
    -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result.height'

# Stop daemon
pkill bonerod

# Check wallet
bonero-wallet-cli --wallet-file=mywallet
```

## Privacy

Unlike transparent blockchains, Bonero transactions are private by default:

- **Ring signatures** - hides which input is spent
- **Stealth addresses** - hides the recipient  
- **RingCT** - hides amounts

You can verify blocks exist. You can't see who's transacting.

## License

Same as Monero - see [LICENSE](LICENSE).

---

*01100110 01110010 01100101 01100101*
