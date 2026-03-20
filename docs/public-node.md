# Public rXMR Node Guide

rXMR can run as a private CPU miner, but public peers make the network easier to discover and sync.

## Minimum host expectations

- 64-bit Linux host
- at least 2 CPU cores
- at least 4 GiB RAM
- stable public IPv4 preferred

## Install

Use the tagged-release installer when one is available:

```bash
curl -fsSLO https://github.com/happybigmtn/rXMR/releases/latest/download/install.sh
less install.sh
bash install.sh --add-path
```

If `rxmrd` is already installed, the systemd path is:

```bash
sudo rxmr-install-public-node
sudo systemctl enable --now rxmrd
```

## Required config

The public-node template installs `/etc/rxmr/rxmr.conf` with:

```ini
p2p-bind-ip=0.0.0.0
p2p-bind-port=18880
rpc-bind-ip=127.0.0.1
rpc-bind-port=18881
zmq-rpc-bind-port=18882
```

Keep RPC bound to localhost unless you are intentionally exposing a restricted remote node behind your own auth and firewall.

## Open the public port

Expose `18880/TCP` on the host and cloud firewall:

- `sudo ufw allow 18880/tcp`
- verify your VPS provider security group also allows inbound `18880/TCP`

## Verify health

After startup:

```bash
rxmr-doctor
curl -fsS http://127.0.0.1:18881/get_info
```

Healthy public peers should show nonzero outbound peers and eventually nonzero inbound peers.

## Enable persistent mining

Once the public node is installed:

```bash
sudo rxmr-install-public-miner --address YOUR_RXMR_ADDRESS --enable-now
```

By default the helper uses `CPU count - 1` threads and sets `Nice=19`.

To remove mining and keep the node online:

```bash
sudo rxmr-install-public-miner --remove --enable-now
```
