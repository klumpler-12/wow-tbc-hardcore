# Verification System Documentation

## Overview

The Verification System is a multi-layered approach to ensuring the integrity of hardcore character data and detecting various forms of cheating, accidental addon failures, and legitimate disconnection events. It combines **hard verification** (cryptographically provable facts) with **soft verification** (peer-based social consensus) to maintain trust in the network.

---

## Trust Hierarchy

The system maintains five distinct trust levels for a player's character:

```
┌─────────────────────────────────────────────────────────────┐
│                    TRUST LEVEL LADDER                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  VERIFIED ────→ Proof of Soul of Iron (hard verification)  │
│      ↑                    OR                                 │
│      │          Peer confirmation + no suspicious flags     │
│      │                                                       │
│  UNVERIFIED ──→ Addon running, seen by peers (soft)        │
│      ↑                    OR                                 │
│      │          Solo player auto-promoted (60s timeout)    │
│      │                                                       │
│  PENDING ─────→ Registered but not yet validated            │
│      │                    OR                                 │
│      │          Waiting for online peers to confirm         │
│      │                                                       │
│  TARNISHED ───→ Verification downgrade (lost SoI)          │
│      │          or instance death with life consumed        │
│      │                                                       │
│  CONTESTED ───→ Suspicious flags detected by peers          │
│      │          (hash mismatch, gap with gains, etc.)      │
│      │                                                       │
│  UNVERIFIED ──→ Auto-promoted after timeout / gap resolved  │
│                                                               │
│  DEAD ────────→ Permanent or instance death (no lives)      │
│                 Peer-verified or local detection           │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Problem Matrix

This matrix shows which verification layers detect which categories of cheating/failure:

| Problem | Detection Method | Verification Layer | Proof Type |
|---------|------------------|-------------------|-----------|
| **Inventory manipulation** | Data hash mismatch (peer comparison) | Heartbeat + Verification | Soft |
| **Score inflation** | SoI presence loss without death | VerificationTracker | Hard |
| **SavedVariables tampering** | Peer hash comparison during heartbeat | Heartbeat.OnDataHashReceived | Soft |
| **Addon disabled during play** | /played gap detection + inventory delta | UptimeTracker.AnalyzeGap | Soft |
| **Crash or accidental disable** | Offline ping with response, gap recovery | Heartbeat (offline pings) | Soft |
| **Disconnect during instance** | Combat log silence + heartbeat gap | DeathTracker + Heartbeat | Soft |
| **/played gap (addon was off)** | Session uptime vs /played time | UptimeTracker | Hard |
| **False death claim** | Peer witness verification + combat log | Verification + DeathTracker | Soft |
| **Character-level faking** | Level regression in hash (impossible) | Heartbeat.OnDataHashReceived | Hard |
| **Buff removal manipulation** | SoI loss without death flag | VerificationTracker | Hard |
| **Cross-player data fraud** | Peer registry comparison | Heartbeat + cross-peer validation | Soft |

---

## Verification Flow

### Complete Verification Pipeline

```
┌──────────────────────────────────────────────────────────────────────┐
│                    ADDON INITIALIZATION                              │
└─────────────────────────────────────┬────────────────────────────────┘
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────────────┐
│ 1. REGISTRATION & INITIAL STATE                                      │
│    • Status → PENDING                                                │
│    • Start: Heartbeat timer, Data hash broadcast (every 2min)       │
│    • Start: Periodic /played requests                               │
│    • Start: Soul of Iron scan (every 30s)                          │
└─────────────────────────────────────┬────────────────────────────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    │                  │                  │
                    ▼                  ▼                  ▼
        ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
        │   SOLO PLAYER    │ │  GUILD MEMBER    │ │  PARTY/RAID      │
        │                  │ │                  │ │                  │
        │ No peers online  │ │ Peers detected   │ │ Peers detected   │
        │                  │ │ via GUILD chat   │ │ via PARTY chat   │
        │ Auto-promotes    │ │                  │ │                  │
        │ to UNVERIFIED    │ │ Seen by peers    │ │ Seen by peers    │
        │ after 60s        │ │ → UNVERIFIED     │ │ → UNVERIFIED     │
        │                  │ │                  │ │                  │
        └────────┬─────────┘ └────────┬─────────┘ └────────┬─────────┘
                 │                    │                    │
                 └────────────────────┼────────────────────┘
                                      │
                                      ▼
        ┌──────────────────────────────────────────────────────┐
        │ 2. MONITORING LAYER: CONTINUOUS TRACKING             │
        │                                                       │
        │  ┌─ Heartbeat Module ─────────────────────────────┐ │
        │  │ • Broadcast every 30s to peers                 │ │
        │  │ • Receive peer heartbeats                      │ │
        │  │ • Detect peer gaps (silent period + return)   │ │
        │  │ • Start offline pings if peer goes silent     │ │
        │  │ • Online peer list maintains trust            │ │
        │  └────────────────────────────────────────────────┘ │
        │                                                       │
        │  ┌─ Data Hash Broadcast (every 2min) ──────────────┐ │
        │  │ • Inventory hash                                │ │
        │  │ • Death count hash                              │ │
        │  │ • Session hash                                  │ │
        │  │ • Peer comparison: watch for impossible changes│ │
        │  │   (e.g., level regression = instant flag)      │ │
        │  └────────────────────────────────────────────────┘ │
        │                                                       │
        │  ┌─ Uptime Tracker ────────────────────────────────┐ │
        │  │ • Track session uptime (when addon is running) │ │
        │  │ • Request /played every 2 minutes              │ │
        │  │ • Compare: /played gap indicates addon disable │ │
        │  │ • Flag: gap + inventory changes = major        │ │
        │  │ • Flag: gap + no changes = minor (threshold)   │ │
        │  └────────────────────────────────────────────────┘ │
        │                                                       │
        │  ┌─ Soul of Iron Scanner (every 30s) ──────────────┐ │
        │  │ • Scan buff list for "Soul of Iron"            │ │
        │  │ • SoI detection = instant status upgrade       │ │
        │  │ • SoI loss without death = critical flag       │ │
        │  │ • Unreliable at level 58+ (instances)          │ │
        │  └────────────────────────────────────────────────┘ │
        │                                                       │
        │  ┌─ Death Tracker ─────────────────────────────────┐ │
        │  │ • Monitor combat log for damage taken          │ │
        │  │ • Detect UNIT_DIED event                       │ │
        │  │ • Record: killer, ability, zone, level         │ │
        │  │ • Broadcast death to peers for verification    │ │
        │  │ • Store death context (last 5 damage events)   │ │
        │  │ • Distinguish: open world (permadeath) vs      │ │
        │  │   instance (life check)                        │ │
        │  └────────────────────────────────────────────────┘ │
        │                                                       │
        └──────────────────────────┬───────────────────────────┘
                                   │
                                   ▼
        ┌──────────────────────────────────────────────────────┐
        │ 3. VERIFICATION RESPONSES (On Detection)             │
        │                                                       │
        │  Death Report Broadcast:                             │
        │  ┌─────────────────────────────────────────────────┐ │
        │  │ Send to GUILD + PARTY/RAID channels            │ │
        │  │ Payload: timestamp, zone, killer, damage       │ │
        │  │ Peers receive → check if they witnessed death  │ │
        │  │ Witness flag set if death in recent CLEU       │ │
        │  │ Verification timeout: 5 minutes                │ │
        │  └─────────────────────────────────────────────────┘ │
        │                                                       │
        │  Peer Verification Response:                         │
        │  ┌─────────────────────────────────────────────────┐ │
        │  │ If death in nearby CLEU: send DEATH_VERIFY    │ │
        │  │ with witnessed=true                             │ │
        │  │ Else: send DEATH_VERIFY with witnessed=false   │ │
        │  │ (still confirms death is legitimate)            │ │
        │  │ Collect verifiers over 5-minute window          │ │
        │  │ Store count and witness status                  │ │
        │  └─────────────────────────────────────────────────┘ │
        │                                                       │
        └──────────────────────────┬───────────────────────────┘
                                   │
                                   ▼
        ┌──────────────────────────────────────────────────────┐
        │ 4. FLAG GENERATION & STORAGE                         │
        │                                                       │
        │  Suspicious Flags Array:                             │
        │  ├─ Gap violations (timestamp, gapMinutes, details)  │
        │  ├─ Hash mismatches (level regression, etc.)         │
        │  ├─ SoI anomalies (loss without death)               │
        │  ├─ Addon loaded in instance (zone, type)            │
        │  └─ Network silence (peer offline, pinging response) │
        │                                                       │
        │  Severity Levels:                                    │
        │  • high: immediate action needed (SoI loss, major gap)│
        │  • major: gains during gap (inventory/level/prof)    │
        │  • minor: gap only, no gains (counts weekly)         │
        │  • warning: adjacent to violations, watch closely    │
        │                                                       │
        └──────────────────────────┬───────────────────────────┘
                                   │
                                   ▼
        ┌──────────────────────────────────────────────────────┐
        │ 5. STATUS RESOLUTION                                 │
        │                                                       │
        │  ┌─ Hard Verification Paths ──────────────────────┐  │
        │  │ Status: PENDING/UNVERIFIED → VERIFIED          │  │
        │  │ Trigger: Soul of Iron buff detected           │  │
        │  │ Proof: Game-provided buff, cryptographically  │  │
        │  │        tied to hardcore settings              │  │
        │  │ No way to fake: buff comes from server        │  │
        │  └────────────────────────────────────────────────┘  │
        │                                                       │
        │  ┌─ Soft Verification Paths ──────────────────────┐  │
        │  │ Status: PENDING → UNVERIFIED                  │  │
        │  │ Trigger: Any registered peer sees heartbeat   │  │
        │  │ Timeout: 60 seconds (solo fallback)           │  │
        │  │ No peers? Auto-promote (solo player friendly) │  │
        │  │ Proof: Social consensus, peer acknowledgment  │  │
        │  └────────────────────────────────────────────────┘  │
        │                                                       │
        │  ┌─ Downgrade Paths ──────────────────────────────┐  │
        │  │ Status: VERIFIED → TARNISHED                  │  │
        │  │ Trigger: SoI lost due to valid death         │  │
        │  │ OR: Instance death with life consumed         │  │
        │  │                                                │  │
        │  │ Status: VERIFIED → CONTESTED                  │  │
        │  │ Trigger: Hash mismatch detected (from peer)   │  │
        │  │ OR: Gap violation with suspicious gains       │  │
        │  │                                                │  │
        │  │ Status: ANY → DEAD                            │  │
        │  │ Trigger: Open world death (permadeath)        │  │
        │  │ OR: Instance death, no lives left             │  │
        │  │ OR: Multiple peers confirm non-survival       │  │
        │  └────────────────────────────────────────────────┘  │
        │                                                       │
        └──────────────────────────┬───────────────────────────┘
                                   │
                                   ▼
        ┌──────────────────────────────────────────────────────┐
        │ 6. CONTINUOUS MONITORING DURING VERIFIED STATE       │
        │                                                       │
        │  Even VERIFIED characters are monitored for:         │
        │  • Data hash changes (compare peers every 2 min)     │
        │  • Gap anomalies (addon disable detection)           │
        │  • SoI loss without death (manual removal attempt)    │
        │  • Cross-peer validation (others validate your data) │
        │  • Peer consensus (multiple peers confirm status)    │
        │                                                       │
        └──────────────────────────────────────────────────────┘
