# TBC Hybrid Hardcore — Testing Checklist & Test Plan

> **Version:** 2.0 (aligned with PROJECT_PLAN_REVISED.md)
> **Last Updated:** 2026-03-17
> **Target:** Public Alpha by April 30, 2026
> **Status**: ✅ Pass | ❌ Fail | ⚠️ Partial | 🔲 Not Tested | 🚫 Blocked | N/A Not Applicable

---

## Test Plan Overview

### Phase-Priority Map

| Phase | Window | Focus | Test Sections |
|-------|--------|-------|---------------|
| **0 — Pre-Alpha PoC** | Mar 17–23 | Validate existing code with 2-3 players | §1–§7, §10 |
| **0.5 — Clean Rebuild** | Mar 24–30 | Modular architecture, all trackers wired | §8, §11 |
| **1 — Semi-Private Alpha** | Mar 31 – Apr 20 | 10-20 testers, all core features, bug-fix | §1–§14 (full) |
| **2 — Public Alpha** | Apr 21–30 | CurseForge release, hotfix pipeline | Regression of all §, §15 |

### Alpha-Critical Features (must pass before CurseForge)

| Feature | Modules | Sections |
|---------|---------|----------|
| Death tracking + permadeath | `Tracking/DeathTracker.lua`, `Core.lua` | §5, §6, §7 |
| Checkpoint (boosted 58, GF, SSF soft reset) | `Systems/Checkpoint.lua`, `Systems/SoftReset.lua` | §9 |
| Instance lifes (+1 bonus model) | `Tracking/InstanceTracker.lua`, `Constants.lua` | §10 |
| Network peer verification (experimental, toggleable) | `Network/Heartbeat.lua`, `Network/Protocol.lua`, `Network/Verification.lua` | §12 |
| Comprehensive tracking (record everything) | All `Tracking/*.lua`, `Core.lua` | §11 |
| Setup wizard + registration | `Systems/Registration.lua`, `UI/SetupWizard.lua` | §4 |

### How to Use This Checklist

1. Work through sections in order during Phase 0.
2. Fill in **Status** column (✅/❌/⚠️/🔲).
3. Add notes on **any** deviation from expected behavior.
4. For fails: note reproduction steps and severity (P0–P3).
5. Return completed checklist for triage and next-cycle fixes.

---

## §1 — Installation & Load

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 1 | Copy `addon/HardcorePlus/` to `Interface/AddOns/` — folder structure intact | 🔲 | |
| 2 | Addon listed in character-select addon panel | 🔲 | |
| 3 | Addon loads without Lua errors on login (check `/console` or BugSack) | 🔲 | |
| 4 | Chat message: `HardcorePlus v0.1.0-alpha loaded` | 🔲 | |
| 5 | All Ace3 libs load (AceAddon, AceDB, AceEvent, AceTimer, AceComm, AceSerializer, AceConsole) | 🔲 | |
| 6 | LibDataBroker + LibDBIcon load (minimap button registers) | 🔲 | |
| 7 | No taint warnings from Blizzard secure frames | 🔲 | |
| 8 | Load with 0 other addons → no errors | 🔲 | |
| 9 | Load alongside Details!, DBM, Questie → no errors or conflicts | 🔲 | |

---

## §2 — Minimap Button

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 10 | Skull icon visible on minimap after login | 🔲 | |
| 11 | Left-click toggles main panel open/close | 🔲 | |
| 12 | Right-click opens AceConfig settings | 🔲 | |
| 13 | Tooltip on hover shows: status, level, deaths, SoI state | 🔲 | |
| 14 | Shift+drag repositions around minimap ring | 🔲 | |
| 15 | Position persists across sessions (SavedVariables) | 🔲 | |
| 16 | Hide minimap button in settings → button disappears | 🔲 | |
| 17 | Re-enable minimap button in settings → button reappears | 🔲 | |

---

