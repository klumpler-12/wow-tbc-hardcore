// Rule Manager UI — v2 (reworked survey per review feedback)
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

  // Survey — guided flow (reworked)
  // Permadeath is FIXED — always on, shown as locked info, not a question
  // Scoring removed (experimental/future)
  // Houses removed (premium guild management, not a rule)
  var QUESTIONS = [
    { q: 'Instance lifes: which rule set?', help: 'Lifes protect against one-shot wipes in dungeons and raids.', opts: [
      { text: 'Base rules \u2014 \u2665\u2665 easy, \u2665\u2665\u2665 hard (default)', tags: { 'InstanceLives': 'base' } },
      { text: 'Custom life rules \u2014 define your own values', badge: 'Premium', tags: { 'InstanceLives': 'custom' } }
    ]},
    { q: 'Self-found mode?', help: 'Restricts trading. SSF/Guildfound chars are eligible for soft reset on permadeath.', opts: [
      { text: 'SSF \u2014 no trading, no auction house', tags: { 'SelfFound': 'ssf' } },
      { text: 'Guildfound \u2014 guild trading only', tags: { 'SelfFound': 'gf' } },
      { text: 'No restriction \u2014 checkpoints by official boosting only, no soft reset', tags: { 'SelfFound': 'none' } }
    ]},
    { q: 'Play style?', help: 'Defines your group setup. Group composition is locked after first XP is gained.', opts: [
      { text: 'Solo player', tags: { 'PlayStyle': 'solo' } },
      { text: 'Group \u2014 define members at char creation (locked after first XP)', tags: { 'PlayStyle': 'group' } },
      { text: 'Guild \u2014 requires Premium for management tools', badge: 'Premium', link: '#houses', tags: { 'PlayStyle': 'guild' } }
    ]},
    { q: 'PvP rules?', help: 'Player Enforced PvP (PEP) is an experimental future feature.', opts: [
      { text: 'PvP with HC rules (BGs + Arena count)', tags: { 'PvP': 'hc' } },
      { text: 'PvP exempt from HC rules', tags: { 'PvP': 'exempt' } }
    ]},
    { q: 'Checkpoint system?', help: 'Reaching the checkpoint level unlocks the ability to restart via official boost.', opts: [
      { text: 'Yes \u2014 checkpoint at level 58 (default)', tags: { 'Checkpoints': true } },
      { text: 'No checkpoints \u2014 permadeath is final', tags: { 'Checkpoints': false } }
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
    q.opts.forEach(function(opt) {
      var btn = document.createElement('div');
      var isDefault = opt.text.indexOf('(default)') !== -1;
      btn.className = 'survey-option' + (isDefault ? ' survey-option-default' : '');
      var label = opt.text;
      if (opt.badge) label += ' <span class="survey-badge survey-badge-' + opt.badge.toLowerCase() + '">' + opt.badge + '</span>';
      btn.innerHTML = label;
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
    // Order must match HTML rows: Permadeath, Instance Lifes, Self-Found, Play Style, PvP, Checkpoints, Scoring, Houses
    var map = [
      'Permadeath (fixed)',
      answers['InstanceLives'] === 'base' ? 'Base Rules' : answers['InstanceLives'] === 'custom' ? 'Custom (Premium)' : null,
      answers['SelfFound'] === 'ssf' ? 'SSF' : answers['SelfFound'] === 'gf' ? 'Guildfound' : answers['SelfFound'] === 'none' ? 'No Restriction' : null,
      answers['PlayStyle'] === 'solo' ? 'Solo' : answers['PlayStyle'] === 'group' ? 'Group' : answers['PlayStyle'] === 'guild' ? 'Guild (Premium)' : null,
      answers['PvP'] === 'hc' ? 'HC Rules' : answers['PvP'] === 'exempt' ? 'Exempt' : null,
      answers['Checkpoints'] === true ? 'Level 58' : answers['Checkpoints'] === false ? 'Off' : null,
      'Experimental',
      'Premium'
    ];
    map.forEach(function(val, i) {
      if (val && cfgCells[i]) {
        cfgCells[i].textContent = val;
        cfgCells[i].classList.remove('rm-cfg-pending');
        var isOff = val === 'Off' || val === 'No Restriction' || val === 'Exempt';
        var isExp = val === 'Experimental' || val === 'Premium';
        cfgCells[i].classList.toggle('rm-cfg-on', !isOff && !isExp);
        cfgCells[i].classList.toggle('rm-cfg-off', isOff);
        cfgCells[i].classList.toggle('rm-cfg-dim', isExp);
      }
    });
  }

  // Set fixed values on load
  updateConfigSummary();

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
    updateConfigSummary(); // re-apply fixed values
    syncGuildCard();
  });

  // Guild Card sync
  function syncGuildCard() {
    if (!tagsContainer) return;
    var tags = tagsContainer.querySelectorAll('.gc-tag');
    tags.forEach(function(tag) {
      var key = tag.getAttribute('data-for');
      if (answers[key] !== undefined) {
        tag.classList.toggle('active', !!answers[key]);
      }
    });
  }

  syncGuildCard();
})();
