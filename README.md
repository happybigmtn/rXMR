# rXMR

Private money for private machines.

rXMR is a Monero-derived chain for agent-operated systems. It keeps ring signatures, stealth addresses, RingCT, and RandomX CPU mining, but runs on its own network identity, ports, seeds, binaries, and data directory.

**Current release: v0.1.0.1** — based on Monero v0.18.4.6 (March 2026).

## Quick Install

Tagged releases are the intended public install target. The installer uses the newest published tag when one exists, and falls back to building `master` if not.

```bash
curl -fsSLO https://github.com/happybigmtn/rXMR/releases/latest/download/install.sh
less install.sh
bash install.sh --add-path
```

## Quick Mining

```bash
# 1. Create a wallet and save the seed phrase.
rxmr-wallet-cli --generate-new-wallet=mywallet

# 2. Start the daemon with seed peers.
rxmrd --detach --data-dir ~/.rxmr --non-interactive \
  --add-peer 95.111.227.14:18880 \
  --add-peer 95.111.239.142:18880 \
  --add-peer 161.97.114.192:18880 \
  --add-peer 185.218.126.23:18880

# 3. Start mining (1 thread, low priority).
curl -s http://127.0.0.1:18881/start_mining \
  -d miner_address:YOUR_RXMR_ADDRESS \
  -H Content-Type: 
cd /root/bonero-src

# Update README with version and upstream merge info
cat > README.md << 'REOF'
# rXMR

Private money for private machines.

rXMR is a Monero-derived chain for agent-operated systems. It keeps ring signatures, stealth addresses, RingCT, and RandomX CPU mining, but runs on its own network identity, ports, seeds, binaries, and data directory.

**Current release: v0.1.0.1** — based on Monero v0.18.4.6 (March 2026).

## Quick Install

Tagged releases are the intended public install target. The installer uses the newest published tag when one exists, and falls back to building `master` if not.

```bash
curl -fsSLO https://github.com/happybigmtn/rXMR/releases/latest/download/install.sh
less install.sh
bash install.sh --add-path
```

## Quick Mining

```bash
# 1. Create a wallet and save the seed phrase.
rxmr-wallet-cli --generate-new-wallet=mywallet

# 2. Start the daemon with seed peers.
rxmrd --detach --data-dir ~/.rxmr --non-interactive \
  --add-peer 95.111.227.14:18880 \
  --add-peer 95.111.239.142:18880 \
  --add-peer 161.97.114.192:18880 \
  --add-peer 185.218.126.23:18880

# 3. Start mining (1 thread, low priority).
curl -s http://127.0.0.1:18881/start_mining \
  -d threads_count:1 \
  -H Content-Type: application/json

# 4. Check status.
curl -s http://127.0.0.1:18881/json_rpc \
  -d jsonrpc:2.0 \
  -H Content-Type: application/json

# 4. Check status.
curl -s http://127.0.0.1:18881/json_rpc \
  -d id:0 \
  -H Content-Type: application/json

# 4. Check status.
curl -s http://127.0.0.1:18881/json_rpc \
  -d method:get_info \
  -H Content-Type: application/json
curl -s http://127.0.0.1:18881/mining_status
```

## Network Parameters

| Parameter | Value |
|---|---|
| Algorithm | RandomX |
| Target block time | 60 seconds |
| Address prefix | `C` (byte 66) |
| P2P port | 18880 |
| RPC port | 18881 |
| ZMQ RPC port | 18882 |
| Default datadir | `~/.rxmr` |
| Mainnet URI scheme | `rxmr:` |
| Upstream base | Monero v0.18.4.6 |

## Chain Status

The chain launched in early 2026 and has been mining continuously. As of March 2026:

- Block height: ~64,000+
- Difficulty: ~18,000
- Block reward: ~8.53 rXMR
- Active miners: 9 nodes
- Total estimated supply: ~550,000 rXMR

The live chain preserves its historical genesis memo from the Bonero launch era. The rename does not roll a new genesis or discard existing chain history.

## Seed Nodes

These public seeds are baked into the installer, the daemon fallback list, and the example public-node config:

```text
95.111.227.14:18880
95.111.229.108:18880
95.111.239.142:18880
161.97.83.147:18880
161.97.97.83:18880
161.97.114.192:18880
161.97.117.0:18880
185.218.126.23:18880
185.239.209.227:18880
```

## Public VPS Node

To run a public peer that accepts inbound connections:

```bash
sudo rxmr-install-public-node --enable-now
sudo ufw allow 18880/tcp
```

To run persistent mining under systemd on the same host:

```bash
sudo rxmr-install-public-miner --address YOUR_RXMR_ADDRESS --enable-now
```

Operator notes are in [docs/public-node.md](docs/public-node.md).

## Build From Source

```bash
# Dependencies (Debian/Ubuntu)
sudo apt-get install -y \
  build-essential cmake pkg-config git python3 \
  libboost-all-dev libssl-dev libzmq3-dev libunbound-dev \
  libsodium-dev libhidapi-dev liblzma-dev libreadline-dev \
  libexpat1-dev libpgm-dev libusb-1.0-0-dev

