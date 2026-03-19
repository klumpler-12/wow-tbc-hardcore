# Archived Concepts (Not in PoC — Future Reference Only)

Saved from PoC v1 planning session. Most were rejected. Kept for reference.

---

## Soft Reset Punishments (ALL REJECTED)

### Viable Punishments (WoW API enforceable) — REJECTED
1. Scoring Debt: Start at -500 score
2. Probation Period: No instance lives for first X levels after reset
3. Rep-Gated Content Lockout: Flag rep-vendor items as illegitimate
4. Delayed Instance Lives: No instance lives for 2 weeks after reset
5. Public Shame Tag: "Soft Reset x[N]" displayed prominently
6. Mandatory SSF Lock: Stricter trade mode after reset
7. Cooldown Timer: Once per 30 days

### Creative Punishments — REJECTED
8. Walk of Shame: Must reach level 10 before safety net
9. Tiered Harshness: Escalating penalties per reset count

---

## Checkpoint Alternatives (MOSTLY REJECTED)

### Alternative 1: "Legacy XP Boost" — REJECTED (doesn't work)
### Alternative 2: "Heirloom Allowance" — REJECTED
### Alternative 3: "Spirit Bond" (shared checkpoint pool) — REJECTED
### Alternative 4: "Mentor System" — PARTIAL KEEP
- Implement mentoring as concept for future guild management update
- Group Hardcore mode: one dies, all die. Registered upon start. All must have addon active.
### Alternative 5: "Partial Checkpoint at 40" — REJECTED

---

## Sauercrowd-Inspired Event System (FUTURE — not PoC)

Modular event framework replacing Sauercrowd's hardcoded approach. Configurable event templates (HC races, ironman, speed dungeons, PvP tournaments).

### Event Config Schema
```lua
EventConfig = {
  name = "Season 1 HC Race",
  type = "hc_race",
  duration = { start = timestamp, end = timestamp },
  participants = { mode = "guild", filter = "level >= 1" },
  rules = {
    { type = "death_penalty", action = "eliminate", scope = "open_world" },
    { type = "death_penalty", action = "life_consume", scope = "instance", lives = 3 },
    { type = "restriction", target = "auction_house", action = "block" },
    { type = "restriction", target = "trade", action = "guild_only" },
  },
  verification = { peer_required = true, host_required = false, min_peers = 2 },
}
```

### Companion App + Event Server (FUTURE)
- Electron app watches SavedVariables + addon file hashes (SHA-256)
- Signs data with HMAC, sends to event server
- Cross-references all participants for discrepancies
- Premium: "Event Verification API" for other addon developers

### Sauercrowd Comparison
| Feature | Sauercrowd | TBC Hybrid Hardcore Events |
|---|---|---|
| Rules | Hardcoded | Configurable |
| Events | Single | Multiple concurrent |
| Verification | Guild broadcast | Peer + host + external |
| Tamper evidence | Trust-based | Multi-layer |
| Modularity | Monolithic | Template-based |
