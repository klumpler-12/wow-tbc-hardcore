// Shared utilities — DRY helpers used across modules
window.HCUtils = {

  // Generic tab switcher: container element, tab selector, panel selector, data-attribute name
  tabSwitcher: function(container, tabSel, panelSel, attr) {
    if (!container) return;
    var tabs = container.querySelectorAll(tabSel);
    var panels = container.querySelectorAll(panelSel);
    tabs.forEach(function(tab) {
      tab.addEventListener('click', function() {
        tabs.forEach(function(t) { t.classList.remove('active'); });
        panels.forEach(function(p) { p.classList.remove('active'); });
        tab.classList.add('active');
        var target = tab.getAttribute(attr);
        var panel = document.getElementById(target);
        if (panel) panel.classList.add('active');
      });
    });
  },

  // Count-up animation: element, start, end, suffix, duration ms
  countUp: function(el, from, to, suffix, duration) {
    suffix = suffix || '';
    duration = duration || 900;
    var steps = 30;
    var step = Math.ceil(Math.abs(to - from) / steps) || 1;
    var current = from;
    var interval = setInterval(function() {
      current += step;
      if (current >= to) {
        current = to;
        clearInterval(interval);
      }
      el.textContent = current.toLocaleString() + suffix;
    }, duration / steps);
  },

  // requestAnimationFrame throttle wrapper
  throttleRAF: function(fn) {
    var ticking = false;
    return function() {
      if (!ticking) {
        ticking = true;
        requestAnimationFrame(function() {
          fn();
          ticking = false;
        });
      }
    };
  },

  // Build N heart icons
  hearts: function(count) {
    var html = '<div class="il-hearts">';
    for (var i = 0; i < count; i++) html += '<span class="il-h full">\u2665</span>';
    html += '</div>';
    return html;
  }
};
