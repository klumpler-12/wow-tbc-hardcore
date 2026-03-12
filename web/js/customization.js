// Checkpoint slider animation
(function() {
  var fill = document.getElementById('cpdFill');
  var marker = document.getElementById('cpdMarker');
  var label = document.getElementById('cpdLabel');
  if (!fill || !marker || !label) return;

  var steps = [
    { pct: 57.1, lvl: 40 },
    { pct: 71.4, lvl: 50 },
    { pct: 100,  lvl: 70 },
    { pct: 82.9, lvl: 58 }
  ];
  var idx = 0;
  var running = false;

  function animate() {
    if (!running) return;
    var s = steps[idx];
    fill.style.width = s.pct + '%';
    marker.style.left = s.pct + '%';
    label.style.left = s.pct + '%';
    label.textContent = 'Checkpoint: ' + s.lvl;
    idx = (idx + 1) % steps.length;
    setTimeout(function() { if (running) animate(); }, 1400);
  }

  var obs = new IntersectionObserver(function(entries) {
    entries.forEach(function(e) {
      if (e.isIntersecting && !running) {
        running = true;
        setTimeout(animate, 600);
      } else if (!e.isIntersecting) {
        running = false;
        fill.style.width = '82.9%';
        marker.style.left = '82.9%';
        label.style.left = '82.9%';
        label.textContent = 'Checkpoint: 58';
        idx = 0;
      }
    });
  }, { threshold: 0.1 });
  obs.observe(document.getElementById('cpdBar'));
})();

// Tag cycling highlight for customization
(function() {
  var tags = document.querySelectorAll('#customization .custom-tags .gc-tag');
  if (!tags.length) return;
  var hi = 0;
  function cycle() {
    tags.forEach(function(t) { t.style.transform = ''; });
    tags[hi].style.transform = 'scale(1.08)';
    hi = (hi + 1) % tags.length;
  }
  var obs = new IntersectionObserver(function(entries) {
    if (entries[0].isIntersecting) { cycle(); setInterval(cycle, 2000); obs.disconnect(); }
  }, { threshold: 0.1 });
  obs.observe(document.querySelector('#customization'));
})();