```

---

## Verification Methods

### 1. Cheating Detection

#### Inventory Manipulation
- **Method**: Data hash comparison (peer-to-peer)
- **Trigger**: Heartbeat broadcasts hashes every 2 minutes
- **Detection**: Peers compare inventory hashes, flag mismatches
- **Hard Proof**: No (hashes can be recalculated with manipulation)
- **Soft Proof**: Yes (multiple peers must independently confirm)
- **Resolution**: Flag stored, peer notification sent, status review triggered
- **Bypass Difficulty**: Very high (requires fooling multiple peers simultaneously)

#### Score Inflation
- **Method**: Soul of Iron buff presence verification
- **Trigger**: Periodic scan (every 30 seconds)
- **Detection**: SoI only exists with hardcore mode active (server-enforced)
- **Hard Proof**: Yes (buff comes from server, impossible to fake locally)
- **Soft Proof**: N/A (hard proof is absolute)
- **Resolution**: Instant status upgrade on detection
- **Bypass Difficulty**: Impossible (buff is server-provided)

#### SavedVariables Tampering
- **Method**: Hash changes detected by peers
- **Trigger**: Every 2-minute heartbeat interval
- **Detection**: Compare old hash → new hash for logical impossibilities
- **Hard Proof**: No (hashes prove changes, not intent)
- **Soft Proof**: Yes (peer consensus on impossible changes)
- **Examples**: Level regression, death count reduction, inventory loss
- **Resolution**: Peer hash mismatch event triggers flag storage
- **Bypass Difficulty**: Very high (requires hacking peer clients too)

### 2. Accidental Addon Turn-Offs / Crashes

#### Offline Detection
- **Method**: Heartbeat timeout + offline pings
- **Trigger**: Peer goes silent (no heartbeat for PEER_TIMEOUT seconds)
- **Detection**:
  - Session: Online peer list removes player
  - Persistent: Registry still tracks them
  - Recovery: Auto-reconnect on next heartbeat
- **Hard Proof**: No (silence could be network lag)
- **Soft Proof**: Yes (offline pings detect addon toggle vs network)
- **Offline Ping Mechanism**:
  - Exponential backoff: 30s → 60s → 120s → 240s → 480s → 600s
  - If response received = addon was running (benign)
  - If no response = truly offline or addon disabled
  - Max 6 attempts, then stop (player legitimately offline)
- **Resolution**: Brief message in UI, auto-reconnect on heartbeat
- **Bypass Difficulty**: Low for accidental disables (intended behavior)

#### Gap Recovery
- **Method**: /played time reconciliation
- **Trigger**: Session restart + TIME_PLAYED_MSG received
- **Detection**:
  - Compare: /played when session started
  - Compare: /played at session end
  - Calculate: Expected session duration vs actual /played delta
  - Gap = (actual /played delta) - (session duration)
- **Hard Proof**: Yes (if gap is within grace period, no flag)
- **Soft Proof**: Yes (if gap + gains detected, peer review)
- **Resolution**:
  - Under grace (default 5 min): ignored
  - Over grace, no gains: minor violation (counts toward weekly limit)
  - Over grace, gains detected: major violation (awaits peer confirmation)
- **Bypass Difficulty**: Very high (multiple time sources must align)

### 3. Disconnects During Instances

#### Detection Strategy
- **Method**: Combat log silence + heartbeat gap
- **Trigger**: Simultaneous conditions:
  - Heartbeat gap > PEER_TIMEOUT
  - Combat log activity stopped
  - Instance flag set at time of disconnect
- **Detection**:
  - Locally: Heartbeat gap confirms network issue
  - Peer validation: Others can verify you were in instance at gap time
  - Recovery: Heartbeat resumes = reconnect detected
- **Hard Proof**: No (gap proves disconnection, not survival)
- **Soft Proof**: Yes (peers can confirm via registry + offline ping response)
- **Resolution**:
  - No flagging for pure network gaps (grace period applies)
  - If gap + inventory changes during instance: reviewed by peers
  - If gap + instance death reported: peer verification critical
- **Bypass Difficulty**: Medium (network gaps are normal, hard to distinguish from manipulation)

### 4. /played Gap Detection

#### The /played System
- **Method**: Addon uptime vs game /played command
- **Trigger**: Every 2 minutes (periodic request)
- **Mechanics**:
  - Session start: Record /played (via TIME_PLAYED_MSG)
  - Session end: Record /played again
  - Expected duration: session end time - session start time
  - Actual played: (/played at end) - (/played at start)
  - Gap = Actual - Expected (should be ≈ 0)
- **Detection Logic**:
  ```
  Gap > grace period (5 min)?
    → Check inventory, gold, level, professions
    → Has gains? MAJOR violation (peer review required)
    → No gains? MINOR violation (weekly threshold)
  ```
- **Hard Proof**: Yes (math is absolute)
- **Soft Proof**: Yes (peer confirmation of gains)
- **Examples**:
  - Addon off for 30 min, no changes = minor (1 of 5 allowed per week)
  - Addon off for 10 min, leveled up = major (peer must confirm survival)
  - Addon off for 2 min = ignored (grace period)
- **Resolution**:
  - Minor: Count toward weekly limit (auto-reset Tuesday)
  - Major: Flag stored, peer notification sent, status held at UNVERIFIED until resolved
- **Bypass Difficulty**: Extremely high (requires manipulating both /played AND inventory)

### 5. Cross-Player Verification

#### Peer Validation Network
- **Method**: Decentralized peer registry + consensus voting
- **Trigger**: Heartbeat messages + specific query channels
- **Data Shared**:
  - Status (VERIFIED, UNVERIFIED, DEAD, etc.)
  - Level
  - Death counts (open world + instance)
  - Soul of Iron flag
  - Title
  - Last seen timestamp
  - Last hash
  - Peer flags (anomalies others detected)
- **Verification Process**:
  1. Each peer maintains local registry of all contacts
  2. Heartbeat updates registry entries every 30 seconds
  3. On query: Peer responds with full status snapshot
  4. Consensus: 2+ peers must agree on status for promotion
  5. Dispute: Hash mismatch between peers = immediate investigation
- **Hard Proof**: No (peer data is local snapshot, can be out of sync)
- **Soft Proof**: Yes (distributed agreement is consensus proof)
- **Resolution**:
  - Promotion to VERIFIED: Needs SoI OR (2+ peers agree + no flags)
  - Demotion to CONTESTED: 1 peer reports hash mismatch
  - Death confirmation: 1+ peer witness = corroborated death
- **Bypass Difficulty**: Very high (requires controlling multiple client machines)

### 6. Soul of Iron Buff Checking

#### Buff Verification
- **Method**: Scan aura list every 30 seconds
- **Trigger**: Periodic scan + on login
- **Detection**:
  - Buff name: "Soul of Iron"
  - Buff slot: 1-40 (standard buff range)
  - Reliability: 100% until level 58 (instance content)
- **Hard Proof**: Yes (buff is server-enforced, can't be faked locally)
- **Soft Proof**: N/A (hard proof only)
- **State Transitions**:
  - SoI detected → Status promotion (PENDING/UNVERIFIED → VERIFIED)
  - SoI lost with death → Expected (transition to TARNISHED)
  - SoI lost without death → CRITICAL FLAG (suspicious, investigated)
- **Edge Cases**:
  - Level 58+: Instance content may temporarily suppress SoI (noted as unreliable)
  - Death animation: Brief loss during death sequence (acceptable)
  - Load screen: Buff list not available (skip check)
- **Resolution**: Instant status change on SoI acquisition/loss
- **Bypass Difficulty**: Impossible (buff comes from server)

### 7. Death Verification

#### Two-Tier Death Proof System

**Tier 1: Local Proof**
- **Method**: Combat log event (UNIT_DIED) + death context
- **Trigger**: COMBAT_LOG_EVENT_UNFILTERED event
- **Data Collected**:
  - Killer (last damage source)
  - Ability (spell name or "Melee")
  - Zone + subzone
  - Level at death
  - Recent damage history (last 5 events)
  - Inventory state
  - Gold
- **Hard Proof**: Yes (WoW client-provided, not modifiable)
- **Resolution**: Local death record created, flagged for peer verification

**Tier 2: Cross-Player Verification**
- **Method**: Peer witness + death report broadcast
- **Trigger**: Death broadcast to all available channels
- **Verification Types**:
  - Witnessed: Peer saw death in their own CLEU
  - Confirmed: Peer received death report but wasn't nearby
  - Unverified: No peer response within 5 minutes
- **Consensus Rules**:
  - 1+ witness = STRONG proof (death happened)
  - 1+ confirmed (no witness) = WEAK proof (recorded but not seen)
  - 0 responses = UNVERIFIED (may be solo player)
- **Hard Proof**: No (peers can collude or be offline)
- **Soft Proof**: Yes (distributed witness consensus)
- **False Death Detection**:
  - Claim death but CLEU shows no matching event = flag
  - Claim death, no inventory/gold change = review (might be log error)
  - Claim death, peers deny witnessing = contested, peer voting
- **Resolution**:
  - Verified: Status → DEAD immediately
  - Unverified: Status → DEAD after timeout (local trust backup)
  - Contested: Status held, flagged for manual review

---

## Hard vs. Soft Verification

### Hard Verification (Cryptographically Provable)

| Component | Proof | Source | Bypass |
|-----------|-------|--------|--------|
| **Soul of Iron buff** | Game server enforces buff existence | Server + Client | Impossible |
| **/played time** | Game clock manages time tracking | Game client | Requires time manipulation (OS-level) |
| **Combat log death** | Game engine records all UNIT_DIED events | Game client | Requires hooking WoW client (detection risk) |
| **Level regression** | Math: level can only stay same or increase | Game logic | Impossible (impossible state) |
| **Session duration math** | Arithmetic: (end time - start time) | Addon logic | Requires addon manipulation (detectable) |

### Soft Verification (Social Consensus)

| Component | Proof | Source | Bypass |
|-----------|-------|--------|--------|
| **Peer witness** | Multiple clients saw event in CLEU | Distributed peers | Requires controlling multiple machines |
| **Hash consensus** | 2+ peers report same inventory hash | Distributed peers | Requires manipulating multiple clients |
| **Peer gap detection** | Others confirm you were offline | Distributed peers | Requires coordination with peer group |
| **Title validation** | Peer confirms title status matches level | Distributed peers | Requires fooling all active peers |
| **Death count verification** | Peers compare death numbers at intervals | Distributed peers | Requires synchronizing fake data across machines |

---

## Failure Points and Recovery

### Scenario 1: Addon Crash During Raid

```
Timeline:
├─ 14:00:00 — Raid starts, heartbeat every 30s
├─ 14:15:00 — Addon crashes (ERROR in frame handling)
├─ 14:15:30 — Missed heartbeat (peers notice)
├─ 14:16:00 — Missed heartbeat (peers notice)
├─ 14:20:00 — Player manually reloads addon (/reload)
├─ 14:20:30 — Heartbeat resumes, peers notified
├─ 14:21:00 — Offline ping #1 cancelled (peer came back online)
└─ 14:25:00 — Gap review: 5 min gap, no level change, no inv change = MINOR

