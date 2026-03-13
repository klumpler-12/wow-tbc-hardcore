/* ═══ Concept Timeline — Animated Level Progression ═══
   Bar: orange 1→58 (checkpoint), green 58→67, death (red), drop to 58, green 58→70 MAX.
   Sparks at checkpoint + max. Hearts loop after 60.
*/
(function() {
  'use strict';

  var timeline = document.getElementById('conceptTimeline');
  var bar = document.getElementById('ctBar');
  var h1 = document.getElementById('ctH1');
  var h2 = document.getElementById('ctH2');
  var marker58 = document.getElementById('ctMarker58');
  var label58 = document.getElementById('ctLabel58');
  var marker70 = document.getElementById('ctMarker70');
  var label70 = document.getElementById('ctLabel70');
  var marker1 = document.getElementById('ctMarker1');
  var label1 = document.getElementById('ctLabel1');
  var cpBox = document.getElementById('ctCheckpointBox');
  var multiLifeBox = document.getElementById('ctMultiLifeBox');
  var multiLifeText = document.getElementById('ctMultiLifeText');
  if (!timeline || !bar) return;

  var fill = bar.querySelector('.ct-fill-hc');
  var track = bar.querySelector('.ct-track');
  if (!fill || !track) return;

  // ── Slider ──
  var slider = document.createElement('div');
  slider.className = 'ct-slider';
  var sliderLvl = document.createElement('span');
  sliderLvl.className = 'ct-slider-lvl';
  sliderLvl.textContent = 'Lvl 1';
  slider.appendChild(sliderLvl);
  track.appendChild(slider);

  // ── MAX indicator ──
  var maxIndicator = document.createElement('div');
  maxIndicator.className = 'ct-max-indicator';
  maxIndicator.textContent = 'MAX!';
  maxIndicator.style.opacity = '0';
  bar.appendChild(maxIndicator);

  // ── Spark canvas ──
  var sparkCanvas = document.createElement('canvas');
  sparkCanvas.className = 'ct-spark-canvas';
  sparkCanvas.width = bar.offsetWidth || 600;
  sparkCanvas.height = 60;
  bar.appendChild(sparkCanvas);
  var sparkCtx = sparkCanvas.getContext('2d');
  var sparks = [];

  function spawnSparks(pctX, color, count) {
    var cx = (pctX / 100) * sparkCanvas.width;
    var cy = sparkCanvas.height / 2;
    for (var i = 0; i < (count || 12); i++) {
      var angle = Math.random() * Math.PI * 2;
      var speed = 1.5 + Math.random() * 3;
      sparks.push({
        x: cx, y: cy,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed - 1,
        life: 1,
        decay: 0.015 + Math.random() * 0.02,
        size: 1.5 + Math.random() * 2,
        color: color
      });
    }
    if (!sparkAnimRunning) animateSparks();
  }

  var sparkAnimRunning = false;
  function animateSparks() {
    sparkAnimRunning = true;
    sparkCtx.clearRect(0, 0, sparkCanvas.width, sparkCanvas.height);
    var alive = [];
    for (var i = 0; i < sparks.length; i++) {
      var s = sparks[i];
      s.x += s.vx;
      s.y += s.vy;
      s.vy += 0.06;
      s.life -= s.decay;
      if (s.life > 0) {
        sparkCtx.globalAlpha = s.life;
        sparkCtx.fillStyle = s.color;
        sparkCtx.shadowColor = s.color;
        sparkCtx.shadowBlur = 4;
        sparkCtx.beginPath();
        sparkCtx.arc(s.x, s.y, s.size * s.life, 0, Math.PI * 2);
        sparkCtx.fill();
        alive.push(s);
      }
    }
    sparkCtx.globalAlpha = 1;
    sparkCtx.shadowBlur = 0;
    sparks = alive;
    if (alive.length > 0) {
      requestAnimationFrame(animateSparks);
    } else {
      sparkAnimRunning = false;
    }
  }

  // ── Colors ──
  var COLOR_ORANGE = '#e8a624';
  var COLOR_GREEN = '#39ff14';
  var COLOR_RED = '#d44040';

  function setBarColor(color) {
    if (color === 'orange') {
      fill.style.background = 'linear-gradient(90deg, ' + COLOR_ORANGE + ', rgba(232,166,36,0.5))';
      fill.style.boxShadow = '0 0 8px rgba(232,166,36,0.4), 0 0 20px rgba(232,166,36,0.15)';
      slider.style.background = COLOR_ORANGE;
      slider.style.boxShadow = '0 0 10px rgba(232,166,36,0.5)';
      sliderLvl.style.color = COLOR_ORANGE;
    } else if (color === 'green') {
      fill.style.background = 'linear-gradient(90deg, ' + COLOR_GREEN + ', rgba(57,255,20,0.4))';
      fill.style.boxShadow = '0 0 8px rgba(57,255,20,0.3), 0 0 20px rgba(57,255,20,0.1)';
      slider.style.background = COLOR_GREEN;
      slider.style.boxShadow = '0 0 10px rgba(57,255,20,0.5)';
      sliderLvl.style.color = COLOR_GREEN;
    } else if (color === 'red') {
      fill.style.background = 'linear-gradient(90deg, ' + COLOR_RED + ', rgba(212,64,64,0.5))';
      fill.style.boxShadow = '0 0 12px rgba(212,64,64,0.5), 0 0 24px rgba(212,64,64,0.2)';
      slider.style.background = COLOR_RED;
      slider.style.boxShadow = '0 0 10px rgba(212,64,64,0.5)';
      sliderLvl.style.color = COLOR_RED;
    }
  }

  // Checkpoint is at 82.9% (level 58). Match exactly.
  var CP_LVL = 58;
  var CP_PCT = 82.9;
  function lvlToPercent(lvl) {
    if (lvl <= CP_LVL) {
      return (lvl - 1) / (CP_LVL - 1) * CP_PCT;
    }
    return CP_PCT + (lvl - CP_LVL) / (70 - CP_LVL) * (100 - CP_PCT);
  }

  function setLevel(lvl) {
    var pct = lvlToPercent(lvl);
    fill.style.width = pct + '%';
    slider.style.left = pct + '%';
    sliderLvl.textContent = 'Lvl ' + Math.round(lvl);
  }

  function animateTo(fromLvl, toLvl, duration, easeFn, onDone) {
    var startT = performance.now();
    function tick(now) {
      var t = Math.min((now - startT) / duration, 1);
      var e = easeFn ? easeFn(t) : t;
      setLevel(fromLvl + (toLvl - fromLvl) * e);
      if (t < 1) requestAnimationFrame(tick);
      else if (onDone) onDone();
    }
    requestAnimationFrame(tick);
  }

  function easeInOut(t) { return t < 0.5 ? 2*t*t : -1+(4-2*t)*t; }
  function easeOut(t) { return 1 - Math.pow(1-t, 3); }

  // ── Heart loop — simple generation-based approach ──
  var heartGen = 0; // increment to cancel all pending callbacks

  function resetHearts() {
    if (h1) { h1.innerHTML = '&#9829;'; h1.classList.remove('skull'); h1.style.opacity = '1'; }
    if (h2) { h2.innerHTML = '&#9829;'; h2.classList.remove('lost','skull'); h2.style.display = ''; h2.style.opacity = '1'; }
    if (multiLifeText) { multiLifeText.style.color = ''; multiLifeText.style.transition = 'color 0.4s ease'; }
  }

  function startHeartLoop() {
    heartGen++;
    var gen = heartGen;
    resetHearts();

    function cycle() {
      if (gen !== heartGen) return;
      // Start: 2 hearts visible
      resetHearts();

      // 1.5s: lose 1 heart (h2 fades out) → 1 heart
      setTimeout(function() {
        if (gen !== heartGen) return;
        if (h2) { h2.classList.add('lost'); h2.style.opacity = '0'; }
      }, 1500);

      // 3.0s: lose 2nd heart (h1 fades out) → 0 hearts
      setTimeout(function() {
        if (gen !== heartGen) return;
        if (h1) { h1.classList.add('lost'); h1.style.opacity = '0'; }
      }, 3000);

      // 4.0s: skull replaces hearts — text turns red
      setTimeout(function() {
        if (gen !== heartGen) return;
        if (h2) h2.style.display = 'none';
        if (h1) { h1.innerHTML = '&#128128;'; h1.classList.add('skull'); h1.style.opacity = '1'; }
        if (multiLifeText) multiLifeText.style.color = COLOR_RED;
      }, 4000);

      // 5.5s: pause then restart
      setTimeout(function() {
        if (gen !== heartGen) return;
        cycle();
      }, 5500);
    }
    cycle();
  }

  function stopHeartLoop() {
    heartGen++; // invalidates all pending callbacks
  }

  // ── Initial state ──
  function resetAll() {
    stopHeartLoop();
    resetHearts();
    fill.style.width = '0%';
    fill.style.left = '0';
    slider.style.left = '0%';
    slider.classList.remove('dead');
    fill.classList.remove('death-flash', 'max-reached');
    setBarColor('orange');
    if (multiLifeBox) multiLifeBox.style.opacity = '0';
    if (cpBox) cpBox.style.opacity = '0';
    if (marker58) marker58.classList.remove('highlight');
    if (cpBox) cpBox.classList.remove('highlight');
    if (label58) label58.style.opacity = '0';
    if (label70) label70.style.opacity = '0';
    if (marker1) marker1.style.display = 'none'; // slider replaces this
    maxIndicator.style.opacity = '0';
    sliderLvl.textContent = 'Lvl 1';
  }
  resetAll();

  // ── Main sequence (slower timings) ──
  var isRunning = false;

  function runSequence() {
    if (isRunning) return;
    isRunning = true;
    resetAll();
    sparkCanvas.width = bar.offsetWidth || 600;

    // 4s offset before animation starts
    setTimeout(function() {
      // Phase 1: 1→58 (5.6s — 40% slower than 4s)
      setBarColor('orange');
      animateTo(1, 58, 5600, easeInOut, function() {

        // Checkpoint reached
        if (label58) {
          label58.style.opacity = '1';
          label58.style.transition = 'opacity 0.4s ease';
          label58.style.top = '-20px';
          label58.style.bottom = 'auto';
          label58.style.marginLeft = '-8px';
        }
        if (cpBox) { cpBox.style.opacity = '1'; cpBox.style.transition = 'opacity 0.4s ease'; }
        if (marker58) marker58.classList.add('highlight');
        if (cpBox) cpBox.classList.add('highlight');
        spawnSparks(82.9, COLOR_ORANGE, 16);

        // Switch to green after brief pause (700ms — 40% slower)
        setTimeout(function() {
          setBarColor('green');

          // Phase 2: 58→60 (1.4s)
          animateTo(58, 60, 1400, easeOut, function() {
            if (multiLifeBox) { multiLifeBox.style.opacity = '1'; multiLifeBox.style.transition = 'opacity 0.5s ease'; }
            startHeartLoop();

            // 60→67 (2.8s)
            animateTo(60, 67, 2800, easeInOut, function() {

              // DEATH at 67
              setBarColor('red');
              slider.classList.add('dead');
              fill.classList.add('death-flash');

              setTimeout(function() {
                fill.classList.remove('death-flash');

                // Drop to 58 (1.4s)
                animateTo(67, 58, 1400, easeOut, function() {
                  slider.classList.remove('dead');
                  setBarColor('green');
                  if (marker58) marker58.classList.add('highlight');
                  if (cpBox) cpBox.classList.add('highlight');
                  spawnSparks(82.9, COLOR_GREEN, 10);

                  setTimeout(function() {
                    if (marker58) marker58.classList.remove('highlight');
                    if (cpBox) cpBox.classList.remove('highlight');

                    // Phase 4: 58→70 (4.2s)
                    animateTo(58, 70, 4200, easeInOut, function() {

                      if (label70) { label70.style.opacity = '1'; label70.style.transition = 'opacity 0.4s ease'; }
                      fill.classList.add('max-reached');
                      sliderLvl.textContent = '';
                      maxIndicator.style.opacity = '1';
                      maxIndicator.style.transition = 'opacity 0.5s ease';
                      spawnSparks(100, COLOR_GREEN, 24);

                      setTimeout(function() {
                        fill.classList.remove('max-reached');
                        stopHeartLoop();
                        isRunning = false;
                      }, 5000);
                    });
                  }, 1120);
                });
              }, 840);
            });
          });
        }, 700);
      });
    }, 4000);
  }

  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(e) {
      if (e.isIntersecting && !isRunning) runSequence();
    });
  }, { threshold: 0.5 });

  observer.observe(timeline);
})();
