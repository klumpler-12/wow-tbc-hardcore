// Scoring Tree
(function() {
  var panel = document.getElementById('stPanel');
  var countEl = document.getElementById('stCount');
  var leafOpts = document.getElementById('stLeafOpts');
  if (!panel) return;

  var activeTab = 0;
  var selectedLeaf = null;

  var TREE = [
    { label: 'Character Progression', children: [
      { label: 'Leveling', optType: 'level', children: [
        { label: 'Lvl 58 (Outland)', on: true }, { label: 'Lvl 60', on: true },
        { label: 'Lvl 65', on: true }, { label: 'Lvl 70 (Max)', on: true }
      ]},
      { label: 'Professions', optType: 'maxable', children: [
        { label: 'Alchemy', on: true }, { label: 'Blacksmithing', on: true },
        { label: 'Enchanting', on: true }, { label: 'Engineering', on: false },
        { label: 'Herbalism', on: true }, { label: 'Jewelcrafting', on: true },
        { label: 'Leatherworking', on: false }, { label: 'Mining', on: true },
        { label: 'Skinning', on: false }, { label: 'Tailoring', on: true },
        { label: 'Cooking', on: true }, { label: 'First Aid', on: true }, { label: 'Fishing', on: true },
        { label: 'Skill Milestones (75/150/225/300/375)', on: true }
      ]},
      { label: 'Reputation', optType: 'maxable', children: [
        { label: 'Honor Hold / Thrallmar', on: true }, { label: 'Cenarion Expedition', on: true },
        { label: 'Lower City', on: true }, { label: "Sha'tar", on: true },
        { label: 'Aldor / Scryers', on: true }, { label: 'Keepers of Time', on: true },
        { label: 'Violet Eye', on: true }, { label: 'Consortium', on: false },
        { label: 'Netherwing', on: false }, { label: "Ogri'la", on: false },
        { label: 'Sporeggar', on: false }, { label: 'Skyguard', on: false }
      ]},
      { label: 'Gear Thresholds', optType: 'level', children: [
        { label: 'Green (Uncommon)', on: false }, { label: 'Blue (Rare)', on: true },
        { label: 'Purple (Epic)', on: true }, { label: 'Orange (Legendary)', on: true }
      ]}
    ]},
    { label: 'PvE Content', children: [
      { label: 'Dungeons', optType: 'clearable', children: [
        { label: 'Normal Clears', on: true }, { label: 'Heroic Clears', on: true },
        { label: 'Timed Runs', on: false },
        { label: 'Hellfire Ramparts', on: true }, { label: 'Blood Furnace', on: true },
        { label: 'Shattered Halls', on: true }, { label: 'Slave Pens', on: true },
        { label: 'Underbog', on: true }, { label: 'Steamvault', on: true },
        { label: 'Mana-Tombs', on: true }, { label: 'Auchenai Crypts', on: true },
        { label: 'Sethekk Halls', on: true }, { label: 'Shadow Labyrinth', on: true },
        { label: 'Mechanar', on: true }, { label: 'Botanica', on: true },
        { label: 'Arcatraz', on: true }, { label: 'Old Hillsbrad', on: true },
        { label: 'Black Morass', on: true }, { label: "Magister's Terrace", on: true }
      ]},
      { label: 'Raids', optType: 'clearable', children: [
        { label: 'Boss Kills', on: true }, { label: 'Full Clears', on: true }, { label: 'Speed Clears', on: false },
        { label: 'Karazhan (10-man)', on: true }, { label: "Gruul's Lair", on: true },
        { label: "Magtheridon's Lair", on: true }, { label: 'Serpentshrine Cavern', on: true },
        { label: 'The Eye', on: true }, { label: 'Hyjal Summit', on: true },
        { label: 'Black Temple', on: true }, { label: 'Sunwell Plateau', on: true }
      ]},
      { label: 'World Content', optType: 'level', children: [
        { label: 'Elite Kills', on: true }, { label: 'Rare Spawns', on: true },
        { label: 'World Bosses (Kazzak, Doomwalker)', on: true }
      ]}
    ]},
    { label: 'PvP Content', children: [
      { label: 'Battlegrounds', optType: 'level', children: [
        { label: 'BG Wins', on: false }, { label: 'Flag Captures', on: false }, { label: 'Killing Blows', on: false }
      ]},
      { label: 'Arena', optType: 'level', children: [
        { label: 'Rating Thresholds', on: false }, { label: 'Win Streaks', on: false }
      ]},
      { label: 'World PvP', optType: 'level', children: [
        { label: 'Zone Objectives', on: false }, { label: 'Honorable Kills', on: false }
      ]}
    ]},
    { label: 'Guild Achievements', children: [
      { label: 'Public Achievements', badge: 'public', optType: 'pts', children: [
        { label: 'First maxxed Fishing in guild', on: true, pts: '+250' },
        { label: 'First Karazhan full clear', on: true, pts: '+1000' },
        { label: 'Guild-wide 0 deaths in a week', on: true, pts: '+500' }
      ]},
      { label: 'Hidden Achievements', badge: 'hidden', optType: 'pts', children: [
        { label: 'Sit in every chair in Shattrath', on: true, pts: '+75', hidden: true },
        { label: 'Die to Fel Reaver 3 times', on: true, pts: '-200', hidden: true },
        { label: 'Complete a dungeon naked', on: false, pts: '+300', hidden: true }
      ]}
    ]},
    { label: 'Penalties', children: [
      { label: 'Death Penalties', optType: 'penalty', children: [
        { label: 'Life Lost', on: true }, { label: 'Score Deduction', on: true }
      ]},
      { label: 'Infraction Penalties', optType: 'penalty', children: [
        { label: 'Rule Violation', on: true }, { label: 'Unauthorized Trade', on: true }
      ]},
      { label: 'Custom Penalties (GM)', optType: 'penalty', children: [
        { label: 'Custom Penalty', on: true }
      ]}
    ]}
  ];

  function countLeaves(nodes) {
    var t = 0, e = 0;
    (function walk(arr) {
      arr.forEach(function(n) {
        if (n.children) walk(n.children);
        else { t++; if (n.on) e++; }
      });
    })(nodes);
    return { total: t, enabled: e };
  }

  function updateCount() {
    var c = countLeaves(TREE);
    if (countEl) countEl.textContent = c.enabled + '/' + c.total + ' enabled';
  }

  function getState(node) {
    if (!node.children) return node.on ? 'on' : 'off';
    var onCount = 0, total = 0;
    (function walk(ch) {
      ch.forEach(function(c) {
        if (c.children) walk(c.children);
        else { total++; if (c.on) onCount++; }
      });
    })(node.children);
    if (onCount === total) return 'on';
    if (onCount === 0) return 'off';
    return 'mixed';
  }

  function setAll(node, val) {
    if (!node.children) { node.on = val; return; }
    node.children.forEach(function(c) { setAll(c, val); });
  }

  function renderPanel() {
    panel.innerHTML = '';
    hideLeafOpts();
    var cat = TREE[activeTab];
    if (!cat || !cat.children) return;

    var branchRow = document.createElement('div');
    branchRow.className = 'st-branch-row';

    cat.children.forEach(function(branch, bi) {
      var card = document.createElement('div');
      card.className = 'st-branch-card';

      var hdr = document.createElement('div');
      hdr.className = 'st-branch-hdr';
      var state = getState(branch);
      var toggle = document.createElement('span');
      toggle.className = 'st-check ' + state;
      toggle.addEventListener('click', function(e) {
        e.stopPropagation();
        var newVal = getState(branch) !== 'on';
        setAll(branch, newVal);
        renderPanel();
        updateCount();
      });
      hdr.appendChild(toggle);
      var lbl = document.createElement('span');
      lbl.className = 'st-branch-label';
      lbl.textContent = branch.label;
      hdr.appendChild(lbl);
      if (branch.badge) {
        var bdg = document.createElement('span');
        bdg.className = 'st-badge ' + branch.badge;
        bdg.textContent = branch.badge === 'hidden' ? '\uD83D\uDD12 Hidden' : branch.badge === 'public' ? '\u2605 Public' : branch.badge;
        hdr.appendChild(bdg);
      }
      var bc = countLeaves([branch]);
      var cnt = document.createElement('span');
      cnt.className = 'st-branch-count';
      cnt.textContent = bc.enabled + '/' + bc.total;
      hdr.appendChild(cnt);
      card.appendChild(hdr);

      var items = branch.children || [];
      var list = document.createElement('div');
      list.className = 'st-leaf-list';
      items.forEach(function(leaf) {
        if (leaf.children) {
          leaf.children.forEach(function(sub) {
            list.appendChild(buildLeafRow(sub, branch.optType || ''));
          });
        } else {
          list.appendChild(buildLeafRow(leaf, branch.optType || ''));
        }
      });
      card.appendChild(list);
      branchRow.appendChild(card);
    });

    panel.appendChild(branchRow);
  }

  function buildLeafRow(leaf, optType) {
    var row = document.createElement('div');
    row.className = 'st-leaf-row' + (leaf.on ? '' : ' off');

    var check = document.createElement('span');
    check.className = 'st-check ' + (leaf.on ? 'on' : '');
    check.addEventListener('click', function(e) {
      e.stopPropagation();
      leaf.on = !leaf.on;
      renderPanel();
      updateCount();
    });
    row.appendChild(check);

    var name = document.createElement('span');
    name.className = 'st-leaf-name';
    name.textContent = leaf.label;
    row.appendChild(name);

    if (leaf.pts) {
      var pts = document.createElement('span');
      pts.className = 'st-badge';
      pts.style.color = leaf.pts.charAt(0) === '+' ? 'var(--neon-green)' : 'var(--red)';
      pts.textContent = leaf.pts;
      row.appendChild(pts);
    }
    if (leaf.hidden) {
      var hid = document.createElement('span');
      hid.className = 'st-badge hidden';
      hid.textContent = '\uD83D\uDD12';
      row.appendChild(hid);
    }

    if (optType !== 'penalty' && optType !== 'level') {
      row.style.cursor = 'pointer';
      row.addEventListener('click', function(e) {
        e.stopPropagation();
        showLeafOpts(leaf, optType, row);
      });
    }

    return row;
  }

  function showLeafOpts(leaf, optType, anchorRow) {
    if (selectedLeaf === leaf) { hideLeafOpts(); return; }
    selectedLeaf = leaf;
    var loName = document.getElementById('stLoName');
    var loMaxFirst = document.getElementById('stLoMaxFirst');
    var loMaxGen = document.getElementById('stLoMaxGen');
    var loCustom = document.getElementById('stLoCustom');
    if (loName) loName.textContent = leaf.label;

    if (loMaxFirst) loMaxFirst.style.display = (optType === 'maxable') ? 'flex' : 'none';
    if (loMaxGen) loMaxGen.style.display = (optType === 'maxable') ? 'flex' : 'none';
    if (loCustom) loCustom.style.display = (optType === 'maxable' || optType === 'clearable') ? 'flex' : 'none';

    leafOpts.style.display = 'block';
    anchorRow.parentNode.insertBefore(leafOpts, anchorRow.nextSibling);
  }

  function hideLeafOpts() {
    selectedLeaf = null;
    if (leafOpts) leafOpts.style.display = 'none';
  }

  var loClose = document.getElementById('stLoClose');
  if (loClose) loClose.addEventListener('click', hideLeafOpts);

  var tabs = document.querySelectorAll('#stTabs .st-tab');
  tabs.forEach(function(tab) {
    tab.addEventListener('click', function() {
      tabs.forEach(function(t) { t.classList.remove('active'); });
      tab.classList.add('active');
      activeTab = parseInt(tab.getAttribute('data-cat'));
      renderPanel();
    });
  });

  renderPanel();
  updateCount();

  // Add achievement button
  var addBtn = document.getElementById('stAddAch');
  var addForm = document.getElementById('stAddForm');
  var achConfirm = document.getElementById('stAchConfirm');
  if (addBtn && addForm) {
    addBtn.addEventListener('click', function() {
      addForm.style.display = addForm.style.display === 'none' ? 'flex' : 'none';
    });
  }
  if (achConfirm) {
    achConfirm.addEventListener('click', function() {
      var name = document.getElementById('stAchName').value.trim();
      var pts = document.getElementById('stAchPts').value || '100';
      var hidden = document.getElementById('stAchHidden').checked;
      if (!name) return;
      var targetBranch = hidden ? TREE[3].children[1] : TREE[3].children[0];
      targetBranch.children.push({
        label: name, on: true, pts: (parseInt(pts) >= 0 ? '+' : '') + pts,
        hidden: hidden
      });
      document.getElementById('stAchName').value = '';
      document.getElementById('stAchPts').value = '100';
      document.getElementById('stAchHidden').checked = false;
      addForm.style.display = 'none';
      activeTab = 3;
      tabs.forEach(function(t) { t.classList.remove('active'); });
      tabs[3].classList.add('active');
      renderPanel();
      updateCount();
    });
  }
})();
