// Language Toggle — EN/DE
(function() {
  var toggle = document.getElementById('langToggle');
  if (!toggle) return;

  var translations = {
    // Hero
    'An extension to classic Hardcore, designed for TBC.': 'Eine Erweiterung des klassischen Hardcore-Modus, entwickelt für TBC.',
    'Same thrill, more flexibility, less frustration.': 'Gleicher Nervenkitzel, mehr Flexibilität, weniger Frust.',

    // Concept Timeline
    'LEVEL PROGRESSION': 'LEVEL-FORTSCHRITT',
    'Classic HC Leveling': 'Klassisches HC-Leveling',
    'Multi-Life Instances': 'Multi-Leben Instanzen',
    'Checkpoints, lifes, death penalties —': 'Checkpoints, Leben, Todesstrafen —',
    'everything adapts.': 'alles passt sich an.',
    'unlocks full customization.': 'schaltet volle Anpassung frei.',

    // Rule Config
    'Configure': 'Konfigurieren',
    'Your Rules,': 'Deine Regeln,',
    'Your Way': 'Dein Weg',
    'Base mode works out of the box. Want more control? Customize everything below.': 'Der Basismodus funktioniert sofort. Mehr Kontrolle gewünscht? Alles unten anpassen.',
    'Quick Setup': 'Schnellstart',
    'Answer a few questions to build your ruleset.': 'Beantworte ein paar Fragen, um dein Regelwerk zu erstellen.',
    'unlocks granular customization.': 'schaltet detaillierte Anpassung frei.',
    'Permadeath (fixed)': 'Permadeath (fest)',

    // Premium
    'Premium: Full Customization': 'Premium: Volle Anpassung',
    'Work in Progress': 'In Arbeit',
    'GMs with Premium unlock a granular decision tree. Every rule can be individually tuned, toggled, and saved as a reusable preset. Base mode covers the essentials — Premium lets you fine-tune everything.': 'GMs mit Premium schalten einen detaillierten Entscheidungsbaum frei. Jede Regel kann individuell eingestellt, umgeschaltet und als wiederverwendbare Vorlage gespeichert werden.',
    'Copy Rulesets': 'Regelwerke kopieren',
    "Copy any guild's or player's rule configuration with one click. Play along any event, community challenge, or custom ruleset you enjoy — no manual setup needed.": 'Kopiere die Regelkonfiguration jeder Gilde oder jedes Spielers mit einem Klick. Spiele bei jedem Event, Community-Challenge oder benutzerdefinierten Regelwerk mit.',
    'Scoring': 'Punktesystem',
    'Guild Setup': 'Gilden-Setup',
    'Premium is delivered via Patreon. It adds management tools for GMs — no gameplay advantage. Free players always participate fully.': 'Premium wird über Patreon bereitgestellt. Es fügt Management-Tools für GMs hinzu — kein Gameplay-Vorteil. Freie Spieler nehmen immer voll teil.',

    // Instance Lifes
    'Base Mode': 'Basismodus',
    'Dungeon & Raid': 'Dungeon- & Raid-',
    'Lifes': 'Leben',
    "Don't limit yourself —": 'Schränk dich nicht ein —',
    'challenge yourself.': 'fordere dich heraus.',
    'Difficulty-based lifes protect against': 'Schwierigkeitsbasierte Leben schützen vor',
    'one-shot': 'One-Shot',
    'wipes while keeping': 'Wipes und halten',
    'stakes high.': 'den Einsatz hoch.',
    'These are': 'Dies sind',
    'base mode defaults': 'Basismodus-Standards',
    'unlocks full customization of every value.': 'schaltet volle Anpassung jedes Wertes frei.',
    'Heroic Dungeons': 'Heroische Dungeons',
    'Raids': 'Schlachtzüge',
    'Lifes are active from level 58. Harder heroics grant more lifes. Reaching 0 = permadeath.': 'Leben sind ab Level 58 aktiv. Schwerere Heroics gewähren mehr Leben. Bei 0 = Permadeath.',
    'Lifes always active. Reaching 0 = permadeath.': 'Leben immer aktiv. Bei 0 = Permadeath.',

    // Death Sequence
    'The Stakes': 'Der Einsatz',
    'Play Every Instance.': 'Spiele jede Instanz.',
    'No Fear.': 'Ohne Angst.',
    "Instance lifes mean a one-shot wipe won't end your character. Attempt the hardest content knowing you have a safety net — but once your lifes run out, it's over for good.": 'Instanz-Leben bedeuten, dass ein One-Shot-Wipe deinen Charakter nicht beendet. Versuche den schwersten Content mit einem Sicherheitsnetz — aber wenn deine Leben aufgebraucht sind, ist es endgültig vorbei.',

    // Guild
    'Guild Management Tools': 'Gilden-Verwaltungstools',
    'Your Guild,': 'Deine Gilde,',
    'Many Banners': 'Viele Banner',
    'Split your guild into competing Fractions, draft players into Houses, and track everything with automated scoring.': 'Teile deine Gilde in konkurrierende Fraktionen, drafte Spieler in Häuser und verfolge alles mit automatischer Punktevergabe.',

    // Houses
    'Houses & Scoring': 'Häuser & Punktesystem',
    'Fractions': 'Fraktionen',
    'Compete': 'Wettkampf',
    'Weekly Score': 'Wochenpunktzahl',
    'Total Score': 'Gesamtpunktzahl',

    // Guild Sites
    'Web Platform': 'Web-Plattform',
    'Guild Sites &': 'Gilden-Seiten &',
    'Player Profiles': 'Spielerprofile',
    'Every guild gets a web presence. Every player gets a profile. Preview the interactive demos below.': 'Jede Gilde bekommt eine Webpräsenz. Jeder Spieler bekommt ein Profil. Sieh dir die interaktiven Demos unten an.',

    // Scoring
    'Experimental — Future Update': 'Experimentell — Zukünftiges Update',
    'Every Action': 'Jede Aktion',
    'Counts': 'Zählt',

    // Ideas Lab
    'Early Concepts': 'Frühe Konzepte',
    'Ideas': 'Ideen-',
    'Lab': 'Labor',
    'Brainstorm-phase features being explored. These concepts are not final — they\'re being shaped by community feedback.': 'Features in der Brainstorm-Phase. Diese Konzepte sind nicht endgültig — sie werden durch Community-Feedback geformt.',

    // Get Started
    'Get Started': 'Loslegen',
    'Choose Your': 'Wähle deinen',
    'Path': 'Weg',
    'Free on CurseForge. Premium unlocks guild management & web platform.': 'Kostenlos auf CurseForge. Premium schaltet Gildenverwaltung & Web-Plattform frei.',
    'Base Add-on': 'Basis-Addon',
    'Free': 'Kostenlos',
    'via Patreon': 'über Patreon',
    'Everything in Base': 'Alles aus Basis',
    'Coming to CurseForge': 'Bald auf CurseForge',
    'View Roadmap': 'Roadmap ansehen',
    'Free players always participate fully. Premium adds management tools for GMs. Never pay-to-win.': 'Freie Spieler nehmen immer voll teil. Premium fügt Management-Tools für GMs hinzu. Niemals Pay-to-Win.',

    // Tier card features (Base)
    'Permadeath tracking (1': 'Permadeath-Tracking (1',
    'Instance lifes system': 'Instanz-Leben-System',
    'Checkpoint / soft reset': 'Checkpoint / Soft Reset',
    'Death detection & combat log': 'Toderkennung & Combat-Log',
    'SSF / Guildfound modes': 'SSF / Gildenfund-Modi',
    'Player profile page': 'Spieler-Profilseite',
    'Basic rule configuration': 'Basis-Regelkonfiguration',
    'Download on CurseForge': 'Download auf CurseForge',

    // Tier card features (Premium)
    'Guild site (hardcoreplus.gg/guild/...)': 'Gilden-Seite (hardcoreplus.gg/guild/...)',
    'Houses & Fractions management': 'Häuser- & Fraktionen-Verwaltung',
    'Guild Draft system': 'Gilden-Draft-System',
    'Custom scoring & leaderboards': 'Eigenes Punktesystem & Ranglisten',
    'Custom life rules per instance': 'Eigene Lebensregeln pro Instanz',
    'Punishment & reward manager': 'Bestrafungs- & Belohnungs-Manager',
    'Priority support & early access': 'Prioritäts-Support & Early Access',
    'Follow on Patreon': 'Folgen auf Patreon',

    // Architecture
    'Architecture': 'Architektur',
    'Modular': 'Modulares',
    'Plugin System': 'Plugin-System',
    'The addon is split into a lightweight': 'Das Addon ist aufgeteilt in einen leichtgewichtigen',
    'Core Engine (always loaded)': 'Kern-Engine (immer geladen)',
    'Event Bus': 'Event-Bus',
    'Character Tracker': 'Charakter-Tracker',
    'Death Detection': 'Toderkennung',
    'Life System': 'Leben-System',
    'Scoring Engine': 'Punkte-Engine',
    'Config API': 'Config-API',
    'Fundamental HC framework': 'Fundamentales HC-Framework',
    'always active when addon is enabled': 'immer aktiv wenn das Addon aktiviert ist',

    // Phases
    'Development': 'Entwicklung',
    'Project': 'Projekt-',
    'Phases': 'Phasen',

    // Death Sequence (longer text variant with mdash)
    "Instance lifes mean a one-shot wipe won't end your character. Attempt the hardest content knowing you have a safety net — but once your lifes run out, it's over for good.": 'Instanz-Leben bedeuten, dass ein One-Shot-Wipe deinen Charakter nicht beendet. Versuche den schwersten Content mit einem Sicherheitsnetz — aber wenn deine Leben aufgebraucht sind, ist es endgültig vorbei.',

    // Houses / Fractions
    "Each Fraction fields": 'Jede Fraktion stellt',
    'Houses': 'Häuser',
    "that compete with automated scoring. House Leaders name their sub-teams. Each house holds up to": 'die mit automatischer Punktevergabe konkurrieren. Häuserführer benennen ihre Sub-Teams. Jedes Haus fasst bis zu',
    "of your guild's member cap. Need more room? Link guilds as a": 'deiner Gildenmitglieder-Obergrenze. Mehr Platz nötig? Verknüpfe Gilden als',
    'Super Guild': 'Super-Gilde',

    // Scoring section desc
    'Guild-wide and server-wide scoring. Complete hard challenges, earn virtual rewards, and climb the leaderboard.': 'Gilden- und serverweites Punktesystem. Meistere schwere Herausforderungen, verdiene virtuelle Belohnungen und klettere in der Rangliste.',
    'This feature is planned but not included in the first release.': 'Dieses Feature ist geplant, aber nicht im ersten Release enthalten.',

    // Hide & Seek
    'Hide & Seek Mode': 'Versteckspiel-Modus',
    'Mini-Game': 'Minispiel',
    'Hider': 'Verstecker',
    'Seeker': 'Sucher',
    '60s to find a hiding spot': '60s um ein Versteck zu finden',
    'Screen blacked out during hide phase': 'Bildschirm verdunkelt während der Versteckphase',
    'Free to move': 'Freie Bewegung',
    'No restrictions': 'Keine Einschränkungen',
    'No UI': 'Kein UI',
    'No target': 'Kein Ziel',
    'Find & click': 'Finden & klicken',
    "How it works:": 'So funktioniert es:',
    'A UI-off approach where immersion is key. During seek phase: no nameplates, no minimap, no target frames': 'Ein UI-freier Ansatz, bei dem Immersion im Vordergrund steht. Während der Suchphase: keine Namensplaketten, keine Minimap, keine Zielrahmen',
    'pure game world. Seekers must physically walk to hidden players and click within 5 yards.': 'pure Spielwelt. Sucher müssen physisch zu versteckten Spielern laufen und innerhalb von 5 Yards klicken.',
    'Nameplates': 'Namensplaketten',
    'Minimap': 'Minimap',
    'Target Frame': 'Zielrahmen',
    'Party Frames': 'Gruppenrahmen',
    '3D World Only': 'Nur 3D-Welt',
    'Safety First:': 'Sicherheit zuerst:',
    'Players warned to take safe positions before start. Deaths during Hide & Seek are flagged': 'Spieler werden gewarnt, sichere Positionen einzunehmen. Tode während des Versteckspiels werden markiert',
    'anti-griefing protection active.': 'Anti-Griefing-Schutz aktiv.',

    // Soft Reset
    'The Soft Reset': 'Der Soft Reset',
    'Concept:': 'Konzept:',
    'For players with limited playtime who hit permadeath. Instead of full character deletion, allow a': 'Für Spieler mit begrenzter Spielzeit, die Permadeath erleiden. Statt vollständiger Charakterlöschung, erlaube einen',
    'soft reset': 'Soft Reset',
    'if the character reached the checkpoint (lvl 58) before dying.': 'wenn der Charakter den Checkpoint (Stufe 58) vor dem Tod erreicht hat.',
    'Permadeath': 'Permadeath',
    'Strip All Gear, Professions & Gold': 'Ausrüstung, Berufe & Gold entfernen',
    'Continue as': 'Weiter als',
    'Non-HC': 'Non-HC',
    'Character permanently marked as': 'Charakter permanent markiert als',
    'on profile and guild roster. Visible to all players. No hiding it.': 'auf Profil und Gildenaufstellung. Für alle Spieler sichtbar. Kein Verstecken.',
    'Rules:': 'Regeln:',
    'Must have reached 60 before death. Guild can enable/disable this option. All gear, gold, professions and earned items removed. Score reset to 0. Character flag is permanent. Needs further design on limitations.': 'Muss vor dem Tod Stufe 60 erreicht haben. Gilde kann diese Option aktivieren/deaktivieren. Alle Ausrüstung, Gold, Berufe und verdiente Gegenstände werden entfernt. Punktzahl auf 0 zurückgesetzt. Charakter-Markierung ist permanent. Limitierungen werden noch ausgestaltet.',

    // Project Phases (data.js rendered content)
    'Alpha': 'Alpha',
    'Selected testers, core features. Goal: validate the core loop works.': 'Ausgewählte Tester, Kernfeatures. Ziel: Validierung, dass die Kernschleife funktioniert.',
    'Core Addon Framework': 'Kern-Addon-Framework',
    'Event bus & message routing between modules': 'Event-Bus & Nachrichtenweiterleitung zwischen Modulen',
    'SavedVariables storage layer (per-character + per-guild)': 'SavedVariables-Speicherschicht (pro Charakter + pro Gilde)',
    'Config API — read/write rule values, default presets': 'Config-API — Regelwerte lesen/schreiben, Standard-Vorlagen',
    'Addon communication channel (guild sync protocol)': 'Addon-Kommunikationskanal (Gilden-Sync-Protokoll)',
    'Death & Life System': 'Tod- & Leben-System',
    'Open-world death detection (combat log parsing)': 'Open-World-Toderkennung (Combat-Log-Parsing)',
    'Permadeath flag — character marked permanently on death': 'Permadeath-Flag — Charakter wird bei Tod permanent markiert',
    'Instance life pool — assign 2-3 lifes per dungeon/raid difficulty': 'Instanz-Lebenpool — 2-3 Leben pro Dungeon/Raid-Schwierigkeit',
    'Life loss event — UI notification, sound, combat log entry': 'Lebensverlust-Event — UI-Benachrichtigung, Sound, Combat-Log-Eintrag',
    'Life refill rules — weekly reset, per-instance, or never': 'Leben-Nachfüll-Regeln — wöchentlicher Reset, pro Instanz oder nie',
    'Death recap — last 5 damage sources before death': 'Todesrückblick — letzte 5 Schadensquellen vor dem Tod',
    'Checkpoint System': 'Checkpoint-System',
    'Level 58 checkpoint trigger — auto-flag on reaching 58': 'Stufe-58-Checkpoint-Auslöser — Auto-Flag bei Erreichen von 58',
    'Checkpoint UI indicator in character panel': 'Checkpoint-UI-Anzeige im Charakterpanel',
    'Soft reset flow — strip gear, gold, professions on use': 'Soft-Reset-Ablauf — Ausrüstung, Gold, Berufe bei Nutzung entfernen',
    'Permanent "Soft Reset" profile flag visible to all': 'Permanentes „Soft Reset"-Profil-Flag für alle sichtbar',
    'Rule Configuration': 'Regel-Konfiguration',
    'Base mode defaults — works without any setup': 'Basismodus-Standards — funktioniert ohne Setup',
    'Survey-based quick setup (6 questions)': 'Umfragebasiertes Schnell-Setup (6 Fragen)',
    'Config summary panel — live preview of active rules': 'Konfigurations-Übersicht — Live-Vorschau aktiver Regeln',
    'Preset import/export (copy rulesets between guilds)': 'Vorlagen-Import/Export (Regelwerke zwischen Gilden kopieren)',
    'Player Profiles & Tracking': 'Spielerprofile & Tracking',
    'Player profile page (web) — gear, stats, death log': 'Spieler-Profilseite (Web) — Ausrüstung, Statistiken, Todeslog',
    'Death log with timestamp, zone, killer, combat replay link': 'Todeslog mit Zeitstempel, Zone, Killer, Combat-Replay-Link',
    'Deathless streak counter': 'Deathless-Streak-Zähler',
    'Basic stat tracking — time played, dungeons cleared, deaths': 'Basis-Statistik-Tracking — Spielzeit, Dungeons geschafft, Tode',
    'Testing & Infrastructure': 'Tests & Infrastruktur',
    'Internal alpha testing with selected guild (10-20 players)': 'Internes Alpha-Testing mit ausgewählter Gilde (10-20 Spieler)',
    'Bug reporting system (in-addon + Discord integration)': 'Bug-Reporting-System (im Addon + Discord-Integration)',
    'Automated SavedVariables backup on addon update': 'Automatisches SavedVariables-Backup bei Addon-Update',
    'Version check & update notification': 'Versionsprüfung & Update-Benachrichtigung',
    'Public Alpha': 'Öffentliche Alpha',
    'Open to all guilds. Passive polling shapes base mode defaults.': 'Offen für alle Gilden. Passives Polling formt die Basismodus-Standards.',
    'Open registration for guilds': 'Offene Registrierung für Gilden',
    'Passive polling — popular settings define base mode': 'Passives Polling — beliebte Einstellungen definieren den Basismodus',
    'Community feedback collection': 'Community-Feedback-Sammlung',
    'Balance adjustments to life counts & checkpoint level': 'Balance-Anpassungen der Lebensanzahl & Checkpoint-Stufe',
    'Beta': 'Beta',
    'Feature-complete. Final rulesets, premium features, guild sites.': 'Feature-komplett. Finale Regelwerke, Premium-Features, Gilden-Seiten.',
    'Premium features (houses, drafts, scoring, guild sites)': 'Premium-Features (Häuser, Drafts, Punktesystem, Gilden-Seiten)',
    'Guild site generation (hardcoreplus.gg)': 'Gilden-Seiten-Generierung (hardcoreplus.gg)',
    'Leaderboards & server-wide rankings': 'Ranglisten & serverweite Rankings',
    'Full API for third-party integrations': 'Vollständige API für Drittanbieter-Integrationen',
    'Release': 'Release',
    'Stable release on CurseForge. Bug fixes & polish.': 'Stabiles Release auf CurseForge. Bugfixes & Feinschliff.',
    'CurseForge listing & auto-updater': 'CurseForge-Eintrag & Auto-Updater',
    'Performance optimization & memory profiling': 'Performance-Optimierung & Speicher-Profiling',
    'Documentation & setup guides': 'Dokumentation & Einrichtungsanleitungen',
    'Community moderation tools': 'Community-Moderationstools',
    'WotLK & Beyond': 'WotLK & Darüber hinaus',
    'Expansion ports, Classic+ support': 'Erweiterungs-Portierungen, Classic+-Unterstützung',
    'Future': 'Zukunft',

    // Architecture — plugins
    'Guild Setup & Draft': 'Gilden-Setup & Draft',
    'Active': 'Aktiv',
    'Inactive': 'Inaktiv',
    'Houses, divisions, draft tool, Super Guild': 'Häuser, Divisionen, Draft-Tool, Super-Gilde',
    'Web Export': 'Web-Export',
    'Guild sites, player profiles, leaderboards': 'Gilden-Seiten, Spielerprofile, Ranglisten',
    'Mini-Games': 'Minispiele',
    'Hide & Seek, custom GM events': 'Versteckspiel, eigene GM-Events',
    'Each plugin is activated through the main addon menu only when needed. This keeps memory footprint minimal and allows features to be independently updated, disabled, or swapped for new expansion ports (WotLK, Classic+).': 'Jedes Plugin wird nur bei Bedarf über das Hauptmenü des Addons aktiviert. Das hält den Speicherverbrauch minimal und ermöglicht unabhängige Updates, Deaktivierung oder den Austausch für neue Erweiterungen (WotLK, Classic+).',

    // Guild Sites — mockup content
    'Members': 'Mitglieder',
    'Season': 'Saison',
    'Ruleset:': 'Regelwerk:',
    'Top House:': 'Bestes Haus:',
    'Leading': 'Führend',
    'Week:': 'Woche:',
    'boss kills': 'Boss-Kills',
    'deaths': 'Tode',
    'Prot Paladin': 'Schutz-Paladin',
    'House Ironforge': 'Haus Eisenschmiede',
    'Alive': 'Lebendig',
    'Score': 'Punkte',
    'Rank': 'Rang',
    'Deaths': 'Tode',
    'Achiev.': 'Erfolge',
    'Equipped Gear': 'Angelegte Ausrüstung',
    'Death Log': 'Todeslog',
    'No deaths recorded. Deathless streak: 14 days': 'Keine Tode verzeichnet. Deathless-Streak: 14 Tage',
    'Full profile with gear, death log, achievements & deathclip': 'Vollständiges Profil mit Ausrüstung, Todeslog, Erfolgen & Deathclip',
    'Open Player Profile': 'Spielerprofil öffnen',
    'Guild overview, house standings, roster & premium features': 'Gildenübersicht, Haus-Rangliste, Aufstellung & Premium-Features',
    'Open Guild Overview': 'Gildenübersicht öffnen',
    'members': 'Mitglieder',

    // Houses — card data (rendered by houses.js)
    'Leader:': 'Anführer:',
    'First Kara clear': 'Erster Kara-Clear',
    'Most achievements': 'Meiste Erfolge',
    'Zero deaths this week': 'Null Tode diese Woche',
    'Highest avg score': 'Höchste Durchschnittspunktzahl',
    'Most heroic clears': 'Meiste Heroic-Clears',
    'Best mini-game record': 'Bester Minispiel-Rekord',
    'House Ironforge': 'Haus Eisenschmiede',
    'House Dawnblade': 'Haus Dawnblade',
    'House Ashwind': 'Haus Ashwind',
    'House Stormgarde': 'Haus Stormgarde',
    'House Thornwall': 'Haus Thornwall',
    'House Nightveil': 'Haus Nightveil',
    'Fraction Alpha': 'Fraktion Alpha',
    'Fraction Omega': 'Fraktion Omega',

    // Draft
    'Draft starts automatically when you scroll here': 'Der Draft startet automatisch beim Scrollen zu diesem Bereich',
    'Open Design': 'Offenes Design',
    'How many guilds can link?': 'Wie viele Gilden können verknüpft werden?',
    '(Draft feature supports up to 4 guilds for now)': '(Draft-Feature unterstützt derzeit bis zu 4 Gilden)',

    // Scoring tree
    'Scoring Configuration': 'Punktesystem-Konfiguration',
    'enabled': 'aktiviert',
    'Character': 'Charakter',
    'PvE': 'PvE',
    'PvP': 'PvP',
    'Guild Achievements': 'Gilden-Erfolge',
    'Penalties': 'Strafen',
    'Leveling': 'Leveling',
    'Professions': 'Berufe',
    'Reputation': 'Ruf',
    'Gear Thresholds': 'Ausrüstungs-Schwellen',
    'Green (Uncommon)': 'Grün (Ungewöhnlich)',
    'Blue (Rare)': 'Blau (Selten)',
    'Purple (Epic)': 'Lila (Episch)',
    'Orange (Legendary)': 'Orange (Legendär)',
    'Add Guild Achievement': 'Gilden-Erfolg hinzufügen',
    'Achievement name...': 'Erfolgsname...',
    'Add': 'Hinzufügen',
    'Hidden (GM only)': 'Versteckt (nur GM)',
    'Maxed First (first in guild)': 'Zuerst Maximal (erster in Gilde)',
    'Maxed General (anyone)': 'Maximal Allgemein (jeder)',
    'Custom Goal:': 'Eigenes Ziel:',
    'Visibility:': 'Sichtbarkeit:',
    'Public': 'Öffentlich',
    'Hidden (GM)': 'Versteckt (GM)',

    // Rule Manager — survey questions & options
    'Instance lifes: which rule set?': 'Instanz-Leben: welches Regelwerk?',
    'Lifes protect against one-shot wipes in dungeons and raids.': 'Leben schützen vor One-Shot-Wipes in Dungeons und Raids.',
    'Base rules': 'Basisregeln',
    'easy,': 'einfach,',
    'hard (default)': 'schwer (Standard)',
    'Custom life rules': 'Eigene Lebensregeln',
    'define your own values': 'eigene Werte festlegen',
    'Self-found mode?': 'Self-Found-Modus?',
    'Restricts trading. SSF/Guildfound chars are eligible for soft reset on permadeath.': 'Beschränkt den Handel. SSF/Gildenfund-Charaktere können bei Permadeath einen Soft Reset durchführen.',
    'no trading, no auction house': 'kein Handel, kein Auktionshaus',
    'guild trading only': 'nur Gildenhandel',
    'No restriction': 'Keine Einschränkung',
    'checkpoints by official boosting only, no soft reset': 'Checkpoints nur durch offizielles Boosting, kein Soft Reset',
    'Play style?': 'Spielstil?',
    'Defines your group setup. Group composition is locked after first XP is gained.': 'Definiert dein Gruppen-Setup. Gruppenzusammensetzung ist nach erstem XP-Gewinn gesperrt.',
    'Solo player': 'Solo-Spieler',
    'define members at char creation (locked after first XP)': 'Mitglieder bei Charaktererstellung festlegen (gesperrt nach erstem XP)',
    'requires Premium for management tools': 'benötigt Premium für Verwaltungstools',
    'PvP rules?': 'PvP-Regeln?',
    'Player Enforced PvP (PEP) is an experimental future feature.': 'Player Enforced PvP (PEP) ist ein experimentelles zukünftiges Feature.',
    'PvP with HC rules (BGs + Arena count)': 'PvP mit HC-Regeln (BGs + Arena zählen)',
    'PvP exempt from HC rules': 'PvP ausgenommen von HC-Regeln',
    'Checkpoint system?': 'Checkpoint-System?',
    'Reaching the checkpoint level unlocks the ability to restart via official boost.': 'Das Erreichen der Checkpoint-Stufe ermöglicht den Neustart über offiziellen Boost.',
    'Yes': 'Ja',
    'checkpoint at level 58 (default)': 'Checkpoint bei Stufe 58 (Standard)',
    'No checkpoints': 'Keine Checkpoints',
    'permadeath is final': 'Permadeath ist endgültig',
    'Quick Setup': 'Schnellstart',
    'Presets': 'Vorlagen',
    'Your Ruleset': 'Dein Regelwerk',
    'Instance Lifes': 'Instanz-Leben',
    'Instance Leben': 'Instanz-Leben',
    'Self-Found': 'Self-Found',
    'Play Style': 'Spielstil',
    'Checkpoints': 'Checkpoints',
    'Houses & Guilds': 'Häuser & Gilden',
    'Rule Setting Manager': 'Regel-Einstellungsmanager',
    'Answer a few questions to build your ruleset.': 'Beantworte ein paar Fragen, um dein Regelwerk zu erstellen.',

    // Checkpoint & Soft Reset section
    'Two paths to continue after reaching the checkpoint at level 58. One for boosters, one for everyone.': 'Zwei Wege nach Erreichen des Checkpoints auf Stufe 58. Einer für Booster, einer für alle.',
    'Booster Checkpoint': 'Booster-Checkpoint',
    'If you reached level 58 on a class before dying, you can purchase a': 'Wenn du mit einer Klasse Stufe 58 vor dem Tod erreicht hast, kannst du einen',
    'same-class boost': 'Boost derselben Klasse',
    'and register the new boosted character as a checkpoint continuation.': 'kaufen und den neuen geboosteten Charakter als Checkpoint-Fortsetzung registrieren.',
    'Reach Lvl 58': 'Stufe 58 erreichen',
    'Buy Same-Class Boost': 'Gleiche-Klasse-Boost kaufen',
    'Register & Continue': 'Registrieren & Weiterspielen',
    'Only available for the': 'Nur verfügbar für die',
    'same class': 'gleiche Klasse',
    'you previously reached 58 on. Character is marked as a checkpoint continuation on profile.': 'mit der du zuvor 58 erreicht hast. Charakter wird als Checkpoint-Fortsetzung auf dem Profil markiert.',
    'Alternative for Non-Boosters': 'Alternative für Nicht-Booster',
    "For players who don\u2019t boost. If you reached the checkpoint (lvl 58) before dying, you can continue": 'Für Spieler, die nicht boosten. Wenn du den Checkpoint (Stufe 58) vor dem Tod erreicht hast, kannst du weiterspielen',
    'but at a heavy cost.': 'aber zu einem hohen Preis.',
    'on profile and guild roster. Visible to all players.': 'auf Profil und Gildenaufstellung. Für alle Spieler sichtbar.',
    'Must have reached 58 before death. Guild can enable/disable. All gear, gold, professions removed. Score reset to 0. Flag is permanent.': 'Muss vor dem Tod Stufe 58 erreicht haben. Gilde kann aktivieren/deaktivieren. Ausrüstung, Gold, Berufe werden entfernt. Punktzahl auf 0. Markierung ist permanent.',

    // Decision tree sub-descriptions
    'Point values per action, category weights, visibility (public/GM-only), custom achievements': 'Punktwerte pro Aktion, Kategorie-Gewichtung, Sichtbarkeit (öffentlich/nur GM), eigene Erfolge',
    'Houses, fractions, draft rules, season length, Super Guild linking': 'Häuser, Fraktionen, Draft-Regeln, Saisonlänge, Super-Gilden-Verknüpfung',

    // Open Design Questions — Instance Lifes
    'Open Design Questions': 'Offene Design-Fragen',
    'Do normal dungeons have lifes, or are deaths just tracked?': 'Haben normale Dungeons Leben, oder werden Tode nur erfasst?',
    'Is there a reset timer per dungeon (e.g., lifes refresh weekly)?': 'Gibt es einen Reset-Timer pro Dungeon (z.\u00A0B. Leben werden wöchentlich aufgefrischt)?',
    'Does the life count reset when you leave the instance, or persist?': 'Wird die Lebensanzahl beim Verlassen der Instanz zurückgesetzt oder bleibt sie bestehen?',
    'These will be shaped by': 'Diese werden durch',
    'passive polling': 'passives Polling',
    'popular settings define the base mode.': 'beliebte Einstellungen definieren den Basismodus.',

    // Open Design — Super Guild
    'Super Guild features are addon-only': 'Super-Gilden-Features sind nur im Addon',
    'gchat and in-game guild features remain separate': 'Gchat und Ingame-Gildenfunktionen bleiben getrennt',
    'This is': 'Dies ist',
    'open for research': 'offen für Recherche',
    'many details still being designed': 'viele Details werden noch gestaltet',

    // Nav
    'Features': 'Features',
    'Guild Tools': 'Gilden-Tools',
    'Roadmap': 'Roadmap'
  };

  // Sort keys by length (longest first) to prevent partial matches
  var translationKeys = Object.keys(translations).sort(function(a, b) { return b.length - a.length; });

  var currentLang = 'en';
  var originalTexts = new Map();

  function collectTextNodes(root) {
    var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null, false);
    var nodes = [];
    var node;
    while (node = walker.nextNode()) {
      if (node.textContent.trim().length > 0) {
        nodes.push(node);
      }
    }
    return nodes;
  }

  function switchLang(lang) {
    if (lang === currentLang) return;
    currentLang = lang;

    // Update button states
    toggle.querySelectorAll('.lang-btn').forEach(function(btn) {
      btn.classList.toggle('active', btn.getAttribute('data-lang') === lang);
    });

    if (lang === 'de') {
      // Store originals and translate
      var textNodes = collectTextNodes(document.body);
      textNodes.forEach(function(node) {
        var text = node.textContent.trim();
        translationKeys.forEach(function(en) {
          if (text.indexOf(en) !== -1) {
            if (!originalTexts.has(node)) {
              originalTexts.set(node, node.textContent);
            }
            node.textContent = node.textContent.replace(en, translations[en]);
            text = node.textContent.trim();
          }
        });
      });
      document.documentElement.lang = 'de';
    } else {
      // Restore originals
      originalTexts.forEach(function(original, node) {
        node.textContent = original;
      });
      originalTexts.clear();
      document.documentElement.lang = 'en';
    }
  }

  toggle.addEventListener('click', function(e) {
    var btn = e.target.closest('.lang-btn');
    if (btn) {
      switchLang(btn.getAttribute('data-lang'));
    }
  });
})();
