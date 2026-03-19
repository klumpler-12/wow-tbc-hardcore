# Version Archive

Tracks the version and status of all project documents and artifacts.

_Last updated: 2026-03-17_

---

## Addon Versions

| Version | Date | Phase | Tag | Notes |
|---------|------|-------|-----|-------|
| 0.0.1-concept | 2026-03-12 | Phase 0 | — | Initial concept, documentation, website |
| **0.1.0-alpha** | **2026-03-17** | **Phase 0** | — | **CURRENT — Pre-alpha with all core systems** |
| 0.2.0-alpha | — (target Mar 30) | Phase 0.5 | — | Clean rebuild, all trackers wired |
| 0.3.0-alpha | — (target Apr 20) | Phase 1 | — | Semi-private alpha, bug-fixed |
| 0.5.0-alpha | — (target Apr 30) | Phase 2 | — | Public alpha, CurseForge release |

**Database version:** HCP.DB_VERSION = 1 (since 0.1.0-alpha)
**Interface version:** 20400 (TBC 2.4.3)

---

## Document Registry

### Source of Truth (Canonical)

| Document | Version | Last Updated | Status | Location |
|----------|---------|-------------|--------|----------|
| TESTAMENT.md | 1.0 | 2026-03-12 | CURRENT | docs/ |
| PROJECT_PLAN_REVISED.md | 2.0-REVISED | 2026-03-17 | CURRENT | docs/ |

### Active Documentation

| Document | Version | Last Updated | Status | Location |
|----------|---------|-------------|--------|----------|
| README.md (root) | — | 2026-03-17 | CURRENT | / |
| docs/README.md (index) | — | 2026-03-17 | CURRENT | docs/ |
| overview.md | 1.0-DRAFT | 2026-03-12 | CURRENT | docs/ |
| architecture.md | 1.0 | 2026-03-12 | CURRENT | docs/ |
| risks.md | 1.0 | 2026-03-12 | CURRENT | docs/ |
| competitors.md | 1.0 | 2026-03-12 | CURRENT | docs/ |
| glossary.md | 1.0 | 2026-03-12 | CURRENT | docs/ |
| onlyfangs3.md | 1.0 | 2026-03-12 | CURRENT | docs/ |
| monetization.md | 1.0 | 2026-03-12 | CURRENT | docs/ |
| WEBSITE_LOGIC_ERRORS.md | — | 2026-03-17 | CURRENT (backlog) | docs/ |

### Feature Specifications

| Document | Version | Last Updated | Phase Target | Location |
|----------|---------|-------------|-------------|----------|
| features/ruleset-engine.md | 1.0 | 2026-03-12 | Phase 0 (core) | docs/features/ |
| features/tracking.md | 1.0 | 2026-03-12 | Phase 0.5 | docs/features/ |
| features/verification-system.md | 1.0 | 2026-03-12 | Phase 0–3 (progressive) | docs/features/ |
| features/scoring.md | 1.0-DRAFT | 2026-03-12 | Phase 3+ | docs/features/ |
| features/punishments.md | 1.0 | 2026-03-12 | Phase 3+ | docs/features/ |
| features/rewards.md | 1.0 | 2026-03-12 | Phase 3+ | docs/features/ |
| features/houses.md | 1.0 | 2026-03-12 | Phase 3+ | docs/features/ |
| features/mini-games.md | 1.0 | 2026-03-12 | Phase 3+ | docs/features/ |
| features/web-interface.md | 1.0-WIP | 2026-03-12 | Phase 3+ | docs/features/ |
| features/challenges.md | 1.0 | 2026-03-17 | Phase 3+ | docs/features/ |

### Project Operations

| Document | Version | Created | Location |
|----------|---------|---------|----------|
| CHANGELOG.md | 1.0 | 2026-03-17 | docs/project/ |
| BACKLOG.md | 1.0 | 2026-03-17 | docs/project/ |
| DECISION_LOG.md | 1.0 | 2026-03-17 | docs/project/ |
| STATUS_DASHBOARD.md | 1.0 | 2026-03-17 | docs/project/ |
| DEPENDENCY_MAP.md | 1.0 | 2026-03-17 | docs/project/ |
| RELEASE_CHECKLIST.md | 1.0 | 2026-03-17 | docs/project/ |
| VERSION_ARCHIVE.md | 1.0 | 2026-03-17 | docs/project/ |

### Addon QA

| Document | Version | Last Updated | Location |
|----------|---------|-------------|----------|
| AUDIT_REPORT.md | Pre-Testing | 2026-03-17 | addon/ |
| TESTING_CHECKLIST.md | 2.0 | 2026-03-17 | addon/ |
| SETUP.txt | — | 2026-03-17 | addon/HardcorePlus/ |

### Legacy / Archived

| Document | Original Version | Archived Date | Location |
|----------|-----------------|---------------|----------|
| phases-original.md | 1.0 | 2026-03-17 | docs/legacy/ |
| PROJECT_PLAN_EN.md | 1.0-DRAFT | 2026-03-17 (removed) | git history only |
| PROJECT_PLAN_DE.md | 1.0-DRAFT | 2026-03-17 (removed) | git history only |
| concepts-archive.md | — | — | docs/ (intentional archive) |

---

## File Count Summary

| Category | Files | Notes |
|----------|-------|-------|
| Addon Lua (custom) | 34 | Core + Systems + Tracking + Network + UI |
| Addon Lua (libraries) | 17 | Ace3 + LDB + LibDBIcon |
| Addon other (.toc, .txt) | 2 | HardcorePlus.toc, SETUP.txt |
| Documentation | 20 | docs/ + docs/features/ + docs/project/ |
| QA documents | 2 | AUDIT_REPORT.md, TESTING_CHECKLIST.md |
| Project ops | 7 | docs/project/ (this session) |
| Website | ~20 | HTML, CSS, JS, assets |
| Infrastructure | 4 | Dockerfile, docker-compose.yml, .gitignore, launch.json |
| Legacy/archived | 2 | docs/legacy/, docs/concepts-archive.md |
| **Total tracked** | **~106** | Excluding .git and backup/ |

---

_When creating a new document, add an entry here. When updating a document significantly, update its version and Last Updated date._
