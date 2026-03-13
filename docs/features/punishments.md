# Punishment System

Allows GMs to respond to rule violations with automated and creative consequences.

---

## Automated Tracking

- All violations auto-detected and logged with timestamps
- GM gets instant notification: **who**, **what rule**, **when**, **what they were doing**
- Severity categories: Minor (accidental AH browse), Major (completed trade), Critical (disallowed buff in raid)

---

## Standard Punishments (Free)

- **Point Deduction:** Configurable per violation type
- **Guild Notification:** Public announcement in guild chat
- **Strike System:** Accumulate strikes; configurable thresholds (3 = kicked from fraction, 5 = removed from leaderboard)
- **Death Equivalent:** Violation treated as death for scoring

---

## Creative Punishments (Premium)

- **Slow-Force (RP-Walk):** Forced RP-walk for configurable duration
- **Gear-Lock:** Cannot change equipment for X minutes
- **Trade-Ban:** Temporary trade restriction beyond ruleset
- **Shame Walk:** Walk from A to B without mounting (guild verifies)
- **Duel Obligation:** Must accept next duel request
- **Custom GM-Designed:** Templates via web dashboard with descriptions, durations, verification
- **Remote-Triggered:** GMs trigger from web dashboard without being in-game

---

## Data Structure

```lua
Punishment = {
    id = "pun_001",
    type = "slow_force",
    target = "PlayerName-Server",
    issuedBy = "GM-Name",
    reason = "Traded epic gear in SSF mode",
    duration = 3600,
    startTime = 1710000000,
    verified = false,
    verifiedBy = nil,
}
```
