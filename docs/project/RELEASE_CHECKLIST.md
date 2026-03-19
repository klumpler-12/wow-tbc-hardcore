# Release Checklist

Gate checks for each phase transition. A phase is not complete until ALL items in its section are checked.

_Last updated: 2026-03-17_

---

## Phase 0 → 0.5 Gate (Target: Mar 23)

### Compat Validation (MUST PASS)
- [ ] CLEU polyfill: death correctly detected on CMaNGOS via StoreCLEUArgs()
- [ ] BackdropTemplate polyfill: all UI frames render without errors
- [ ] IsInGroup()/IsInRaid() polyfill: party/guild detection works
- [ ] GetInstanceInfo() polyfill: instance name/type/difficulty returned correctly
- [ ] SetColorTexture() polyfill: UI colors render, AceGUI doesn't error
- [ ] No Lua errors on addon load (/console scriptErrors 1)

### Core Feature Validation
- [ ] Setup wizard completes successfully (new character registration)
- [ ] Death detected and recorded (die → death log entry → UI updates)
- [ ] Status transitions work (PENDING → UNVERIFIED after 5 min solo)
- [ ] Instance lives widget appears on heroic/raid entry
- [ ] Checkpoint token generated on death at 58+
- [ ] SavedVariables persist across /reload and relog
- [ ] Debug panel toggles correctly enable/disable systems
- [ ] All slash commands respond (/hcp show, status, deaths, lives, etc.)

### Quality
- [ ] No Lua errors during 30 min play session
- [ ] No chat spam (silent /played, no debug output unless verbose enabled)
- [ ] Minimap button functional (left-click = panel, right-click = settings)

---

## Phase 0.5 → 1 Gate (Target: Mar 30)

### Tracker Modules
- [ ] GoldTracker: PLAYER_MONEY event fires, snapshots recorded with cap
- [ ] KillTracker: PARTY_KILL events logged via hidden frame
- [ ] TradeTracker: TRADE events logged, items captured
- [ ] MailTracker: MAIL_SEND_SUCCESS logged
- [ ] AHTracker: AH visit duration tracked
- [ ] DistanceTracker: zone transitions recorded
- [ ] ProfessionTracker: skill snapshots on SKILL_LINES_CHANGED
- [ ] EquipmentTracker: gear changes logged on PLAYER_EQUIPMENT_CHANGED
- [ ] LootTracker: items logged on LOOT_OPENED
- [ ] All 9 trackers toggleable via debug panel independently
- [ ] All data caps verified (fill to cap → oldest entries removed)

### Performance
- [ ] Memory usage < 2 MB (UpdateAddOnMemoryUsage() check)
- [ ] No measurable FPS drop with all systems enabled
- [ ] SavedVariables file size < 500 KB after 4 hours of play
- [ ] No timer drift or stacking (12 repeating timers verified stable)

### Bug Fixes
- [ ] BUG-001: sessions[] table capped
- [ ] BUG-002: suspiciousFlags[] table capped
- [ ] BUG-003: checkpointTokens[] has hard cap
- [ ] BUG-004: per-instance death lists capped
- [ ] BUG-005: peerFlags[] per player capped

---

## Phase 1 → 2 Gate (Target: Apr 20)

### Testing Coverage
- [ ] TESTING_CHECKLIST.md sections 1–5 complete (install, minimap, UI, wizard, death)
- [ ] TESTING_CHECKLIST.md sections 6–10 complete (verification, instance lives, checkpoint, soft reset, network)
- [ ] TESTING_CHECKLIST.md sections 11–15 complete (tracking, verification, status flow, edge cases, regression)
- [ ] All P0 blockers from testing resolved
- [ ] All HIGH severity bugs resolved
- [ ] 10+ testers have run full lifecycle (register → play → die → checkpoint/reset)

### Network Validation
- [ ] 2-player heartbeat exchange verified
- [ ] 5+ player guild scenario tested
- [ ] Death verification by peers confirmed
- [ ] Peer offline detection working (5 min timeout)
- [ ] No message spam or throttle violations

### Stability
- [ ] No Lua errors in 2-hour continuous session
- [ ] No memory leaks (memory stable after 2 hours)
- [ ] SavedVariables corruption recovery tested (delete file → clean reload)
- [ ] /reload mid-instance doesn't break state

---

## Phase 2 Launch (Target: Apr 30)

### Release Packaging
- [ ] Version number updated in .toc (0.5.0-alpha or appropriate)
- [ ] CHANGELOG.md updated with all Phase 0–1 changes
- [ ] SETUP.txt updated with current file count and features
- [ ] .zip package created with correct folder structure
- [ ] .zip tested: extract → copy to AddOns → loads correctly
- [ ] No dev-only files in package (no .git, no docs/, no backup/)

### CurseForge
- [ ] CurseForge account created
- [ ] Addon listing created with description, screenshots, tags
- [ ] First release uploaded
- [ ] Download link verified

### Website
- [ ] All 8 items in WEBSITE_LOGIC_ERRORS.md resolved
- [ ] Instance lives model matches addon implementation
- [ ] Phase numbering matches revised plan
- [ ] Status state diagram complete
- [ ] Download/CurseForge link added to website

### Documentation
- [ ] README.md updated for public audience
- [ ] SETUP.txt accurate and complete
- [ ] Known limitations section current
- [ ] License file present (MIT)

### Hotfix Pipeline
- [ ] Git tagging convention established (v0.5.0, v0.5.1, etc.)
- [ ] Build script: git tag → .zip → CurseForge upload
- [ ] Bug report channel established (Discord? GitHub Issues?)
- [ ] Emergency hotfix can be deployed within 24 hours

---

## Post-Launch (Phase 3+ Readiness)

These are NOT gate checks — they're "nice to have before Phase 3 begins":

- [ ] Database technology decided (DEC-P01)
- [ ] Companion app technology decided (DEC-P03)
- [ ] Instance lives model finalized (DEC-P04)
- [ ] Premium distribution method decided (DEC-P02)
- [ ] Community feedback channels established
- [ ] First community survey on scoring/difficulty preferences

---

_Each checked item should include the date and tester initials in a comment or separate tracking sheet._
