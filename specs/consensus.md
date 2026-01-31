# Bonero Consensus

## Proof of Work
- Algorithm: RandomX (inherited from Monero)
- No changes needed

## Block Timing

| Parameter | Monero | Bonero | Rationale |
|-----------|--------|--------|-----------|
| Target block time | 120 seconds | **60 seconds** | Match Botcoin, faster confirmations |
| Difficulty window | 720 blocks (~24h) | 1440 blocks (~24h) | Maintain 24h window |
| Difficulty lag | 15 blocks | 15 blocks | Keep same |

## Emission (Adjusted for 60s blocks)

To maintain the same emission schedule as Monero despite 2x faster blocks, all rewards are halved:

| Parameter | Monero | Bonero |
|-----------|--------|--------|
| Initial block reward | ~17.5 XMR | **~8.75 BON** |
| Tail emission | 0.6 XMR/block | **0.3 BON/block** |
| Main emission period | ~8 years | ~8 years |
| Total main emission | ~18.4M | ~18.4M BON |
| Annual tail inflation | ~157,680 XMR | ~157,680 BON |

### Emission Formula

```
reward = max(0.3, (2^64 - 1 - already_emitted) * 2^-20 * 10^-12)
```

Note: Changed from 2^-19 to 2^-20 to halve the reward.

## Privacy Features (all inherited)
- Ring size: 16 minimum
- RingCT: Enabled
- Stealth addresses: Enabled

## Implementation

```cpp
// src/cryptonote_config.h
#define DIFFICULTY_TARGET_V2                               60  // 60 seconds (was 120)
#define DIFFICULTY_BLOCKS_COUNT_V2                         1440 // 24h window at 60s blocks

// src/cryptonote_basic/cryptonote_basic_impl.cpp
// Modify get_block_reward() to halve emission:
// Change shift from 19 to 20 in the emission calculation
```