## §3 — Main Panel & UI Shell

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 18 | Panel appears centered (or remembered position) | 🔲 | |
| 19 | Panel is draggable via header bar | 🔲 | |
| 20 | ESC closes the panel (added to UISpecialFrames) | 🔲 | |
| 21 | Close button (X) works | 🔲 | |
| 22 | Header: "HARDCOREPLUS" in gold (#e8a624), version in grey | 🔲 | |
| 23 | Status line shows current status with correct color coding | 🔲 | |
| 24 | Character info: name, level, class, deaths, SoI indicator | 🔲 | |
| 25 | Gold accent line under header visible | 🔲 | |
| 26 | Tabs visible: Overview, Deaths, Lifes, Network, Flags, Debug | 🔲 | |
| 27 | Clicking a tab switches content; only one tab active | 🔲 | |
| 28 | Active tab = gold text + gold underline | 🔲 | |
| 29 | Inactive tab = dim text; hover brightens background | 🔲 | |
| 30 | Panel position persists across sessions | 🔲 | |

### Visual Canon (HC Website Color Match)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 31 | Background dark (#0a0a0f range) | 🔲 | |
| 32 | Gold accent matches website (#e8a624) | 🔲 | |
| 33 | Text colors match website palette (#e0ddd5 / #8a877f) | 🔲 | |
| 34 | Border subtle dark (#2a2a3a), not bright | 🔲 | |
| 35 | Overall feel: belongs to the HC website aesthetic | 🔲 | |

---

## §4 — Setup Wizard & Registration

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 36 | Wizard appears ~2s after first login (unregistered char) | 🔲 | |
| 37 | Wizard does NOT appear if char already registered | 🔲 | |
| 38 | **Step 1 — Welcome:** shows char name, class, race, level | 🔲 | |
| 39 | **Step 2 — Freshness:** checks run (level, gold, profs, talents, gear, bags) | 🔲 | |
| 40 | Each freshness check: green ✓ or red ✗ | 🔲 | |
| 41 | Fresh char (lvl 1-5, no gold, no profs) → all pass | 🔲 | |
| 42 | Progressed char → some fail, "Late Registration" path offered | 🔲 | |
| 43 | **Step 3 — Settings:** trade mode radio (SSF / Guildfound / Open) | 🔲 | |
| 44 | **Step 3:** Instance Lifes toggle (Enable / Disable) | 🔲 | |
| 45 | **Step 3:** Checkpoint toggle (Enable / Disable) | 🔲 | |
| 46 | Disabling both lifes + checkpoint → "Juggernaut" title preview | 🔲 | |
| 47 | **Step 4 — Summary:** all chosen settings displayed | 🔲 | |
| 48 | "CONFIRM HC REGISTRATION" button registers character | 🔲 | |
| 49 | After registration: status = "Pending" | 🔲 | |
| 50 | After registration: settings locked in AceConfig (read-only) | 🔲 | |
| 51 | Wizard does not reappear on next login | 🔲 | |
| 52 | Late Registration: status = "Late Registration" instead of "Pending" | 🔲 | |

### Freshness Thresholds (Constants.lua)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 53 | MAX_LEVEL check: level ≤ 5 passes, level 6+ fails | 🔲 | |
| 54 | MAX_GOLD check: gold ≤ 5000 copper (50s) passes | 🔲 | |
| 55 | MAX_PLAYED check: /played ≤ 7200s (2h) passes | 🔲 | |

---

## §5 — Death Detection

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 56 | Die to mob → "DEATH RECORDED" message in chat | 🔲 | |
| 57 | Death record includes: killer name, ability, zone, subzone, level, timestamp | 🔲 | |
| 58 | Death count increments in `/hcp status` | 🔲 | |
| 59 | Death appears in Deaths tab of main panel | 🔲 | |
| 60 | **Open world** death → message: "Open world death — this is PERMANENT" | 🔲 | |
| 61 | **Instance** death → message: "Instance death — checking lifes..." | 🔲 | |
| 62 | Multiple deaths in quick succession don't double-count (5s debounce) | 🔲 | |
| 63 | `/hcp deaths` prints last 5 deaths in chat | 🔲 | |
| 64 | Death via SWING_DAMAGE captured correctly (melee mob) | 🔲 | |
| 65 | Death via SPELL_DAMAGE captured correctly (caster mob) | 🔲 | |
| 66 | Death via ENVIRONMENTAL_DAMAGE (fall, drown, lava) captured | 🔲 | |
| 67 | Death while disconnected/lag → captured on reconnect via PLAYER_DEAD backup | 🔲 | |
| 68 | Overkill amount recorded in death context | 🔲 | |
| 69 | Inventory hash + gold snapshot taken at moment of death | 🔲 | |

### Death Record Data Completeness

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 70 | `timestamp` present and accurate (server time) | 🔲 | |
| 71 | `level` matches player level at death | 🔲 | |
| 72 | `zone` + `subzone` recorded correctly | 🔲 | |
| 73 | `killerName` populated (mob name or environment type) | 🔲 | |
| 74 | `inInstance` flag set correctly (true inside dungeon/raid) | 🔲 | |
| 75 | `instanceType` populated for instance deaths (party/raid) | 🔲 | |
| 76 | Death stored in `char.deaths[]` array in SavedVariables | 🔲 | |

---

## §6 — Death Log UI (Deaths Tab)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 77 | Deaths tab: "No deaths recorded" when clean | 🔲 | |
| 78 | After death: entry with #, killer, ability, zone, level, timestamp | 🔲 | |
| 79 | Instance deaths show `[INST]` tag in blue | 🔲 | |
| 80 | Shows up to 10 most recent deaths (scrollable if more) | 🔲 | |
| 81 | Death text colors match severity (red for permadeath, gold for instance) | 🔲 | |

---

## §7 — Death Monitor Widget

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 82 | Monitor widget appears after registration (top-right area) | 🔲 | |
| 83 | Shows: status text, death count, current zone | 🔲 | |
| 84 | Green dot = addon tracking normally | 🔲 | |
| 85 | Red dot = dead status | 🔲 | |
| 86 | Gold dot = has flags/violations | 🔲 | |
| 87 | Widget is draggable | 🔲 | |
| 88 | Right-click minimizes to single line | 🔲 | |
| 89 | `/hcp monitor` toggles widget on/off | 🔲 | |
| 90 | Widget updates live after death (count, status, color) | 🔲 | |
| 91 | Zone text updates when moving between areas | 🔲 | |
| 92 | Instance zone names show in blue | 🔲 | |
| 93 | Widget position persists across sessions | 🔲 | |

---

## §8 — Slash Commands

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 94 | `/hcp` shows help text with all available commands | 🔲 | |
| 95 | `/hcp show` toggles main panel | 🔲 | |
| 96 | `/hcp status` prints status summary (status, level, deaths, SoI, lifes) | 🔲 | |
| 97 | `/hcp deaths` prints death log (last 5 or "no deaths") | 🔲 | |
| 98 | `/hcp lives` prints instance lifes info | 🔲 | |
| 99 | `/hcp config` opens AceConfig settings panel | 🔲 | |
| 100 | `/hcp monitor` toggles death monitor widget | 🔲 | |
| 101 | `/hcp debug` toggles debug mode (alpha-only) | 🔲 | |
| 102 | Unknown subcommand → shows help text, not error | 🔲 | |

---

## §9 — Checkpoint System

### Boosted 58 Checkpoint

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 103 | Checkpoint system enabled in registration wizard | 🔲 | |
| 104 | Checkpoint token generated on permadeath (if checkpoint enabled) | 🔲 | |
| 105 | Token stored in `global.checkpointTokens[]` (SavedVariables) | 🔲 | |
| 106 | Token contains: original char name, level at death, death cause, timestamp | 🔲 | |
| 107 | New character can claim a checkpoint token during setup wizard | 🔲 | |
| 108 | Claiming token sets starting level to 58 | 🔲 | |
| 109 | Token consumed after use (cannot reuse) | 🔲 | |
| 110 | Character created with boosted_58 tagged in SavedVariables | 🔲 | |
| 111 | Checkpoint panel (UI) shows available tokens | 🔲 | |
| 112 | Checkpoint panel shows token details (origin char, death info) | 🔲 | |

### Soft Reset — GF (Guildfound)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 113 | GF soft reset available after level 58+ death (if trade mode = Guildfound/Open) | 🔲 | |
| 114 | Soft reset panel shows requirements and current state | 🔲 | |
| 115 | Gold transferred during soft reset (up to SoftResetConfig.MAX_GOLD = 1g) | 🔲 | |
| 116 | Completion window enforced (SoftResetConfig.COMPLETION_WINDOW = 2h /played) | 🔲 | |
| 117 | After soft reset: status = "Soft Reset", tagged in SavedVariables | 🔲 | |
| 118 | Soft reset character can proceed normally after completion | 🔲 | |

### Soft Reset — SSF

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 119 | SSF soft reset available after level 58+ death (if trade mode = SSF) | 🔲 | |
| 120 | SSF reset does NOT allow gold transfer (SSF rules enforced) | 🔲 | |
| 121 | SSF character can group for instances but cannot trade items/gold | 🔲 | |
| 122 | Status tagged as "Soft Reset (SSF)" in SavedVariables | 🔲 | |

### Checkpoint Edge Cases

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 123 | Death below level 58 → NO checkpoint token generated | 🔲 | |
| 124 | Character with checkpoint disabled → NO token on death | 🔲 | |
| 125 | Multiple tokens from multiple deaths → all stored, selectable | 🔲 | |
| 126 | Token from different server → cannot be claimed (server mismatch check) | 🔲 | |
| 127 | "Juggernaut" title holder dies → NO checkpoint (both disabled) | 🔲 | |

---

## §10 — Instance Lifes (+1 Bonus Model)

### Core Mechanics

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 128 | Enter qualifying heroic dungeon → lifes display shows "1 + 1 bonus = 2 total" | 🔲 | |
| 129 | Enter qualifying raid → lifes display shows "1 + 1 bonus = 2 total" | 🔲 | |
| 130 | Enter NON-qualifying dungeon (normal mode) → "0 bonus lifes — permadeath" | 🔲 | |
| 131 | Enter NON-qualifying dungeon (easy heroic not in list) → "0 bonus lifes" | 🔲 | |
| 132 | First death in qualifying instance → life deducted, message: "1 life remaining" | 🔲 | |
| 133 | Second death in qualifying instance → PERMADEATH enforced | 🔲 | |
| 134 | First death in NON-qualifying instance → PERMADEATH (no bonus) | 🔲 | |

### Qualifying Instance Verification (Constants.lua)

Test each instance in `HCP.BonusLifeHeroics`:

| # | Instance | Heroic? | Bonus? | Status | Notes |
|---|----------|---------|--------|--------|-------|
| 135 | The Shattered Halls | Heroic | +1 | 🔲 | |
| 136 | Magisters' Terrace | Heroic | +1 | 🔲 | |
| 137 | Shadow Labyrinth | Heroic | +1 | 🔲 | |
| 138 | The Arcatraz | Heroic | +1 | 🔲 | |
| 139 | Opening of the Dark Portal | Heroic | +1 | 🔲 | |
| 140 | The Steamvault | Heroic | +1 | 🔲 | |
| 141 | Sethekk Halls | Heroic | +1 | 🔲 | |

Test each instance in `HCP.BonusLifeRaids`:

| # | Instance | Bonus? | Status | Notes |
|---|----------|--------|--------|-------|
| 142 | Serpentshrine Cavern | +1 | 🔲 | |
| 143 | Tempest Keep (The Eye) | +1 | 🔲 | |
| 144 | Hyjal Summit | +1 | 🔲 | |
| 145 | Black Temple | +1 | 🔲 | |
| 146 | Sunwell Plateau | +1 | 🔲 | |
| 147 | Zul'Aman | +1 | 🔲 | |
| 148 | Gruul's Lair | +1 | 🔲 | |

### Negative Tests (should NOT grant bonus)

| # | Instance | Mode | Expected | Status | Notes |
|---|----------|------|----------|--------|-------|
| 149 | The Shattered Halls | Normal | 0 bonus | 🔲 | |
| 150 | Karazhan | Raid | 0 bonus | 🔲 | |
| 151 | Magtheridon's Lair | Raid | 0 bonus | 🔲 | |
| 152 | Slave Pens | Heroic | 0 bonus | 🔲 | |
| 153 | Underbog | Heroic | 0 bonus | 🔲 | |
| 154 | Any Classic dungeon | Normal | 0 bonus | 🔲 | |

### Instance Lifes UI (Lifes Panel)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 155 | Lifes tab shows current instance info when inside instance | 🔲 | |
| 156 | Lifes tab shows "Not in instance" when in open world | 🔲 | |
| 157 | Bonus lifes count displayed correctly | 🔲 | |
| 158 | After death in instance: lifes count decrements in real-time | 🔲 | |
| 159 | Weekly pool display (HCP.WeeklyPoolDefault = 10) shows correctly | 🔲 | |

### `HCP.GetBonusLives()` Function

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 160 | `GetBonusLives("The Shattered Halls", true)` → returns 1 | 🔲 | |
| 161 | `GetBonusLives("The Shattered Halls", false)` → returns 0 | 🔲 | |
| 162 | `GetBonusLives("Serpentshrine Cavern", true)` → returns 1 | 🔲 | |
| 163 | `GetBonusLives("Serpentshrine Cavern", false)` → returns 1 (raids always qualify) | 🔲 | |
| 164 | `GetBonusLives("Karazhan", true)` → returns 0 | 🔲 | |
| 165 | `GetBonusLives("Random Dungeon", false)` → returns 0 | 🔲 | |

---

## §11 — Tracking Fundamentals

### Goal: Record EVERYTHING, Calculate NOTHING (Yet)

These trackers collect data for future retrospective scoring. They must be lightweight and not spam the client.

### Session & Uptime Tracking (`Tracking/UptimeTracker.lua`)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 166 | `/played` requested on login (silent — no chat spam) | 🔲 | |
| 167 | Session start time recorded in SavedVariables | 🔲 | |
| 168 | Periodic `/played` requests every 2 min (silent) | 🔲 | |
| 169 | ChatFrame_DisplayTimePlayed hook suppresses `/played` output | 🔲 | |
| 170 | On re-login after normal logout: no violation | 🔲 | |
| 171 | Session count increments correctly across multiple logins | 🔲 | |
| 172 | Total /played value stored and updated in SavedVariables | 🔲 | |

### Gap Detection & Violations

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 173 | Gap < 15 min (grace period) → IGNORED, no violation | 🔲 | |
| 174 | Gap ≥ 15 min, NO gains → MINOR VIOLATION message | 🔲 | |
| 175 | Minor violation counter shows in chat (X/5 this week) | 🔲 | |
| 176 | Gap ≥ 15 min WITH gains (gold/items/level) → MAJOR VIOLATION | 🔲 | |
| 177 | Major violation lists detected changes (inventory, gold, level, profs) | 🔲 | |
| 178 | 5+ minor violations/week → escalation warning message | 🔲 | |
| 179 | Violations appear in Flags tab | 🔲 | |
| 180 | Flags tab shows: severity, gap duration, details, timestamp | 🔲 | |

### Death Tracking Data (`Tracking/DeathTracker.lua`)
(Covered in §5 — cross-reference)

### Verification Tracking (`Tracking/VerificationTracker.lua`)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 181 | Inventory hash computed periodically (every ~10 min or on change) | 🔲 | |
| 182 | Gold snapshot taken periodically (every ~5 min) | 🔲 | |
| 183 | Equipment snapshot taken on level-up | 🔲 | |
| 184 | Equipment snapshot taken on death | 🔲 | |
| 185 | Profession changes detected and logged | 🔲 | |
| 186 | All snapshots stored in SavedVariables with timestamps | 🔲 | |

### Instance Tracking (`Tracking/InstanceTracker.lua`)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 187 | Instance entry detected (zone change to instance) | 🔲 | |
| 188 | Instance exit detected (return to open world) | 🔲 | |
| 189 | Instance name + type recorded | 🔲 | |
| 190 | Heroic vs normal difficulty detected correctly (GetInstanceDifficulty) | 🔲 | |
| 191 | Entry/exit timestamps stored | 🔲 | |
| 192 | Instance reload detection: addon loading inside instance → WARNING flag | 🔲 | |

### Future Trackers (Phase 0.5 — Verify Hooks Ready)

These modules may not exist yet. Check if event hooks are registered:

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 193 | PLAYER_LEVEL_UP event handled → level snapshot created | 🔲 | |
| 194 | PLAYER_MONEY event hookable for gold tracking | 🔲 | |
| 195 | TRADE_ACCEPT_UPDATE event hookable for trade logging | 🔲 | |
| 196 | MAIL_SEND_SUCCESS event hookable for mail logging | 🔲 | |
| 197 | LOOT_OPENED event hookable for loot/fishing tracking | 🔲 | |
| 198 | COMBAT_LOG_EVENT_UNFILTERED already parsed for kills | 🔲 | |

### Tracking Performance

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 199 | No FPS drop during combat with all trackers active | 🔲 | |
| 200 | SavedVariables file size after 2h session: note size | 🔲 | Size: _____ KB |
| 201 | Memory usage (GetAddOnMemoryUsage): note amount | 🔲 | Memory: _____ KB |
| 202 | No chat spam from tracking systems | 🔲 | |
| 203 | 100+ mob kills in one session → no lag | 🔲 | |

---

## §12 — Network Peer Verification (Experimental)

### Heartbeat System (`Network/Heartbeat.lua`)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 204 | Heartbeat broadcasts every 60s (HCP.Net.HEARTBEAT_INTERVAL) | 🔲 | |
| 205 | Heartbeat includes: player status, level, death count | 🔲 | |
| 206 | Peers appear in peer registry after receiving heartbeat | 🔲 | |
| 207 | Peer timeout after 5 min (HCP.Net.PEER_TIMEOUT) of no heartbeat | 🔲 | |
| 208 | PENDING auto-promotion to UNVERIFIED after 5 min with no peers | 🔲 | |
| 209 | Network tab shows connected peers with status | 🔲 | |

### Protocol (`Network/Protocol.lua`)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 210 | Messages use "HCPlus" prefix (HCP.Net.PREFIX) | 🔲 | |
| 211 | AceComm message serialization works (no corruption) | 🔲 | |
| 212 | Messages received from non-addon players → ignored gracefully | 🔲 | |
| 213 | Large messages chunked correctly (AceComm handles this) | 🔲 | |

### Peer Verification (`Network/Verification.lua`)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 214 | Hash broadcast every 5 min (HCP.Net.HASH_INTERVAL) | 🔲 | |
| 215 | Peer compares hashes → match = no action | 🔲 | |
| 216 | Peer hash mismatch → flag for review (not auto-punish) | 🔲 | |
| 217 | Death event broadcast to group members | 🔲 | |
| 218 | Group members confirm death reception | 🔲 | |
| 219 | Toggleable: disable peer verification → no network traffic except heartbeat | 🔲 | |

### Network Edge Cases

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 220 | Solo player (no peers) → verification gracefully disabled | 🔲 | |
| 221 | Player in full raid (25 players) → heartbeat doesn't flood | 🔲 | |
| 222 | Cross-guild players in same group → can verify each other | 🔲 | |
| 223 | Player disconnects mid-instance → group warned (out of combat only) | 🔲 | |
| 224 | Reconnect within grace period (5 min) → tracking resumes | 🔲 | |
| 225 | Reconnect AFTER grace period → status flagged "contested" | 🔲 | |

---

## §13 — Soul of Iron Detection

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 226 | Char with SoI buff → "Soul of Iron detected!" | 🔲 | |
| 227 | SoI scan runs every ~30s (no performance impact) | 🔲 | |
| 228 | SoI detected → status transitions to "Verified" (from Pending/Unverified) | 🔲 | |
| 229 | Losing SoI buff without death → WARNING + high severity flag | 🔲 | |
| 230 | Losing SoI via death → "Soul of Iron lost due to death" (expected) | 🔲 | |
| 231 | After level 58: SoI marked "unreliable" in display | 🔲 | |
| 232 | SoI status shows "Active (unreliable — Lvl 58+)" after 58 | 🔲 | |

---

## §14 — Status State Machine

### Valid Transitions

| # | Transition | Trigger | Status | Notes |
|---|-----------|---------|--------|-------|
| 233 | PENDING → VERIFIED | SoI buff detected | 🔲 | |
| 234 | PENDING → UNVERIFIED | 5 min with no peers, no SoI | 🔲 | |
| 235 | UNVERIFIED → VERIFIED | SoI detected | 🔲 | |
| 236 | VERIFIED → TARNISHED | SoI lost / instance death | 🔲 | |
| 237 | VERIFIED → DEAD | Open world death | 🔲 | |
| 238 | TARNISHED → DEAD | Open world death | 🔲 | |
| 239 | UNVERIFIED → DEAD | Open world death | 🔲 | |
| 240 | DEAD → SOFT_RESET | Soft reset initiated | 🔲 | |
| 241 | LATE_REG → VERIFIED | SoI detected | 🔲 | |
| 242 | LATE_REG → DEAD | Open world death | 🔲 | |

### Invalid Transitions (must be blocked)

| # | Transition | Status | Notes |
|---|-----------|--------|-------|
| 243 | DEAD → VERIFIED | 🔲 | Should be blocked |
| 244 | DEAD → PENDING | 🔲 | Should be blocked |
| 245 | SOFT_RESET → DEAD (without new reg) | 🔲 | Should be blocked |

### Status Display

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 246 | Status transitions print "OLD → NEW" in chat with reason | 🔲 | |
| 247 | Overview tab: full summary (status, SoI, deaths, lifes, integrity, session) | 🔲 | |
| 248 | Section headers in gold with underline | 🔲 | |
| 249 | Integrity section shows flag counts (major/minor breakdown) | 🔲 | |
| 250 | Session info: current uptime, total /played, session count | 🔲 | |
| 251 | Status color-coded in minimap tooltip | 🔲 | |
| 252 | `/hcp status` reflects current status correctly | 🔲 | |

---

## §15 — Settings & Debug Panel

### AceConfig Settings

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 253 | Settings panel opens without errors | 🔲 | |
| 254 | Shows registration status | 🔲 | |
| 255 | Minimap icon toggle (show/hide) works | 🔲 | |
| 256 | Violation tracking info displays correctly | 🔲 | |
| 257 | Settings persist across sessions | 🔲 | |

### Debug Panel (Alpha-Only)

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 258 | Debug tab visible (always in alpha builds) | 🔲 | |
| 259 | Master debug toggle works (HCP.DebugDefaults.enabled) | 🔲 | |
| 260 | Verbose mode toggle (detailed messages to chat) | 🔲 | |
| 261 | Individual system toggles work: | | |
| 261a | — Death tracking on/off | 🔲 | |
| 261b | — Uptime tracking on/off | 🔲 | |
| 261c | — SoI tracking on/off | 🔲 | |
| 261d | — Verification on/off | 🔲 | |
| 261e | — Network on/off | 🔲 | |
| 261f | — Instance lifes on/off | 🔲 | |
| 261g | — Checkpoint on/off | 🔲 | |
| 261h | — Soft reset on/off | 🔲 | |
| 262 | Disabling a system stops its tracking (no events processed) | 🔲 | |
| 263 | Re-enabling a system resumes tracking cleanly | 🔲 | |

---

## §16 — SavedVariables Integrity

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 264 | `HardcorePlusDB` exists after logout | 🔲 | |
| 265 | Data persists across sessions (re-login = same data) | 🔲 | |
| 266 | Global data present: settings, minimap, checkpointTokens, peerRegistry, debug | 🔲 | |
| 267 | Per-char data present: registration, deaths, instanceLives, weeklyPool, soulOfIron, sessions, violations, checkpoint, softReset | 🔲 | |
| 268 | DB_VERSION = 1 (HCP.DB_VERSION from Constants.lua) | 🔲 | |
| 269 | Corrupted SavedVariables → addon loads with defaults, no crash | 🔲 | |
| 270 | Delete SavedVariables file → addon recreates fresh DB on login | 🔲 | |

---

## Concept Visualizations

### How Death Tracking Works
```
Player in combat
    │
    ├── COMBAT_LOG_EVENT_UNFILTERED fires
    │   ├── SWING_DAMAGE to player → stored in recentDamage[] (last 5)
    │   ├── SPELL_DAMAGE to player → stored in recentDamage[]
    │   ├── ENVIRONMENTAL_DAMAGE → stored in recentDamage[]
    │   └── UNIT_DIED (player) → triggers OnPlayerDied()
    │
    └── PLAYER_DEAD event (backup) → triggers OnPlayerDied() if not already processed
            │
            ├── Build death record:
            │   ├── timestamp, zone, subzone, level
            │   ├── killer name + ability (from last recentDamage entry)
            │   ├── inInstance flag + instanceType
            │   └── inventoryHash + gold snapshot
            │
            ├── Store in deaths[] array, increment counters
            │   ├── Open world → openWorldDeaths++
            │   └── Instance → instanceDeaths++
            │
            └── Fire HCP_PLAYER_DEATH event
                ├── → VerificationTracker: status transition
                │   ├── Open world death → status = DEAD (permadeath)
                │   └── Instance death → status = TARNISHED
                ├── → DeathMonitor: update widget display
                └── → Network: broadcast DEATH_REPORT to peers
```

### How /played Gap Detection Works
```
SESSION START (addon loads)
    │
    ├── Record session start time
    ├── Snapshot: inventoryHash, gold, level, professions
    └── Request /played from server
            │
            ▼
TIME_PLAYED_MSG (server responds)
    │
    ├── Compare: totalPlayed (server) vs playedTotal (our last record)
    │   └── If gap exists (played advanced more than session time):
    │       └── Fire HCP_ADDON_GAP_DETECTED(gapMinutes)
    │
    └── Update playedTotal in SavedVariables
            │
            ▼
GAP ANALYSIS (UptimeTracker)
    │
    ├── Gap < 15 min? → IGNORED (grace period for crashes)
    │
    ├── Gap ≥ 15 min, NO gains?
    │   └── MINOR VIOLATION
    │       ├── Count toward weekly limit (5/week)
    │       └── 5+/week → escalation warning
    │
    └── Gap ≥ 15 min, WITH gains? (inventory/gold/level/prof changed)
        └── MAJOR VIOLATION
            ├── Peers confirm alive → Major flag, NOT permadeath
            └── No peer confirmation → PERMADEATH
```

### Instance Lifes Decision Flow
```
Player dies inside instance
    │
    ├── Is instance in BonusLifeHeroics AND heroic difficulty?
    │   └── YES → +1 bonus life granted
    │
    ├── Is instance in BonusLifeRaids?
    │   └── YES → +1 bonus life granted
    │
    └── Neither → 0 bonus lifes (permadeath on first death)
            │
            ▼
    Check remaining lifes for this instance
    │
    ├── lifes > 0? → Deduct 1 life, announce "X lifes remaining"
    │                 Status → TARNISHED
    │
    └── lifes == 0? → PERMADEATH
                      Status → DEAD
                      Fire enforcement (logout/deletion)
```

### Checkpoint Token Flow
```
Character DIES (permadeath)
    │
    ├── Is checkpoint system enabled for this character?
    │   ├── NO → Standard permadeath. No token.
    │   └── YES → Continue
    │
    ├── Was character level ≥ 58?
    │   ├── NO → No token (too low level for checkpoint)
    │   └── YES → Generate checkpoint token
    │       │
    │       ├── Token contains:
    │       │   ├── Original character name
    │       │   ├── Level at death
    │       │   ├── Death cause + killer
    │       │   ├── Timestamp
    │       │   └── Trade mode (SSF / GF / Open)
    │       │
    │       └── Store in global.checkpointTokens[]
    │
    ▼
NEW CHARACTER created
    │
    ├── Setup wizard detects available tokens
    │   └── Player selects token (or skips)
    │
    ├── Token claimed:
    │   ├── trade mode = SSF → SSF soft reset path
    │   ├── trade mode = GF/Open → GF soft reset path
    │   └── Starting level set to 58
    │
    └── Token consumed (removed from global pool)
```

### Status State Machine
```
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │  [New Character]                                            │
    │       │                                                     │
    │       ▼                                                     │
    │   ┌────────┐   SoI buff    ┌──────────┐                    │
    │   │PENDING │──detected────▶│ VERIFIED │                    │
    │   └────────┘               └──────────┘                    │
    │       │                         │                           │
    │       │                    SoI lost / instance death        │
    │   No SoI (5min)                │                           │
    │       │                         ▼                           │
    │       ▼                   ┌───────────┐                    │
    │  ┌────────────┐           │ TARNISHED │                    │
    │  │ UNVERIFIED │           └───────────┘                    │
    │  └────────────┘                │                           │
    │       │                   Open world death                  │
    │       │                        │                            │
    │       └───── OW death ────────▶│                            │
    │                                ▼                            │
    │                          ┌──────────┐                      │
    │                          │   DEAD   │                      │
    │                          └──────────┘                      │
    │                           │        │                        │
    │                    checkpoint    soft reset                  │
    │                           │        │                        │
    │                           ▼        ▼                        │
    │                    UNVERIFIED  SOFT_RESET                   │
    │                    (new char)  (same char, tagged)          │
    │                                                             │
    │  ┌────────────────┐                                        │
    │  │ LATE_REG       │  (existing progress chars)             │
    │  │ Can → VERIFIED │  (if SoI detected)                     │
    │  │ Can → DEAD     │  (on OW death)                         │
    │  └────────────────┘                                        │
    └─────────────────────────────────────────────────────────────┘
```

---

## Performance Checks

| # | Check | Status | Notes |
|---|-------|--------|-------|
| P1 | No noticeable FPS drop with addon loaded | 🔲 | |
| P2 | No Lua errors in `/console` during normal play | 🔲 | |
| P3 | Panel opens/closes without delay | 🔲 | |
| P4 | Death monitor widget doesn't cause lag | 🔲 | |
| P5 | SoI scan (every 30s) → no visible impact | 🔲 | |
| P6 | /played requests (every 2m) → don't spam chat | 🔲 | |
| P7 | Heartbeat broadcast (every 60s) → no lag in raids | 🔲 | |
| P8 | Hash broadcast (every 5m) → no lag | 🔲 | |
| P9 | SavedVariables write on logout → no hang | 🔲 | |
| P10 | Memory usage stays under 2MB during normal play | 🔲 | |

---

## General Feedback

### Bugs Found
| # | Description | Severity (P0/P1/P2/P3) | Reproduction Steps |
|---|-------------|------------------------|-------------------|
| | | | |

### Visual Issues
| # | What looks wrong | Suggestion |
|---|------------------|------------|
| | | |

### Feature Requests / Adjustments
| # | Description | Priority |
|---|-------------|----------|
| | | |

---

## State Report (fill before returning)

**Testing Environment:**
- WoW Client Version:
- Server (CMaNGOS / other):
- Character Level:
- Character Class:
- Other addons loaded:
- Testing date:
- Tester name:

**Phase 0 Gate Check:**
- [ ] §1 Installation passes (items 1-9)
- [ ] §5 Death detection works (items 56-69)
- [ ] §10 Instance lifes logic correct (items 128-134)
- [ ] §11 Tracking doesn't crash or spam (items 166-203)
- [ ] §16 SavedVariables persist correctly (items 264-270)
- [ ] No P0 blockers remain

**Phase 1 Gate Check:**
- [ ] All §1–§14 tested with 10+ testers
- [ ] §9 Checkpoint system works end-to-end
- [ ] §12 Network verification functions (basic)
- [ ] No P0 or P1 bugs remain
- [ ] Performance checks P1–P10 pass

**Overall Assessment:**
- [ ] Ready for Phase 0.5 (Clean Rebuild)
- [ ] Ready for Phase 1 (Semi-Private Alpha)
- [ ] Ready for Phase 2 (Public Alpha / CurseForge)
- [ ] Needs fixes before proceeding
- [ ] Major rework needed

**Priority Fix List (in order):**
1.
2.
3.
4.
5.

---

*Return this file with your feedback. I'll address all items before moving to the next phase gate.*