git clone --recursive https://github.com/happybigmtn/rXMR.git
cd rXMR
cmake -S . -B build -D BUILD_TESTS=OFF -D CMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)" --target daemon simplewallet wallet_rpc_server
```

Expected binaries land in `build/bin/`:

- `rxmrd` — full node daemon
- `rxmr-wallet-cli` — interactive wallet
- `rxmr-wallet-rpc` — JSON-RPC wallet server

## RPC Quick Reference

```bash
# Chain info
curl -s http://127.0.0.1:18881/json_rpc \
  -d jsonrpc:2.0 \
  -H Content-Type: application/json
curl -s http://127.0.0.1:18881/mining_status
```

## Network Parameters

| Parameter | Value |
|---|---|
| Algorithm | RandomX |
| Target block time | 60 seconds |
| Address prefix | `C` (byte 66) |
| P2P port | 18880 |
| RPC port | 18881 |
| ZMQ RPC port | 18882 |
| Default datadir | `~/.rxmr` |
| Mainnet URI scheme | `rxmr:` |
| Upstream base | Monero v0.18.4.6 |

## Chain Status

The chain launched in early 2026 and has been mining continuously. As of March 2026:

- Block height: ~64,000+
- Difficulty: ~18,000
- Block reward: ~8.53 rXMR
- Active miners: 9 nodes
- Total estimated supply: ~550,000 rXMR

The live chain preserves its historical genesis memo from the Bonero launch era. The rename does not roll a new genesis or discard existing chain history.

## Seed Nodes

These public seeds are baked into the installer, the daemon fallback list, and the example public-node config:

```text
95.111.227.14:18880
95.111.229.108:18880
95.111.239.142:18880
161.97.83.147:18880
161.97.97.83:18880
161.97.114.192:18880
161.97.117.0:18880
185.218.126.23:18880
185.239.209.227:18880
```

## Public VPS Node

To run a public peer that accepts inbound connections:

```bash
sudo rxmr-install-public-node --enable-now
sudo ufw allow 18880/tcp
```

To run persistent mining under systemd on the same host:

```bash
sudo rxmr-install-public-miner --address YOUR_RXMR_ADDRESS --enable-now
```

Operator notes are in [docs/public-node.md](docs/public-node.md).

## Build From Source

```bash
# Dependencies (Debian/Ubuntu)
sudo apt-get install -y \
  build-essential cmake pkg-config git python3 \
  libboost-all-dev libssl-dev libzmq3-dev libunbound-dev \
  libsodium-dev libhidapi-dev liblzma-dev libreadline-dev \
  libexpat1-dev libpgm-dev libusb-1.0-0-dev

git clone --recursive https://github.com/happybigmtn/rXMR.git
cd rXMR
cmake -S . -B build -D BUILD_TESTS=OFF -D CMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)" --target daemon simplewallet wallet_rpc_server
```

Expected binaries land in `build/bin/`:

- `rxmrd` — full node daemon
- `rxmr-wallet-cli` — interactive wallet
- `rxmr-wallet-rpc` — JSON-RPC wallet server

## RPC Quick Reference

```bash
# Chain info
curl -s http://127.0.0.1:18881/json_rpc \
  -d id:0 \
  -H Content-Type: application/json