Resolution:
→ No flag (within 5-min grace period)
→ Raid death during gap: Unverified, but peers confirm raid happened
→ Status remains VERIFIED (optional grace period active)
```

### Scenario 2: Network Disconnect During Instance

```
Timeline:
├─ 15:00:00 — Instance: Dungeon (Slavepens)
├─ 15:05:00 — Internet drops, no heartbeat
├─ 15:05:30 — Offline ping #1 sent by guild peers
├─ 15:06:00 — Player reconnects, heartbeat resumes
├─ 15:06:30 — Offline ping #1 response received = addon running
├─ 15:10:00 — Gap review: 6 min gap, no inventory change = MINOR
└─ 15:15:00 — Peer confirms: "Saw you in Slavepens at 15:05, you died to trash"

Resolution:
→ Death verified by peer (witnessed)
→ Death recorded as instance death (checked for lives)
→ If life consumed: Status → TARNISHED
→ If no life: Status → DEAD (permanent)
```

### Scenario 3: Major Violation (Addon Off for 30 Minutes)

```
Timeline:
├─ 12:00:00 — Player disables addon (experimental patch)
├─ 12:15:00 — Plays for 15 minutes with addon off
├─ 12:20:00 — Levels from 42 → 43 (unexpected gain)
├─ 12:30:00 — Re-enables addon
├─ 12:30:30 — First heartbeat after re-enable
├─ 12:32:00 — /played request shows 31 min gap
├─ 12:32:15 — AnalyzeGap fires: gap=31, inventory changed, level gained
└─ 12:32:30 — Major violation flagged

