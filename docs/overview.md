# Vision & Target Audience

> **Version:** 1.0-DRAFT
> **Target Platform:** World of Warcraft: The Burning Crusade (Client 2.4.3)

---

## Who Is This For?

### Guilds (Primary Target)
- Large organized community events (OnlyFangs 3, Sauercrowd, custom HC events)
- Guild Masters needing fine-grained control over rulesets, punishments, rewards
- Internal competition structures (fractions/teams) without splitting guild entities
- Cross-guild events with shared rulesets but independent leaderboards

### Streamers (High-Value Target)
- On-screen overlays and narratives via companion app data export
- Viewer engagement: live leaderboards, death notifications, mini-game participation
- Competitive narratives: fraction rivalries, draft picks, progression races
- Clip-worthy moments: creative punishments, surprise achievements, dramatic deaths

### Solo Players (Growth Target)
- Personal challenge modes with self-tracking
- Global leaderboard participation without a guild
- Achievement hunting across thousands of micro-achievements
- SSF enforcement for purist gameplay

---

## Core Concept: Hybrid Hardcore for TBC

TBC is too punishing for pure permadeath:
- Random one-shots in dungeons (Shattered Halls gauntlet, Shadow Lab mind controls)
- Unavoidable boss mechanics (raid-wide damage, random target selection)
- High-density mob zones in Outland (Hellfire Peninsula onwards)
- Multi-step attunement chains creating repeated failure points

**Hybrid HC solves this:**
1. Permadeath during leveling (1–70 open world)
2. Checkpoint system at level 58 (class-based rollback instead of full restart)
3. Instance lives system makes raid/dungeon content viable
4. Fully customizable rulesets per guild/event

---

## Design Principles

- **Customization over prescription** — never hardcode a rule that a GM might want to change
- **Track everything, enforce selectively** — track all activity, only enforce what the GM enables
- **Free must be functional** — free tier is a complete HC experience; premium adds control and creativity, never competitive advantage
- **Performance first** — zero measurable gameplay impact; async tracking, throttled UI, batched communication
- **Privacy by default** — data only shared within guild unless player opts into global leaderboards
