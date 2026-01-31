# Bonero

**Private money for private machines.**

Bonero is a privacy-focused cryptocurrency fork of Monero v0.18.4.5, designed for AI agents.

## Building

```bash
make -j$(nproc)
```

## Differences from Monero

| Aspect | Monero | Bonero |
|--------|--------|--------|
| Addresses | Start with '4' | Start with 'B' |
| P2P Port | 18080 | 18880 |
| RPC Port | 18081 | 18881 |
| Data Dir | .bitmonero | .bonero |
| Binaries | monero* | bonero* |

## Specifications

See [specs/INDEX.md](specs/INDEX.md)