Resolution:
→ Major violation stored in suspiciousFlags
→ Network notified of major gap + gains
→ Peers review death events in death registry during this time
→ If peers confirm survival during that 31 min: OK, move to UNVERIFIED
→ If peers can't confirm: Status held at CONTESTED until resolution
```

### Scenario 4: SoI Lost Without Death

```
Timeline:
├─ 10:00:00 — VERIFIED status, SoI present
├─ 10:30:00 — SoI scanner detects: SoI is gone
├─ 10:30:05 — Death tracker check: no recent death recorded
├─ 10:30:10 — VerificationTracker flags: "SoI removed without death"
├─ 10:30:15 — CRITICAL FLAG STORED
└─ 10:30:30 — Status transition to TARNISHED

Resolution:
→ Immediate status downgrade (VERIFIED → TARNISHED)
→ Character investigated (peers asked for context)
→ Possible explanations:
   a) Buff server lag (reappears within seconds) = cleared
   b) Addon reload during death animation = cleared if death in log
   c) Manual corruption (SavedVariables edit) = CONFIRMED CHEAT
→ Peer vote determines if corrected or permanent
```

### Scenario 5: Peer Hash Mismatch

```
Timeline:
├─ 09:00:00 — Peer A broadcasts: "Level 45, 5 deaths, inv hash ABC123"
├─ 09:00:05 — Peer A broadcasts: "Level 45, 5 deaths, inv hash ABC123"
├─ 09:02:00 — Peer A broadcasts: "Level 44, 4 deaths, inv hash ABC123"
│   (IMPOSSIBLE: level decreased, death count decreased)
├─ 09:02:05 — Peer B receives & compares: "This is impossible!"
├─ 09:02:10 — Peer B broadcasts flag: "Peer A detected: impossible state"
├─ 09:02:15 — All peers notified: Peer A is CONTESTED
└─ 09:05:00 — Peer A's status changed by network consensus

