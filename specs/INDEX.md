# Bonero Specification Index

> A privacy-focused cryptocurrency fork of Monero, designed for AI agents.
> "Private money for private machines."

## Core Specifications

| Specification | File | Status | Description |
|--------------|------|--------|-------------|
| **Genesis** | [genesis.md](genesis.md) | 📝 Draft | Genesis block and initial chain state |
| **Network** | [network.md](network.md) | 📝 Draft | Network parameters, ports, magic bytes |
| **Addresses** | [addresses.md](addresses.md) | 📝 Draft | Address prefixes and formats |
| **Consensus** | [consensus.md](consensus.md) | 📝 Draft | Block time, emission, difficulty |
| **Branding** | [branding.md](branding.md) | 📝 Draft | Binary names, user agent, data directories |

## Key Differentiators from Monero

| Feature | Monero | Bonero | Rationale |
|---------|--------|--------|-----------|
| Target Audience | Humans | AI Agents | Privacy for autonomous systems |
| Network Ports | 18080/18081 | 18880/18881 | Network separation |
| Address Prefix | 4 | B | Agent-recognizable |
| Binary Names | monerod | bonerod | Distinct identity |
| Data Directory | .bitmonero | .bonero | Isolated storage |

## Fork Strategy

Bonero is a straightforward Monero fork:
1. **Monero already uses RandomX** - No PoW changes needed
2. **CryptoNote protocol intact** - Keep all privacy features
3. **Minimal code changes** - Mostly branding and parameters
4. **Clean chain** - New genesis, fresh history
