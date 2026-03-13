// Modular Architecture Demo — with IntersectionObserver pause/resume (no memory leak)
(function() {
  var container = document.getElementById('archPlugins');
  if (!container) return;
  var cards = container.querySelectorAll('.arch-plugin');
  var fired = false;
  var toggleInterval = null;

  var obs = new IntersectionObserver(function(entries) {
    if (entries[0].isIntersecting) {
      if (!fired) {
        fired = true;
        cards.forEach(function(card, i) {
          card.style.opacity = '0';
          card.style.transform = 'translateY(16px)';
          setTimeout(function() {
            card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
          }, i * 120);
        });
      }
      if (!toggleInterval) {
        toggleInterval = setInterval(function() {
          var toggles = container.querySelectorAll('.arch-toggle:not(.core)');
          if (!toggles.length) return;
          var idx = Math.floor(Math.random() * toggles.length);
          var t = toggles[idx];
          t.classList.toggle('on');
          var label = t.closest('.arch-plugin').querySelector('.arch-status');
          if (label) label.textContent = t.classList.contains('on') ? 'Active' : 'Inactive';
        }, 3500);
      }
    } else {
      if (toggleInterval) { clearInterval(toggleInterval); toggleInterval = null; }
    }
  }, { threshold: 0.2 });
  obs.observe(container);
})();
