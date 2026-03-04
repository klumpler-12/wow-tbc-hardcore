# WoW TBC Hardcore: Master Technical Project Plan

This document serves as the central architectural blueprint and milestone tracker for the entire TBC Hardcore project. The absolute priority is the core **LUA Addon tracking engine** running in the 2.4.3 client, validating that dynamic Hardcore rulesets and synchronized death events are technically feasible before scaling up the web presence.

---

## 📌 Phase 1: Environment & Hello World PoC (Status: Completed)
**Objective:** Establish a safe, offline testing environment and successfully execute a basic LUA trace inside a WoW 2.4.3 client.

### Strategy
* **Safe Sandbox:** Set up a local CMaNGOS TBC server via Docker to prevent any interaction with official Blizzard retail servers.
* **Addon Scaffold:** Learn the basic structure of WoW Addons (`.toc` manifest and `.lua` logic) and how to load them.
* **Execution:** Successfully hook into `ADDON_LOADED` and print a "Hello World" trace to the default chat frame.

### Steps Reached
- [x] Researched safe ToS environments (CMaNGOS TBC Docker).
- [x] Defined Hardcore Rulesets and scope on advertisement website (`development.html`).
- [x] Built the first functional LUA Addon rendering a basic frame.
- [x] Pushed web marketing materials to GitHub / Local Raspberry Pi.

---

## 📌 Phase 2: Communication PoC (Status: Active)
**Objective:** Prove that two separate LUA addons on different game clients can communicate custom data synchronously without requiring an external database.

### Strategy
* **The Problem:** Private TBC servers do not have modern synchronized tracking databases out-of-the-box. We cannot easily track Guild Rulesets if players run the addon independently.
* **The Solution:** We must exploit the hidden addon communication channel API: `C_ChatInfo.SendAddonMessage` (or the 2.4.3 equivalent `SendAddonMessage`).
* **The Test:** Create a command `/tbchc ping` that broadcasts a hidden message to the guild channel. Any other player with the addon must receive that message and print "Pong received from [Player]" in their local chat window. This proves rulesets and death notifications can be managed purely in-game.

### Subtasks
- [ ] Determine the exact 2.4.3 signature for `SendAddonMessage("prefix", "text", "type", "target")`.
- [ ] Hook into the `CHAT_MSG_ADDON` event listener to catch incoming hidden broadcasts.
- [ ] Execute a successful Ping/Pong sequence between two LUA clients in the CMaNGOS sandbox.
- [ ] Build a serialization function that converts a simple table (e.g. `{mode="HCP", lives=1}`) into a broadcastable string and parses it back securely.

---

## 📌 Phase 3: Core LUA Engine & Death Tracking
**Objective:** Develop the deeply integrated LUA logic necessary to track player state, deaths, level-ups, and enforce hardcore rulesets. 

### Strategy
* **Authentic Death Engine:** Relying purely on `PLAYER_DEAD` triggers false positives via Warlock Soulstones, Shaman Reincarnation, or Hunter Feign Death. We must synthesize `UNIT_DIED`, `UNIT_HEALTH` <= 1, and aura scanning to confirm an absolute permanent death.
* **Saved Variables:** Changes to rulesets and death events must persist through re-logs. We must configure standard Ace3 Database management (`SavedVariables.lua`).

### Subtasks
- [ ] Implement multi-step authentic Death Verification Engine to filter false positives.
- [ ] Hook into `UNIT_INVENTORY_CHANGED` to monitor gear wipes (Hybrid Hardcore penalty).
- [ ] Write SSF Enforcer logic (Trading/Mailbox/AH blocking hooks).
- [ ] Structure the local Save file to securely lock configuration changes into `TBCHardcoreDB`.

---

## 📌 Phase 4: The Desktop Bridge & Web-App Backend
**Objective:** Only after the Addon successfully tracks deaths locally, we engineer the cloud infrastructure and the secure desktop bridge relay that transmits local WoW data to the global website.

### Strategy
* **The Bridge Problem:** Web browsers and cloud servers cannot read local game files (`SavedVariables.lua`).
* **The Bridge Solution:** Construct an Electron Companion App. This lightweight local daemon monitors file-write events on `WTF/Account/.../SavedVariables.lua`. 
* **Security:** Upon a `PLAYER_DEAD` write, the app immediately hashes the payload using an HMAC-SHA256 local secret to prevent API spoofing, and securely transmits it via WebSocket to the central server.
* **Backend:** Node.js API Gateway, MongoDB tracking leaderboard scores.

### Subtasks
- [ ] Setup Node.js REST API Gateway with JWT.
- [ ] Design MongoDB schema design: Players (Scores, Deaths), Guilds (Rulesets).
- [ ] Develop basic Electron Companion App UI (Select WoW Directory).
- [ ] Implement file system watcher (`fs.watch`) in Electron for `SavedVariables.lua`.
- [ ] Implement HMAC payload hashing to protect against API spoofing.

---

## 📌 Phase 5: Streamer Mechanics & Twitch Extension 
**Objective:** Implement the interactive spectator ecosystem, penalty wheel, and OBS overlays governed by the official Twitch Developer API.

### Strategy
* **Execution Layer:** A viewer spends Twitch Bits on the 'Penalty Wheel'. Our Twitch Backend Service (EBS) routes a secure WebSocket notification to the specific streamer's Electron Companion App, which instantly injects a trigger to the local Addon, executing the penalty (e.g., forced RP walk or item deletion).

### Subtasks
- [ ] Register Twitch Developer Organization and provision API secrets.
- [ ] Build secure Twitch Extension Backend Service endpoints.
- [ ] Engineer Addon hooks to securely execute localized UI penalties from external triggers via the Companion App bridge.
