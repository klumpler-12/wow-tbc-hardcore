# Risk Assessment & Mitigations

---

## Technical Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TBC 2.4.3 API limitations prevent key features | High | Medium | Early PoC tests all critical API calls; fallback designs ready |
| SavedVariables file corruption | High | Low | Auto-backups before writes; validation on load; recovery mode |
| Addon comm throttling causes data loss | Medium | Medium | Message queuing with retry; priority for deaths; batch non-critical |
| Performance impact during raids (40+ addons) | High | Medium | Aggressive throttling in raids; disable non-essential during bosses; benchmark early |
| Companion app file watcher reliability | Medium | Low | Fallback to polling; manual sync button; error handling |

## Community Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Community rejects premium as "pay-to-win" | High | Medium | Clear messaging: free is fully functional; community input on tier split |
| Low adoption vs. established competitors | Medium | Medium | Focus on unique features; streamer partnerships; migration tools |
| Cheating undermines leaderboards | High | Medium | Multi-layer verification; GM review tools; community flagging |
| Feature creep delays launch | High | High | Strict MVP; phase gating; no new features added mid-phase |

## Business Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Blizzard TOS changes | High | Low | Monitor announcements; TOS-compliant design; no gameplay automation |
| Hosting costs exceed revenue | Medium | Medium | Start minimal (single VPS); scale with demand; serverless where possible |
| Key developer leaves | High | Medium | Comprehensive docs; modular codebase; no single knowledge points |

---

## Open Questions

### Architecture Decisions
1. **Database:** MongoDB (flexible, fast prototyping) vs. PostgreSQL (relational integrity)?
2. **Companion app:** Electron (proven) vs. Tauri (smaller, Rust backend)?
3. **Real-time:** WebSocket (dashboard) + polling (companion app sync)?

### Design Decisions
4. **Scoring:** Both Complex and Simple coexist as GM-selectable options?
5. **Premium distribution:** Patreon download vs. license key vs. OAuth-gated?
6. **Death verification:** `IsInInstance()` at death time, cross-verified by group members?

### Community Decisions (Require Voting)
7. Heroic difficulty rating scale: 1–5 vs. 1–10 vs. point values directly?
8. Achievement point values: community vote vs. formula?
9. Draft format: snake vs. auction vs. random + trade period?
