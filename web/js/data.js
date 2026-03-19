// Shared data arrays — single source of truth for all rendered content
window.HCData = {

  // Instance Lifes — Heroic Dungeons + Raids
  instanceLives: {
    heroic: [
      { diff: 'easy', lives: 2, label: '★ Easy — 2 Lifes', dungeons: [
        'HC Mechanar', 'HC Slave Pens', 'HC Ramparts', 'HC Blood Furnace'
      ]},
      { diff: 'hard', lives: 3, label: '★★ Hard — 3 Lifes', dungeons: [
        'HC Shadow Lab', 'HC Arcatraz', 'HC Black Morass',
        'HC Underbog', 'HC Old Hillsbrad', 'HC Botanica',
        'HC Steamvault', 'HC Auchenai Crypts', 'HC Sethekk Halls', 'HC Mana-Tombs',
        'HC Shattered Halls', "HC Magisters' Terrace"
      ], initialShow: 3, expandId: 'ilHeroicHardMore' }
    ],
    raids: [
      { diff: 'easy', lives: 2, label: '★ Entry — 2 Lifes', dungeons: [
        { name: 'Karazhan', size: '10-man' },
        { name: "Gruul's Lair", size: '25-man' },
        { name: 'Magtheridon', size: '25-man' }
      ]},
      { diff: 'hard', lives: 3, label: '★★ Mid & End — 3 Lifes', dungeons: [
        { name: "Zul'Aman", size: '10-man' },
        { name: 'Serpentshrine Cavern', size: '25-man' },
        { name: 'Tempest Keep', size: '25-man' },
        { name: 'Mount Hyjal', size: '25-man' },
        { name: 'Black Temple', size: '25-man' },
        { name: 'Sunwell Plateau', size: '25-man' }
      ], initialShow: 3, expandId: 'ilRaidMore' }
    ]
  },

  // Houses — 2 Fractions × 3 Houses each
  houses: [
    { fraction: 'left', name: 'House Ironforge', leader: 'Theron', detail: 'First Kara clear', weekly: 1420, total: 4280 },
    { fraction: 'left', name: 'House Dawnblade', leader: 'Mirael', detail: 'Most achievements', weekly: 1180, total: 3910 },
    { fraction: 'left', name: 'House Ashwind', leader: 'Korrak', detail: 'Zero deaths this week', weekly: 890, total: 2750 },
    { fraction: 'right', name: 'House Stormgarde', leader: 'Vex', detail: 'Highest avg score', weekly: 1350, total: 4100 },
    { fraction: 'right', name: 'House Thornwall', leader: 'Senna', detail: 'Most heroic clears', weekly: 1100, total: 3600 },
    { fraction: 'right', name: 'House Nightveil', leader: 'Kel', detail: 'Best mini-game record', weekly: 680, total: 2200 }
  ],

  // Punishments — 7 rows
  punishments: [
    { cat: 'death',      icon: '\u2620', name: 'Instance Death',        severity: 90,  label: 'Critical', action: 'Lose 1 life + score penalty',         tip: 'Instance deaths consume lifes from your pool', reward: false, enabled: true },
    { cat: 'death',      icon: '\u2620', name: 'Open World Death',      severity: 100, label: 'Fatal',    action: 'Permadeath (1\u201370) / checkpoint at 58', tip: 'True hardcore \u2014 die in the open world, start over', reward: false, enabled: true },
    { cat: 'infraction', icon: '\u26A0', name: 'GM Flagged Violation',  severity: 80,  label: 'High',     action: 'Score deduction + public log entry',   tip: 'GM-flagged rule breaks visible to all', reward: false, enabled: true },
    { cat: 'infraction', icon: '\u23F1', name: 'AFK / Inactive Timer',  severity: 30,  label: 'Low',      action: 'Score decay after 7 days inactive',    tip: 'Encourages active play \u2014 optional rule', reward: false, enabled: false },
    { cat: 'reward',     icon: '\u2733', name: 'Deathless Streak',      severity: 80,  label: 'High',     action: '+500 pts per 7-day streak',            tip: 'Stay alive, climb the leaderboard', reward: true,  enabled: true },
    { cat: 'reward',     icon: '\u2733', name: 'Weekly MVP',            severity: 60,  label: 'Bonus',    action: 'Custom title + house score bonus',     tip: 'Top contributor earns recognition', reward: true,  enabled: true },
    { cat: 'custom',     icon: '\u270E', name: 'First Boss Kill',       severity: 50,  label: 'Bonus',    action: '+200 pts for server/guild first',      tip: 'Reward competitive PvE milestones', reward: true,  enabled: true }
  ],

  // Challenge Modes — meme-meta weapon/playstyle restrictions
  challenges: [
    { id: 'onlyfists', name: 'Onlyfists', icon: '\u{1F44A}', desc: 'Fist weapons only to 40 / 60 / 70',
      tiers: [
        { name: 'Bronze', level: 40, pts: 300 },
        { name: 'Silver', level: 60, pts: 750 },
        { name: 'Gold',   level: 70, pts: 1500 }
      ],
      chicken: true, chickenPenalty: -100,
      tip: 'Forfeit before a checkpoint and earn the Chicken title' },
    { id: 'wandslinger', name: 'Wandslinger', icon: '\u{1F52E}', desc: 'Wands only (caster classes)',
      tiers: [
        { name: 'Bronze', level: 40, pts: 400 },
        { name: 'Silver', level: 60, pts: 900 },
        { name: 'Gold',   level: 70, pts: 1800 }
      ],
      chicken: true, chickenPenalty: -100,
      tip: 'Only available for Mage, Warlock, Priest' },
    { id: 'petless', name: 'Petless Hunter', icon: '\u{1F3AF}', desc: 'Hunter with no pet — ever',
      tiers: [
        { name: 'Bronze', level: 40, pts: 500 },
        { name: 'Silver', level: 60, pts: 1000 },
        { name: 'Gold',   level: 70, pts: 2000 }
      ],
      chicken: true, chickenPenalty: -150,
      tip: 'Summon a pet even once and the challenge is voided' },
    { id: 'naked', name: 'Naked & Afraid', icon: '\u{1F633}', desc: 'No armor — weapons only',
      tiers: [
        { name: 'Bronze', level: 20, pts: 500 },
        { name: 'Silver', level: 40, pts: 1200 },
        { name: 'Gold',   level: 60, pts: 3000 }
      ],
      chicken: true, chickenPenalty: -200,
      tip: 'Equipping any armor piece voids the challenge' }
  ],

  // Flex Raiding — dynamic life scaling for smaller groups
  flexRaiding: {
    description: 'Fewer raiders = more lifes. Prevents mixed-group abuse with a hard cap.',
    examples: [
      { size: 25, bonus: 0, total: 1, label: 'Full raid' },
      { size: 20, bonus: 1, total: 2, label: '20-man' },
      { size: 15, bonus: 2, total: 3, label: '15-man' },
      { size: 10, bonus: 3, total: 4, label: '10-man (capped)' }
    ],
    rules: [
      'Bonus lifes capped at +3 (25-man) / +2 (10-man)',
      'Mixed groups (addon + non-addon) disable instance lifes entirely',
      'GM-configurable per instance — trivial content may not qualify',
      'Solo/duo cannot exploit: minimum group size thresholds apply'
    ]
  },

  // Fishing Frenzy — competitive fishing events
  fishingFrenzy: {
    description: 'Zone-wide or server-wide fishing competitions with titles and points.',
    modes: [
      { name: 'Zone Frenzy', scope: 'Same zone', duration: '15–30 min', trigger: 'GM or auto' },
      { name: 'Server Frenzy', scope: 'All addon users', duration: '1 hour', trigger: 'Scheduled' },
      { name: 'Guild Frenzy', scope: 'Guild only', duration: 'GM-configurable', trigger: 'GM' }
    ],
    rewards: [
      { place: '1st', reward: 'Fishing Frenzy Champion title (1 day or 1 week)' },
      { place: '1st (Server)', reward: 'Addon-wide title visible to all TBC Hybrid Hardcore users' },
      { place: 'Top 3', reward: 'Bonus score points' },
      { place: 'Participation', reward: 'Small point reward' }
    ]
  },

  // Achievements — WoW quality color classes
  achievements: [
    { pts: '+250',  name: 'First to kill 5 named mobs',      quality: 'rare' },
    { pts: '+500',  name: 'First to reach Fishing 375',      quality: 'epic' },
    { pts: '+100',  name: 'Clear Blood Furnace Heroic',      quality: 'uncommon' },
    { pts: '+50',   name: 'Loot a gray from Winterspring yetis', quality: 'poor' },
    { pts: '+1000', name: 'First Karazhan full clear',       quality: 'legendary' },
    { pts: '+75',   name: 'Sit in every chair in Shattrath', quality: 'poor' },
    { pts: '-200',  name: 'Death during dungeon run',        quality: 'penalty' },
    { pts: '+150',  name: 'Win a spontaneous GM race',       quality: 'uncommon' },
    { pts: '+1500', name: 'Onlyfists Gold — level 70 fists only', quality: 'legendary' },
    { pts: '+300',  name: 'Fishing Frenzy Champion',         quality: 'epic' }
  ],

  // Mixed Group & Disconnect Rules
  mixedGroupRules: {
    instanceLives: 'Instance lifes disabled in mixed groups (addon + non-addon players)',
    disconnect: {
      warning: 'Out-of-combat warning to group when a member disconnects',
      gracePeriod: 300, // 5 minutes
      outcome: 'Status flagged as "contested" if grace period expires — GM can review'
    }
  },

  // Project Phases
  phases: [
    { phase: 1, title: 'Alpha', desc: 'Selected testers, core features. Goal: validate the core loop works.', active: true,
      subs: [
        { heading: 'Core Addon Framework', items: [
          'Event bus & message routing between modules',
          'SavedVariables storage layer (per-character + per-guild)',
          'Config API — read/write rule values, default presets',
          'Addon communication channel (guild sync protocol)'
        ]},
        { heading: 'Death & Life System', items: [
          'Open-world death detection (combat log parsing)',
          'Permadeath flag — character marked permanently on death',
          'Instance life pool — assign 2-3 lifes per dungeon/raid difficulty',
          'Life loss event — UI notification, sound, combat log entry',
          'Life refill rules — weekly reset, per-instance, or never',
          'Death recap — last 5 damage sources before death'
        ]},
        { heading: 'Checkpoint System', items: [
          'Level 58 checkpoint trigger — auto-flag on reaching 58',
          'Checkpoint UI indicator in character panel',
          'Soft reset flow — strip gear, gold, professions on use',
          'Permanent "Soft Reset" profile flag visible to all'
        ]},
        { heading: 'Rule Configuration', items: [
          'Base mode defaults — works without any setup',
          'Survey-based quick setup (6 questions)',
          'Config summary panel — live preview of active rules',
          'Preset import/export (copy rulesets between guilds)'
        ]},
        { heading: 'Player Profiles & Tracking', items: [
          'Player profile page (web) — gear, stats, death log',
          'Death log with timestamp, zone, killer, combat replay link',
          'Deathless streak counter',
          'Basic stat tracking — time played, dungeons cleared, deaths'
        ]},
        { heading: 'Testing & Infrastructure', items: [
          'Internal alpha testing with selected guild (10-20 players)',
          'Bug reporting system (in-addon + Discord integration)',
          'Automated SavedVariables backup on addon update',
          'Version check & update notification'
        ]}
      ]
    },
    { phase: 2, title: 'Public Alpha', desc: 'Open to all guilds. Passive polling shapes base mode defaults.', active: false,
      subs: [
        'Open registration for guilds',
        'Passive polling — popular settings define base mode',
        'Community feedback collection',
        'Balance adjustments to life counts & checkpoint level'
      ]
    },
    { phase: 3, title: 'Beta', desc: 'Feature-complete. Final rulesets, premium features, guild sites.', active: false,
      subs: [
        'Premium features (houses, drafts, scoring, guild sites)',
        'Guild site generation (hardcoreplus.gg)',
        'Leaderboards & server-wide rankings',
        'Full API for third-party integrations'
      ]
    },
    { phase: 4, title: 'Release', desc: 'Stable release on CurseForge. Bug fixes & polish.', active: false,
      subs: [
        'CurseForge listing & auto-updater',
        'Performance optimization & memory profiling',
        'Documentation & setup guides',
        'Community moderation tools'
      ]
    },
    { phase: null, title: 'WotLK & Beyond', desc: 'Expansion ports, Classic+ support', active: false, future: true }
  ]
};
