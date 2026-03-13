# Fractions (Houses)

For large guilds (100+ members), fractions provide internal competition structure. Premium feature.

---

## Structure

- Each guild can have 2–8 fractions (configurable)
- Each fraction has a **Fraction Leader** and optional officers
- Fractions compete within the guild on a faction leaderboard
- Individual player scores contribute to their fraction's total
- Max fraction size: **1/8 of guild member cap**

---

## Competition

- **Per-Activity Points:** Fraction member kills boss, clears dungeon, earns achievement → points added to both personal score and fraction total
- **Fraction vs. Fraction Events:** GMs create direct competitions (e.g., "First fraction to clear Heroic Mechanar wins 500 bonus points")
- **Weekly/Monthly Standings:** Automated leaderboard snapshots for guild meetings

---

## Team Aggregation

- Fractions can be grouped into 2 competing teams
- 2 competing leaders, each leading multiple fractions
- For 25-man content, fractions merge into their team
- Points from 25-man content split across participating fractions

---

## Draft System

For events where leaders draft players:

- **Player Ratings:** 1–10 based on prior performance, class, experience
- **Draft Budget:** Each leader has point budget (e.g., 60 points for 10-man roster)
- **Draft Rules:** Top-rated players cost more (10-rated = 10 budget points)
- **Draft Order:** GM determines (random, reverse standings, auction, snake draft)
- **Draft UI:** In-game panel + web dashboard

---

## Data Structure

```lua
Fraction = {
    id = "fraction_1",
    name = "Vanguard",
    team = "fraction_a",
    leader = "PlayerName-Server",
    officers = {"Officer1-Server", "Officer2-Server"},
    members = {},
    totalScore = 0,
    weeklyScore = 0,
    seasonScore = 0,
}
```
