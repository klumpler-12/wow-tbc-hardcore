// Data-driven renderers + Intersection observer for scroll-triggered animations
(function() {
  var D = window.HCData || {};

  // Render achievements from data
  var achGrid = document.getElementById('achievementGrid');
  if (achGrid && D.achievements) {
    D.achievements.forEach(function(a) {
      var div = document.createElement('div');
      div.className = 'achievement ach-' + a.quality;
      div.innerHTML = '<span class="achievement-pts">' + a.pts + '</span>' +
        '<span class="achievement-name">' + a.name + '</span>';
      achGrid.appendChild(div);
    });
  }

  // Render project phases from data (collapsible with sub-items)
  var phasesRow = document.getElementById('phasesRow');
  if (phasesRow && D.phases) {
    D.phases.forEach(function(p) {
      var div = document.createElement('div');
      var hasSubs = p.subs && p.subs.length > 0;
      div.className = 'phase-box' + (p.active ? ' active' : '') + (p.future ? ' future' : '') + (hasSubs ? ' has-subs expanded' : '');
      var label = p.phase ? 'Phase ' + p.phase : 'Future';
      var subsHtml = '';
      if (hasSubs) {
        // Check if subs are objects with heading+items (Alpha) or simple strings
        var firstSub = p.subs[0];
        if (typeof firstSub === 'object' && firstSub.heading) {
          subsHtml = '<div class="phase-subs-detailed">';
          p.subs.forEach(function(group) {
            subsHtml += '<div class="phase-group">';
            subsHtml += '<div class="phase-group-heading">' + group.heading + '</div>';
            subsHtml += '<ul class="phase-subs">';
            group.items.forEach(function(item) { subsHtml += '<li>' + item + '</li>'; });
            subsHtml += '</ul></div>';
          });
          subsHtml += '</div>';
        } else {
          subsHtml = '<ul class="phase-subs">';
          p.subs.forEach(function(s) { subsHtml += '<li>' + s + '</li>'; });
          subsHtml += '</ul>';
        }
      }
      var toggleIcon = hasSubs ? '<span class="phase-toggle">\u25BC</span>' : '';
      div.innerHTML = '<div class="phase-label">' + label + toggleIcon + '</div>' +
        '<div class="phase-title">' + p.title + '</div>' +
        '<div class="phase-desc">' + p.desc + '</div>' + subsHtml;
      if (hasSubs) {
        div.addEventListener('click', function(e) {
          // Don't toggle when clicking links inside
          if (e.target.tagName === 'A') return;
          // Already expanded — keep it open (always one expanded)
          if (div.classList.contains('expanded')) return;
          // Collapse all others
          var all = phasesRow.querySelectorAll('.phase-box.expanded');
          for (var j = 0; j < all.length; j++) all[j].classList.remove('expanded');
          div.classList.add('expanded');
        });
      }
      phasesRow.appendChild(div);
    });
  }

  // Scroll-triggered fade-in observer
  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, { threshold: 0 });

  document.querySelectorAll('.fade-in, .reveal-up, .house-card, .achievement, .mockup-frame').forEach(function(el) {
    observer.observe(el);
  });
})();