Resolution:
→ Peer A status immediately lowered in peer registry
→ Death verification for Peer A becomes very strict (2+ witness required)
→ Future broadcasts from Peer A heavily scrutinized
→ Manual review queued (administrator check in web interface)
```

---

## Status Transitions

### Full State Machine

```
                      ┌──────────────┐
                      │   PENDING    │
                      │ (Registered  │
                      │  not seen)   │
                      └──────┬───────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼ Timeout (60s)     ▼ Peer sees         ▼ SoI detected
    [UNVERIFIED]      [UNVERIFIED]          [VERIFIED]
    (solo player)     (peer-confirmed)      (hard proof)
         │                   │                   ▲
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
                    ┌────────▼────────┐
                    │   VERIFIED      │
                    │ (SoI + 0 flags) │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
      ▼ Death  ▼ Gap+Gains    ▼ SoI Lost   (instance life)
    [DEAD]  [CONTESTED]  [TARNISHED]   └→ [TARNISHED]
      │         │          ▲│                 │
      │         └──────────┘│                 │
      │                     │                 │
      │         ┌───────────┼─────────────────┘
      │         │           │
      └────────┼─ Peer      │ Checkpoint
               │  Review:   │ / Soft Reset
               │  OK?       │
               │            │
         [YES] ▼            ▼ [NO]
        [UNVERIFIED]    [DEAD]
             │                (under extreme review)
             │
    (recover from major violation)
             │
             ▼
        [UNVERIFIED] ← New status
        (can re-verify)
