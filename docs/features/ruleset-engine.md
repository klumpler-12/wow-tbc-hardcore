# Ruleset Engine

The Ruleset Engine is the foundation of Hardcore Plus. It defines what rules are active, who can modify them, and how they are enforced.

---

## Rule Categories

### Hard Rules (Immutable)
Cannot be changed by GMs. Define core identity:
- Permadeath always enforced during leveling (1–70 open world)
- All deaths tracked with full context
- Anti-cheat verification always active
- Addon verification required
- Death log is public and permanent

### Soft Rules (GM-Configurable)
See [TESTAMENT.md](../TESTAMENT.md) for the full table with defaults and ranges.

Key configurable rules:
- Instance lives per difficulty tier
- Life reset behavior (per-leave / per-lockout / permanent)
- SSF mode (Full SSF / Guild trading / Off)
- PvP rules (Scored / Exempt / Disabled)
- Scoring and houses on/off
- Custom achievements on/off
- Death penalty configuration

---

## Ruleset Operations

- **Export/Import:** Rulesets serialized to string, shareable between GMs
- **Versioning:** Each ruleset has a version number. Updates are logged with timestamps, members notified
- **Comparability Scoring:** Different rulesets compared via normalized scores. Stricter rulesets apply a multiplier
- **Auto-Detection:** Addon monitors player actions against active ruleset. Violations logged instantly, GM notified

---

## Ruleset Data Structure (Conceptual)

```lua
Ruleset = {
    id = "of3-hybrid-v2",
    name = "OnlyFangs 3 Hybrid",
    version = 3,
    mode = "hybrid",
    createdBy = "Sodapoppin-Gehennas",
    createdAt = 1710000000,
    hardRules = {
        deathIsDeletion = true,
        levelBracket = {1, 70},
    },
    softRules = {
        ssf = false,
        tradeRestrictions = {"gear"},
        instanceLives = 3,
        livesPer = "boss",     -- "boss" | "instance" | "lockout"
        dungeonLockouts = {},
        buffRestrictions = {},
        checkpointLevel = 58,
    },
    difficultyMultiplier = 1.2,
}
```
