const translations = {
    en: {
        nav: {
            modes: 'Modes',
            streamer: 'Streamer Tools',
            ideas: 'Ideas Lab',
            profile: 'Profile',
            explain: 'Explain WoW HC'
        },
        hero: {
            badge: 'Built for OnlyFangs 3',
            title1: 'Hardcore Reimagined',
            title2: 'For The Burning Crusade',
            subtitle: "TBC was never designed for hardcore. We're changing that. Choose your challenge mode, shape the rules with the community, and compete on the leaderboard.",
            btnModes: 'Explore Modes',
            btnVote: 'Cast Your Vote',
            btnScore: 'View Scoring'
        },
        modes: {
            label: 'Choose Your Challenge',
            title: 'Four Ways to Play',
            desc: 'From classic permadeath to competitive leagues — pick the mode that fits your playstyle. Each brings unique mechanics to TBC.',
            classic: {
                name: 'Hardcore Classic',
                tagline: 'The original ruleset. One life, one character. Death is permanent and absolute.',
                p1: '<strong class="highlight-red">Permadeath</strong> — character is voided forever on any death',
                p2: 'Full SSF — no mail, no AH, no trading, no grouping outside dungeons',
                p3: 'No boosts, no shortcuts — level 1 to 70 every time',
                p4: 'Closest to official Classic HC rules, adapted for TBC'
            },
            plus: {
                name: 'Hardcore Plus',
                tagline: 'Permadeath with progression. Hit checkpoints to unlock boosts for future characters.',
                p1: '<strong class="highlight-red">Permadeath</strong> — same finality as HC Classic',
                p2: '<strong class="highlight-purple">Checkpoint boost</strong>: reach level 70 once → unlock <strong>58 boost</strong> for future characters',
                p3: 'Account-wide <strong class="highlight-green">scoring</strong> — earn points for quests, milestones, achievements',
                p4: 'Leaderboards and seasonal rankings with titles'
            },
            softcore: {
                name: 'Softcore',
                tagline: 'You survive death, but lose everything equipped. Rebuild from your bank and keep going.',
                p1: 'All equipped gear, inventory, and gold <strong class="highlight-orange">destroyed</strong> on death',
                p2: 'Bank and alts are safe — rebuild from your stash',
                p3: 'Guild trading allowed — partial SSF with trusted allies',
                p4: 'No character deletion — death is costly but not final'
            },
            nullcore: {
                name: 'Nullcore League',
                tagline: 'No permadeath. Pure score-based competition where every action earns or costs points.',
                p1: 'Deaths <strong class="highlight-red">deduct points</strong> — quests, dungeons, achievements <strong class="highlight-green">earn points</strong>',
                p2: 'Season-based competition with time-limited leaderboards',
                p3: 'Tier titles: Bronze → Silver → Gold → <strong class="highlight-gold">Gladiator</strong>',
                p4: 'No trade restrictions — play WoW normally, compete on merit'
            }
        },
        strip: {
            f1: 'Death Monitoring',
            f2: 'Penalty Engine',
            f3: 'Scoring System',
            f4: 'Guild Sync',
            f5: 'SSF Enforcement',
            f6: 'Leaderboards',
            link: 'Explore Features, Scoring & Pipeline →'
        },
        streamer: {
            label: 'Streamer & Viewer Integration',
            title: 'Hardcore as a Spectator Sport',
            desc: 'Companion app bridges addon data to OBS overlays, Twitch chat, and public profiles.',
            m1Label: 'Twitch Stream — HC Addon Overlay',
            wTitle: 'Live Tracker',
            wMode: 'Mode',
            wScore: 'Score',
            wDeaths: 'Deaths',
            wRank: 'Rank',
            m2Label: 'Player Profile — Preview',
            p1Val: 'Retribution Paladin · HC Plus',
            btnProfile: 'View Full Profile →',
            m3Label: 'Viewer Penalty Vote (Twitch)',
            vEvent: '💀 PUPI DIED — Killed by Fel Reaver',
            vQ: 'Chat decides the penalty!',
            v1: '⚔️ Full gear wipe',
            v2: '📉 Score penalty (−300)',
            v3: '🔒 Gear lock 1hr',
            vTimer: '1,247 votes | ⏱ 28s',
            m4Label: 'Stream Event Alerts',
            a1: '<strong>CHARACTER VOIDED</strong><br>Zuzu (Priest) — Fel Reaver, Hellfire<br><span class="salert-pts neg">−300 pts</span>',
            a2: '<strong>MILESTONE</strong><br>Pupi hit Level 68 — Nagrand<br><span class="salert-pts pos">+100 pts · Rank #3</span>',
            a3: '<strong>GEAR BATTLE WON</strong><br>Pupi vs Thokk — Lionheart Blade<br><span class="salert-pts pos">+75 pts · "Duelist"</span>',
            a4: '<strong>VIEWER CHALLENGE</strong><br>xXhunterXx spent 5k pts — Zone Lock: Nagrand',
            m5Label: 'Live Penalty Execution — Gear Wipe',
            pRoll: 'Rolling for penalty item...',
            pSpin: 'Spinning...',
            notice: 'Viewer → game interactions require legal review against <strong>Blizzard addon policy</strong> and <strong>Twitch Extension guidelines</strong>.'
        },
        explore: {
            title: 'Explore More',
            ideas: {
                title: 'Ideas Lab',
                desc: 'Brainstorms, raw concepts, list of todos, monetization ideas, and future possibilities being shaped.'
            },
            profile: {
                title: 'Mock Profile',
                desc: 'Full streamer profile: armory, deathclips, achievements, death log.'
            },
            intro: {
                title: 'Explain WoW HC',
                desc: 'A dedicated page for new viewers explaining what World of Warcraft and Hardcore mode are all about.'
            }
        }
    },
    de: {
        nav: {
            modes: 'Modi',
            streamer: 'Streamer-Tools',
            ideas: 'Ideen-Labor',
            profile: 'Profil',
            explain: 'Erkläre WoW HC'
        },
        hero: {
            badge: 'Entwickelt für OnlyFangs 3',
            title1: 'Hardcore Neu Gedacht',
            title2: 'Für The Burning Crusade',
            subtitle: "TBC war nie für Hardcore ausgelegt. Wir ändern das. Wähle deinen Modus, bestimme die Regeln mit der Community und kämpfe um die Bestenliste.",
            btnModes: 'Modi entdecken',
            btnVote: 'Stimme abgeben',
            btnScore: 'Wertung ansehen'
        },
        modes: {
            label: 'Wähle deine Herausforderung',
            title: 'Vier Arten zu spielen',
            desc: 'Von klassischem Permadeath bis zu kompetitiven Ligen — wähle den Modus, der zu dir passt. Jeder bringt einzigartige Mechaniken.',
            classic: {
                name: 'Hardcore Classic',
                tagline: 'Das Original-Regelwerk. Ein Leben, ein Charakter. Der Tod ist endgültig und absolut.',
                p1: '<strong class="highlight-red">Permadeath</strong> — Charakter ist bei jedem Tod für immer verloren',
                p2: 'Volles SSF — keine Post, kein AH, kein Handel, keine Gruppen außer Dungeons',
                p3: 'Keine Boosts, keine Abkürzungen — jedes Mal Level 1 bis 70',
                p4: 'Nah an den offiziellen Classic HC-Regeln, angepasst für TBC'
            },
            plus: {
                name: 'Hardcore Plus',
                tagline: 'Permadeath mit Fortschritt. Erreiche Checkpoints, um Boosts freizuschalten.',
                p1: '<strong class="highlight-red">Permadeath</strong> — gleiche Endgültigkeit wie HC Classic',
                p2: '<strong class="highlight-purple">Checkpoint-Boost</strong>: Einmal Stufe 70 erreichen → schaltet <strong>Stufe-58-Boost</strong> für zukünftige Charaktere frei',
                p3: 'Accountweite <strong class="highlight-green">Wertung</strong> — verdiene Punkte für Quests, Meilensteine, Erfolge',
                p4: 'Bestenlisten und saisonale Rankings mit Titeln'
            },
            softcore: {
                name: 'Softcore',
                tagline: 'Du überlebst den Tod, verlierst aber alles Ausgerüstete. Baue dich aus der Bank wieder auf.',
                p1: 'Alle ausgerüsteten Gegenstände, Inventar und Gold werden beim Tod <strong class="highlight-orange">zerstört</strong>',
                p2: 'Bank und Twinks sind sicher — baue dich aus deinem Vorrat wieder auf',
                p3: 'Gildenhandel erlaubt — partielles SSF mit vertrauten Verbündeten',
                p4: 'Keine Charakterlöschung — der Tod ist teuer, aber nicht das Ende'
            },
            nullcore: {
                name: 'Nullcore-Liga',
                tagline: 'Kein Permadeath. Reiner punktbasierter Wettbewerb, bei dem jede Aktion Punkte bringt oder kostet.',
                p1: 'Tode <strong class="highlight-red">ziehen Punkte ab</strong> — Quests, Dungeons, Erfolge <strong class="highlight-green">bringen Punkte</strong>',
                p2: 'Saisonbasierter Wettbewerb mit zeitlich begrenzten Bestenlisten',
                p3: 'Rangtitel: Bronze → Silber → Gold → <strong class="highlight-gold">Gladiator</strong>',
                p4: 'Keine Handelseinschränkungen — spiele WoW normal, konkurriere nach Leistung'
            }
        },
        strip: {
            f1: 'Todesüberwachung',
            f2: 'Strafen-Engine',
            f3: 'Wertungssystem',
            f4: 'Gilden-Synchronisation',
            f5: 'SSF-Erzwingung',
            f6: 'Bestenlisten',
            link: 'Entdecke Features, Wertung & Ablauf →'
        },
        streamer: {
            label: 'Streamer & Zuschauer Integration',
            title: 'Hardcore als Zuschauersport',
            desc: 'Die Companion-App verknüpft Addon-Daten mit OBS-Overlays, Twitch-Chat und öffentlichen Profilen.',
            m1Label: 'Twitch-Stream — HC Addon Overlay',
            wTitle: 'Live-Tracker',
            wMode: 'Modus',
            wScore: 'Punkte',
            wDeaths: 'Tode',
            wRank: 'Rang',
            m2Label: 'Spielerprofil — Vorschau',
            p1Val: 'Vergeltungs-Paladin · HC Plus',
            btnProfile: 'Zum vollständigen Profil →',
            m3Label: 'Zuschauer-Strafen-Abstimmung (Twitch)',
            vEvent: '💀 PUPI IST GESTORBEN — Getötet vom Teufelshäscher',
            vQ: 'Der Chat entscheidet über die Strafe!',
            v1: '⚔️ Komplette Ausrüstung löschen',
            v2: '📉 Punkteabzug (−300)',
            v3: '🔒 Ausrüstungssperre 1 Std.',
            vTimer: '1.247 Stimmen | ⏱ 28s',
            m4Label: 'Stream-Ereignis-Benachrichtigungen',
            a1: '<strong>CHARAKTER VERNICHTET</strong><br>Zuzu (Priester) — Teufelshäscher, Höllenfeuerhalbinsel<br><span class="salert-pts neg">−300 Pkt.</span>',
            a2: '<strong>MEILENSTEIN</strong><br>Pupi hat Level 68 erreicht — Nagrand<br><span class="salert-pts pos">+100 Pkt. · Rang #3</span>',
            a3: '<strong>GEAR BATTLE GEWONNEN</strong><br>Pupi gegen Thokk — Löwenherzklinge<br><span class="salert-pts pos">+75 Pkt. · "Duellant"</span>',
            a4: '<strong>ZUSCHAUER-HERAUSFORDERUNG</strong><br>xXhunterXx hat 5k Pkt. ausgegeben — Zonen-Sperre: Nagrand',
            m5Label: 'Live-Strafen-Ausführung — Ausrüstung löschen',
            pRoll: 'Rolle um bestraften Gegenstand...',
            pSpin: 'Dreht sich...',
            notice: 'Zuschauer → Spiel-Interaktionen erfordern eine rechtliche Prüfung gemäß <strong>Blizzard Addon-Richtlinien</strong> und <strong>Twitch Extension-Richtlinien</strong>.'
        },
        explore: {
            title: 'Mehr entdecken',
            ideas: {
                title: 'Ideen-Labor',
                desc: 'Brainstorms, rohe Konzepte, To-Do-Listen, Monetarisierungsideen und zukünftige Möglichkeiten.'
            },
            profile: {
                title: 'Mock-Profil',
                desc: 'Vollständiges Streamer-Profil: Arsenal, Todesclips, Erfolge, Todesprotokoll.'
            },
            intro: {
                title: 'Erkläre WoW HC',
                desc: 'Eine spezielle Seite für neue Zuschauer, die erklärt, worum es bei World of Warcraft und dem Hardcore-Modus geht.'
            }
        }
    }
};

let currentLang = 'en';

function setLanguage(lang) {
    currentLang = lang;
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        const keys = key.split('.');
        let text = translations[lang];
        keys.forEach(k => {
            text = text[k];
        });

        if (text) {
            if (typeof text === 'string') {
                el.innerHTML = text;
            }
        }
    });

    document.getElementById('lang-en').classList.toggle('active', lang === 'en');
    document.getElementById('lang-de').classList.toggle('active', lang === 'de');

    // Set html lang attribute
    document.documentElement.lang = lang;
}

document.addEventListener('DOMContentLoaded', () => {
    const btnEn = document.getElementById('lang-en');
    const btnDe = document.getElementById('lang-de');

    if (btnEn) btnEn.addEventListener('click', () => setLanguage('en'));
    if (btnDe) btnDe.addEventListener('click', () => setLanguage('de'));

    // Default load
    setLanguage(currentLang);
});
