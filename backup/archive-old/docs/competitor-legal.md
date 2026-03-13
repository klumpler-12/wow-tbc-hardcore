# AIINFO: Competitor & Legal Research for WoW TBC Hardcore Addon
Date: March 2026

## 1. Competitor Analysis (Classic WoW & TBC Addons)

### 1.1 "Hardcore" (Defias Pillager / Official Classic Era)
- **Status:** Highly active, supported officially by Blizzard on Era servers.
- **Core Features:** Strict death=delete, no trading, no AH.
- **Where we win:** TBC compatibility. Official HC doesn't support Outland. They lack the "Hybrid" modularity for GM rules.
- **Lessons Learned:** Verification strings (hashing combat logs to prevent cheating) are essential.

### 1.2 "Hardcore Addon" (Community original, updated late 2024/2025)
- **Status:** The gold standard for community tracking before official servers.
- **Core Features:** Addon-based SSF enforcement, automated appeals via Discord webhooks, achievement tracker.
- **Where we win:** Streamer integration (gear wagers, penalty spin wheels via Twitch Chat) and Guild-level scoring.
- **Limitations:** Too rigid. It forces one playstyle. Our addon thrives on "⚙️ Guild Master Ruleset Customization".

### 1.3 "Deathlog" (Updated 2024)
- **Status:** Widely used alongside official HC.
- **Core Features:** Global death announcements, heatmap of dangerous zones, death statistics.
- **Where we win:** Deathlog is passive observation. We are active enforcement (punishments, score drops, gear wipes).
- **Integration Idea:** Pull heatmap data from Deathlog API to visualize "Zone Danger Ranks" in our app.

### 1.4 "RestedXP Survival" (Updated 2025)
- **Status:** Premium leveling guide adapted for Hardcore.
- **Core Features:** Warns about elite patrols, unsafe quests, provides a safe route.
- **Where we win:** Not a direct competitor. RXP helps you *survive*. We manage the *rules* of survival and the metagame.

---

## 2. Legal Research & Considerations

### 2.1 Blizzard Terms of Service (ToS) compliance
- **Monetization:** Blizzard's Addon Policy explicitly forbids putting addon features behind a paywall (Patreon-only addon features are banned).
  - *Strategy:* The addon MUST be 100% free. Monetization must come from the Web App companion, Twitch extension features, or optional cosmetic donations that don't alter the Lua code.
- **Automation / Botting:** Addons cannot automate combat or movement.
  - *Strategy:* Our Anti-Boost radar and Penalty Gear Wipes must rely on `DestroyCursorItem()` or similar API calls that might require hardware events (clicking to confirm). If automatic gear deletion is blocked by Blizzard API limits, the addon must instead apply a "Debuff" or "Equip Lock" until the player manually deletes the item and verifies it.
- **Chat/Social APIs:** Reading party levels for Anti-Boost is perfectly fine within the API.

### 2.2 Twitch Extension Guidelines
- **Gambling Rules:** Twitch strictly regulates gambling. "Gear Battle Wagers" must not involve real money or Bits directly tied to the chance of losing.
  - *Strategy:* Wagers are purely in-game items and addon-score. If Viewers trigger "Penalty Wheel", they can use Bits to buy a spin, but they aren't "winning" a monetary prize, only causing an in-game event. This complies with Twitch Interactive guidelines (similar to Crowd Control).

---
## Summary of Actionable Mechanics
1. **Verification Hash:** Must implement log-hashing to prevent players from editing local DBs to restore dead characters.
2. **GM Controls:** Need to store GM rulesets in Guild Info or Web API, so the addon syncs the correct difficulty for the whole guild.
3. **Item Deletion:** Investigate WoW API `PickupInventoryItem` and `DeleteCursorItem`. If protected during combat, defer penalty processing until out of combat.
