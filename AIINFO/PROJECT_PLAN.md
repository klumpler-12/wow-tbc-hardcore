# WoW TBC Hardcore: Master Technical Project Plan

This document serves as the central architectural blueprint and milestone tracker for the entire TBC Hardcore project. It outlines the strategic goals, technical research, mitigating steps for Blizzard API compliance, and granular subtasks required for a successful Version 1.0 launch.

## 📌 Phase 1: Foundation, UI Mockups & Research (Status: In Progress)
**Objective:** Establish a high-performance web presence, finalize localization pipelines, and conduct critical legal/technical research regarding Twitch and Blizzard API integrations.

### Research & Strategy
* **Tech Stack:** Vanilla CSS, HTML5, Vanilla JavaScript. Avoiding heavy frameworks (React/Vue) ensures optimal load times for streamers embedding overlays.
* **Localization:** Implemented custom `data-i18n` attribute parsing. The dictionary object is loaded asynchronously to prevent render-blocking.
* **Legal Compliance:** Blizzard's Addon Policy explicitly forbids pay-to-win or direct monetary gating of addon features. Therefore, the Twitch Extension (Bits) must be entirely decoupled from the in-game Addon. The addon will only react to local file changes initiated by a separate Companion App.

### Subtasks
- [x] Initial Repository Setup & Git Configuration (GitHub Milestones active).
- [x] UI Design: Dark Mode, Glassmorphism & authentic TBC aesthetics.
- [x] HTML Structure: Mode Selection, Ideas Lab, Streamer Tools, Interactive Roadmap.
- [x] Addon Simulation UI: Gear Battle Wager animations and Penalty Wheels.
- [x] Core Documentation: Competitor & Legal Research documented within `AIINFO`.
- [x] Dynamic GitHub Milestone tracking integration on the frontend.
- [ ] Mobile Responsive Polish & Cross-Browser Testing for Safari/Firefox.

---

## 📌 Phase 2: Core Addon Architecture (Lua 5.1, WoW 2.4.3)
**Objective:** Develop the deeply integrated LUA addon logic necessary to track player state, deaths, penalties, and enforce hardcore rulesets without server-side validation.

### Research & Strategy
* **Authentic Death Engine:** Relying on `PLAYER_DEAD` triggers false positives via Warlock Soulstones, Shaman Reincarnation, or Hunter Feign Death. We must synthesize `UNIT_DIED`, `UNIT_HEALTH` <= 1, and aura scanning to confirm an absolute permanent death.
* **Guild Synchronization:** Since there is no modern synchronized server state for Vanilla servers, we exploit `C_ChatInfo.SendAddonMessage`. The Guild Master addon will serialize the active ruleset into a compressed string and broadcast it to the hidden `TBCHC` channel.

### Subtasks
- [ ] Scaffold standard WoW Addon architecture utilizing the Ace3 Framework for robust configuration management.
- [ ] Implement multi-step authentic Death Verification Engine to filter false positives.
- [ ] Event listeners: Hook into `UNIT_INVENTORY_CHANGED` for gear wiping penalties.
- [ ] Develop hidden Guild Communication channel for Ruleset Sync (`TBCHC` prefix).
- [ ] Write SSF Enforcer logic (Trading/Mailbox/AH blocking hooks).
- [ ] Local Serialization module to securely lock configuration changes into `SavedVariables.lua`.

---

## 📌 Phase 3: Web-App Backend & Desktop Bridge (Node.js & Electron)
**Objective:** Engineer the cloud infrastructure, database schema, and the secure desktop bridge relay that transmits local WoW data to the cloud.

### Research & Strategy
* **The Bridge Problem:** Web browsers and cloud servers cannot read local game files (`SavedVariables.lua`).
* **The Bridge Solution:** Construct an Electron Companion App. This lightweight local daemon monitors file-write events on `WTF/Account/.../SavedVariables.lua`. 
* **Security:** Upon a `PLAYER_DEAD` write, the app immediately hashes the payload using an HMAC-SHA256 local secret to prevent API spoofing, and securely transmits it via WebSocket to the central server.
* **Backend:** Node.js processing realtime state changes, MongoDB for deep leaderboard indexing.

### Subtasks
- [ ] Setup Node.js REST API Gateway with JWT Authentication.
- [ ] Design MongoDB schema design: Players (Scores, Deaths), Guilds (Rulesets), Checkpoints.
- [ ] API Endpoints: `/api/deaths`, `/api/leaderboard`, `/api/guild/:id`.
- [ ] Develop Electron Companion App interface (Login with Twitch, Select WoW Directory).
- [ ] Implement file system watcher (`fs.watch`) in Electron for `SavedVariables.lua`.
- [ ] Implement HMAC payload hashing to protect against API spoofing.
- [ ] Deploy realtime WebSocket server using `Socket.io` for instant Leaderboard updates.

---

## 📌 Phase 4: Streamer Mechanics & Twitch Extension 
**Objective:** Implement the interactive spectator ecosystem, penalty wheel, and OBS overlays governed by the official Twitch Developer API.

### Research & Strategy
* **Twitch Extension Workflow:** Viewer interaction operates via the official Twitch Extension Backend Service (EBS). A viewer spends Twitch Bits on the 'Penalty Wheel'.
* **Validation:** Twitch validates the transaction and pings our EBS webhook securely.
* **Execution Layer:** Our EBS routes a secure WebSocket push notification to the specific streamer's Electron Companion App, which instantly injects a macro or triggers a lua hook executing the penalty (e.g., deleting an equipped item). The entire pipeline must resolve in under 500ms to maintain broadcast sync.

### Subtasks
- [ ] Register Twitch Developer Organization and provision API secrets.
- [ ] Build secure Twitch Extension Backend Service (EBS) endpoints to receive Bits transactions.
- [ ] Develop basic Twitch Extension frontend (HTML/JS Panel for Twitch UI).
- [ ] Develop 2-way streaming WebSocket listener in the Companion App.
- [ ] Engineer Addon hooks to securely execute localized UI penalties from external triggers.
- [ ] Design transparent, modular OBS Browser Source overlays for Live Trackers.

---

## 📌 Phase 5: Production Infrastructure & Version 1.0 Release
**Objective:** Architect the scalable production environment, harden security, and orchestrate the public Version 1.0 launch.

### Research & Strategy
* **Deployment & Scaling:** The official launch day will invite extreme network traffic. We will containerize the Node.js backend using Docker Compose. A highly-available Nginx reverse proxy will terminate SSL and balance load across multiple Node instances.
* **DDoS Mitigation:** Hardcore WoW projects frequently face targeted DDoS attacks. We will place the entire infrastructure behind a Cloudflare Web Application Firewall (WAF) to aggressively filter invalid requests while caching read-only Leaderboard endpoints at the edge.

### Subtasks
- [ ] Finalize Multi-Container Docker configuration for production deployment (Raspberry Pi compatibility test).
- [ ] Configure Nginx Reverse Proxy with Let's Encrypt automated TLS certificates.
- [ ] Host Web Frontend on a high-availability CDN (Cloudflare Pages or Vercel).
- [ ] Integrate Cloudflare WAF and aggressively cache static JSON routes.
- [ ] Automate Addon distribution via Curseforge Developer API & GitHub Releases Actions.
- [ ] Execute final penetration test targeting the Leaderboard API endpoints.
- [ ] Invite 5 prominent Guild Masters for Closed Alpha testing of the syncing rulesets.
