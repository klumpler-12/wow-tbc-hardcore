# Mini-Games

Spontaneous entertainment and additional point-earning opportunities. Premium feature.

---

## Built-In Mini-Games

- **Race to Location:** GM picks destination, first player to /say keyword there wins
- **Scavenger Hunt:** Collect a list of items; first to complete wins
- **First to X:** First to reach a milestone (level, skill, kill count) earns bonus
- **Survival Challenge:** All enter dangerous area; last alive wins
- **Trivia:** GM asks WoW lore questions in guild chat; first correct answer wins
- **Hide and Seek:** One hides, others seek. Proximity detection verifies

---

## Custom Mini-Game Framework

GMs create custom mini-games via template system:
- Name, description, start condition, win condition
- Point reward, maximum participants
- Can be scheduled or triggered spontaneously
- Results logged and contribute to leaderboard

---

## Data Structure

```lua
MiniGame = {
    id = "mg_race_001",
    type = "race",
    name = "Race to the Dark Portal",
    description = "First to /say 'ARRIVED' at the Dark Portal wins!",
    reward = 200,
    maxParticipants = 0,       -- 0 = unlimited
    startTime = 1710000000,
    endTime = nil,             -- nil = ends when won
    winner = nil,
    participants = {},
}
```
