// Modular Architecture Demo
(function() {
  var container = document.getElementById('archPlugins');
  if (!container) return;
  var cards = container.querySelectorAll('.arch-plugin');
  var fired = false;

  var obs = new IntersectionObserver(function(entries) {
    if (entries[0].isIntersecting && !fired) {
      fired = true;
      obs.disconnect();
      cards.forEach(function(card, i) {
        card.style.opacity = '0';
        card.style.transform = 'translateY(16px)';
        setTimeout(function() {
          card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
          card.style.opacity = '1';
          card.style.transform = 'translateY(0)';
        }, i * 120);
      });

      // Simulate toggle clicks
      setInterval(function() {
        var toggles = container.querySelectorAll('.arch-toggle:not(.core)');
        if (!toggles.length) return;
        var idx = Math.floor(Math.random() * toggles.length);
        var t = toggles[idx];
        t.classList.toggle('on');
        var label = t.closest('.arch-plugin').querySelector('.arch-status');
        if (label) label.textContent = t.classList.contains('on') ? 'Active' : 'Inactive';
      }, 3500);
    }
  }, { threshold: 0.2 });
  obs.observe(container);
})();