```

### Transition Rules

```
PENDING:
  → UNVERIFIED: (a) After 60s timeout with no peers, OR
                (b) Any registered peer sees heartbeat, OR
                (c) Manual promotion
  → VERIFIED: SoI detected

UNVERIFIED:
  → VERIFIED: SoI detected OR (peer consensus after review)
  → DEAD: Open world death OR (instance death, no lives)
  → CONTESTED: Major violation or peer hash mismatch

VERIFIED:
  → TARNISHED: SoI lost (due to death), OR instance death (life consumed)
  → CONTESTED: Hash mismatch OR major gap violation
  → DEAD: Open world death OR (instance death, no lives)

TARNISHED:
  → VERIFIED: Peer confirmation + re-detect SoI (unlikely)
  → DEAD: Any death event (lost lives)
  → UNVERIFIED: Recovery attempt (checkpoint/soft reset)

CONTESTED:
  → VERIFIED: Peer review complete, all flags resolved
  → UNVERIFIED: Peer review allows recovery, flags tolerated
  → DEAD: Death event during disputed status

DEAD:
  → UNVERIFIED: Checkpoint triggered (regain life)
  → SOFT_RESET_1: Soft reset mode activated (1st reset)
  → SOFT_RESET_2: (2nd reset, etc.)
  → [FINAL]: Character permanently dead (no resets available)
