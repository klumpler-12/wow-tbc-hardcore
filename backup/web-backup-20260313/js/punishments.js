// Punishment Manager — data-driven rendering + toggles + severity animation
(function() {
  var pm = document.getElementById('punishmentManager');
  if (!pm) return;

  // Render rows from HCData
  var table = document.getElementById('pmTable');
  var data = window.HCData && window.HCData.punishments || [];
  var CAT_LABELS = { death: '\u2620 Death', infraction: '\u26A0 Infraction', reward: '\u2733 Reward', custom: '\u270E Custom' };

  data.forEach(function(r) {
    var row = document.createElement('div');
    row.className = 'pm-row';
    row.setAttribute('data-cat', r.cat);
    var sevClass = r.reward ? 'pm-severity pm-sev-reward' : 'pm-severity';
    var barClass = r.reward ? 'pm-sev-bar reward' : 'pm-sev-bar';
    row.innerHTML =
      '<span class="pm-col pm-col-type"><span class="pm-cat-tag ' + r.cat + '">' + CAT_LABELS[r.cat] + '</span></span>' +
      '<span class="pm-col pm-col-name">' + r.name + '</span>' +
      '<span class="pm-col pm-col-severity"><div class="' + sevClass + '"><div class="' + barClass + '" style="width:' + r.severity + '%"></div></div><span class="pm-sev-label">' + r.label + '</span></span>' +
      '<span class="pm-col pm-col-action">' + r.action + '<span class="pm-action-tip">' + r.tip + '</span></span>' +
      '<span class="pm-col pm-col-toggle"><div class="toggle ' + (r.enabled ? 'on' : 'off') + '"></div></span>';
    table.appendChild(row);
  });

  // Toggle click handlers
  pm.querySelectorAll('.toggle').forEach(function(toggle) {
    toggle.style.cursor = 'pointer';
    toggle.addEventListener('click', function() {
      toggle.classList.toggle('on');
      toggle.classList.toggle('off');
    });
  });

  // Severity bar animation on scroll
  var bars = pm.querySelectorAll('.pm-sev-bar');
  var fired = false;
  var obs = new IntersectionObserver(function(entries) {
    if (entries[0].isIntersecting && !fired) {
      fired = true;
      obs.disconnect();
      bars.forEach(function(bar, i) {
        var w = bar.style.width;
        bar.style.width = '0%';
        setTimeout(function() {
          bar.style.transition = 'width 0.8s cubic-bezier(0.22, 0.61, 0.36, 1)';
          bar.style.width = w;
        }, i * 100);
      });
    }
  }, { threshold: 0.2 });
  obs.observe(pm);
})();
