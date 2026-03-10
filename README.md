# Hardcore Plus

**Hybrid Hardcore for WoW: The Burning Crusade**

TBC was never meant for permadeath. We're changing that. Customizable rulesets, creative punishments, competitive houses, deep scoring systems, and full guild management — built for OnlyFangs 3 and beyond.

## What Is This?

Hardcore Plus is a WoW TBC addon that introduces **Hybrid Hardcore** — keeping the thrill of permadeath leveling while making endgame viable through configurable checkpoints, creative penalties, and a deep competition layer.

### Three Modes

| Mode | Death Penalty | Target |
|------|--------------|--------|
| **Hardcore** | Permadeath. Character voided forever. Gear destroyed. SSF enforced. | Purists |
| **Hybrid HC** | HC leveling + configurable instance lives/checkpoints. Penalties scale. | Most players |
| **Nullcore** | Score deduction only. Gear kept. Open economy. | Casual competition |

### Key Features

- **Ruleset Engine** — Hard rules (HC until 60) + soft rules (GM-configurable). Export/import across guilds.
- **Track Everything** — Deaths, kills, movement, fishing, dungeons, gear, trades. All feeds into scoring.
- **Scoring System** — Complex multipliers OR simple fixed values (community votes). 1000+ micro-achievements.
- **Houses (Sub-Guilds)** — Compete within your guild. Draft system with player ratings. House leaderboards.
- **Creative Punishments** — RP-walk of shame, gear lock, trade embargo. GM-triggered remotely.
- **Mini-Games** — Spontaneous races, scavenger hunts, first-to-X competitions.
- **Web Dashboard** — Configure everything from your browser. Leaderboards, analytics, reward designer.
- **Anti-Cheat** — Inventory hash snapshots, cross-verification, companion app backend verification.

### OnlyFangs 3 Ready

Every feature Sodapoppin and NMP discussed for OF3 — houses within Aldor/Scryer, point systems for heroics, micro-achievements, player drafts, weekly tallies — is a core feature of Hardcore Plus.

## Project Structure

```
wow-tbc-hardcore/
├── web/              # Presentation website
├── addon/            # WoW addon (Lua) — in development
├── docs/             # Project plans (DE + EN), research
│   ├── PROJECT_PLAN_DE.md
│   └── PROJECT_PLAN_EN.md
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Tech Stack

- **Addon:** Lua 5.1 (WoW 2.4.3 API)
- **Web:** HTML / CSS / JS (presentation site)
- **Backend:** Node.js + MongoDB (planned)
- **Companion App:** Electron (planned)
- **Dashboard:** React (planned)

## Status

Phase 0: Concept & Architecture — Active

## Monetization

- **Free** on CurseForge: Core tracking, scoring, 3 modes, SSF enforcement, leaderboard
- **Premium** via Patreon: Creative punishments, houses management, web dashboard, mini-games, achievement designer

Free players always participate in scoring and leaderboards. Premium adds management tools. Never pay-to-win.

## License

MIT
