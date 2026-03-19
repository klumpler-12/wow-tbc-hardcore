# Challenge Modes & Community Features

> **Version:** 1.0-DRAFT
> **Last Updated:** 2026-03-17
> **Status:** Concept / Future Features

---

## 1. Onlyfists — Weapon Restriction Challenge

**Concept:** OnlyFans-inspired branding ("Onlyfists"). Players commit to leveling using only fist weapons. The challenge creates a meme-worthy meta by forcing unconventional combat choices.

### Tier Structure

| Tier | Requirement | Title |
|------|-------------|-------|
| Bronze | Level to 40 using only fist weapons | Onlyfists Bronze |
| Silver | Level to 60 using only fist weapons | Onlyfists Silver |
| Gold | Level to 70 using only fist weapons | Onlyfists Gold |

### Forfeiture & "Chicken" Rule

- At any point before a tier checkpoint (40, 60, 70), the player may forfeit the challenge.
- **Chicken mechanic:** When forfeiting before a checkpoint, the player is prompted: *"Are you sure? You will lose your Onlyfists progress and receive the Chicken title."*
- If the player forfeits, they receive the "Chicken" title (visible to guild, on profile).
- If the player pushes past a checkpoint, they lock in that tier's reward and can safely stop.
- Reaching the next checkpoint removes the Chicken risk for the previous tier.

### Expansion: Other Weapon/Playstyle Combos

The Onlyfists framework is extensible to other meme challenges:

| Challenge | Restriction | Difficulty |
|-----------|-------------|------------|
| Onlyfists | Fist weapons only | High |
| Wandslinger | Wands only (caster classes) | Very High |
| Shieldwall | Shield + no weapon (tanking without DPS) | Extreme |
| Petless Hunter | Hunter, no pet allowed | High |
| Naked & Afraid | No armor, weapons only | Extreme |
| Pacifist | No killing mobs directly (XP from quests, exploration, professions only) | Meme |

Each challenge tracks weapon/equipment snapshots periodically and flags violations if disallowed items are equipped.

### Scoring Integration

- Completing a challenge tier awards bonus points to the player and their house.
- Harder challenges have higher multipliers.
- "Chicken" forfeiture results in a small point deduction (shame penalty).
- First guild-wide completion of a challenge tier awards a guild achievement.

---

## 2. Flex Raiding Lives — Dynamic Life Scaling

**Concept:** Raid groups smaller than the maximum size receive bonus instance lives to compensate for the increased difficulty. Prevents mixed-group abuse and encourages legitimate small-group raiding.

### Scaling Formula

```
BonusLives = floor((MaxGroupSize - ActualGroupSize) / ScaleFactor)
```

- **ScaleFactor:** Configurable per raid tier (default: 5 for 25-man, 3 for 10-man).
- **Maximum cap:** Bonus lives cannot exceed a hard cap (e.g., +3 for 25-man, +2 for 10-man). This prevents solo/duo farming with inflated lives.

### Example: 25-Man Raid

| Group Size | Bonus Lives | Total Lives (base 1 + bonus) |
|------------|-------------|------------------------------|
| 25 | +0 | 1 |
| 20 | +1 | 2 |
| 15 | +2 | 3 |
| 10 | +3 (capped) | 4 |
| 5 | +3 (capped) | 4 |

### Restrictions

- **No mixed groups for instance lives (for now):** If the raid contains players both with and without the addon, instance lives are disabled for the entire group. This prevents non-addon players from benefiting without being tracked.
- **Minimum group size threshold:** For extremely easy content (e.g., Karazhan for a 25-man geared group), flex scaling may not apply. GM-configurable per instance.
- **Not all content qualifies:** Trivially easy content does not award flex bonus lives. The GM or a community vote determines which instances qualify.

---

## 3. Fishing Frenzy — Zone Fishing Competition

**Concept:** A spontaneous or scheduled fishing competition. All addon users in the same zone (or all active addon users server-wide) compete to catch the most fish within a time window.

### Modes

| Mode | Scope | Duration |
|------|-------|----------|
| Zone Frenzy | All addon users in the same zone | 15-30 minutes |
| Server Frenzy | All active addon users server-wide | 1 hour |
| Guild Frenzy | Guild members only | GM-configurable |

### Mechanics

- A GM or automated timer triggers the event.
- The addon tracks fish caught (via `LOOT_OPENED` with fishing context) during the event window.
- Real-time count updates are broadcast via guild/addon communication.
- At the end of the window, the top fisher is crowned.

### Rewards & Titles

| Placement | Reward |
|-----------|--------|
| 1st Place | "Fishing Frenzy Champion" title (displayed for 1 day or 1 week, configurable) |
| 1st Place (Server Frenzy) | Addon-wide title visible to all TBC Hybrid Hardcore users |
| Top 3 | Bonus score points |
| Participation | Small point reward for joining |

### Future Extensions

- Rare fish bonus (catching a rare fish counts as 5 normal fish).
- Fish quality tracking (by fishing skill bracket).
- Seasonal tournaments with cumulative scoring.

---

## 4. Instance Lives in Mixed Groups — Current Limitations

**Current rule:** Instance lives do not function in mixed groups (groups containing both addon and non-addon users). This is a deliberate design choice to prevent:

- Non-tracked players receiving unearned benefits
- Score manipulation through unmonitored group members
- Verification gaps in death/kill tracking

### Disconnect Handling

**Problem:** If a group member disconnects during an instance, their addon status becomes uncertain. This creates a verification gap.

**Solution:**
- When a group member disconnects, the addon broadcasts a warning to all remaining group members: *"[PlayerName] has disconnected. Instance life tracking is paused. Wait for reconnect or leave instance to preserve status."*
- The warning only fires **out of combat** to avoid distraction during boss fights.
- A configurable grace period (default: 5 minutes) allows the player to reconnect.
- If the grace period expires without reconnection:
  - The disconnected player's instance life status is flagged as "contested" (not automatically voided).
  - The remaining group must decide: continue (accepting that the DC'd player's status may be contested) or exit.
  - GM review can resolve contested statuses after the fact.
- If the player reconnects within the grace period, tracking resumes normally.

---

## Implementation Priority

| Feature | Phase | Priority | Addon PoC | Website |
|---------|-------|----------|-----------|---------|
| Onlyfists (basic) | Alpha+ | Medium | Weapon snapshot tracking | Feature showcase |
| Onlyfists (full tier system) | Beta | Medium | Tier unlock + Chicken mechanic | Profile badges |
| Flex Raiding Lives | Beta | High | Group size detection + scaling | Rule config display |
| Fishing Frenzy | Beta+ | Low | Fish count tracking + events | Leaderboard display |
| Mixed Group Handling | Alpha | High | Already partially implemented | Status explanation |
| Disconnect Grace Period | Alpha | High | Heartbeat-based detection | N/A |
