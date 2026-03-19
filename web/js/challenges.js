// ═══ Challenge Modes, Flex Raiding, Fishing Frenzy ═══
// Renders data from HCData.challenges, HCData.flexRaiding, HCData.fishingFrenzy

(function () {
  'use strict';

  // ── Challenge Cards ──
  var grid = document.getElementById('challengesGrid');
  if (grid && HCData.challenges) {
    HCData.challenges.forEach(function (ch) {
      var card = document.createElement('div');
      card.className = 'concept-card fade-in';
      card.style.cssText = 'border-left:3px solid var(--purple)';

      var tiersHtml = ch.tiers.map(function (t) {
        return '<span style="display:inline-block;background:rgba(128,64,212,0.15);border:1px solid rgba(128,64,212,0.3);border-radius:4px;padding:2px 8px;font-size:0.72rem;margin:2px">'
          + t.name + ' (Lvl ' + t.level + ') <span style="color:var(--neon-green)">+' + t.pts + '</span></span>';
      }).join('');

      var chickenHtml = ch.chicken
        ? '<div style="margin-top:8px;font-size:0.75rem;color:var(--red)">&#128020; Chicken penalty: ' + ch.chickenPenalty + ' pts</div>'
        : '';

      card.innerHTML =
        '<div class="concept-tag" style="color:var(--purple)">' + ch.icon + ' Challenge</div>' +
        '<h3>' + ch.name + '</h3>' +
        '<p style="font-size:0.8rem;color:var(--text-dim);margin:8px 0">' + ch.desc + '</p>' +
        '<div style="margin:8px 0">' + tiersHtml + '</div>' +
        chickenHtml +
        '<div style="font-size:0.7rem;color:var(--text-dim);margin-top:6px;font-style:italic">' + ch.tip + '</div>';

      grid.appendChild(card);
    });
  }

  // ── Flex Raiding Table ──
  var flexBody = document.querySelector('#flexTable tbody');
  if (flexBody && HCData.flexRaiding) {
    HCData.flexRaiding.examples.forEach(function (ex) {
      var tr = document.createElement('tr');
      var bonusColor = ex.bonus > 0 ? 'var(--neon-green)' : 'var(--text-dim)';
      tr.innerHTML =
        '<td>' + ex.size + ' players</td>' +
        '<td style="color:' + bonusColor + '">+' + ex.bonus + '</td>' +
        '<td style="font-weight:700">' + ex.total + '</td>' +
        '<td style="font-size:0.8rem;color:var(--text-dim)">' + ex.label + '</td>';
      flexBody.appendChild(tr);
    });
  }

  // ── Flex Rules List ──
  var rulesList = document.getElementById('flexRulesList');
  if (rulesList && HCData.flexRaiding) {
    var allRules = HCData.flexRaiding.rules.slice();
    if (HCData.mixedGroupRules) {
      allRules.push(HCData.mixedGroupRules.instanceLives);
      allRules.push('Disconnect grace period: ' + (HCData.mixedGroupRules.disconnect.gracePeriod / 60) + ' minutes — ' + HCData.mixedGroupRules.disconnect.outcome);
    }
    allRules.forEach(function (rule) {
      var li = document.createElement('li');
      li.style.cssText = 'padding:6px 0;border-bottom:1px solid rgba(255,255,255,0.05);font-size:0.85rem;color:var(--text)';
      li.innerHTML = '<span style="color:var(--accent);margin-right:8px">&#9654;</span>' + rule;
      rulesList.appendChild(li);
    });
  }

  // ── Fishing Frenzy Rewards ──
  var frenzyBody = document.querySelector('#frenzyRewardsTable tbody');
  if (frenzyBody && HCData.fishingFrenzy) {
    HCData.fishingFrenzy.rewards.forEach(function (r) {
      var tr = document.createElement('tr');
      tr.innerHTML =
        '<td style="font-weight:700;color:var(--accent)">' + r.place + '</td>' +
        '<td style="font-size:0.85rem">' + r.reward + '</td>';
      frenzyBody.appendChild(tr);
    });
  }

})();