```

---

## Network Verification Layers

### Layer 1: Heartbeat Validity

```
Every 30 seconds, each addon broadcasts:

├─ Sender key (Name-Realm)
├─ Status (VERIFIED, UNVERIFIED, DEAD, etc.)
├─ Level (must never decrease)
├─ Death counts (must never decrease)
├─ Soul of Iron flag (true/false)
├─ Flags bitmask (title status, soft resets, etc.)
├─ Title (JUGGERNAUT, TRUE_HC, etc.)
├─ Registered flag (true/false)
└─ Timestamp

Peers verify:
✓ Level never regresses
✓ Death count never regresses
✓ SoI state change has death record (if lost)
✓ Status follows valid transitions
✓ Heartbeat timestamp is recent (< PEER_TIMEOUT)
✗ Impossible changes = flag
```

### Layer 2: Data Hash Validation

```
Every 2 minutes, each addon broadcasts hashes:

├─ Inventory hash (SHA1 of item GUIDs + quantities)
├─ Death hash (SHA1 of death records array)
├─ Session hash (SHA1 of session uptime + /played)
├─ Level (included for regression check)
└─ Timestamp

Peers compare with previous broadcast:
✓ Inventory hash changed = inventory activity (expected)
✓ Death hash changed = death event (cross-reference)
✓ Level stays same or increases (not decreases)
✗ Level decreased = IMPOSSIBLE (instant flag)
✗ Death count in heartbeat decreased = IMPOSSIBLE
```

### Layer 3: Offline Ping Chain

```
Peer A offline (no heartbeat for > 120 seconds):

