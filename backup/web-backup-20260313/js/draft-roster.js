// Draft System + Guild Roster
(function() {
  var CLASS_COLORS = {
    paladin: '#f58cba', priest: '#ffffff', rogue: '#fff569',
    druid: '#ff7d0a', warlock: '#9482c9', mage: '#69ccf0',
    hunter: '#abd473', warrior: '#c79c6e', shaman: '#0070de'
  };

  var PLAYERS = [
    { name: 'Pupi', cls: 'priest', lvl: 70, rating: 3, div: null },
    { name: 'Grimjaw', cls: 'rogue', lvl: 68, rating: 2, div: null },
    { name: 'Moonwhisper', cls: 'druid', lvl: 70, rating: 3, div: null },
    { name: 'Hexmaw', cls: 'warlock', lvl: 65, rating: 1, div: null },
    { name: 'Frostleaf', cls: 'mage', lvl: 70, rating: 3, div: null },
    { name: 'Korrak', cls: 'warrior', lvl: 70, rating: 2, div: null },
    { name: 'Senna', cls: 'hunter', lvl: 69, rating: 2, div: null },
    { name: 'Mirael', cls: 'shaman', lvl: 70, rating: 1, div: null },
  ];

  // Build player pool as list
  var poolGrid = document.getElementById('draftPoolGrid');
  var poolCount = document.getElementById('draftPoolCount');
  function renderPool() {
    if (!poolGrid) return;
    poolGrid.innerHTML = '';
    PLAYERS.forEach(function(p, i) {
      var el = document.createElement('div');
      el.className = 'draft-player' + (p.div ? ' drafted' : '');
      el.setAttribute('data-idx', i);
      var stars = '';
      for (var s = 0; s < p.rating; s++) stars += '\u2605';
      for (var s2 = p.rating; s2 < 3; s2++) stars += '\u2606';
      el.innerHTML = '<span class="dp-name" style="color:' + CLASS_COLORS[p.cls] + '">' + p.name + '</span><span class="dp-class">' + p.cls + '</span><span class="dp-lvl">' + p.lvl + '</span><span class="dp-stars">' + stars + '</span>';
      poolGrid.appendChild(el);
    });
  }
  renderPool();

  // Sort button
  var sortBtn = document.getElementById('draftSortBtn');
  if (sortBtn) {
    sortBtn.addEventListener('click', function() {
      PLAYERS.sort(function(a, b) { return b.rating - a.rating; });
      renderPool();
    });
  }

  // Draft auto-animation on scroll (no click needed)
  var divAlphaSlots = document.getElementById('divAlphaSlots');
  var divOmegaSlots = document.getElementById('divOmegaSlots');
  var draftSystem = document.getElementById('draftSystem');
  var draftFired = false;

  function runDraftAnimation() {
    if (draftFired) return;
    draftFired = true;
    var sorted = PLAYERS.slice().sort(function(a, b) { return b.rating - a.rating; });
    var alphaCount = 0, omegaCount = 0;
    sorted.forEach(function(p, i) {
      var toAlpha = (i % 2 === 0);
      var origIdx = PLAYERS.indexOf(p);
      setTimeout(function() {
        var poolEl = poolGrid.querySelector('[data-idx="' + origIdx + '"]');
        if (poolEl) poolEl.classList.add('drafted');
        var slot = document.createElement('div');
        slot.className = 'draft-slot ' + (toAlpha ? 'alpha' : 'omega');
        slot.textContent = p.name + ' \u2605'.repeat(p.rating);
        if (toAlpha) {
          divAlphaSlots.appendChild(slot);
          alphaCount++;
          divAlphaSlots.closest('.draft-division').querySelector('.draft-div-count').textContent = alphaCount + ' / 62';
        } else {
          divOmegaSlots.appendChild(slot);
          omegaCount++;
          divOmegaSlots.closest('.draft-division').querySelector('.draft-div-count').textContent = omegaCount + ' / 62';
        }
        setTimeout(function() { slot.classList.add('visible'); }, 50);
        var remaining = PLAYERS.length - (i + 1);
        if (poolCount) poolCount.textContent = remaining + ' available';
      }, i * 500);
    });
  }

  if (draftSystem) {
    var draftObs = new IntersectionObserver(function(entries) {
      if (entries[0].isIntersecting && !draftFired) {
        draftObs.disconnect();
        setTimeout(runDraftAnimation, 600);
      }
    }, { threshold: 0.1 });
    draftObs.observe(draftSystem);
  }

  // Guild roster with custom notes
  var tbody = document.getElementById('rosterBody');
  if (!tbody) return;

  var ROSTER = [
    { name: 'Theron', cls: 'paladin', lvl: 70, note: 'Team Alpha \u00B7 House Ironforge \u00B7 \u2605\u2605\u2605', score: '12,450', lives: 3, status: 'Alive', achievements: 84, heroics: 12, deaths: 0, joined: 'Season 1, Week 1' },
    { name: 'Pupi', cls: 'priest', lvl: 70, note: 'Team Alpha \u00B7 House Dawnblade \u00B7 \u2605\u2605\u2605', score: '9,870', lives: 2, status: 'Alive', achievements: 61, heroics: 8, deaths: 1, joined: 'Season 1, Week 1' },
    { name: 'Grimjaw', cls: 'rogue', lvl: 68, note: 'Team Omega \u00B7 House Ironforge \u00B7 \u2605\u2605', score: '7,230', lives: 3, status: 'Alive', achievements: 44, heroics: 3, deaths: 0, joined: 'Season 1, Week 2' },
    { name: 'Moonwhisper', cls: 'druid', lvl: 70, note: 'Team Alpha \u00B7 House Ashwind \u00B7 \u2605\u2605\u2605', score: '8,540', lives: 1, status: '1 life remaining', achievements: 52, heroics: 6, deaths: 2, joined: 'Season 1, Week 1' },
    { name: 'Vex', cls: 'hunter', lvl: 69, note: 'Team Omega \u00B7 House Stormgarde \u00B7 \u2605\u2605', score: '6,800', lives: 3, status: 'Alive', achievements: 38, heroics: 2, deaths: 0, joined: 'Season 1, Week 3' },
    { name: 'Frostleaf', cls: 'mage', lvl: 70, note: 'Team Omega \u00B7 House Thornwall \u00B7 \u2605\u2605\u2605', score: '10,100', lives: 2, status: 'Alive', achievements: 67, heroics: 9, deaths: 1, joined: 'Season 1, Week 1' },
    { name: 'Korrak', cls: 'warrior', lvl: 70, note: 'Team Alpha \u00B7 House Ashwind \u00B7 \u2605\u2605', score: '11,200', lives: 0, status: 'DEAD', achievements: 71, heroics: 11, deaths: 3, joined: 'Season 1, Week 1' },
    { name: 'Hexmaw', cls: 'warlock', lvl: 65, note: 'Team Omega \u00B7 \u2605', score: '5,120', lives: 3, status: 'Alive', achievements: 29, heroics: 0, deaths: 0, joined: 'Season 1, Week 4' },
  ];

  // Add detail panel under the table
  var detailPanel = document.createElement('div');
  detailPanel.className = 'roster-detail';
  detailPanel.id = 'rosterDetail';
  detailPanel.style.display = 'none';
  detailPanel.innerHTML = '<div class="rd-header"><span class="rd-name" id="rdName"></span><span class="rd-close" id="rdClose">\u00D7</span></div><div class="rd-body" id="rdBody"></div>';
  var guildBody = document.querySelector('#guildWindow .ingame-body');
  if (guildBody) guildBody.appendChild(detailPanel);

  ROSTER.forEach(function(m, idx) {
    var tr = document.createElement('tr');
    tr.className = 'roster-row-clickable';
    tr.setAttribute('data-ridx', idx);
    var pips = '';
    for (var i = 0; i < 3; i++) {
      pips += '<span class="life-pip ' + (i < m.lives ? 'alive' : 'dead') + '"></span>';
    }
    tr.innerHTML = '<td style="color:' + CLASS_COLORS[m.cls] + '">' + m.name + '</td><td>' + m.lvl + '</td><td style="font-size:0.65rem;color:var(--text-dim)">' + m.note + '</td><td>' + m.score + '</td><td class="lives-cell">' + pips + '</td>';
    tr.style.opacity = '0';
    tr.style.transform = 'translateY(10px)';
    tr.style.cursor = 'pointer';
    tr.addEventListener('click', function() {
      showPlayerDetail(idx);
    });
    tbody.appendChild(tr);
  });

  function showPlayerDetail(idx) {
    var m = ROSTER[idx];
    var panel = document.getElementById('rosterDetail');
    var nameEl = document.getElementById('rdName');
    var bodyEl = document.getElementById('rdBody');
    nameEl.innerHTML = '<span style="color:' + CLASS_COLORS[m.cls] + '">' + m.name + '</span> <span style="color:var(--text-dim);font-size:0.7rem">' + m.cls.charAt(0).toUpperCase() + m.cls.slice(1) + ' \u00B7 Lvl ' + m.lvl + '</span>';
    var statusColor = m.status === 'DEAD' ? '#ff4444' : m.lives <= 1 ? '#ffaa00' : 'var(--neon-green)';
    bodyEl.innerHTML = '<div class="rd-stats">' +
      '<div class="rd-stat"><span class="rd-stat-val" style="color:' + statusColor + '">' + m.status + '</span><span class="rd-stat-lbl">Status</span></div>' +
      '<div class="rd-stat"><span class="rd-stat-val">' + m.score + '</span><span class="rd-stat-lbl">Score</span></div>' +
      '<div class="rd-stat"><span class="rd-stat-val">' + m.achievements + '</span><span class="rd-stat-lbl">Achievements</span></div>' +
      '<div class="rd-stat"><span class="rd-stat-val">' + m.heroics + '</span><span class="rd-stat-lbl">Heroics</span></div>' +
      '<div class="rd-stat"><span class="rd-stat-val">' + m.deaths + '</span><span class="rd-stat-lbl">Deaths</span></div>' +
      '<div class="rd-stat"><span class="rd-stat-val" style="font-size:0.65rem">' + m.joined + '</span><span class="rd-stat-lbl">Joined</span></div>' +
      '</div>';
    panel.style.display = 'block';
    // Highlight row
    tbody.querySelectorAll('tr').forEach(function(r) { r.classList.remove('roster-row-active'); });
    tbody.querySelector('[data-ridx="' + idx + '"]').classList.add('roster-row-active');
  }

  var rdClose = document.getElementById('rdClose');
  if (rdClose) rdClose.addEventListener('click', function() {
    document.getElementById('rosterDetail').style.display = 'none';
    tbody.querySelectorAll('tr').forEach(function(r) { r.classList.remove('roster-row-active'); });
  });

  var fired = false;
  var obs = new IntersectionObserver(function(entries) {
    if (entries[0].isIntersecting && !fired) {
      fired = true;
      obs.disconnect();
      var rows = tbody.querySelectorAll('tr');
      rows.forEach(function(row, i) {
        setTimeout(function() {
          row.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
          row.style.opacity = '1';
          row.style.transform = 'translateY(0)';
        }, i * 120);
      });
    }
  }, { threshold: 0.2 });
  obs.observe(document.getElementById('guildWindow') || tbody);
})();
