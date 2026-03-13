# Hardcore Plus

**Hybrid Hardcore for WoW: The Burning Crusade**

TBC was never meant for permadeath. We're changing that. Customizable rulesets, creative punishments, competitive fractions, deep scoring systems, and full guild management — built for OnlyFangs 3 and beyond.

## What Is This?

Hardcore Plus is a WoW TBC addon that introduces **Hybrid Hardcore** — a single, unified mode that keeps the thrill of permadeath leveling while making endgame viable through configurable checkpoints, instance lives, creative penalties, and a deep competition layer.

### Hybrid HC — One Mode, Fully Configurable

| Layer | What It Does |
|-------|-------------|
| **Base Ruleset** | Permadeath 1–70, instance lives, checkpoint at 58, death tracking, scoring — always active |
| **Free Customization** | SSF toggle (Full SSF / Guildfound / Off), PvP rules, minor toggles |
| **Premium Customization** | Guild-wide rulesets, extra lives, custom checkpoints, fractions & draft, guild web profiles, export tools |

### Key Features

- **Ruleset Engine** — Hard rules (permadeath until 70) + soft rules (GM-configurable). Export/import across guilds.
- **Instance Lives** — Lives per character per instance, scaled by difficulty (Easy 2 / Hard 3 / Brutal 5). Makes TBC endgame viable.
- **Checkpoint at 58** — On death after checkpoint: Blizzard boost or soft reset (strip all progress, re-register as HC).
- **Track Everything** — Deaths, kills, movement, fishing, dungeons, gear, trades. All feeds into scoring.
- **Scoring System** — Complex multipliers OR simple fixed values. 1000+ micro-achievements.
- **Fractions & Houses** — Two competing fractions per guild, houses as sub-teams within each. Draft system with player ratings.
- **Creative Punishments** — RP-walk of shame, gear lock, trade embargo. GM-triggered remotely.
- **Mini-Games** — Spontaneous races, scavenger hunts, first-to-X competitions.
- **Web Dashboard** — Configure everything from your browser. Leaderboards, analytics, reward designer.
- **Anti-Cheat** — Inventory hash snapshots, cross-verification, companion app backend verification.

### OnlyFangs 3 Ready

Every feature discussed for OF3 — fractions within Aldor/Scryer, point systems for heroics, micro-achievements, player drafts, weekly tallies — is a core feature of Hardcore Plus.

## Project Structure

```
wow-tbc-hardcore/
├── web/                  # Presentation website (static HTML/CSS/JS)
│   ├── index.html        # Main page
│   ├── roadmap.html      # Development roadmap
│   ├── profile.html      # Player profile demo
│   ├── guild-profile.html # Guild profile demo
│   ├── styles.css        # Main styles
│   ├── css/              # Page-specific styles
│   └── js/               # Modular JS (14 files)
├── docs/                 # Documentation
│   ├── TESTAMENT.md      # Source of truth — core rules & parameters
│   ├── features/         # Feature specs (8 files)
│   └── ...               # Architecture, monetization, phases, etc.
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Tech Stack

- **Addon:** Lua 5.1, WoW TBC 2.4.3 API, Ace3 libraries
- **Web:** Static HTML/CSS/JS (no build step)
- **Backend (planned):** Node.js/Express, MongoDB/SQLite
- **Companion App (planned):** Electron
- **Dashboard (planned):** React 18

## Status

Phase 0: Concept & Architecture — Active

## Monetization

| Feature | Free (CurseForge) | Premium (Patreon) |
|---------|-------------------|-------------------|
| Base ruleset (permadeath, lives, checkpoint at 58) | Yes | Yes |
| Death tracking & scoring | Yes | Yes |
| Instance lives system | Yes | Yes |
| Guild roster integration | Yes | Yes |
| Extra lives (self / guild-wide) | No | Yes |
| Custom checkpoint levels / multi-checkpoint | No | Yes |
| Full rule customization | No | Yes |
| Fractions & draft system | No | Yes |
| Guild web sites & player profiles | No | Yes |
| Custom achievements & export tools | No | Yes |

**Pricing:** $5/month individual, $15/month guild, $25/month event
Free players always participate fully in base gameplay. Premium adds management tools. Never pay-to-win.

## License

MIT