Time 0s:    Heartbeat received from Peer A
Time 120s:  No heartbeat → marked offline
Time 150s:  Send STATUS_QUERY whisper to Peer A
Time 180s:  [If response] Peer was online (addon running)
            → they left guild/party but addon still on (benign)
            → or they toggled addon briefly (minor flag)

Time 150s:  [If no response]
Time 300s:  Send STATUS_QUERY whisper #2
Time 630s:  Send STATUS_QUERY whisper #3
Time 1230s: Send STATUS_QUERY whisper #4
Time 2430s: Send STATUS_QUERY whisper #5
Time 4830s: Send STATUS_QUERY whisper #6
Time 4830s: Stop pinging, accept as offline

Possible states at end:
• Genuinely offline (no responses) = normal
• Came back online = reconnected
• Responded from away = addon was running, left group (benign)
• Never responded but appears later = network issues (no flag)
```

---

## Violation Classification

### Minor Violations (Weekly Threshold)

**Criteria**:
- Addon gap detected via /played
- Gap duration > grace period (5 minutes)
- No inventory changes
- No level gain
- No profession gain
- No gold change > 100g

**Impact**:
- Counted toward weekly limit (default 5 per week)
- Reset every Tuesday (WoW weekly reset)
- Escalation: If hit limit, future gaps become MAJOR
- No status change (stays VERIFIED)

**Example Scenarios**:
```
Scenario A: 15-minute gap, no changes
→ Minor violation #1 (1/5 this week)

Scenario B: 30-minute gap, gold ±50g (within tolerance)
→ Minor violation #2 (2/5 this week)

Scenario C: 8-minute gap, 1 skill up gained
→ MAJOR violation (changed profession count)

Scenario D: Week repeats, 5 minor violations already
Scenario E: New 10-minute gap
→ MAJOR violation (escalated, weekly limit hit)
```

### Major Violations (Peer Review Required)

**Criteria**:
- Gap > grace period AND any of:
  - Inventory hash changed
  - Level increased
  - Profession increased
  - Gold changed > 100g
  - Escalated flag set (5+ minor violations)

**Impact**:
- Immediate peer notification
- Status held at UNVERIFIED until resolved
- Peers review death events during gap period
- If peers confirm survival: OK, move to VERIFIED
- If peers deny: Status → CONTESTED / DEAD

**Example Scenarios**:
```
Scenario A: 20-minute gap, leveled 42→43
→ Major violation: peers check if you died/resurrected in logs
→ If death found: OK (expected gain)
→ If no death: CONTESTED (unauthorized level gain)

Scenario B: 10-minute gap, 50 gold gained
→ Minor violation (gold is fungible)

Scenario C: 10-minute gap, new enchanting level
→ Major violation: profession learned
→ Peers review deaths during this 10 min
```

---

## Summary Table: Which Layers Catch What

| Attack Vector | Layer 1 | Layer 2 | Layer 3 | Layer 4 | Detection Rate |
|---|---|---|---|---|---|
| Direct inventory hack | ✗ | ✓ (hash) | ✗ | ✓ (flag) | High |
| Level manipulation | ✗ | ✓ (impossible) | ✗ | ✓ (instant) | Guaranteed |
| SoI buff removal | ✓ (loss flag) | ✗ | ✗ | ✓ (critical) | Guaranteed |
| Addon disable + play | ✓ (gap) | ✓ (gain check) | ✗ | ✓ (major) | Very High |
| Fake death claim | ✗ | ✗ | ✓ (witness) | ✓ (flag) | Very High |
| SavedVariables edit | ✗ | ✓ (hash change) | ✗ | ✓ (peer verify) | High |
| Network silence | ✗ | ✗ | ✓ (ping) | ✓ (comeback) | Medium |
| Coordinated fraud | ✗ | ✗ | ✗ | ✗ | Very Low (multi-box) |

---

## Implementation Reference

The verification system is implemented across these modules:

- **Heartbeat.lua**: Peer heartbeat broadcast, online detection, offline pings
- **Verification.lua**: Death reporting, cross-player verification, hash mismatch handling
- **UptimeTracker.lua**: /played gap detection, violation classification, weekly reset
- **VerificationTracker.lua**: Soul of Iron scanning, status state machine, suspicious activity checks
- **DeathTracker.lua**: Combat log monitoring, death context capture, nearby death detection

Each module fires events that other systems can listen to, creating a responsive verification network.
