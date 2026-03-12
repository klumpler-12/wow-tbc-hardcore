// Rule Manager UI
(function() {
  var manager = document.getElementById('ruleManager');
  var tagsContainer = document.getElementById('gcTags');
  if (!manager) return;

  // Customize button toggles the survey panel
  var customBtn = document.getElementById('rmCustomizeBtn');
  var customPanel = document.getElementById('rmCustomPanel');
  var baseDefault = document.getElementById('rmBaseDefault');
  if (customBtn && customPanel) {
    customBtn.addEventListener('click', function() {
      customPanel.style.display = customPanel.style.display === 'none' ? '' : 'none';
      customBtn.textContent = customPanel.style.display === 'none' ? '\u2699 Customize Rules' : '\u2715 Close Customization';
    });
  }

  // Tab switching
  var tabs = manager.querySelectorAll('.rm-tab');
  var panels = manager.querySelectorAll('.rm-panel');
  tabs.forEach(function(tab) {
    tab.addEventListener('click', function() {
      tabs.forEach(function(t) { t.classList.remove('active'); });
      panels.forEach(function(p) { p.classList.remove('active'); });
      tab.classList.add('active');
      var target = tab.getAttribute('data-rm');
      var panel = document.getElementById('rm' + target.charAt(0).toUpperCase() + target.slice(1));
      if (panel) panel.classList.add('active');
    });
  });

  // Survey — guided flow
  var QUESTIONS = [
    { q: 'Are you using base mode or custom rules?', help: 'Base mode uses unified defaults. Custom lets you define everything.', opts: [
      { text: 'Base Mode \u2014 unified defaults, free for all', tags: { 'Mode': 'base', 'HC Mode': true } },
      { text: 'Custom Rules \u2014 full configuration (Premium)', tags: { 'Mode': 'custom', 'HC Mode': true } }
    ]},
    { q: 'Leveling phase (1\u201360): what happens on death?', help: 'This defines the core leveling experience.', opts: [
      { text: 'Permadeath \u2014 die once, character is gone', tags: { 'Leveling': 'permadeath', '3 Lives': false } },
      { text: 'Multiple lives \u2014 lose a life per death', tags: { 'Leveling': 'lives', '3 Lives': true } },
      { text: 'Score only \u2014 deaths cost points, no deletion', tags: { 'Leveling': 'score', '3 Lives': false } }
    ]},
    { q: 'Instance lives: how many lives in dungeons and raids?', help: 'These protect against wipes inside instanced content.', opts: [
      { text: 'Same for all \u2014 unified life count everywhere', tags: { 'InstanceLives': 'unified' } },
      { text: 'Per-type \u2014 different lives for dungeons, heroics, raids', tags: { 'InstanceLives': 'per-type' } },
      { text: 'No instance lives \u2014 deaths count as normal', tags: { 'InstanceLives': 'none' } }
    ]},
    { q: 'Enable scoring and leaderboards?', opts: [
      { text: 'Full scoring + guild leaderboards', tags: { 'Scoring': true } },
      { text: 'Basic tracking only', tags: { 'Scoring': true } },
      { text: 'No scoring', tags: { 'Scoring': false } }
    ]},
    { q: 'Self-found restrictions?', opts: [
      { text: 'Full SSF \u2014 no trading, no AH', tags: { 'SSF': true } },
      { text: 'Guild trading only', tags: { 'SSF': true } },
      { text: 'No restrictions', tags: { 'SSF': false } }
    ]},
    { q: 'PvP in hardcore?', opts: [
      { text: 'PvP with scoring (BGs + Arena)', tags: { 'BGs': true } },
      { text: 'PvP exempt from HC rules', tags: { 'BGs': false } }
    ]},
    { q: 'House competition?', opts: [
      { text: 'Yes \u2014 draft into competing houses', tags: { 'Houses': true } },
      { text: 'No houses', tags: { 'Houses': false } }
    ]},
    { q: 'Checkpoint system?', opts: [
      { text: 'Yes \u2014 save at level milestones', tags: { 'Checkpoints': true } },
      { text: 'No checkpoints', tags: { 'Checkpoints': false } }
    ]}
  ];

  var answers = {};
  var currentQ = 0;
  var dotsContainer = document.getElementById('surveyDots');
  var cardsContainer = document.getElementById('surveyCards');
  var doneEl = document.getElementById('surveyDone');

  // Build dots
  QUESTIONS.forEach(function(_, i) {
    var dot = document.createElement('span');
    dot.className = 'survey-dot' + (i === 0 ? ' current' : '');
    dotsContainer.appendChild(dot);
  });

  // Build cards
  QUESTIONS.forEach(function(q, qi) {
    var card = document.createElement('div');
    card.className = 'survey-card' + (qi === 0 ? ' active' : '');
    var helpHtml = q.help ? '<div class="survey-help">' + q.help + '</div>' : '';
    card.innerHTML = '<div class="survey-q">' + q.q + '</div>' + helpHtml + '<div class="survey-options"></div>';
    var optsDiv = card.querySelector('.survey-options');
    q.opts.forEach(function(opt, oi) {
      var btn = document.createElement('div');
      btn.className = 'survey-option';
      btn.textContent = opt.text;
      btn.addEventListener('click', function() {
        optsDiv.querySelectorAll('.survey-option').forEach(function(o) { o.classList.remove('selected'); });
        btn.classList.add('selected');
        Object.keys(opt.tags).forEach(function(k) { answers[k] = opt.tags[k]; });
        updateConfigSummary();
        setTimeout(function() { advanceSurvey(); }, 400);
      });
      optsDiv.appendChild(btn);
    });
    cardsContainer.appendChild(card);
  });

  function advanceSurvey() {
    var dots = dotsContainer.querySelectorAll('.survey-dot');
    var cards = cardsContainer.querySelectorAll('.survey-card');
    dots[currentQ].classList.remove('current');
    dots[currentQ].classList.add('done');
    cards[currentQ].classList.remove('active');
    currentQ++;
    if (currentQ < QUESTIONS.length) {
      dots[currentQ].classList.add('current');
      cards[currentQ].classList.add('active');
    } else {
      doneEl.style.display = 'block';
      var restartBtn = document.getElementById('rmRestart');
      if (restartBtn) restartBtn.style.display = 'inline-block';
      syncGuildCard();
    }
  }

  // Config summary live update
  function updateConfigSummary() {
    var rows = document.getElementById('rmConfigRows');
    if (!rows) return;
    var cfgCells = rows.querySelectorAll('.rm-cfg-value');
    var map = [
      answers['Mode'] === 'base' ? 'Base Mode' : answers['Mode'] === 'custom' ? 'Custom (Premium)' : null,
      answers['Leveling'] === 'permadeath' ? 'Permadeath' : answers['Leveling'] === 'lives' ? 'Multiple Lives' : answers['Leveling'] === 'score' ? 'Score Only' : null,
      answers['InstanceLives'] === 'unified' ? 'Unified' : answers['InstanceLives'] === 'per-type' ? 'Per-Type' : answers['InstanceLives'] === 'none' ? 'None' : null,
      answers['Scoring'] === true ? 'Enabled' : answers['Scoring'] === false ? 'Disabled' : null,
      answers['SSF'] === true ? 'Enabled' : answers['SSF'] === false ? 'Off' : null,
      answers['BGs'] === true ? 'Enabled' : answers['BGs'] === false ? 'Disabled' : null,
      answers['Houses'] === true ? 'Enabled' : answers['Houses'] === false ? 'Disabled' : null,
      answers['Checkpoints'] === true ? 'Enabled' : answers['Checkpoints'] === false ? 'Off' : null
    ];
    map.forEach(function(val, i) {
      if (val && cfgCells[i]) {
        cfgCells[i].textContent = val;
        cfgCells[i].classList.remove('rm-cfg-pending');
        cfgCells[i].classList.toggle('rm-cfg-on', val !== 'Disabled' && val !== 'Off' && val !== 'None');
        cfgCells[i].classList.toggle('rm-cfg-off', val === 'Disabled' || val === 'Off' || val === 'None');
      }
    });
  }

  // Restart survey
  var restartBtn = document.getElementById('rmRestart');
  if (restartBtn) restartBtn.addEventListener('click', function() {
    answers = {};
    currentQ = 0;
    var dots = dotsContainer.querySelectorAll('.survey-dot');
    var cards = cardsContainer.querySelectorAll('.survey-card');
    dots.forEach(function(d) { d.className = 'survey-dot'; });
    cards.forEach(function(c) { c.classList.remove('active'); c.querySelectorAll('.survey-option').forEach(function(o) { o.classList.remove('selected'); }); });
    if (dots[0]) dots[0].classList.add('current');
    if (cards[0]) cards[0].classList.add('active');
    doneEl.style.display = 'none';
    restartBtn.style.display = 'none';
    var cfgCells = document.querySelectorAll('.rm-cfg-value');
    cfgCells.forEach(function(c) { c.textContent = '\u2014'; c.className = 'rm-cfg-value rm-cfg-pending'; });
    syncGuildCard();
  });

  // Guild Card sync
  function syncGuildCard() {
    if (!tagsContainer) return;
    var tags = tagsContainer.querySelectorAll('.gc-tag');
    tags.forEach(function(tag) {
      var key = tag.getAttribute('data-for');
      if (answers[key] !== undefined) {
        tag.classList.toggle('active', answers[key]);
      }
    });
  }

  syncGuildCard();
})();
