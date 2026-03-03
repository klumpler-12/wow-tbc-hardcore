# WoW TBC Hardcore: Master Project Plan & Checklists

## 📌 Phase 1: Foundation & UI Mockups (Status: In Progress)
*Milestone: "Phase 1: Foundation & UI"*
- [x] Initial Repository Setup & Git Configuration
- [x] UI Design: Dark Mode, Glassmorphism & TBC aesthetics
- [x] HTML Structure: Landing Page, Ideas Lab, Streamer Tools
- [x] Addon Simulation UI: Gear Battle Wager animations
- [x] Core Documentation: Competitor & Legal Research (`AIINFO`)
- [ ] Mobile Responsive Polish & Cross-Browser Testing

## 📌 Phase 2: Core Addon Architecture (Lua)
*Milestone: "Phase 2: Addon Architecture"*
- [ ] Initialize standard WoW Addon structure (`.toc`, `.lua`, `Bindings.xml`)
- [ ] Setup event listeners (`PLAYER_DEAD`, `UNIT_INVENTORY_CHANGED`, `CHAT_MSG_SYSTEM`)
- [ ] Implement Guild Communication channel for ruleset syncing
- [ ] Implement data persistence (SavedVariables) for deaths and scores
- [ ] State Machine: Death processing vs Spirit Healer vs PvP

## 📌 Phase 3: Web-App Backend & API
*Milestone: "Phase 3: Web-App Backend"*
- [ ] Setup Node.js Express server to receive data from Companion App
- [ ] Database Schema Design: Players, Guilds, Deaths, Rulesets
- [ ] API Endpoints: `/api/deaths`, `/api/leaderboard`, `/api/guild/:id`
- [ ] Implement Twitch OAuth for Streamer Profiles
- [ ] Websocket setup for Live Guild/Death feeds on the frontend

## 📌 Phase 4: Ruleset Mechanics & Enforcement
*Milestone: "Phase 4: Rule Enforcement"*
- [ ] Trading Blocker: Hook `TradeFrame` to reject trades if SSF is active
- [ ] Auction House Blocker: Hook `AuctionFrame`
- [ ] Gear Wipe Penalty Logic: Identify equipped items, force unequip, hook `CursorHasItem()`
- [ ] Score-Based Logic: Hook Quest turn-ins and boss kills, transmit score to DB

## 📌 Phase 5: Streamer Interactions & Twitch Extensions
*Milestone: "Phase 5: Streamer Tools"*
- [ ] Build basic Twitch Extension frontend (HTML/JS)
- [ ] Connect Twitch Extension EBS (Extension Backend Service) to Node API
- [ ] Viewer Penalty Wheel Trigger logic: Broadcast event to specific connected Streamer
- [ ] Addon: Listen to local companion app for "Trigger Penalty" event

## 📌 Phase 6: Beta Deployment & Testing
*Milestone: "Phase 6: Beta Release"*
- [ ] Deploy backend to Raspberry Pi/Production Server
- [ ] Host Web Frontend on Firebase/Vercel or Pi Nginx
- [ ] Invite 5 Guild Masters for Closed Alpha
- [ ] Stress-test Twitch Extension with simulated viewer load
- [ ] Collect feedback & bug reports (Appeals System logic)

---

### Deployment Strategy
1. **Frontend:** Nginx Docker container on Raspberry Pi (handled via current compose setup).
2. **Backend Engine:** Upcoming Node.js companion script. Needs Dockerization.
3. **Database:** Postgres or MongoDB container on Raspberry Pi.
4. **WoW Addon:** Hosted on Curseforge & GitHub Releases.

### User Checklist for Review:
- [ ] Please review the phases above. Should any feature be prioritized?
- [ ] Do you want to separate the "Companion App" (Desktop) from the "Backend API"?
- [ ] Should the Twitch Extension be built fully independently or integrated into the Web App?
