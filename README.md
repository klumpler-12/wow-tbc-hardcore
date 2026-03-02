# ⚔️ WoW TBC Hardcore Addon

A multi-mode hardcore addon for World of Warcraft: The Burning Crusade, designed for the **OnlyFangs 3** event and beyond.

## 🎯 Vision

TBC is notorious for not being a great hardcore version of WoW. This addon aims to change that by offering **configurable hardcore modes** with community-driven rules, making hardcore TBC feasible and exciting.

## 🎮 Game Modes

| Mode | Death Penalty | Gear | Economy |
|------|--------------|------|---------|
| **Hardcore** | Character voided forever (guild banned, tracked as "dead") | Destroyed | SSF enforced, mail locked |
| **Softcore** | Gear + inventory + gold deleted | Destroyed | Partially restricted |
| **Nullcore** | Score deduction only | Kept | Open |

## ✨ Features

- **Death Tracking** — Monitors deaths via combat log, records cause, zone, level, and killer
- **Penalty Modes** — Configurable penalties from permadeath-equivalent to score-only
- **Scoring System** — Points for quests, dungeons, achievements; deductions for deaths
- **Guild Management** — Auto-kick, death marking, leaderboards
- **SSF Enforcement** — Mail lock, trade restrictions
- **Addon Communication** — Syncs data between guild members

## 🗳️ Community Voting

Visit the [concept site](#) to vote on key rules and help shape the addon.

## 📁 Project Structure

```
wow-tbc-hardcore/
├── web/          # Concept visualization website
├── addon/        # WoW addon (Lua) — coming soon
├── AIINFO/       # Research notes
├── Dockerfile
└── docker-compose.yml
```

## 🛠️ Tech Stack

- **Addon:** Lua 5.1 (WoW API)
- **Concept Site:** HTML / CSS / JS
- **Deployment:** Docker / Nginx

## 📋 Status

🚧 **In Development** — Concept visualization phase

## 📜 License

MIT
