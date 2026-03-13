# Tracking System

Records all measurable player activity. Data stored locally in SavedVariables, optionally synced to backend via companion app.

---

## Tracked Data Points

| Category | Data Point | WoW API Source | Storage |
|----------|-----------|----------------|---------|
| Deaths | Cause, zone, level, killer, overkill, timestamp | `COMBAT_LOG_EVENT_UNFILTERED`, `PLAYER_DEAD`, `UNIT_DIED` | Per-character log |
| Movement | Distance (yards), zones visited, time per zone | `GetPlayerMapPosition()` polling (5s) | Cumulative counter |
| Playtime | Total /played, session time, time per level/zone | `TIME_PLAYED_MSG`, session clock | Per-character stats |
| Mob Kills | Name, level, type, zone, timestamp, XP | `COMBAT_LOG_EVENT_UNFILTERED` (UNIT_DIED) | Counter + log |
| Fishing | Fish caught, type, time, skill changes | `LOOT_OPENED` (fishing context), `SKILL_LINES_CHANGED` | Counter + log |
| Dungeons | Instance name, entry/exit time, wipe count, clear status | `ZONE_CHANGED_NEW_AREA`, `IsInInstance()` | Per-instance log |
| Bosses | Name, kill time, survivors, damage, healing | `BOSS_KILL`, `ENCOUNTER_END`, combat log | Per-boss log |
| Equipment | Gear snapshots at key moments | `PLAYER_EQUIPMENT_CHANGED`, manual triggers | Snapshot array |
| Trading | Partner, items, gold, AH listings, mail | `TRADE_SHOW`, `MAIL_SHOW`, `AUCTION_HOUSE_SHOW` | Transaction log |
| Combat | DPS/HPS samples, damage taken, duration | `COMBAT_LOG_EVENT_UNFILTERED` parsing | Rolling averages |

---

## Data Integrity

- **Inventory Hash Snapshots:** Periodic hashes to detect item duplication/injection
- **Cross-Verification:** Group members' addons cross-verify kills and loot
- **Community Flagging:** Players flag suspicious deaths/achievements for GM review
- **Timestamp Anchoring:** Local time + server time to prevent clock manipulation

---

## Performance

- Combat log parsing: per-event with early-exit checks
- Movement tracking: 5-second polling (not per-frame)
- Data serialization: batched during loading screens or logout
- Historical data >30 days: compressed/archived to reduce SavedVariables size
