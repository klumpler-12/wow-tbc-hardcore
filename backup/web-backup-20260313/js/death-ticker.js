// Death Ticker
(function() {
  var track = document.getElementById('tickerTrack');
  if (!track) return;
  var DEATHS = [
    { name: 'Zuzu (Priest, 62)', cause: 'Killed by Fel Reaver \u00B7 Hellfire Peninsula \u00B7 Alliance', guild: 'Iron Wolves', pts: '\u2212300' },
    { name: 'Hexmaw (Warlock, 44)', cause: 'Drowning \u00B7 Zangarmarsh \u00B7 Horde', guild: '', pts: '\u2212180' },
    { name: 'Thokk (Warrior, 68)', cause: 'Killed by Shattered Hand Legionnaire \u00B7 Shattered Halls \u00B7 Horde', guild: 'Warbringers', pts: '\u2212450' },
    { name: 'Lightbane (Paladin, 70)', cause: 'Killed by Prince Malchezaar \u00B7 Karazhan \u00B7 Alliance', guild: 'Iron Wolves', pts: '\u2212600' },
    { name: 'Frostleaf (Mage, 64)', cause: 'Falling \u00B7 Blade\'s Edge Mountains \u00B7 Alliance', guild: '', pts: '\u2212120' },
    { name: 'Grimjaw (Rogue, 70)', cause: 'Killed by Murmur \u00B7 Shadow Labyrinth \u00B7 Horde', guild: 'Deathwish', pts: '\u2212340' },
    { name: 'Moonwhisper (Druid, 58)', cause: 'Killed by Bog Giant \u00B7 Zangarmarsh \u00B7 Alliance', guild: 'Silver Dawn', pts: '\u2212260' },
    { name: 'Darkshot (Hunter, 70)', cause: 'Killed by Nightbane \u00B7 Karazhan \u00B7 Horde', guild: '', pts: '\u2212550' },
    { name: 'Soulrender (Warlock, 39)', cause: 'Fire/Lava \u00B7 Searing Gorge \u00B7 Horde', guild: 'Warbringers', pts: '\u2212150' },
    { name: 'Ironvow (Warrior, 70)', cause: 'Killed by Gruul the Dragonkiller \u00B7 Gruul\'s Lair \u00B7 Alliance', guild: 'Iron Wolves', pts: '\u2212520' },
  ];
  var html = DEATHS.map(function(d) {
    var guildTag = d.guild ? ' <span style="color:var(--text-dim)">&lt;' + d.guild + '&gt;</span>' : '';
    return '<div class="ticker-item"><span class="skull">\u{1F480}</span> <span>' + d.name + '</span>' + guildTag + ' <span style="color:var(--text-dim)">\u2014 ' + d.cause + '</span> <span class="pts">' + d.pts + ' pts</span></div>';
  }).join('');
  track.innerHTML = html + html;
})();
