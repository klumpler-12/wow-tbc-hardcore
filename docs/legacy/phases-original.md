# Development Phases

---

## Phase 0: Final Draft Concept (1–2 weeks)

**Goal:** Solidify the plan, make all architectural decisions, prepare for development.

- [ ] Finalize project plan with team consensus
- [ ] Create detailed feature matrix: Free vs. Premium
- [ ] Technical architecture decisions:
  - [ ] Choose Ace3 libraries (AceAddon, AceDB, AceGUI, AceComm, AceSerializer)
  - [ ] Decide SavedVariables schema (per-character vs. per-account vs. hybrid)
  - [ ] Choose backend database (MongoDB vs. PostgreSQL)
  - [ ] Choose companion app framework (Electron vs. Tauri)
- [ ] Competitor deep-analysis:
  - [ ] Install and test Sauercrowd, HardcoreTBC, Deathlog, base HC addons
  - [ ] Document all features and limitations
  - [ ] Review base HC source code for reusable patterns
- [ ] Map OnlyFangs 3 requirements to features
- [ ] Define Minimum Viable Addon (MVA)
- [ ] Set up dev environment:
  - [ ] CMaNGOS TBC Docker with test accounts
  - [ ] Git repo with branching strategy
  - [ ] CI/CD pipeline for addon packaging
  - [ ] Issue tracker populated with Phase 1 tasks

**Deliverable:** Approved plan, dev environment ready, issue tracker populated.

---

## Phase 1: PoC — Basic WoW Menu (1–2 weeks)

**Goal:** Prove we can create a functioning addon in the TBC 2.4.3 client.

- [ ] Create `.toc` file with TBC interface number (20400)
- [ ] Core.lua with AceAddon-3.0 initialization
- [ ] AceGUI frame: title bar, Score tab, Settings tab, chat button
- [ ] Slash command `/hcp` to toggle main frame
- [ ] CMaNGOS TBC Docker test environment documented
- [ ] First unit test: addon loads without errors

**Acceptance Criteria:**
1. `/hcp` opens and closes the main frame
2. Frame displays correctly at 1920x1080 and 1280x720
3. Button prints "Hardcore Plus: Score = 0" to chat
4. No Lua errors on load or interaction

---

## Phase 2: Tracking Library (2–3 weeks)

**Goal:** Build modular, performant tracking library for all player activity.

- [ ] Catalog all relevant WoW API events for TBC 2.4.3
- [ ] Build tracker modules: DeathTracker, MobTracker, MoveTracker, TradeTracker, DungeonTracker, GearTracker, FishingTracker
- [ ] SavedVariables serialization with schema, migration, compression
- [ ] Unit tests for each tracker module
- [ ] Performance benchmarking with budgets

**Acceptance Criteria:**
1. Deaths recorded with correct killer, zone, level, timestamp
2. Mob kills counted accurately
3. Equipment snapshots match actual equipped items
4. SavedVariables < 500KB after 10 hours of play
5. No frame rate drop (>1fps) with all trackers active

---

## Phase 3: PoC — Guild Communication (2–3 weeks)

**Goal:** Establish reliable addon-to-addon communication within a guild.

- [ ] Communication layer: SendAddonMessage, serialization, chunking, queuing
- [ ] Message protocol: SYNC_REQUEST, SYNC_RESPONSE, DEATH_NOTIFY, RULE_UPDATE, SCORE_UPDATE, PUNISHMENT, ACHIEVEMENT, HEARTBEAT
- [ ] Data synchronization: initial sync, incremental updates, conflict resolution
- [ ] Ruleset broadcast: GM push, offline sync, hash verification
- [ ] Security: guild validation, GM rank verification, rate limiting

**Acceptance Criteria:**
1. Player A death visible in Player B addon within 5 seconds
2. GM ruleset update reaches all online members within 10 seconds
3. Late-login player receives current ruleset on sync
4. No chat throttle disconnects from message queue

---

## Phase 4: Website Voting Feature (1–2 weeks)

**Goal:** Web-based voting system for community decisions.

- [ ] Voting pages: heroic difficulty ratings, scoring system vote, custom polls
- [ ] Backend: Node.js/Express, SQLite, REST API
- [ ] Anti-manipulation: one vote per account (OAuth)
- [ ] Frontend: clean UI, real-time results, mobile-responsive

---

## Phase 5: Rudimentary HC Addon (3–4 weeks)

**Goal:** First playable version with at least one example from every feature category.

- [ ] Tracking: death tracking + guild-wide notifications
- [ ] Scoring: death deduction, boss kill points, level-up points
- [ ] Punishments: one creative punishment (RP-walk PoC)
- [ ] Rules: Hybrid HC base ruleset with SSF toggle
- [ ] Leaderboard: top 20 players by score
- [ ] SSF enforcement: block trade/mail/AH
- [ ] Achievements: 10–20 micro-achievements
- [ ] UI polish: consistent styling, proper scaling
- [ ] E2E test with 3+ players on CMaNGOS

---

## Phase 6: Alpha to Beta (4–6 weeks)

**Goal:** Feature-complete beta.

- [ ] Houses/fractions: full implementation
- [ ] Draft system: ratings, budget, order, UI
- [ ] Mini-games: 3+ built-in, custom template system
- [ ] All creative punishments
- [ ] Reward system: public, hidden, GM-created, guild-wide
- [ ] Full scoring (both options, GM selectable)
- [ ] 100+ micro-achievements
- [ ] Web dashboard MVP (guild overview, leaderboard, ruleset editor, houses, profiles)
- [ ] Companion app (Electron): file watcher, data parser, HMAC sync, system tray
- [ ] Anti-cheat: inventory hashes, cross-verification, flagging, GM review
- [ ] Bug fixing and performance optimization

---

## Phase 7: Playtesting (2–4 weeks)

**Goal:** Validate with real players, balance scoring, stress-test.

- [ ] Closed beta: 20–50 testers from target communities
- [ ] Weekly feedback surveys, in-game `/hcp feedback`, error reporting
- [ ] Balancing: scoring, difficulty ratings, punishment severity, free/premium split
- [ ] Stress testing: 100+ concurrent users, 1000 req/min API, large SavedVariables, 40-man raids
- [ ] Security testing: message spoofing, SavedVariables manipulation, SSF bypass, web pentesting

---

## Phase 8: Launch Preparation (2 weeks)

**Goal:** All distribution channels, docs, and marketing ready.

- [ ] CurseForge: project page, upload, auto-update
- [ ] Patreon: page, tiers, premium file distribution
- [ ] Documentation: install guide, GM quickstart, player guide, API docs, FAQ
- [ ] Marketing: trailer, social clips, Reddit, Discord, streamer outreach
- [ ] Launch day: backend scaling, support briefed, hotfix process, rollback plan

---

## Timeline Summary

| Phase | Duration | Cumulative |
|-------|----------|------------|
| 0: Final Draft Concept | 1–2 weeks | Week 2 |
| 1: PoC — Basic Menu | 1–2 weeks | Week 4 |
| 2: Tracking Library | 2–3 weeks | Week 7 |
| 3: PoC — Guild Comms | 2–3 weeks | Week 10 |
| 4: Website Voting | 1–2 weeks | Week 12 |
| 5: Rudimentary HC Addon | 3–4 weeks | Week 16 |
| 6: Alpha to Beta | 4–6 weeks | Week 22 |
| 7: Playtesting | 2–4 weeks | Week 26 |
| 8: Launch Prep | 2 weeks | Week 28 |

**Total: 18–28 weeks (4.5–7 months)** assuming 2–3 part-time developers.