curl -s http://127.0.0.1:18881/mining_status
```

## Network Parameters

| Parameter | Value |
|---|---|
| Algorithm | RandomX |
| Target block time | 60 seconds |
| Address prefix | `C` (byte 66) |
| P2P port | 18880 |
| RPC port | 18881 |
| ZMQ RPC port | 18882 |
| Default datadir | `~/.rxmr` |
| Mainnet URI scheme | `rxmr:` |
| Upstream base | Monero v0.18.4.6 |

## Chain Status

The chain launched in early 2026 and has been mining continuously. As of March 2026:

- Block height: ~64,000+
- Difficulty: ~18,000
- Block reward: ~8.53 rXMR
- Active miners: 9 nodes
- Total estimated supply: ~550,000 rXMR

The live chain preserves its historical genesis memo from the Bonero launch era. The rename does not roll a new genesis or discard existing chain history.

## Seed Nodes

These public seeds are baked into the installer, the daemon fallback list, and the example public-node config:

```text
95.111.227.14:18880
95.111.229.108:18880
95.111.239.142:18880
161.97.83.147:18880
161.97.97.83:18880
161.97.114.192:18880
161.97.117.0:18880
185.218.126.23:18880
185.239.209.227:18880
```

## Public VPS Node

To run a public peer that accepts inbound connections:

```bash
sudo rxmr-install-public-node --enable-now
sudo ufw allow 18880/tcp
```

To run persistent mining under systemd on the same host:

```bash
sudo rxmr-install-public-miner --address YOUR_RXMR_ADDRESS --enable-now
```

Operator notes are in [docs/public-node.md](docs/public-node.md).

## Build From Source

```bash
# Dependencies (Debian/Ubuntu)
sudo apt-get install -y \
  build-essential cmake pkg-config git python3 \
  libboost-all-dev libssl-dev libzmq3-dev libunbound-dev \
  libsodium-dev libhidapi-dev liblzma-dev libreadline-dev \
  libexpat1-dev libpgm-dev libusb-1.0-0-dev

git clone --recursive https://github.com/happybigmtn/rXMR.git
cd rXMR
cmake -S . -B build -D BUILD_TESTS=OFF -D CMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)" --target daemon simplewallet wallet_rpc_server
```

Expected binaries land in `build/bin/`:

- `rxmrd` — full node daemon
- `rxmr-wallet-cli` — interactive wallet
- `rxmr-wallet-rpc` — JSON-RPC wallet server

## RPC Quick Reference

```bash
# Chain info
curl -s http://127.0.0.1:18881/json_rpc \
  -d method:get_info \
  -H Content-Type: application/json

# Latest block
curl -s http://127.0.0.1:18881/json_rpc \
  -d jsonrpc:2.0 \
  -H Content-Type: application/json

# Latest block
curl -s http://127.0.0.1:18881/json_rpc \
  -d id:0 \
  -H Content-Type: application/json

# Latest block
curl -s http://127.0.0.1:18881/json_rpc \
  -d method:get_last_block_header \
  -H Content-Type: application/json

# Start mining
curl -s http://127.0.0.1:18881/start_mining \
  -d miner_address:C... \
  -H Content-Type: application/json

# Start mining
curl -s http://127.0.0.1:18881/start_mining \
  -d threads_count:1 \
  -H Content-Type: application/json

# Mining status
curl -s http://127.0.0.1:18881/mining_status

# Stop daemon
curl -s http://127.0.0.1:18881/stop_daemon
```

## Release History

| Version | Date | Base | Notes |
|---------|------|------|-------|
| v0.1.0.1 | 2026-03-21 | Monero v0.18.4.6 | P2P fixes, multisig fix, OpenSSL 3.0.19, port 18880 |
| v0.1.0.0 | 2026-02-01 | Monero v0.18.4.5 | Genesis release (Bonero) |

## What Changed From Monero

- Chain identity: distinct network IDs, ports, address prefixes, seeds, and datadir
- Product identity: `rxmrd`, `rxmr-wallet-cli`, `rxmr-wallet-rpc`, `rxmr:` URIs
- Mining defaults: first-class CPU-mining helpers and public-node installers
- Emission: 60-second blocks, emission speed factor 21

The underlying privacy model and core transaction format remain Monero-derived.

## License

See [LICENSE](LICENSE).
