// Punishment Manager Toggles
(function() {
  var pm = document.getElementById('punishmentManager');
  if (!pm) return;
  var toggles = pm.querySelectorAll('.toggle');
  toggles.forEach(function(toggle) {
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
