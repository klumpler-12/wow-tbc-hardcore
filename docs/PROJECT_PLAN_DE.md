# TBC Hardcore Plus - Projektplan

**Version:** 1.0 (Draft)
**Erstellt:** 10. Maerz 2026
**Status:** Finales Konzeptdokument
**Zielplattform:** World of Warcraft: The Burning Crusade (Client 2.4.3)

---

## Inhaltsverzeichnis

1. [Projektvision und Zielgruppen](#1-projektvision-und-zielgruppen)
2. [Kernfeatures](#2-kernfeatures)
3. [Monetarisierung](#3-monetarisierung)
4. [Entwicklungsplan (Phasen)](#4-entwicklungsplan-phasen)
5. [Technische Architektur](#5-technische-architektur)
6. [Konkurrenz-Analyse](#6-konkurrenz-analyse)
7. [OnlyFangs 3 Anforderungen](#7-onlyfangs-3-anforderungen)
8. [Risiken und Gegenmaßnahmen](#8-risiken-und-gegenmaßnahmen)
9. [Offene Fragen und Entscheidungen](#9-offene-fragen-und-entscheidungen)
10. [Glossar](#10-glossar)

---

## 1. Projektvision und Zielgruppen

### 1.1 Vision

TBC Hardcore Plus (im Folgenden "Hardcore Plus" oder "HC+") ist ein Hybrid-Hardcore-System fuer World of Warcraft: The Burning Crusade. Im Gegensatz zu bestehenden Hardcore-Addons verfolgt HC+ einen modularen Ansatz: Anstatt ein starres Regelwerk vorzugeben, bietet das Addon eine konfigurierbare Engine, die es Gildenmeistern, Event-Organisatoren und Einzelspielern ermoeglicht, eigene Regelsaetze zu definieren, zu teilen und miteinander zu vergleichen.

Das Kernprinzip lautet: **Hardcore soll Spass machen, nicht frustrieren.** Regulaeres Hardcore bis Level 60 (oder 70) bleibt bestehen, aber danach greifen anpassbare Regeln, Checkpoints und ein kreatives Bestrafungs-/Belohnungssystem, das den Spielspass auch im Endgame aufrechthaelt.

### 1.2 Zielgruppen

#### a) Gilden (Primaere Zielgruppe)

- Grosse Gilden wie OnlyFangs, die strukturierte Hardcore-Events mit Hunderten von Spielern veranstalten
- Mittelgrosse Gilden, die Hardcore als Gildenprojekt spielen moechten
- Gilden, die interne Wettbewerbe zwischen Sub-Gruppen ("Haeuser") austragen wollen
- Gildenmeister und Offiziere, die Kontrolle ueber Regeln, Strafen und Belohnungen benoetigen

#### b) Streamer und Content-Creator

- Grosse Streamer (Sodapoppin, NMP, etc.), die Hardcore-Events fuer ihre Community organisieren
- Mittelgrosse Streamer, die einzigartige Hardcore-Erlebnisse fuer ihre Zuschauer schaffen wollen
- Content-Creator, die Statistiken und Leaderboards fuer Videos und Streams nutzen moechten
- Event-Organisatoren, die uebergreifende Wettbewerbe planen

#### c) Solo-Spieler

- Spieler, die Hardcore alleine erleben und ihre Fortschritte tracken moechten
- Spieler, die sich mit anderen Solo-Spielern ueber globale Leaderboards vergleichen wollen
- Spieler, die ein personalisiertes Hardcore-Erlebnis mit eigenen Regeln suchen

### 1.3 Kernkonzept: Hybrid Hardcore

Das Hybrid-Hardcore-Konzept unterscheidet sich grundlegend von klassischem Hardcore:

| Aspekt | Klassisches HC | Hybrid HC (HC+) |
|--------|---------------|-----------------|
| Tod | Permanent, Charakter wird geloescht | Konfigurierbar: Permanent, Lives-System, Checkpoints |
| Regeln | Fest vorgegeben | Konfigurierbar durch GM |
| Endgame | Kaum existent | Vollstaendiges Endgame mit angepassten Regeln |
| Instanzen | Oft verboten oder stark eingeschraenkt | Checkpoints und Leben in Instanzen |
| Vergleichbarkeit | Alle spielen nach gleichen Regeln | Scoring-System gleicht unterschiedliche Regelsaetze aus |
| Bestrafung | Tod = Ende | Kreative Strafen als Alternative |

#### Stufenmodell

1. **Level 1-60:** Regulaeres Hardcore. Ein Tod bedeutet das Ende des Charakters (nicht verhandelbar).
2. **Level 60-70:** Uebergangsphase. GM kann konfigurieren, ob weiterhin Permadeath gilt oder ob Checkpoints aktiviert werden.
3. **Level 70 Endgame:** Volle Konfigurierbarkeit. Heroische Dungeons und Raids mit Leben-System, Checkpoints vor Bossen, kreative Strafen statt Permadeath.

Dieses Stufenmodell stellt sicher, dass das Leveln weiterhin die typische Hardcore-Spannung bietet, waehrend das Endgame durch flexible Regeln langfristig spielbar bleibt. Ohne diese Anpassung wuerden die meisten Spieler vor Heroics und Raids zurueckschrecken, was den Langzeitspass und die Event-Tauglichkeit stark einschraenkt.

---

## 2. Kernfeatures

### 2.1 Regelwerk-Engine

Die Regelwerk-Engine ist das Herzsueck von HC+ und unterscheidet das Addon fundamental von allen Konkurrenten.

#### Harte Vorgaben (nicht aenderbar)

Diese Regeln gelten immer und koennen nicht vom GM deaktiviert werden:

- **Permadeath bis Level 60:** Jeder Charakter, der vor Level 60 stirbt, wird als tot markiert. Der Spieler muss einen neuen Charakter erstellen.
- **Tod-Tracking:** Jeder Tod wird mit vollstaendigem Kontext aufgezeichnet (Zeitpunkt, Ort, Todesursache, letzte Kampfaktionen, anwesende Spieler).
- **Anti-Cheat Grundschutz:** Manipulierte Addon-Daten werden erkannt und gemeldet. SavedVariables-Integritaetspruefung.
- **Addon-Verifizierung:** Spieler ohne aktives HC+ Addon koennen nicht an HC+ Events teilnehmen. Versionskontrolle stellt Kompatibilitaet sicher.

#### Weiche Vorgaben (GM-konfigurierbar)

Der Gildenmeister (oder ein von ihm autorisierter Offizier) kann folgende Regeln anpassen:

**Todes-Regeln (Level 60-70 und Endgame):**
- Permadeath an/aus ab Level 60
- Anzahl der Leben pro Checkpoint (1-5)
- Checkpoint-Positionen (vor jedem Boss, vor Endboessen, keine)
- Raid-spezifische Todes-Regeln (z.B. 3 Raidweite Tode pro Abend erlaubt)
- Wiederbelebungs-Cooldowns
- Soul-Stone / Ankh Nutzung erlauben/verbieten

**Handels- und Wirtschaftsregeln:**
- Self-Found (SSF): Kein Handel, keine Mailbox, kein Auktionshaus
- Semi-SSF: Handel nur innerhalb des eigenen Hauses
- Freier Handel: Keine Einschraenkungen
- Gildenbank-Nutzung: Erlauben/Verbieten/Einschraenken
- AH-Regeln: Komplett verboten, nur Kaufen, nur Verkaufen, beides erlaubt
- Mailbox-Regeln: Keine Items per Mail, nur Gold, beides erlaubt

**Dungeon- und Raid-Regeln:**
- Dungeon-Lockouts pro Tag/Woche
- Mindestspieleranzahl fuer Dungeons (z.B. volle 5er-Gruppe Pflicht)
- Heroic-Freischaltung: Sofort oder erst nach Normal-Clear
- Raid-Zusammensetzung: Flexibel oder nach festen Rollen
- Weltbosse: Erlaubt/Verboten
- Arena: Erlaubt/Verboten (wenn implementiert)

**Klassen- und Talentregeln:**
- Erlaubte Klassen einschraenken
- Talentbaum-Einschraenkungen (z.B. nur ein Baum erlaubt)
- Berufs-Einschraenkungen
- Reittier-Regeln (ab welchem Level, welche Geschwindigkeit)

#### Regelexport und -import

- Regelsaetze werden als kompakte Strings serialisiert (Base64-kodiert)
- GMs koennen Regelsaetze exportieren und mit anderen Gilden teilen
- Import-Funktion mit Vorschau: Spieler sieht alle Regeln bevor er akzeptiert
- Versionierung: Regelaenderungen werden mit Zeitstempel protokolliert
- Broadcast: GM sendet Regelaenderungen automatisch an alle Online-Mitglieder
- Offline-Mitglieder erhalten Regeln beim naechsten Login

#### Vergleichbarkeit

Unterschiedliche Regelsaetze fuehren zu unterschiedlichen Schwierigkeitsgraden. Das Scoring-System (siehe 2.3) gleicht dies aus, indem es die Regelkonfiguration in einen Schwierigkeits-Multiplikator umrechnet. So koennen Spieler und Gilden mit verschiedenen Regelsaetzen trotzdem sinnvoll miteinander verglichen werden.

**Schwierigkeits-Multiplikator-Berechnung:**
- Basiswert: 1.0 (Standard-HC-Regeln)
- SSF: +0.3
- Permadeath bis 70: +0.5
- Keine Checkpoints: +0.2
- Klassen-/Talenteinschraenkungen: +0.1 bis +0.3
- Mehrere Leben: -0.2 bis -0.5
- Die genauen Werte werden durch Community-Voting feinjustiert

---

### 2.2 Tracking-System

Das Tracking-System bildet die Datengrundlage fuer Scoring, Achievements, Leaderboards und das Web-Dashboard. Es erfasst so viele Spieleraktionen wie moeglich.

#### Kern-Tracking-Module

**Tod-Tracking:**
- Todesursache (Mob, Spieler, Umgebung, Fall, Ertrinken)
- Ort (Zone, Subzone, exakte Koordinaten)
- Zeitpunkt (Server-Zeit und lokale Zeit)
- Letzte 30 Sekunden des Kampflogs (Combat-Log-Snapshot)
- Anwesende Spieler im Umkreis
- Gesundheits- und Mana-Verlauf der letzten 10 Sekunden
- Aktive Buffs und Debuffs zum Todeszeitpunkt
- Getragene Ausruestung zum Todeszeitpunkt
- Todesart-Klassifizierung (PvE, PvP, Umgebung, Selbstverschulden)

**Level-Tracking:**
- Level-Up-Zeitpunkte
- Gespielte Zeit pro Level
- Zone bei Level-Up
- XP-Quellen-Verteilung (Quests, Mobs, Dungeons, Entdeckung)
- Schnellster Level-Up im Vergleich zur Gilde

**Mob-Kill-Tracking:**
- Getoetete Mobs nach Name, Level und Typ (Normal, Elite, Rare, Boss)
- Kill-Zeitpunkte und -orte
- Bestiarium: Einzigartige Mob-Typen getoetet
- Kill-Streaks (aufeinanderfolgende Kills ohne Tod)
- Named Mob Kills separat erfasst

**Inventar- und Ausruestungs-Tracking:**
- Komplettes Inventar-Protokoll (Item erhalten, Item entfernt)
- Ausruestungsaenderungen mit Zeitstempel
- Item-Quellen (Drop, Questbelohnung, Handwerk, Handel, AH)
- Gold-Verlauf (Einnahmen, Ausgaben, Kontostand)
- Berufsfortschritt (Skill-Ups mit Zeitstempel)

**Handels-Tracking:**
- Handels-Partner und getauschte Items
- Mailbox-Aktivitaet (gesendet, empfangen)
- AH-Transaktionen (Kauf, Verkauf, Preise)
- Gildenbank-Aktivitaet

**Bewegungs-Tracking:**
- Zurrueckgelegte Schritte (geschaetzt ueber Positionsaenderungen)
- Bereiste Zonen mit Aufenthaltsdauer
- Erkundungsfortschritt (Anteil der entdeckten Gebiete)
- Reittier-Nutzung (Zeit zu Fuss vs. beritten)

**Dungeon- und Raid-Tracking:**
- Betretene Instanzen mit Zeitstempel
- Boss-Kills mit Teilnehmerliste
- Wipe-Count pro Boss
- Durchschnittliche Clear-Zeit pro Instanz
- Loot-Verteilung
- Heroic vs. Normal Unterscheidung

**Angel-Tracking:**
- Gesamte Angelzeit
- Gefangene Fische nach Art und Ort
- Besondere Faenge (Schildkroeten-Reittier, etc.)
- Angel-Skill-Fortschritt

**Kampfausschnitte (Combat-Log-Replay):**
- Die letzten 60 Sekunden vor jedem Tod werden als kompakter Kampflog gespeichert
- Enthaelt: Schadenswerte, Heilung, Buffs, Debuffs, Positionsaenderungen
- Kann in-game und auf der Webseite abgespielt werden
- Ermoeglicht der Community, verdaechtige Tode zu ueberpruefen

#### Daten-Serialisierung

- Alle Tracking-Daten werden in SavedVariables gespeichert
- Komprimierung durch effiziente Datenstrukturen (Indizes statt voller Strings)
- Rotation aelterer Daten: Detaillierte Daten fuer die letzten 7 Tage, aggregierte Daten darueber hinaus
- Maximale SavedVariables-Groesse: 5 MB (mit Warnung ab 3 MB)
- Companion App liest SavedVariables und sendet sie ans Backend, danach werden die lokalen Detaildaten bereinigt

#### Community-Flagging

- Spieler koennen verdaechtige Tode oder Aktivitaeten flaggen
- Geflaggte Events werden mit dem gespeicherten Kampfausschnitt zur Ueberpruefung bereitgestellt
- GM erhaelt Uebersicht aller geflaggten Events
- GM kann Events als "bestaetigt" oder "unbedenklich" markieren
- Bei bestaetigtem Betrug: Automatische Strafe oder manueller GM-Eingriff

---

### 2.3 Scoring und Rating-System

Das Scoring-System wandelt Spieleraktionen in Punkte um, die fuer Leaderboards, Belohnungen und den Vergleich zwischen Spielern verwendet werden.

#### Zwei moegliche Systeme (Community-Abstimmung)

Die Community stimmt vor dem Launch darueber ab, welches System verwendet wird. Beide Systeme koennen parallel getestet und spaeter per Update gewechselt werden.

**System 1: Komplexes System mit Multiplikatoren**

Punkte werden dynamisch berechnet basierend auf mehreren Faktoren:

```
Punkte = Basiswert * Spieler-Level-Faktor * Mob-Level-Faktor * Schwierigkeits-Faktor * Regelwerk-Multiplikator
```

- **Basiswert:** Festgelegter Wert pro Aktionstyp (z.B. Mob-Kill = 10, Boss-Kill = 500, Quest-Abschluss = 50)
- **Spieler-Level-Faktor:** Niedrigerer Faktor bei hohem Level fuer niedrigstufige Mobs (verhindert Farming)
- **Mob-Level-Faktor:** Hoeher fuer Mobs, die naeher am oder ueber dem Spielerlevel liegen
- **Schwierigkeits-Faktor:** Community-gevoteter Wert pro Mob/Boss (z.B. Prince Malchezaar = 8.5/10)
- **Regelwerk-Multiplikator:** Basierend auf den aktiven Regeln (SSF, Permadeath etc.)

Vorteile: Granularer, belohnt schwierigere Aktionen staerker
Nachteile: Komplexer zu verstehen, schwieriger zu balancen

**System 2: Einfaches System mit fixen Werten**

Die Community stimmt ueber feste Punktwerte pro Aktion ab:

- Mob-Kill (Normal): 5 Punkte
- Mob-Kill (Elite): 25 Punkte
- Mob-Kill (Rare): 50 Punkte
- Dungeon-Clear (Normal): 200 Punkte
- Dungeon-Clear (Heroic): 500 Punkte
- Boss-Kill (Raid): Community-gevoteter Wert (z.B. Prince = 1000 Punkte pro ueberlebendem Spieler)
- Quest-Abschluss: 15-50 Punkte je nach Schwierigkeit
- Level-Up: 100 Punkte pro Level
- Tod: -500 Punkte (konfigurierbar)

Vorteile: Einfach zu verstehen, transparent
Nachteile: Weniger differenziert, kann zu Grinding-Optimierung fuehren

#### Punkte-Quellen

Unabhaengig vom gewaehlten System gibt es Punkte fuer:

- **First Kills:** Erste Gilde/Haus/Spieler, die einen Boss legen, erhaelt Bonuspunkte
- **Boss-Clears:** Punkte pro getoetem Boss, skaliert nach Schwierigkeit
- **Achievements:** Tausende kleine und grosse Achievements (siehe unten)
- **Exploration:** Entdeckung neuer Gebiete, vollstaendige Zonenentdeckung
- **Berufe:** Berufs-Meilensteine (z.B. 375 Angeln, 375 Kochen)
- **Ueberlebenszeit:** Bonuspunkte fuer lange Ueberlebensstraeher
- **Mini-Games:** Punkte aus spontanen Events und Wettbewerben

#### Achievement-System

Das Achievement-System umfasst Tausende von kleinen und grossen Errungenschaften, die das Erkunden und vielfaeltiges Spielen belohnen:

**Kategorie: Kampf**
- Erster Spieler, der 100/500/1000/5000 Mobs toetet
- Erster Spieler, der 5 Named Mobs in einer Zone toetet (250 Punkte)
- Kill-Streak: 50/100/200 Mobs ohne Tod
- Toete einen Mob, der 3+ Level ueber dir ist
- Besiege jeden Boss einer Instanz in einer Woche

**Kategorie: Berufe**
- Erster Spieler mit 375 Angeln (500 Punkte)
- Erster Spieler mit 375 in einem Hauptberuf
- Lerne 50/100/200 Rezepte
- Stelle 100 Traenke/Elixiere her
- Fange jeden Fischtyp in Outland

**Kategorie: Erkundung**
- Entdecke alle Gebiete einer Zone
- Entdecke alle Gebiete in Outland
- Besuche jeden Dungeon in Outland
- Reise von Shattrath nach Stormwind/Orgrimmar zu Fuss
- Finde alle versteckten Orte (kuratierte Liste)

**Kategorie: Soziales**
- Handele mit 10/25/50 verschiedenen Spielern
- Schliesse einen Dungeon mit 5 verschiedenen Klassen ab
- Werde von 10 Spielern zum Gruppenleiter gewaehlt
- Hilf einem Spieler bei einer Elite-Quest

**Kategorie: Ueberleben**
- Ueberlebe 10/24/48/100 Stunden Spielzeit
- Ueberlebe eine Begegnung mit weniger als 5% HP
- Ueberlebe einen Elite-Mob solo
- Erreiche Level 70 ohne einen einzigen Tod

**Kategorie: Sammeln**
- Sammle jedes Set-Teil eines Dungeon-Sets
- Erreiche einen bestimmten Goldwert
- Sammle 100/500/1000 einzigartige Items
- Fuelle dein Inventar komplett mit gruenen/blauen Items

#### Anzeige

- **In-Game Panel:** Aehnlich wie Details oder Deathlog; minimalistisches, verschiebbares Fenster mit aktuellem Score, Rang in der Gilde, letzte Achievements
- **Erweitertes In-Game Interface:** Detaillierte Statistiken, Leaderboard, Achievement-Browser
- **Web-Dashboard:** Aktualisierung alle 2-5 Minuten (via Companion App), vollstaendige Statistiken, historische Daten, Vergleichsfunktionen

---

### 2.4 Bestrafungssystem

Das Bestrafungssystem ist eines der kreativsten Features von HC+ und ein wichtiger Differenzierungspunkt gegenueber der Konkurrenz.

#### Automatische Regelverstoss-Erkennung

Das Addon ueberwacht kontinuierlich die Einhaltung der aktiven Regeln:

- **SSF-Verstoss:** Spieler handelt Items oder nutzt AH/Mailbox trotz SSF-Regel
- **Dungeon-Lockout:** Spieler betritt Dungeon trotz ausgeschoepftem Lockout
- **Gruppen-Regeln:** Spieler spielt in einer zu kleinen Gruppe
- **Klassen-Regeln:** Spieler nutzt verbotene Talente oder Faehigkeiten
- **Bewegungs-Regeln:** Spieler nutzt verbotene Transportmittel

Bei jedem erkannten Verstoss wird folgendes protokolliert:
- Zeitpunkt des Verstosses
- Art des Verstosses
- Betroffener Spieler
- Kontext (Zone, Aktivitaet, beteiligte Spieler)

#### GM-Benachrichtigungen

Der GM (und autorisierte Offiziere) erhaelt sofortige Benachrichtigungen ueber Regelverstoesse:

```
[HC+] REGELVERSTOSS: Spieler "Thrallinho" hat gegen SSF-Regel verstossen.
  Aktion: Handel mit "Garroshina" - 3x Heiltrank
  Zeitpunkt: 14:32:15 Serverzeit
  Ort: Shattrath City
  [Strafe verhaengen] [Ignorieren] [Details]
```

#### Kreative Strafen (Premium-Feature)

Folgende Strafen koennen vom GM remote ausgeloest werden und werden auf dem Spieler-Client durchgesetzt:

**Slow-Force (RP-Walk-Zwang):**
- Der betroffene Spieler kann sich fuer eine konfigurierbare Dauer (Standard: 1 Stunde) nur im RP-Walk bewegen
- Technische Umsetzung: Addon setzt `/run MoveForwardStart()` Speed-Override via UIErrorsFrame-Tracking oder warnt bei normaler Geschwindigkeit und protokolliert Verstoesse
- Visuelle Anzeige: Timer-Overlay auf dem Bildschirm des Spielers
- Gildennachricht: "[HC+] Spieler X wurde zum RP-Walk verdonnert! (noch 45 Min.)"

**Gear-Lock (Ausruestungs-Sperre):**
- Der Spieler kann seine Ausruestung fuer X Minuten nicht wechseln
- Technische Umsetzung: Addon blockt EquipItemByName/UseContainerItem Events und zeigt Fehlermeldung
- Konfigurierbare Dauer: 15 Min. bis 4 Stunden
- Optionale Erweiterung: Nur bestimmte Slots gesperrt

**Trade-Ban (Temporaeres Handelsverbot):**
- Der Spieler kann fuer X Minuten nicht handeln
- Alle Handelsversuche werden geblockt und protokolliert
- AH- und Mailbox-Nutzung wird ebenfalls gesperrt
- Konfigurierbare Dauer: 30 Min. bis 24 Stunden

**Dungeon-Ban (Instanz-Sperre):**
- Der Spieler darf fuer X Stunden keine Instanzen betreten
- Betritt er dennoch eine Instanz, wird dies als weiterer Verstoss gewertet
- Konfigurierbare Dauer: 1 Stunde bis 1 Woche

**XP-Freeze (Erfahrungspunkte-Stopp):**
- Der Spieler erhaelt eine Warnung, dass seine naechsten X XP nicht gezaehlt werden
- Da WoW TBC keinen nativen XP-Stop hat, wird der Punkteabzug im Scoring verrechnet
- Alternative: Spieler muss X Quests unbezahlt (ohne Belohnung) abschliessen

**Bounty (Kopfgeld):**
- Auf PvP-Servern: GM setzt Kopfgeld auf den Spieler aus
- Andere Spieler erhalten Bonuspunkte fuer den Kill
- Konfigurierbare Belohnung und Dauer

**Public Shame (Oeffentliche Schande):**
- Automatische Gildennachricht bei Regelverstoss
- Optionaler "Shame-Counter" neben dem Spielernamen im Addon-UI
- Kumulativ: Mehrere Verstoesse erhoehen den Shame-Counter

**Quest-Pflicht (Pflicht-Quest):**
- GM weist dem Spieler eine Busse-Quest zu (z.B. "Fische 100 Fische in Nagrand")
- Quest wird im Addon getrackt
- Bis zur Erfuellung gelten reduzierte Punktegewinne

#### Standard-Strafen (Free-Version)

- **Punkteabzug:** Konfigurierbare Punkteabzuege pro Verstoss-Typ
- **Warnungen:** In-Game Benachrichtigung an den Spieler
- **Verstoss-Zaehler:** Oeffentlich sichtbarer Zaehler
- **Auto-Kick:** Nach X Verstoessen automatischer Ausschluss aus dem HC+ Event (konfigurierbar)

---

### 2.5 Belohnungssystem

#### Oeffentliche Belohnungen

Der GM kann Belohnungen erstellen, die fuer alle Spieler sichtbar sind:

- **First-Kill-Belohnungen:** Bonuspunkte fuer die erste Gilde/Haus, die einen Boss besiegt
- **Meilenstein-Belohnungen:** Punkte fuer das Erreichen bestimmter Meilensteine (z.B. Level 70, 375 in einem Beruf)
- **Wettbewerbs-Belohnungen:** Preise fuer Mini-Game-Gewinner

#### Versteckte Belohnungen

Der GM kann Belohnungen erstellen, die erst bei Erfuellung sichtbar werden:

- **Geheime Achievements:** "Finde den versteckten NPC in Zangarmarsh" (erst sichtbar wenn entdeckt)
- **Ueberraschungs-Events:** Spontane Bonuspunkte fuer bestimmte Aktionen
- **Easter-Eggs:** Versteckte Belohnungen fuer ungewoehnliche Aktionen

#### In-Game Belohnungen bei Boss-Kills/Dungeon-Clears

- Automatische Punktevergabe bei Boss-Kills und Dungeon-Clears
- Skalierung nach Schwierigkeit (Normal vs. Heroic)
- Bonuspunkte fuer Deathless-Runs (kein Tod waehrend der gesamten Instanz)
- Bonuspunkte fuer Speed-Runs (unter einer bestimmten Zeit)

#### Gildenbelohnungen durch Punkte

Punkte koennen fuer Gildenbelohnungen eingesetzt werden:

- **BiS-Gear-Zuweisung:** Spieler mit den meisten Punkten erhalten Prioritaet bei der Loot-Verteilung
- **Raid-Slot-Prioritaet:** Hoehere Punktzahl = hoehere Prioritaet fuer begrenzte Raid-Slots
- **Titel:** In-Game-Titel im Addon-UI (z.B. "Champion des Hauses Aldor")
- **Kosmetische Belohnungen:** Spezielle Chat-Prefixes, Rahmen im Addon-UI

#### Achievement-Benachrichtigungen

Achievements werden gildenweit angezeigt:

```
[HC+] ACHIEVEMENT: Spieler "Thrallinho" hat "Meisterangler von Outland" erreicht! (+500 Punkte)
[HC+] FIRST KILL: Haus Aldor hat Prince Malchezaar als Erstes besiegt! (+2000 Bonuspunkte)
[HC+] MILESTONE: Spieler "Garroshina" hat Level 70 erreicht! Ueberlebenszeit: 127 Stunden
```

---

### 2.6 Haeuser (Sub-Gilden)

Das Haeuser-System ist speziell fuer grosse Gilden und Events wie OnlyFangs konzipiert.

#### Konzept

- Eine Gilde wird in mehrere "Haeuser" unterteilt
- Jedes Haus hat einen Anführer (vom GM ernannt) und optionale Offiziere
- Haeuser konkurrieren untereinander um Punkte, Achievements und Leaderboard-Positionen
- Haeuser koennen nach Fraktionszugehoerigkeit (Aldor/Scryer) weiter gruppiert werden

#### Haus-Verwaltung

- **Erstellung:** GM erstellt Haeuser mit Name, Farbe und optionalem Wappen
- **Mitglieder-Zuweisung:** Spieler werden einem Haus zugewiesen (manuell oder per Draft)
- **Offiziers-Ernennung:** Hausanfuehrer kann Offiziere ernennen
- **Haus-Chat:** Separater Chat-Kanal pro Haus (ueber Addon-Messaging)
- **Haus-Regeln:** Optionale Haus-spezifische Regeln zusaetzlich zu den Gildenregeln

#### Haeuser-Leaderboard

- Punkte werden pro Haus aggregiert
- Zusaetzliche Aggregation nach Team (z.B. Aldor vs. Scryer)
- Verschiedene Leaderboard-Kategorien: Gesamtpunkte, Durchschnittspunkte pro Spieler, meiste Achievements, laengste Ueberlebenszeit, meiste Boss-Kills
- Leaderboard wird in-game und auf der Webseite angezeigt

#### Haus-Wettbewerbe

- **Dungeon-Races:** Welches Haus cleared eine Instanz zuerst?
- **Kill-Wettbewerbe:** Welches Haus toetet zuerst 1000 Mobs in Nagrand?
- **Sammel-Wettbewerbe:** Welches Haus farmt zuerst 500 Primals?
- **Ueberlebens-Wettbewerbe:** Welches Haus hat die laengste durchschnittliche Ueberlebenszeit?

#### Draft-System

Fuer Events wie OnlyFangs, bei denen die Haus-Zusammensetzung entscheidend ist:

1. **Spieler-Rating:** Jeder Spieler erhaelt ein Rating von 1-10 basierend auf:
   - Vorherige HC-Erfahrung
   - Klasse und Rolle
   - Spielzeit-Verfuegbarkeit
   - Community-Bewertung
   - Vorheriges Performance-Rating (wenn verfuegbar)

2. **Punkte-Budget:** Jeder Hausanfuehrer erhaelt ein identisches Punktebudget (z.B. 100 Punkte)

3. **Draft-Ablauf:**
   - Runde 1: Jeder Anfuehrer waehlt einen Spieler (Kosten = Rating-Wert)
   - Runde 2: Umgekehrte Reihenfolge (Snake-Draft)
   - Weiter bis Budget aufgebraucht oder alle Spieler verteilt
   - Niedrig geratete Spieler kosten weniger, erlauben mehr Picks

4. **Balance-Pruefung:** System prueft, ob alle Haeuser ausreichend Tanks, Heiler und DDs haben

---

### 2.7 Mini-Spiele

Mini-Spiele bringen Spontaneitaet und zusaetzlichen Spass in das Hardcore-Erlebnis.

#### Spontane Rennen

- GM startet ein Rennen: "Wer ist als Erstes in Gadgetzan?"
- Automatisches Tracking der Teilnehmer und Reihenfolge
- Fiktive Lootdrops als Preise (Punkte, Achievements)
- Anti-Cheat: Positionsueberpruefung und Plausibilitaetskontrolle (Teleport-Erkennung)

#### Schnitzeljagden

- GM platziert virtuelle "Items" an bestimmten Koordinaten
- Spieler muessen die Koordinaten finden (Hinweise ueber Gildenchat)
- Erster Spieler, der die Position erreicht, erhaelt den Preis
- Multi-Schritt-Schnitzeljagden mit aufeinanderfolgenden Hinweisen

#### Erste-Erreicht-X-Wettbewerbe

- "Erster Spieler, der 100 Oger in Nagrand toetet, erhaelt 500 Bonuspunkte"
- "Erste Gruppe, die Botanica cleared, erhaelt 1000 Punkte pro Spieler"
- Automatisches Tracking und Benachrichtigung

#### Ueberlebens-Challenge

- GM startet eine Challenge: "Die naechsten 2 Stunden gibt es doppelte Punkte, aber auch doppelten Punkteabzug bei Tod"
- Optionale "Hardcore-Stunde": Fuer eine Stunde gilt Permadeath auch im Endgame
- Risk/Reward-Events mit erhoehten Einsaetzen

#### Gilden-Trivia

- Automatisierte Quiz-Fragen im Gildenchat (WoW-Trivia, Gilden-intern, Custom)
- Punkte fuer richtige Antworten
- Trivia-Leaderboard

#### Event-Designer (Premium)

- GMs koennen eigene Mini-Spiele designen
- Konfigurierbare Parameter: Dauer, Belohnung, Teilnahmebedingungen
- Vorlagen fuer gaengige Event-Typen
- Zeitgesteuerte Events (z.B. jeden Samstag um 20:00 Uhr)

---

### 2.8 Web-Interface (Premium)

Das Web-Dashboard bietet erweiterte Verwaltungs- und Analysefunktionen.

#### Sub-Gilden-Management

- Haeuser erstellen, bearbeiten, loeschen
- Spieler Haeusern zuweisen
- Haus-Einstellungen konfigurieren
- Draft-System bedienen
- Haus-Statistiken einsehen

#### Strafen- und Belohnungs-Designer

- Neue Straftypen definieren (aus vordefinierten Bausteinen)
- Belohnungen mit Bedingungen verknuepfen
- Automatische Strafregeln konfigurieren (z.B. "Bei 3. SSF-Verstoss automatisch 2h Trade-Ban")
- Vorlagen fuer gaengige Strafen und Belohnungen

#### Gildenregeln-Konfigurator

- Visueller Editor fuer alle weichen Regeln
- Vorschau der Auswirkungen auf den Schwierigkeits-Multiplikator
- Regel-Templates (z.B. "OnlyFangs Standard", "Casual HC", "Ironman")
- Export/Import von Regelsaetzen

#### Leaderboards und Statistiken

- Globale Leaderboards (alle Gilden)
- Gilden-interne Leaderboards
- Haeuser-Leaderboards
- Historische Daten und Trends
- Filterbar nach Zeitraum, Klasse, Haus, Regelwerk

#### Spielerprofile

- Detaillierte Statistiken pro Spieler
- Achievement-Showcase
- Todes-Historie mit Replay
- Ausruestungs-Historie
- Aktivitaets-Diagramme
- Vergleichsfunktion mit anderen Spielern

#### Heroic-Difficulty-Ratings

- Community-Voting fuer die Schwierigkeit jedes Heroic-Dungeons und Raid-Bosses
- Live-Aktualisierung der Schwierigkeitswerte
- Historische Schwierigkeitsdaten
- Einsicht in die Abstimmungsergebnisse

---

## 3. Monetarisierung

### 3.1 Kostenloses Addon (CurseForge)

Das Basis-Addon ist und bleibt kostenlos. Es wird auf CurseForge veroeffentlicht und enthaelt:

**Enthalten (Free):**
- Vollstaendiges Tod-Tracking
- Basis-Scoring (einfaches System)
- Gilden-Leaderboard in-game
- Basis-Achievement-System (100+ Achievements)
- Regelwerk-Engine (Basis-Regeln)
- Gilden-Kommunikation (Tod-Benachrichtigungen, Regel-Sync)
- Standard-Strafen (Punkteabzug, Warnungen)
- SSF-Enforcement
- Basis-Statistiken in-game

**Spendenoption:**
- CurseForge-eigene Spendefunktion
- Link zu Patreon im Addon-Einstellungsmenue
- Dezenter Hinweis auf Premium-Features (nicht aufdringlich)

### 3.2 Premium (Patreon)

Premium-Features werden ueber einen Patreon-Zugang freigeschaltet. Der technische Ablauf:

1. Spieler abonniert den Patreon (Tier: TBD, voraussichtlich 5-10 EUR/Monat fuer Gilden-GMs)
2. Spieler erhaelt Zugang zu einer speziellen Patreon-Seite mit einer Download-Datei
3. Die Datei enthaelt einen signierten Lizenzschluessel (HMAC-signiert, zeitlich begrenzt)
4. Spieler laedt die Datei in den Addon-Ordner (oder Companion App importiert sie)
5. Addon erkennt die Lizenzdatei und schaltet Premium-Features frei
6. Lizenz wird monatlich erneuert (neue Datei erforderlich oder automatisch via Companion App)

**Premium-Features:**
- Kreative Bestrafungen (RP-Walk, Gear-Lock, Trade-Ban, etc.)
- Haeuser-System (Sub-Gilden, Draft, Haus-Wettbewerbe)
- Erweiterte Statistiken (detaillierte Tracking-Daten, historische Analyse)
- Mini-Game-Framework (eigene Events designen)
- Web-Dashboard Zugang (Gilden-Management, Statistiken, Spielerprofile)
- Companion App (automatische Daten-Synchronisation, Near-Realtime Updates)
- Erweitertes Achievement-System (1000+ zusaetzliche Achievements)
- Event-Designer (eigene Mini-Spiele erstellen)
- Prioritaets-Support

### 3.3 Abgrenzung Free vs. Premium

Entscheidende Regel: **Free MUSS vergleichbar bleiben.** Ein Free-Spieler muss in der Lage sein, an einem HC+ Event teilzunehmen und seine Tode und Scores getrackt zu bekommen. Premium darf nicht "Pay-to-Win" sein.

| Feature | Free | Premium |
|---------|------|---------|
| Tod-Tracking | Ja | Ja |
| Basis-Scoring | Ja | Ja |
| Erweiterte Scoring-Multiplikatoren | Nein | Ja |
| In-Game Leaderboard | Ja (Basis) | Ja (Erweitert) |
| Web-Leaderboard | Nein | Ja |
| Basis-Achievements (100+) | Ja | Ja |
| Erweiterte Achievements (1000+) | Nein | Ja |
| Basis-Regeln | Ja | Ja |
| Erweiterte Regeln | Nein | Ja |
| Standard-Strafen | Ja | Ja |
| Kreative Strafen | Nein | Ja |
| Haeuser-System | Nein | Ja |
| Mini-Games | Basis-Events | Voller Event-Designer |
| Web-Dashboard | Nein | Ja |
| Companion App | Nein | Ja |
| Gilden-Kommunikation | Ja | Ja |
| SSF-Enforcement | Ja | Ja |

### 3.4 Patreon-Tiers (Vorschlag)

| Tier | Preis/Monat | Features |
|------|-------------|----------|
| Supporter | 3 EUR | Basis Premium (Erweiterte Achievements, erweiterte Statistiken) |
| Gildenmeister | 7 EUR | Volles Premium (alle Features fuer eine Gilde) |
| Event-Organisator | 15 EUR | Volles Premium + Multi-Gilden-Support + Prioritaets-Support |

---

## 4. Entwicklungsplan (Phasen)

### Phase 0: Finales Draft-Konzept (1-2 Wochen)

**Ziel:** Alle konzeptionellen Entscheidungen treffen und dokumentieren.

**Aufgaben:**
1. Dieses Dokument finalisieren und im Team reviewen
2. Feature-Matrix erstellen: Detaillierte Aufschluesselung Free vs. Premium fuer jedes einzelne Feature
3. Technische Architektur-Entscheidungen treffen:
   - Ace3 vs. eigenes Framework?
   - Datenbank-Wahl fuer Backend (MongoDB vs. PostgreSQL)?
   - Hosting-Strategie fuer Web-Dashboard?
   - Companion App: Electron vs. native?
4. Konkurrenten analysieren:
   - Sauercrowd: Code-Analyse (Open Source?), Feature-Vergleich
   - HardcoreTBC (mocktailtv): Feature-Analyse, Nutzer-Feedback studieren
   - Deathlog Addon: Tracking-Mechanismen analysieren
   - Base HC Addon (Classic): Feature-Set dokumentieren
5. OnlyFangs 3 Anforderungen final abgleichen (siehe Abschnitt 7)
6. Community-Befragung vorbereiten (Scoring-System, Schwierigkeits-Ratings)

**Ergebnis:** Freigegebenes Konzeptdokument, technische Architektur-Entscheidungen, Feature-Matrix

**Abnahmekriterien:**
- Alle Team-Mitglieder haben das Dokument gelesen und Feedback gegeben
- Alle offenen Fragen sind beantwortet oder als bewusste Entscheidungen dokumentiert
- Feature-Matrix ist vollstaendig und von allen akzeptiert

---

### Phase 1: PoC - Grundlegendes WoW Menu (1-2 Wochen)

**Ziel:** Ein funktionierendes Addon-Geruest in WoW TBC (Client 2.4.3) aufsetzen.

**Aufgaben:**
1. Entwicklungsumgebung einrichten:
   - CMaNGOS TBC Docker-Container aufsetzen und konfigurieren
   - WoW TBC 2.4.3 Client installieren
   - Addon-Entwicklungs-Tools einrichten (IDE mit Lua-Support, Lua-Linter)
   - Git-Repository erstellen mit .gitignore fuer WoW-spezifische Dateien

2. Addon-Grundstruktur erstellen:
   - `.toc` Datei mit korrekter Interface-Version (20400)
   - `Main.lua` als Einstiegspunkt
   - Ordnerstruktur festlegen:
     ```
     HardcorePlus/
     ├── HardcorePlus.toc
     ├── Main.lua
     ├── Core/
     │   ├── Init.lua
     │   └── EventBus.lua
     ├── Modules/
     ├── UI/
     │   ├── MainFrame.lua
     │   └── Templates.xml
     ├── Libs/
     └── Locale/
         └── deDE.lua
     ```

3. Einfaches UI implementieren:
   - Hauptfenster (Frame) mit Titelleiste und Schliessen-Button
   - Minimap-Button zum Oeffnen/Schliessen
   - Slash-Command: `/hcplus` oder `/hc+` zum Oeffnen
   - Ein Button der beim Klicken eine Chat-Nachricht sendet ("HC+ funktioniert!")
   - Tab-Navigation fuer spaetere Module vorbereiten

4. Ace3 Libraries einbinden (falls entschieden):
   - AceAddon-3.0
   - AceEvent-3.0
   - AceComm-3.0 (fuer spaetere Kommunikation)
   - AceDB-3.0 (fuer SavedVariables)
   - AceGUI-3.0 (fuer UI-Elemente)

**Ergebnis:** Addon laed in WoW TBC, zeigt ein Menue, Button funktioniert.

**Abnahmekriterien:**
- Addon laed ohne Fehler in WoW TBC 2.4.3
- Minimap-Button ist sichtbar und funktional
- Hauptfenster oeffnet und schliesst sich korrekt
- Slash-Command funktioniert
- Button im Hauptfenster fuehrt eine Aktion aus
- Keine Lua-Fehler in der Konsole

---

### Phase 2: Library fuer Tracking (2-3 Wochen)

**Ziel:** Eine robuste Tracking-Bibliothek erstellen, die alle relevanten Spieleraktionen erfasst.

**Aufgaben:**
1. WoW API Events katalogisieren:
   - Alle relevanten Events fuer TBC 2.4.3 auflisten
   - Dokumentation der Event-Parameter
   - Kompatibilitaetspruefung mit TBC-spezifischen APIs
   - Events nach Modul gruppieren

2. Tracking-Module implementieren:

   **Tod-Tracking (Prioritaet 1):**
   - Events: `COMBAT_LOG_EVENT_UNFILTERED`, `PLAYER_DEAD`, `PLAYER_ALIVE`, `PLAYER_UNGHOST`
   - Todesursache extrahieren (letzter Schadens-Event)
   - Ort und Zeitpunkt erfassen
   - Kampflog-Snapshot der letzten 30-60 Sekunden
   - Ausruestung und Buffs zum Todeszeitpunkt speichern

   **Level-Tracking (Prioritaet 1):**
   - Events: `PLAYER_LEVEL_UP`, `PLAYER_XP_UPDATE`
   - Level, Zone und Spielzeit bei Level-Up protokollieren
   - XP-Rate berechnen

   **Mob-Kill-Tracking (Prioritaet 1):**
   - Events: `COMBAT_LOG_EVENT_UNFILTERED` (UNIT_DIED Subevent)
   - Mob-Name, Level, Typ (Normal/Elite/Rare/Boss) erfassen
   - Kill-Zaehler pro Mob-Typ
   - Kill-Streaks tracken

   **Inventar-Tracking (Prioritaet 2):**
   - Events: `BAG_UPDATE`, `ITEM_PUSH`, `ITEM_LOCK_CHANGED`
   - Item-Aenderungen protokollieren
   - Ausruestungsaenderungen tracken
   - Gold-Verlauf erfassen

   **Handels-Tracking (Prioritaet 2):**
   - Events: `TRADE_SHOW`, `TRADE_ACCEPT_UPDATE`, `TRADE_REQUEST`, `MAIL_SHOW`, `MAIL_SEND_SUCCESS`, `AUCTION_HOUSE_SHOW`
   - Handelspartner und getauschte Items erfassen
   - Mailbox-Aktivitaet protokollieren
   - AH-Transaktionen aufzeichnen

   **Bewegungs-Tracking (Prioritaet 3):**
   - Positionsabfragen: `GetPlayerMapPosition()`, Timer-basiert
   - Geschaetzte Schritte berechnen
   - Zonen-Aufenthaltszeit messen
   - Erkundungsfortschritt tracken

   **Dungeon/Boss-Tracking (Prioritaet 2):**
   - Events: `ZONE_CHANGED_NEW_AREA`, `BOSS_KILL` (falls verfuegbar in TBC), `ENCOUNTER_START`/`ENCOUNTER_END` (falls verfuegbar)
   - Alternative Erkennung ueber Mob-Name bei Boss-Tod
   - Instanz-Betreten/-Verlassen protokollieren
   - Clear-Zeiten und Wipe-Counter

   **Angel-Tracking (Prioritaet 3):**
   - Events: `ITEM_PUSH` in Kombination mit Angelruten-Check
   - Angelzeit messen (Zeitraum zwischen Auswerfen und Einholen)
   - Gefangene Fische kategorisieren

3. Daten-Serialisierung implementieren:
   - Effiziente Datenstrukturen fuer SavedVariables
   - Komprimierung durch ID-basierte Referenzen (z.B. Zone-IDs statt Zone-Namen)
   - Rotations-Mechanismus fuer aeltere Daten
   - Integritaetspruefung (Checksummen)

4. Unit-Tests:
   - Mock-Framework fuer WoW API Events erstellen
   - Tests fuer jedes Tracking-Modul
   - Edge-Cases testen (Disconnect waehrend Kampf, Serverlag, etc.)
   - Performance-Tests (Tracking darf nicht zu FPS-Einbruechen fuehren)

**Ergebnis:** Vollstaendige Tracking-Library, die alle relevanten Spieleraktionen erfasst und persistent speichert.

**Abnahmekriterien:**
- Alle Prioritaet-1-Module sind implementiert und getestet
- Daten werden korrekt in SavedVariables gespeichert
- Kein messbarer FPS-Einbruch waehrend normalem Spielbetrieb
- Unit-Tests fuer alle Module bestehen
- Dokumentation der API fuer andere Module

---

### Phase 3: PoC - Gilden-Kommunikation ("Gildenbank") (2-3 Wochen)

**Ziel:** Einen robusten Kommunikationslayer zwischen Addon-Instanzen aufbauen.

**Aufgaben:**
1. Addon-Messaging-Framework implementieren:
   - `SendAddonMessage()` und `CHAT_MSG_ADDON` Event-Handler
   - Prefix registrieren: "HCPlus" (max. 16 Zeichen in TBC)
   - Message-Typen definieren: SYNC, BROADCAST, REQUEST, RESPONSE, ACK
   - Nachrichtenserialisierung: Kompakte String-Kodierung oder AceSerializer

2. Kommunikationsprotokolle:

   **Regelwerk-Broadcast:**
   - GM sendet aktuelles Regelwerk an alle Online-Mitglieder
   - Empfaenger bestaetigen Empfang (ACK)
   - Offline-Spieler erhalten Regelwerk beim naechsten Login
   - Versionierung: Nur Aenderungen senden (Delta-Sync)
   - Signierung: GM-Nachrichten werden mit GM-ID verifiziert

   **Tod-Benachrichtigung:**
   - Bei Spielertod: Sofortige Broadcast-Nachricht an alle Gilden-Mitglieder
   - Nachricht enthaelt: Spielername, Level, Todesursache, Ort
   - Empfaenger zeigen In-Game-Popup mit Todesdetails

   **Score-Synchronisation:**
   - Periodische Synchronisation der Score-Daten (alle 5 Minuten)
   - Inkrementelle Updates statt Voll-Sync
   - Konfliktbehandlung bei gleichzeitigen Updates

   **Haus-Kommunikation:**
   - Haus-interne Nachrichten (separater Kanal pro Haus)
   - Haus-Leaderboard Synchronisation
   - Haus-Event-Koordination

3. Throttling und Fehlerbrennung:
   - WoW TBC hat Limits fuer Addon-Messages (Burst: 10 Nachrichten, danach 1 pro Sekunde)
   - Queue-System fuer ausgehende Nachrichten
   - Retry-Logik fuer fehlgeschlagene Nachrichten
   - Priorisierung: Tod-Benachrichtigungen > Regelwerk > Scores

4. Sicherheitsaspekte:
   - GM-Verifizierung: Nur GM und Offiziere koennen bestimmte Nachrichten senden
   - Anti-Spoofing: Nachrichten werden mit Absender-Pruefung verifiziert
   - Rate-Limiting: Schutz gegen Message-Flooding

5. Wiederverwendbares Plugin:
   - Den gesamten Kommunikationslayer als eigenstaendiges Modul kapseln
   - Klar definierte API: `HCPlus.Comm:Send(type, data, target)`, `HCPlus.Comm:RegisterHandler(type, callback)`
   - Unabhaengig vom Rest des Addons nutzbar

**Ergebnis:** Funktionierender Kommunikationslayer, der Daten zuverlaessig zwischen Addon-Instanzen synchronisiert.

**Abnahmekriterien:**
- Regelwerk wird zuverlaessig an alle Online-Mitglieder uebertragen
- Tod-Benachrichtigungen erscheinen innerhalb von 2 Sekunden bei allen Empfaengern
- Score-Synchronisation funktioniert mit 5+ gleichzeitigen Spielern
- Keine spuerbaren Lags durch Addon-Kommunikation
- Message-Queue funktioniert korrekt bei Throttling

---

### Phase 4: Voting-Feature auf der Webseite (1-2 Wochen)

**Ziel:** Eine einfache Webanwendung fuer Community-Abstimmungen und Schwierigkeits-Ratings.

**Aufgaben:**
1. Backend aufsetzen:
   - Node.js Express Server
   - Datenbank: SQLite fuer MVP (spaeter Migration zu MongoDB/PostgreSQL)
   - Einfache REST API:
     - `GET /api/votes/:category` - Alle Abstimmungen einer Kategorie abrufen
     - `POST /api/votes/:id` - Stimme abgeben
     - `GET /api/ratings/heroic` - Heroic-Schwierigkeits-Ratings abrufen
     - `POST /api/ratings/heroic/:dungeon` - Rating abgeben
   - Rate-Limiting und Basis-Authentifizierung

2. Abstimmungs-Seiten implementieren:
   - **Scoring-System Abstimmung:** Komplex vs. Einfach (mit detaillierter Erklaerung beider Systeme)
   - **Heroic-Difficulty Ratings:** Spieler bewerten jeden Heroic-Dungeon auf einer Skala von 1-10
   - **Raid-Boss Ratings:** Spieler bewerten jeden Raid-Boss auf einer Skala von 1-10
   - **Feature-Prioritaeten:** Welche Features sollen zuerst implementiert werden?

3. Frontend implementieren:
   - Einfaches React-Frontend (oder Vanilla JS fuer Schnelligkeit)
   - Abstimmungsformulare mit Echtzeit-Ergebnisanzeige
   - Responsive Design fuer Mobile
   - Charts fuer Ergebnis-Visualisierung (z.B. Chart.js)

4. Datenintegration vorbereiten:
   - Export-API fuer Abstimmungsergebnisse
   - Integration mit dem Addon: Abstimmungsergebnisse koennen als Konfiguration importiert werden
   - Automatische Aktualisierung der Schwierigkeits-Multiplikatoren basierend auf Voting-Ergebnissen

**Ergebnis:** Funktionierende Webseite fuer Community-Abstimmungen mit Echtzeit-Ergebnissen.

**Abnahmekriterien:**
- Abstimmungen koennen erstellt und durchgefuehrt werden
- Ergebnisse werden in Echtzeit aktualisiert
- Rate-Limiting verhindert Mehrfach-Abstimmungen
- Mobile-kompatibles Design
- API-Endpunkte funktionieren zuverlaessig

---

### Phase 5: Rudimentaeres HC Addon (3-4 Wochen)

**Ziel:** Ein spielbares Minimum Viable Product (MVP) mit Beispielen aus allen Kernbereichen.

**Aufgaben:**
1. **Basis-Tod-Tracking mit Benachrichtigungen:**
   - Vollstaendiges Tod-Tracking aus Phase 2 integrieren
   - Gildenweit sichtbare Tod-Benachrichtigungen
   - Tod-Popup mit Details (Ursache, Ort, Zeitpunkt)
   - Todes-Historie abrufbar

2. **Einfaches Scoring:**
   - Implementierung des einfachen Scoring-Systems (fixe Werte)
   - Punkte fuer: Mob-Kills, Boss-Kills, Level-Ups, Quest-Abschluesse
   - Punkteabzug bei Tod
   - Aktueller Score in der UI anzeigen

3. **Eine kreative Strafe implementieren:**
   - RP-Walk-Force als Beispiel-Strafe
   - GM-Interface zum Verhaengen der Strafe
   - Timer-Overlay beim betroffenen Spieler
   - Gildennachricht bei Strafverhaengung
   - Automatische Aufhebung nach Ablauf

4. **Regelwerk-Auswahl:**
   - Drei vordefinierte Modi:
     - **HC (Hardcore):** Permadeath auf allen Leveln, kein Handel, maximale Schwierigkeit
     - **Hybrid:** Permadeath bis 60, Checkpoints ab 60, konfigurierbare Regeln
     - **Nullcore:** Keine Todes-Strafen, nur Tracking und Scoring
   - GM kann Modus fuer die Gilde festlegen
   - Spieler sieht aktiven Modus im UI

5. **Basis-Leaderboard in-game:**
   - Scrollbare Liste der Top-Spieler
   - Anzeige: Rang, Name, Score, Level, Status (lebendig/tot)
   - Filterbar nach Haus (wenn verfuegbar)
   - Aktualisierung bei Score-Aenderungen

6. **SSF-Enforcement:**
   - AH-Nutzung blockieren (Warnung + Protokollierung)
   - Handel blockieren (Warnung + Protokollierung)
   - Mailbox-Nutzung einschraenken (Warnung + Protokollierung)
   - Konfigurierbar pro Regelwerk

**Ergebnis:** Spielbares MVP mit allen Kernbereichen abgedeckt.

**Abnahmekriterien:**
- Spieler koennen HC+ in einem der drei Modi spielen
- Tode werden zuverlaessig getrackt und gildenweit benachrichtigt
- Scoring funktioniert und wird im Leaderboard angezeigt
- RP-Walk-Strafe funktioniert als GM-Tool
- SSF-Enforcement verhindert verbotene Aktionen
- Keine Lua-Fehler waehrend normalem Spielbetrieb

---

### Phase 6: Alpha zu Beta (4-6 Wochen)

**Ziel:** Alle Kernfeatures implementieren und das Addon fuer einen Betatest vorbereiten.

**Aufgaben:**
1. **Haeuser-System vollstaendig implementieren:**
   - Haus-Erstellung und -Verwaltung durch GM
   - Spieler-Zuweisung zu Haeusern
   - Haus-spezifische Leaderboards
   - Haus-Chat ueber Addon-Messaging
   - Haus-Wettbewerbe (mindestens 3 Typen)
   - Draft-System (Basis-Version)

2. **Mini-Game Framework:**
   - Event-System fuer spontane Mini-Games
   - Mindestens 3 implementierte Mini-Games:
     - Rennen ("Wer ist zuerst bei X?")
     - Kill-Wettbewerb ("Wer toetet zuerst 100 Mobs?")
     - Ueberlebens-Challenge ("Keine Tode fuer 1 Stunde = doppelte Punkte")
   - GM-Interface zum Starten und Konfigurieren von Events
   - Automatische Ergebnis-Auswertung und Belohnungs-Vergabe

3. **Web-Dashboard Grundversion:**
   - Spieler-Registrierung und -Login (OAuth ueber Discord oder Battle.net wenn moeglich)
   - Gilden-Dashboard: Mitglieder, Haeuser, aktives Regelwerk
   - Leaderboard-Seite mit Filtern
   - Basis-Spielerprofil mit Statistiken
   - Responsive Design

4. **Companion App fuer Backend-Kommunikation:**
   - Electron-basierte Desktop-App
   - WoW SavedVariables-Verzeichnis ueberwachen
   - Bei Aenderungen: Daten an Backend senden
   - HMAC-SHA256 Signierung der Daten
   - Near-Realtime Updates (Polling alle 10-30 Sekunden)
   - System-Tray Integration (laeuft im Hintergrund)
   - Einfaches Setup: Addon-Ordner automatisch erkennen

5. **Anti-Cheat Grundversion:**
   - SavedVariables-Integritaetspruefung (Checksummen)
   - Plausibilitaetspruefung von Tracking-Daten (z.B. unmoeglich hohe Kill-Raten)
   - Addon-Versions-Verifizierung
   - Community-Flagging-System (Spieler koennen verdaechtige Aktivitaeten melden)
   - GM-Dashboard fuer gemeldete Vorfaelle

6. **Erweitertes Achievement-System:**
   - 500+ Achievements implementieren
   - Achievement-Browser in-game
   - Achievement-Benachrichtigungen gildenweit
   - Achievement-Punkte als Teil des Gesamt-Scores

7. **Erweitertes Bestrafungssystem:**
   - Alle 8 kreativen Strafen implementieren
   - GM-Interface fuer Strafverhaengung
   - Automatische Regelverstoss-Erkennung
   - Straf-Historie pro Spieler

8. **Bugfixing und Performance:**
   - Systematisches Testen aller Features
   - Performance-Profiling (FPS-Auswirkungen messen)
   - Memory-Leak-Pruefung
   - Addon-Groesse optimieren (kompakte SavedVariables)
   - Bekannte Bugs dokumentieren und beheben

**Ergebnis:** Feature-komplettes Addon bereit fuer Betatest.

**Abnahmekriterien:**
- Alle Kernfeatures sind implementiert und funktional
- Haeuser-System funktioniert mit mindestens 4 Haeusern
- Mini-Games koennen vom GM gestartet und gespielt werden
- Web-Dashboard zeigt Leaderboards und Spielerprofile
- Companion App synchronisiert Daten zuverlaessig
- Kein Lua-Fehler waehrend 2-stuendigem Dauertest
- FPS-Einbruch durch Addon maximal 5%

---

### Phase 7: Playtesting (2-4 Wochen)

**Ziel:** Das Addon mit echten Spielern testen, Feedback sammeln und Balancing optimieren.

**Aufgaben:**
1. **Geschlossener Betatest organisieren:**
   - 20-50 Tester rekrutieren (Community, Streamer, erfahrene HC-Spieler)
   - Testserver aufsetzen (CMaNGOS TBC Docker mit vorbereiteter Datenbank)
   - NDA und Feedback-Vereinbarung
   - Dedizierter Discord-Kanal fuer Beta-Tester
   - Strukturierter Feedback-Bogen (Google Forms oder eigenes Tool)

2. **Test-Szenarien:**
   - **Solo-Leveling:** Ein Spieler levelt von 1-70 mit HC+-Tracking
   - **Gilden-Setup:** 20+ Spieler in einer Gilde mit Haeuser-System
   - **Dungeon-Run:** 5er-Gruppe in Heroic mit Checkpoints und Todes-Tracking
   - **Event-Simulation:** GM startet Mini-Games und verhaengt Strafen
   - **Stress-Test:** Alle Spieler gleichzeitig online, Addon-Messaging unter Last
   - **SSF-Test:** Spieler versucht bewusst SSF-Regeln zu umgehen

3. **Feedback sammeln:**
   - Woechentliche Feedback-Runden (Voice-Chat)
   - Bug-Reports ueber Issue-Tracker (GitHub Issues)
   - Feature-Requests priorisieren
   - UX-Feedback (UI verstaendlich? Zu viele Popups? Performance?)

4. **Balancing:**
   - Punkte-Werte feinjustieren basierend auf Tester-Feedback
   - Schwierigkeits-Ratings anpassen
   - Straf-Dauer und -Intensitaet balancen
   - Achievement-Werte ueberpruefen
   - Regelwerk-Multiplikatoren validieren

5. **Stress-Test:**
   - 50+ gleichzeitige Spieler in einer Gilde simulieren
   - Addon-Messaging unter Last testen (Throttling, Queue-Overflow)
   - SavedVariables-Groesse bei Langzeitspielern ueberpruefen
   - Web-Dashboard mit vielen gleichzeitigen Zugriffen testen
   - Companion App Stabilitaet ueber 24h

**Ergebnis:** Getestetes und balanciertes Addon, bereit fuer den Launch.

**Abnahmekriterien:**
- Alle kritischen Bugs sind behoben
- Beta-Tester bewerten das Addon mit mindestens 7/10 im Durchschnitt
- Kein Datenverlust waehrend des gesamten Betatests
- Performance bleibt auch nach 100+ Stunden Spielzeit stabil
- Alle Balancing-Werte sind von mindestens 3 Testern als "fair" bewertet worden

---

### Phase 8: Launch-Vorbereitung (2 Wochen)

**Ziel:** Alles fuer den oeffentlichen Launch vorbereiten.

**Aufgaben:**
1. **CurseForge Upload:**
   - Addon-Paket erstellen (nur Free-Features)
   - CurseForge-Projektseite einrichten
   - Screenshots und Beschreibung erstellen
   - Changelog schreiben
   - Versionierung festlegen (1.0.0)
   - Automatischer Build-Prozess (CI/CD Pipeline)

2. **Patreon Premium System:**
   - Patreon-Seite einrichten mit Tier-Beschreibungen
   - Lizenzdatei-Generator implementieren
   - Lizenzdatei-Validierung im Addon testen
   - Automatische Lizenzerneuerung via Companion App
   - FAQ fuer Premium-Nutzer erstellen

3. **Marketing-Materialien:**
   - Trailer-Video (30-60 Sekunden) mit allen Kern-Features
   - Feature-Showcase Screenshots
   - Social-Media-Ankuendigungen vorbereiten (Twitter, Reddit, Discord)
   - Blog-Post mit ausfuehrlicher Feature-Beschreibung
   - Streamer-Outreach: Kostenlose Premium-Keys fuer ausgewaehlte Streamer

4. **Dokumentation fuer GMs:**
   - Ausfuehrliches GM-Handbuch:
     - Regelwerk-Konfiguration Schritt fuer Schritt
     - Haeuser-Einrichtung und -Verwaltung
     - Straf- und Belohnungssystem Anleitung
     - Mini-Game Nutzung
     - Web-Dashboard Erklaerung
   - Quick-Start-Guide fuer neue Gilden
   - FAQ mit haeufigen Problemen und Loesungen
   - Video-Tutorials fuer komplexe Features

5. **Launch-Checklist:**
   - Alle Known-Issues dokumentiert
   - Support-Kanal eingerichtet (Discord)
   - Monitoring fuer Backend und Web-Dashboard
   - Backup-Strategie fuer Datenbank
   - Rollback-Plan bei kritischen Bugs

**Ergebnis:** Oeffentlich verfuegbares Addon auf CurseForge, funktionierendes Premium-System, Marketing bereit.

**Abnahmekriterien:**
- Addon ist auf CurseForge verfuegbar und installierbar
- Premium-System funktioniert End-to-End (Patreon -> Lizenzdatei -> Feature-Unlock)
- GM-Dokumentation ist vollstaendig und verstaendlich
- Mindestens 3 Streamer haben Premium-Keys erhalten
- Backend und Web-Dashboard sind online und stabil

---

### Gesamtzeitplan (Uebersicht)

| Phase | Dauer | Kumuliert | Abhaengigkeiten |
|-------|-------|-----------|-----------------|
| Phase 0: Konzept | 1-2 Wochen | 2 Wochen | Keine |
| Phase 1: PoC Menu | 1-2 Wochen | 4 Wochen | Phase 0 |
| Phase 2: Tracking Library | 2-3 Wochen | 7 Wochen | Phase 1 |
| Phase 3: Kommunikation | 2-3 Wochen | 10 Wochen | Phase 1 (teilweise Phase 2) |
| Phase 4: Web-Voting | 1-2 Wochen | 12 Wochen | Unabhaengig (parallel moeglich) |
| Phase 5: MVP | 3-4 Wochen | 16 Wochen | Phase 2, 3 |
| Phase 6: Alpha/Beta | 4-6 Wochen | 22 Wochen | Phase 5 |
| Phase 7: Playtesting | 2-4 Wochen | 26 Wochen | Phase 6 |
| Phase 8: Launch | 2 Wochen | 28 Wochen | Phase 7 |

**Geschaetzte Gesamtdauer:** 6-7 Monate

**Parallelisierungsmoeglichkeiten:**
- Phase 4 (Web-Voting) kann parallel zu Phase 2 und 3 entwickelt werden
- Phase 6 Web-Dashboard kann parallel zur Addon-Entwicklung vorangetrieben werden
- Companion App Entwicklung kann ab Phase 5 beginnen

---

## 5. Technische Architektur

### 5.1 WoW Addon (Lua 5.1)

#### Modularer Aufbau

```
HardcorePlus/
├── HardcorePlus.toc          -- Addon-Manifest
├── Main.lua                   -- Einstiegspunkt, laedt alle Module
├── Core/
│   ├── Init.lua              -- Addon-Initialisierung, Namespace
│   ├── EventBus.lua          -- Internes Event-System (Pub/Sub)
│   ├── Config.lua            -- Konfigurationsverwaltung
│   ├── Utils.lua             -- Hilfsfunktionen (Serialisierung, Hashing, etc.)
│   └── Constants.lua         -- Globale Konstanten (Versionen, IDs, etc.)
├── Modules/
│   ├── Tracking.lua          -- Haupt-Tracking-Modul (koordiniert Sub-Module)
│   ├── Tracking/
│   │   ├── Death.lua         -- Tod-Tracking
│   │   ├── Level.lua         -- Level-Tracking
│   │   ├── Combat.lua        -- Kampf- und Mob-Kill-Tracking
│   │   ├── Inventory.lua     -- Inventar- und Ausruestungs-Tracking
│   │   ├── Trade.lua         -- Handels-Tracking (Handel, Mail, AH)
│   │   ├── Movement.lua      -- Bewegungs- und Explorations-Tracking
│   │   ├── Dungeon.lua       -- Dungeon- und Raid-Tracking
│   │   └── Fishing.lua       -- Angel-Tracking
│   ├── Rules.lua             -- Regelwerk-Engine
│   ├── Rules/
│   │   ├── HardRules.lua     -- Nicht aenderbare Regeln
│   │   ├── SoftRules.lua     -- GM-konfigurierbare Regeln
│   │   ├── Presets.lua       -- Vordefinierte Regelsaetze (HC, Hybrid, Nullcore)
│   │   ├── Enforcement.lua   -- Regel-Durchsetzung und Verstoss-Erkennung
│   │   └── Export.lua        -- Export/Import von Regelsaetzen
│   ├── Scoring.lua           -- Punktesystem
│   ├── Scoring/
│   │   ├── SimpleScoring.lua -- Einfaches Scoring mit fixen Werten
│   │   ├── ComplexScoring.lua-- Komplexes Scoring mit Multiplikatoren
│   │   └── Achievements.lua  -- Achievement-System und -Definitionen
│   ├── Communication.lua     -- Addon-Messaging Layer
│   ├── Communication/
│   │   ├── Protocol.lua      -- Nachrichtenprotokolle
│   │   ├── Queue.lua         -- Message-Queue mit Throttling
│   │   ├── Sync.lua          -- Daten-Synchronisation
│   │   └── Security.lua      -- Nachrichtenverifizierung
│   ├── Houses.lua            -- Haeuser-Management
│   ├── Houses/
│   │   ├── Management.lua    -- Haus-Erstellung und -Verwaltung
│   │   ├── Draft.lua         -- Draft-System
│   │   ├── Competition.lua   -- Haus-Wettbewerbe
│   │   └── Leaderboard.lua   -- Haeuser-Leaderboard
│   ├── Punishments.lua       -- Bestrafungssystem
│   ├── Punishments/
│   │   ├── Creative.lua      -- Kreative Strafen (Premium)
│   │   ├── Standard.lua      -- Standard-Strafen (Free)
│   │   └── Detection.lua     -- Automatische Verstoss-Erkennung
│   ├── Rewards.lua           -- Belohnungssystem
│   ├── Rewards/
│   │   ├── Public.lua        -- Oeffentliche Belohnungen
│   │   ├── Hidden.lua        -- Versteckte Belohnungen
│   │   └── GuildRewards.lua  -- Gildenbelohnungen
│   ├── MiniGames.lua         -- Mini-Spiel Framework
│   ├── MiniGames/
│   │   ├── Race.lua          -- Rennen
│   │   ├── KillContest.lua   -- Kill-Wettbewerbe
│   │   ├── Survival.lua      -- Ueberlebens-Challenges
│   │   ├── Trivia.lua        -- Gilden-Trivia
│   │   └── ScavengerHunt.lua -- Schnitzeljagden
│   └── AntiCheat.lua         -- Anti-Cheat Grundschutz
├── UI/
│   ├── MainFrame.lua         -- Hauptfenster
│   ├── MinimapButton.lua     -- Minimap-Icon
│   ├── ScorePanel.lua        -- Score-Anzeige (minimalistisch)
│   ├── Leaderboard.lua       -- Leaderboard-Fenster
│   ├── AchievementBrowser.lua-- Achievement-Browser
│   ├── RulesConfig.lua       -- Regelwerk-Konfigurator (GM)
│   ├── PunishmentPanel.lua   -- Strafverhaengungs-UI (GM)
│   ├── HouseManager.lua      -- Haeuser-Verwaltungs-UI
│   ├── MiniGameUI.lua        -- Mini-Game Anzeige
│   ├── DeathPopup.lua        -- Todes-Benachrichtigung
│   ├── TimerOverlay.lua      -- Timer fuer Strafen/Events
│   └── Templates.xml         -- XML-Templates fuer Frames
├── Libs/
│   ├── Ace3/                 -- Ace3 Library Suite
│   ├── LibDataBroker/        -- Data Broker fuer Minimap
│   └── LibDBIcon/            -- Minimap Icon Library
├── Locale/
│   ├── enUS.lua              -- Englische Lokalisierung
│   └── deDE.lua              -- Deutsche Lokalisierung
└── Data/
    ├── BossDatabase.lua      -- Boss-Datenbank (Name, ID, Instanz, Schwierigkeit)
    ├── ZoneDatabase.lua      -- Zonen-Datenbank
    ├── AchievementDefs.lua   -- Achievement-Definitionen
    └── DefaultScoring.lua    -- Standard-Scoring-Werte
```

#### SavedVariables

SavedVariables werden fuer die Persistenz aller Spielerdaten verwendet:

```lua
-- HardcorePlusDB (Account-weit)
HardcorePlusDB = {
    global = {
        version = "1.0.0",
        premium = false,
        licenseKey = nil,
        licenseExpiry = nil,
    },
    char = {
        -- Pro Charakter gespeichert
        ["Thrallinho - Mankrik"] = {
            tracking = {
                deaths = { ... },
                levels = { ... },
                kills = { ... },
                inventory = { ... },
                trades = { ... },
                movement = { ... },
                dungeons = { ... },
                fishing = { ... },
            },
            scoring = {
                totalScore = 0,
                scoreHistory = { ... },
                achievements = { ... },
            },
            rules = {
                activeRuleset = "hybrid",
                violations = { ... },
            },
            punishments = {
                active = { ... },
                history = { ... },
            },
            house = "Aldor",
            status = "alive", -- "alive", "dead", "retired"
        },
    },
    guild = {
        -- Gilden-spezifische Daten
        ruleset = { ... },
        houses = { ... },
        leaderboard = { ... },
        events = { ... },
    },
}
```

#### Ace3 Libraries (Empfohlen)

| Library | Verwendung |
|---------|------------|
| AceAddon-3.0 | Addon-Struktur und Modul-System |
| AceEvent-3.0 | WoW Event Handling |
| AceComm-3.0 | Addon-zu-Addon Kommunikation |
| AceSerializer-3.0 | Datenserialisierung fuer Kommunikation |
| AceDB-3.0 | SavedVariables Management |
| AceGUI-3.0 | UI-Elemente und Widgets |
| AceConfig-3.0 | Einstellungs-Interface |
| AceLocale-3.0 | Mehrsprachigkeit |
| LibDataBroker-1.1 | Data Broker fuer Minimap |
| LibDBIcon-1.0 | Minimap Icon |

---

### 5.2 Companion App (Electron)

#### Aufgaben

- WoW SavedVariables-Verzeichnis ueberwachen (File-System-Watcher)
- Bei Aenderungen der SavedVariables: Daten parsen und ans Backend senden
- HMAC-SHA256 Signierung aller ausgehenden Daten
- Lizenzdatei-Management (Patreon Premium)
- Auto-Update Mechanismus
- System-Tray Integration

#### Technologie-Stack

- **Framework:** Electron (Cross-Platform: Windows, macOS, Linux)
- **Sprache:** TypeScript
- **File-Watching:** chokidar oder fs.watch
- **HTTP Client:** axios oder node-fetch
- **Lua Parsing:** Custom Parser fuer SavedVariables (Lua Table Syntax)
- **Signierung:** Node.js crypto Modul (HMAC-SHA256)
- **Auto-Update:** electron-updater

#### Architektur

```
companion-app/
├── src/
│   ├── main/
│   │   ├── index.ts           -- Electron Main Process
│   │   ├── tray.ts            -- System-Tray Management
│   │   ├── watcher.ts         -- SavedVariables File Watcher
│   │   ├── parser.ts          -- Lua SavedVariables Parser
│   │   ├── api.ts             -- Backend API Client
│   │   ├── auth.ts            -- Authentifizierung und Lizenzverwaltung
│   │   ├── crypto.ts          -- HMAC-SHA256 Signierung
│   │   └── config.ts          -- App-Konfiguration
│   ├── renderer/
│   │   ├── index.html         -- Haupt-UI
│   │   ├── styles.css         -- Styling
│   │   └── app.ts             -- Renderer Process
│   └── shared/
│       ├── types.ts           -- Gemeinsame Typdefinitionen
│       └── constants.ts       -- Konstanten
├── package.json
├── tsconfig.json
└── electron-builder.yml       -- Build-Konfiguration
```

#### Datenfluss

```
WoW Addon (Lua)
    │
    ▼ (SavedVariables auf Disk schreiben)
SavedVariables/HardcorePlusDB.lua
    │
    ▼ (File-System-Watcher erkennt Aenderung)
Companion App (Electron)
    │
    ├── Lua Parser liest und interpretiert Daten
    ├── Delta-Berechnung (nur Aenderungen senden)
    ├── HMAC-SHA256 Signierung
    │
    ▼ (HTTPS POST)
Backend API (Node.js)
    │
    ├── Signatur-Verifizierung
    ├── Datenvalidierung
    ├── Datenbank-Update
    │
    ▼ (WebSocket Push)
Web Dashboard (React)
```

---

### 5.3 Backend (Node.js)

#### Technologie-Stack

- **Runtime:** Node.js 18+ (LTS)
- **Framework:** Express.js oder Fastify
- **Datenbank:** MongoDB (fuer flexible Dokument-Strukturen) oder PostgreSQL (fuer relationale Daten)
- **Cache:** Redis (fuer Leaderboards und Session-Management)
- **WebSocket:** Socket.io oder ws
- **Authentifizierung:** JWT (JSON Web Tokens)
- **Validierung:** Joi oder Zod
- **Logging:** Winston oder Pino
- **Testing:** Jest

#### API-Endpunkte (Auszug)

```
# Authentifizierung
POST   /api/auth/register         -- Benutzer registrieren
POST   /api/auth/login            -- Anmelden (JWT erhalten)
POST   /api/auth/refresh          -- Token erneuern

# Spieler
GET    /api/players/:id           -- Spielerprofil abrufen
GET    /api/players/:id/stats     -- Detaillierte Statistiken
GET    /api/players/:id/achievements -- Achievements
PUT    /api/players/:id/data      -- Tracking-Daten aktualisieren (Companion App)

# Gilden
GET    /api/guilds/:id            -- Gilden-Informationen
GET    /api/guilds/:id/leaderboard -- Gilden-Leaderboard
GET    /api/guilds/:id/rules      -- Aktives Regelwerk
PUT    /api/guilds/:id/rules      -- Regelwerk aktualisieren (GM)
GET    /api/guilds/:id/houses     -- Haeuser-Uebersicht

# Haeuser
GET    /api/houses/:id            -- Haus-Details
GET    /api/houses/:id/members    -- Haus-Mitglieder
POST   /api/houses/:id/draft      -- Draft starten

# Leaderboards
GET    /api/leaderboards/global   -- Globales Leaderboard
GET    /api/leaderboards/guild/:id -- Gilden-Leaderboard
GET    /api/leaderboards/house/:id -- Haus-Leaderboard

# Events / Mini-Games
POST   /api/events                -- Event erstellen (GM)
GET    /api/events/:id            -- Event-Details
PUT    /api/events/:id/results    -- Event-Ergebnisse

# Voting
GET    /api/votes/:category       -- Abstimmungen abrufen
POST   /api/votes/:id             -- Stimme abgeben
GET    /api/ratings/heroic        -- Heroic-Ratings

# Premium / Lizenz
POST   /api/license/validate      -- Lizenz validieren
GET    /api/license/status        -- Lizenz-Status pruefen
```

#### Datenbank-Schema (MongoDB)

```javascript
// Collection: players
{
    _id: ObjectId,
    characterName: "Thrallinho",
    realm: "Mankrik",
    guildId: ObjectId,
    houseId: ObjectId,
    class: "Warrior",
    level: 70,
    status: "alive",
    totalScore: 15750,
    tracking: {
        deaths: [...],
        kills: { total: 5832, elites: 234, rares: 12, bosses: 45 },
        playtime: 387600, // Sekunden
        // ... weitere Tracking-Daten
    },
    achievements: [...],
    punishments: [...],
    lastUpdated: ISODate,
    createdAt: ISODate
}

// Collection: guilds
{
    _id: ObjectId,
    name: "OnlyFangs",
    realm: "Mankrik",
    ruleset: { ... },
    houses: [...],
    premium: true,
    licenseExpiry: ISODate,
    createdAt: ISODate
}

// Collection: houses
{
    _id: ObjectId,
    guildId: ObjectId,
    name: "Haus Aldor",
    color: "#FF6600",
    leaderId: ObjectId,
    officers: [...],
    members: [...],
    totalScore: 45000,
    createdAt: ISODate
}

// Collection: events
{
    _id: ObjectId,
    guildId: ObjectId,
    type: "race",
    config: { ... },
    participants: [...],
    results: [...],
    status: "active",
    createdAt: ISODate
}
```

---

### 5.4 Web Dashboard (React)

#### Technologie-Stack

- **Framework:** React 18+ mit TypeScript
- **Routing:** React Router v6
- **State Management:** Zustand oder Redux Toolkit
- **Styling:** Tailwind CSS oder Styled Components
- **Charts:** Recharts oder Chart.js (react-chartjs-2)
- **Tabellen:** TanStack Table
- **HTTP Client:** Axios oder React Query (TanStack Query)
- **WebSocket:** Socket.io-client
- **Build Tool:** Vite
- **Hosting:** Vercel, Netlify oder eigener Server

#### Seitenstruktur

```
/                         -- Landing Page mit Feature-Uebersicht
/login                    -- Login (Discord OAuth / Battle.net)
/dashboard                -- Gilden-Dashboard (Premium)
/dashboard/rules          -- Regelwerk-Konfigurator
/dashboard/houses         -- Haeuser-Management
/dashboard/punishments    -- Strafen-Manager
/dashboard/rewards        -- Belohnungs-Manager
/dashboard/events         -- Event-Manager
/leaderboard              -- Globales Leaderboard
/leaderboard/:guildId     -- Gilden-Leaderboard
/player/:id               -- Spielerprofil
/player/:id/achievements  -- Achievement-Showcase
/player/:id/deaths        -- Todes-Historie
/voting                   -- Community-Abstimmungen
/voting/heroic            -- Heroic-Difficulty-Ratings
/docs                     -- Dokumentation / FAQ
```

---

## 6. Konkurrenz-Analyse

### 6.1 Sauercrowd (Deutsches HC Event Addon)

**Beschreibung:** Ein Addon, das speziell fuer deutsche Hardcore-Events in Classic Era entwickelt wurde.

**Staerken:**
- Tod-Tracking mit Benachrichtigungen
- Chat-Prefix-System fuer Hardcore-Spieler
- Content-Creator-Integration (Stream-Overlays)
- Etablierte deutsche Community

**Schwaechen:**
- Komplett hardcoded Regeln (keine Anpassbarkeit)
- Kein Scoring- oder Punktesystem
- Kein Haeuser- oder Sub-Gilden-System
- Nur fuer Classic Era, kein TBC-Support
- Kein Web-Dashboard
- Keine kreativen Strafen
- Kein Mini-Game-System

**Unsere Chance:**
- Sauercrowd ist fuer ein einzelnes Event konzipiert und nicht generisch nutzbar
- Keine Anpassbarkeit bedeutet, dass jede Gilde das gleiche starre Erlebnis bekommt
- Wir bieten alles, was Sauercrowd kann, plus umfangreiche Erweiterungen

### 6.2 HardcoreTBC (von mocktailtv)

**Beschreibung:** Das einzige existierende TBC-spezifische Hardcore-Addon mit ueber 33.000 Downloads.

**Staerken:**
- TBC-spezifisch (gleiche Zielplattform wie HC+)
- Hohe Downloadzahlen zeigen Nachfrage
- Tod-Enforcement (Charakter wird geloescht bei Tod)
- Einfach und funktional

**Schwaechen:**
- Nur ein einziger Modus (Tod = Charakter loeschen)
- Kein Multi-Mode-System
- Kein Scoring oder Leaderboard
- Keine Anpassbarkeit der Regeln
- Kein Gilden-Feature (nur Solo)
- Kein Web-Dashboard
- Keine Companion App

**Unsere Chance:**
- HardcoreTBC zeigt, dass es eine grosse Nachfrage nach TBC HC gibt
- Aber das Addon ist extrem simpel und bietet null Anpassbarkeit
- Wir bieten dasselbe und viel mehr: Scoring, Leaderboards, Gilden-Features, etc.

### 6.3 Base HC Addon (Classic)

**Beschreibung:** Das Standard-Hardcore-Addon fuer WoW Classic mit grosser Community.

**Staerken:**
- Etabliert mit riesiger Spielerbasis
- Offizielle Anerkennung durch die HC-Community
- Robustes Tod-Tracking
- Deathlog-Integration

**Schwaechen:**
- Nur Classic Era/SoM, kein TBC-Support
- Starre Regeln ohne Anpassungsmoeglichkeit
- Kein Haeuser-System
- Kein Scoring (ausser "lebendig/tot")
- Kein Web-Dashboard

**Unsere Chance:**
- Kein TBC-Support bedeutet, dass alle TBC-Spieler eine Alternative brauchen
- Wir koennen von den bewaehrten Mechaniken lernen und sie verbessern

### 6.4 Unser Wettbewerbsvorteil

HC+ bietet als einziges Addon die folgenden Alleinstellungsmerkmale:

1. **Anpassbare Regelsaetze:** Kein anderes Addon erlaubt GM-konfigurierbare Regeln mit Export/Import
2. **Haeuser/Sub-Gilden:** Kein Konkurrent bietet interne Gildenwettbewerbe
3. **Kreatives Bestrafungssystem:** RP-Walk, Gear-Lock, Trade-Ban - einzigartig in der HC-Szene
4. **Web-Dashboard:** Kein Konkurrent bietet eine Web-Oberflaeche fuer Management und Statistiken
5. **Mini-Games:** Spontane Events und Wettbewerbe sind ein voellig neues Feature
6. **Companion App + Backend:** Einziges Addon mit externer Datenverifikation
7. **TBC-native:** Von Grund auf fuer TBC designed, nicht nachtraeglich portiert
8. **Scoring-System:** Differenziertes Punktesystem mit Community-Voting

---

## 7. OnlyFangs 3 Anforderungen

Basierend auf oeffentlich verfuegbaren Informationen ueber das Format von OnlyFangs Events:

### Feature-Abgleich

| OF3-Anforderung | HC+ Feature | Status |
|-----------------|-------------|--------|
| Haeuser-System innerhalb Aldor vs. Scryer | Haeuser-Feature mit Team-Aggregation | Geplant (Phase 6) |
| Punktesystem fuer Heroics | Scoring mit Community-gevoteten Schwierigkeits-Ratings | Geplant (Phase 4/5) |
| Tausende kleine Achievements | Achievement-System mit 1000+ Errungenschaften | Geplant (Phase 5/6) |
| Spieler-Rating fuer Draft | Draft-System mit 1-10 Rating und Punktebudget | Geplant (Phase 6) |
| Cross-House Wettbewerb | Haeuser-Leaderboards und Wettbewerbe | Geplant (Phase 6) |
| Punkte fuer Guild-Belohnungen | Belohnungssystem mit Punkte-Einloesung | Geplant (Phase 5/6) |
| BiS-Gear Zuweisung per Punkte | GM Reward Designer (Premium) | Geplant (Phase 6) |
| Aldor vs. Scryer Team-Wertung | Team-Aggregation in Haeuser-System | Geplant (Phase 6) |

### Spezielle OF3-Anpassungen

Fuer OnlyFangs 3 wuerden wir folgende Spezialanpassungen anbieten:

1. **Aldor/Scryer Integration:** Automatische Team-Zuweisung basierend auf Fraktion (Aldor = Team A, Scryer = Team B). Punkte werden sowohl pro Haus als auch pro Team aggregiert.

2. **Draft-Obertlaeche fuer Streamer:** Spezielle UI fuer Live-Drafts, die Stream-tauglich ist (grosse Schrift, klare Farben, Overlay-kompatibel).

3. **Heroic-Schwierigkeits-Voting:** Vorab Community-Abstimmung ueber die Schwierigkeit jedes Heroic-Dungeons. Ergebnisse fliessen direkt in das Scoring ein.

4. **Event-Spezifische Achievements:** Kuratierte Achievement-Liste speziell fuer OF3 (z.B. "Erstes Haus das Karazhan cleared", "Erster Spieler mit Aldor/Scryer Exalted").

5. **Streamer-Integration:** Spezielle Chat-Befehle und Overlays fuer Streamer, die Score, Leaderboard und Achievements in Echtzeit im Stream anzeigen.

---

## 8. Risiken und Gegenmaßnahmen

### 8.1 Technische Risiken

| Risiko | Wahrscheinlichkeit | Auswirkung | Gegenmaßnahme |
|--------|--------------------:|------------|----------------|
| WoW TBC API-Limitierungen verhindern Features | Mittel | Hoch | Fruehzeitige PoC-Tests, alternative Implementierungen vorbereiten |
| SavedVariables-Groesse sprengt Limits | Mittel | Mittel | Aggressive Datenrotation, Companion App fuer Auslagerung |
| Addon-Messaging Throttling bei grossen Gilden | Hoch | Mittel | Intelligentes Queue-System, priorisierte Nachrichten, Delta-Sync |
| Anti-Cheat wird umgangen | Hoch | Hoch | Mehrschichtiger Ansatz: Client-Checks + Backend-Verifizierung + Community-Flagging |
| Performance-Probleme durch umfangreiches Tracking | Mittel | Hoch | Performance-Budgets pro Modul, asynchrone Verarbeitung wo moeglich |
| Companion App Kompatibilitaet (OS-Versionen) | Niedrig | Mittel | Electron fuer Cross-Platform, ausfuehrliches Testing |

### 8.2 Projekt-Risiken

| Risiko | Wahrscheinlichkeit | Auswirkung | Gegenmaßnahme |
|--------|--------------------:|------------|----------------|
| OnlyFangs 3 findet vor Launch statt | Mittel | Hoch | Minimal Viable Product fruehzeitig bereitstellen, ggf. reduziertes Feature-Set |
| Zu wenige Entwickler fuer den Umfang | Hoch | Hoch | Feature-Priorisierung, MVP-Ansatz, Community-Beitraege ermoeglichen |
| Community bevorzugt Konkurrenz-Addon | Niedrig | Hoch | Differenzierung durch einzigartige Features, Community-Einbindung |
| Patreon-Einnahmen decken Serverkosten nicht | Mittel | Mittel | Hosting-Kosten minimieren, Free-Tier bei Cloud-Anbietern nutzen |
| Feature-Creep verzoegert Launch | Hoch | Hoch | Striktes MVP, klare Phase-Grenzen, "Nice-to-have" Liste fuehren |

### 8.3 Rechtliche Risiken

| Risiko | Wahrscheinlichkeit | Auswirkung | Gegenmaßnahme |
|--------|--------------------:|------------|----------------|
| Blizzard EULA-Verstoss | Niedrig | Sehr hoch | Nur erlaubte API-Funktionen nutzen, keine Automation, keine Botting-Features |
| Datenschutz (DSGVO) | Mittel | Hoch | Datenschutzerklaerung, Datenminimierung, Loesch-Funktion, EU-Hosting |
| Markenrecht (WoW, OnlyFangs) | Niedrig | Mittel | Keine geschuetzten Namen im Addon-Namen, Fair-Use Hinweise |

---

## 9. Offene Fragen und Entscheidungen

Die folgenden Punkte muessen vor oder waehrend Phase 0 geklaert werden:

### 9.1 Technische Entscheidungen

1. **Ace3 vs. eigenes Framework?**
   - Pro Ace3: Bewaehrt, grosse Community, viel Dokumentation, Zeitersparnis
   - Contra Ace3: Abhaengigkeit, moeglicherweise Overhead fuer Features die wir nicht brauchen
   - **Empfehlung:** Ace3 verwenden, reduziert Entwicklungszeit erheblich

2. **Datenbank: MongoDB vs. PostgreSQL?**
   - Pro MongoDB: Flexible Schemas, gut fuer Tracking-Daten mit variierender Struktur
   - Pro PostgreSQL: Relationale Integritaet, besser fuer Leaderboards und Transaktionen
   - **Empfehlung:** MongoDB fuer Tracking-Daten, Redis fuer Leaderboard-Caching

3. **Companion App: Electron vs. native vs. Python?**
   - Pro Electron: Cross-Platform, Web-Technologien, schnelle Entwicklung
   - Pro Native: Kleinere Binary, weniger Ressourcenverbrauch
   - Pro Python: Einfacher zu entwickeln, aber schwieriger zu verteilen
   - **Empfehlung:** Electron fuer Prototyp, spaeter ggf. auf Tauri (Rust-basiert, kleiner) migrieren

4. **Web-Hosting: Self-hosted vs. Cloud?**
   - Pro Cloud (Vercel/AWS): Skalierbar, weniger Wartung
   - Pro Self-hosted: Volle Kontrolle, keine laufenden Kosten
   - **Empfehlung:** Cloud fuer MVP (Vercel Free Tier + MongoDB Atlas Free Tier), spaeter evaluieren

### 9.2 Konzeptionelle Entscheidungen

1. **Scoring-System: Komplex vs. Einfach?**
   - Wird durch Community-Voting entschieden (Phase 4)
   - Beide Systeme muessen implementiert werden (umschaltbar)

2. **Premium-Preis und Tiers?**
   - Marktforschung durchfuehren: Was zahlen Spieler fuer vergleichbare Addons?
   - A/B-Test mit verschiedenen Preismodellen?
   - **Entscheidung bis:** Ende Phase 0

3. **Open Source oder Closed Source?**
   - Pro Open Source: Community-Beitraege, Vertrauen, Transparenz
   - Contra Open Source: Leichtere Umgehung von Anti-Cheat, schwieriger zu monetarisieren
   - **Empfehlung:** Addon Open Source (MIT License), Backend und Companion App Closed Source

4. **Support-Strategie?**
   - Discord-Server als primaerer Support-Kanal
   - GitHub Issues fuer Bug-Reports
   - FAQ und Wiki fuer Selbsthilfe
   - **Entscheidung:** Kein bezahlter Support, Community-basiert mit Premium-Prioritaet

### 9.3 Community-Entscheidungen (via Voting)

1. Scoring-System: Komplex vs. Einfach
2. Heroic-Difficulty-Ratings fuer jeden Dungeon
3. Raid-Boss-Difficulty-Ratings
4. Standard-Straf-Dauer (wie lange sollte RP-Walk als Standard gelten?)
5. Achievement-Punktwerte fuer die wichtigsten Achievements
6. Feature-Priorisierung fuer Post-Launch Updates

---

## 10. Glossar

| Begriff | Definition |
|---------|------------|
| **HC** | Hardcore - Spielmodus mit permanentem Tod |
| **HC+** | Hardcore Plus - Dieses Addon/Projekt |
| **Hybrid HC** | Hardcore-Modus mit konfigurierbaren Regeln ab Level 60 |
| **Nullcore** | Modus ohne Todes-Strafen, nur Tracking und Scoring |
| **SSF** | Solo Self-Found - Spielmodus ohne Handel und externe Hilfe |
| **GM** | Gildenmeister - Leiter einer Gilde mit vollen Konfigurationsrechten |
| **Haus** | Sub-Gilde innerhalb einer groesseren Gilde |
| **Draft** | System zur Verteilung von Spielern auf Haeuser basierend auf Rating |
| **Checkpoint** | Speicherpunkt in Instanzen, der bei Tod zuruecksetzt statt Permadeath |
| **SavedVariables** | WoW-Mechanismus zur persistenten Datenspeicherung von Addons |
| **Companion App** | Desktop-Anwendung, die Addon-Daten ans Backend sendet |
| **Addon-Messaging** | WoW-API zum Senden von Nachrichten zwischen Addon-Instanzen |
| **Throttling** | Begrenzung der Nachrichtenrate durch die WoW-API |
| **Delta-Sync** | Synchronisation, bei der nur Aenderungen uebertragen werden |
| **HMAC-SHA256** | Kryptographisches Verfahren zur Sicherung der Datenintegritaet |
| **Ace3** | Weit verbreitetes WoW-Addon-Framework |
| **CMaNGOS** | Open-Source WoW-Server-Emulator fuer Entwicklung und Tests |
| **CurseForge** | Plattform fuer WoW-Addon-Distribution |
| **Patreon** | Plattform fuer Abo-basierte Monetarisierung |
| **OF3** | OnlyFangs 3 - Grosses Community-Hardcore-Event |
| **BiS** | Best in Slot - Bestmoegliche Ausruestung fuer einen Slot |
| **Heroic** | Heroischer Schwierigkeitsgrad fuer TBC-Dungeons |

---

## Anhang A: Beispiel-Regelsaetze

### A.1 "OnlyFangs Standard"

```
Modus: Hybrid HC
Permadeath: Bis Level 60
Level 60-70: 2 Leben, Checkpoint bei Dungeon-Eingang
Endgame: 3 Leben pro Raid-Abend, Checkpoint vor jedem Boss
SSF: Nein (freier Handel innerhalb des Hauses)
AH: Verboten
Klassen: Alle erlaubt
Berufe: Keine Einschraenkungen
Haeuser: 4-8 Haeuser, Aldor vs Scryer Team-Wertung
Draft: Aktiviert (1-10 Rating, 100 Punkte Budget)
Mini-Games: Aktiviert
Kreative Strafen: Aktiviert (Premium)
```

### A.2 "Ironman Challenge"

```
Modus: HC
Permadeath: Auf allen Leveln
SSF: Ja (komplett, kein Handel, kein AH, keine Mail)
Dungeon: Verboten
Gruppen: Verboten (nur Solo)
Berufe: Nur Sammelberufe
Ausruestung: Nur weisse und graue Items
Talente: Keine Talente erlaubt
Schwierigkeits-Multiplikator: 3.5x
```

### A.3 "Casual Hardcore"

```
Modus: Nullcore
Permadeath: Nein
Tod-Strafe: -200 Punkte, 30 Min. XP-Freeze
SSF: Nein (freier Handel)
AH: Erlaubt
Dungeon: Unbegrenzt
Kreative Strafen: Deaktiviert
Haeuser: Optional
```

---

## Anhang B: WoW TBC 2.4.3 API-Referenz (Relevante Events)

### Kampf-Events
- `COMBAT_LOG_EVENT_UNFILTERED` - Alle Kampflog-Eintraege
- `PLAYER_REGEN_DISABLED` - Spieler im Kampf
- `PLAYER_REGEN_ENABLED` - Spieler ausser Kampf

### Tod-Events
- `PLAYER_DEAD` - Spieler ist gestorben
- `PLAYER_ALIVE` - Spieler ist wiederbelebt
- `PLAYER_UNGHOST` - Spieler ist nicht mehr Geist

### Level-Events
- `PLAYER_LEVEL_UP` - Spieler hat Level aufgestiegen
- `PLAYER_XP_UPDATE` - XP haben sich geaendert

### Inventar-Events
- `BAG_UPDATE` - Tasche wurde aktualisiert
- `ITEM_PUSH` - Item wurde erhalten
- `ITEM_LOCK_CHANGED` - Item-Sperre hat sich geaendert
- `EQUIPMENT_SWAP_FINISHED` - Ausruestungswechsel abgeschlossen

### Handels-Events
- `TRADE_SHOW` - Handelsfenster geoeffnet
- `TRADE_ACCEPT_UPDATE` - Handelsangebot aktualisiert
- `TRADE_REQUEST` - Handelsanfrage erhalten
- `MAIL_SHOW` - Briefkasten geoeffnet
- `MAIL_SEND_SUCCESS` - Brief erfolgreich gesendet
- `AUCTION_HOUSE_SHOW` - Auktionshaus geoeffnet
- `AUCTION_HOUSE_CLOSED` - Auktionshaus geschlossen

### Instanz-Events
- `ZONE_CHANGED_NEW_AREA` - Zonenuebergang
- `ZONE_CHANGED` - Zone hat sich geaendert
- `ZONE_CHANGED_INDOORS` - Spieler ist drinnen/draussen gewechselt

### Kommunikations-Events
- `CHAT_MSG_ADDON` - Addon-Nachricht empfangen
- `CHAT_MSG_GUILD` - Gildenchat-Nachricht

### Sonstige
- `PLAYER_ENTERING_WORLD` - Spieler betritt die Welt
- `PLAYER_LEAVING_WORLD` - Spieler verlaesst die Welt
- `GUILD_ROSTER_UPDATE` - Gildenroster aktualisiert

---

*Dieses Dokument ist ein lebendes Dokument und wird waehrend der Entwicklung kontinuierlich aktualisiert. Alle Teammmitglieder sind aufgefordert, Aenderungsvorschlaege ueber den dafuer vorgesehenen Kanal einzureichen.*

**Naechster Schritt:** Review durch alle Teammitglieder, danach Freigabe fuer Phase 0.
