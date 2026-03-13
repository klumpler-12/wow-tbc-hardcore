/* ═══ Dark Portal Reveal — V2 Hero Animation ═══
   Full V2 animation: particles spiral in, TBC squeezes + green-shifts,
   bloom crossfade to HYBRID with elastic bounce, persistent pulse.
   All effects use radial falloff from center — no hard borders.
   Self-contained: delete this file + CSS + HTML refs to remove.
*/
(function() {
  'use strict';

  var tbcEl    = document.getElementById('morphTBC');
  var hybridEl = document.getElementById('morphHybrid');
  var canvas   = document.getElementById('heroPortalCanvas');
  var hero     = document.getElementById('hero');

  if (!tbcEl || !hybridEl || !canvas || !hero) return;

  // Setup canvas — fill entire hero, DPR-aware
  var dpr = window.devicePixelRatio || 1;
  function sizeCanvas() {
    var rect = hero.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    canvas.style.width = rect.width + 'px';
    canvas.style.height = rect.height + 'px';
  }
  sizeCanvas();
  var ctx = canvas.getContext('2d');
  ctx.scale(dpr, dpr);

  // Portal center = morph container center
  function getCenter() {
    var heroRect = hero.getBoundingClientRect();
    var morphRect = document.getElementById('heroMorph').getBoundingClientRect();
    return {
      x: morphRect.left + morphRect.width / 2 - heroRect.left,
      y: morphRect.top + morphRect.height / 2 - heroRect.top,
      pw: heroRect.width,
      ph: heroRect.height
    };
  }

  // Measure widths for TBC squeeze → HYBRID match
  var tbcW = tbcEl.getBoundingClientRect().width;
  var hybW = hybridEl.getBoundingClientRect().width;
  var HYB_START_SX = 0.65;
  var TBC_END_SX = Math.min((hybW * HYB_START_SX) / tbcW, 1.0);
  var TBC_END_SY = 0.98;

  // Create spiral wisps — more particles for larger canvas, spread wider
  var wisps = [];
  for (var i = 0; i < 100; i++) {
    var a = Math.random() * Math.PI * 2;
    var r = 40 + Math.random() * 160;
    wisps.push({
      angle: a, radius: r, baseRadius: r,
      speed: 1.2 + Math.random() * 2.0,
      size: 1.0 + Math.random() * 1.5,
      brightness: 0.3 + Math.random() * 0.7,
      spoutSpeed: 0.1 + Math.random() * 1.0,
      trail: [],
      _lastTime: 0
    });
  }

  // Timeline
  var STATIC_DUR = 2000;
  var BUILD_DUR  = 2400;
  var CROSS_DUR  = 1000;
  var FADE_DUR   = 1400;
  var totalDur = STATIC_DUR + BUILD_DUR + CROSS_DUR + FADE_DUR;
  var animStart = performance.now();
  var crossStarted = false;
  var pulseActive = false;

  function animate(now) {
    var elapsed = now - animStart;
    var t = Math.min(elapsed / totalDur, 1);
    var c = getCenter();
    var pw = c.pw, ph = c.ph, pcx = c.x, pcy = c.y;

    ctx.save();
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, pw, ph);

    // Bell-curve time warp
    var PARTICLE_EARLY = 1000;
    var rawPortalElapsed = Math.max(elapsed - STATIC_DUR, 0);
    var activeDur = BUILD_DUR + CROSS_DUR + FADE_DUR;
    var rawActiveT = Math.min(rawPortalElapsed / activeDur, 1);
    var bellT = (1 - Math.cos(rawActiveT * Math.PI)) / 2;
    var portalElapsed = bellT * activeDur;
    var particleElapsed = Math.max(elapsed - (STATIC_DUR - PARTICLE_EARLY), 0);
    var buildT = Math.min(portalElapsed / BUILD_DUR, 1);
    var intensity = buildT * buildT * buildT;
    var crossT = portalElapsed > BUILD_DUR ? Math.min((portalElapsed - BUILD_DUR) / CROSS_DUR, 1) : 0;
    var fadeT = portalElapsed > (BUILD_DUR + CROSS_DUR) ? Math.min((portalElapsed - BUILD_DUR - CROSS_DUR) / FADE_DUR, 1) : 0;
    var portalAlpha = fadeT > 0 ? (1 - fadeT) : intensity;

    // TBC effect timing
    var tbcEffectT = buildT > 0.5 ? (buildT - 0.5) / 0.5 : 0;
    var realBuildT = Math.min(rawPortalElapsed / BUILD_DUR, 1);
    var realTbcEffectT = realBuildT > 0.5 ? (realBuildT - 0.5) / 0.5 : 0;
    var effectElapsed = Math.max(portalElapsed - BUILD_DUR * 0.5, 0);
    var effectDur = BUILD_DUR * 0.5 + CROSS_DUR;
    var overallT = Math.min(effectElapsed / effectDur, 1);

    // --- TBC: scale, letter-spacing, skew, shake ---
    var easeIO = overallT * overallT * (3 - 2 * overallT);
    var tbcScaleX = 1.0 - (1.0 - TBC_END_SX) * easeIO;
    var tbcScaleY = 1.0 - (1.0 - TBC_END_SY) * easeIO;
    var letterSpacing = 0.12 - 0.26 * easeIO; // 0.12em → -0.14em
    var fadeCubic = fadeT > 0 ? (1 - fadeT) * (1 - fadeT) * (1 - fadeT) : 1;
    var shakeEnvelope = fadeT > 0 ? fadeCubic : Math.min(tbcEffectT * 2, 1);
    var shake = Math.sin(elapsed * 0.08) * 2.5 * shakeEnvelope;
    var distortEnvelope = Math.sin(overallT * Math.PI);
    var skewX = Math.sin(elapsed * 0.02) * 6 * distortEnvelope;
    var skewY = Math.cos(elapsed * 0.015) * 1.0 * distortEnvelope;

    if (tbcEffectT > 0 || crossT > 0 || fadeT > 0) {
      tbcEl.style.transformOrigin = '50% 50%';
      tbcEl.style.transform = 'translate(calc(-50% + ' + shake + 'px), -50%) scaleX(' + tbcScaleX.toFixed(3) + ') scaleY(' + tbcScaleY.toFixed(3) + ') skew(' + skewX.toFixed(2) + 'deg, ' + skewY.toFixed(2) + 'deg)';
      tbcEl.style.letterSpacing = letterSpacing.toFixed(4) + 'em';
    }

    // --- TBC: RADIAL green shift + glow + blur ---
    if (realTbcEffectT > 0) {
      var greenT = Math.min(realTbcEffectT * 1.5, 1);
      var greenEase = greenT * greenT * greenT;
      var cR = Math.round(255 - greenEase * 198);
      var cG = 255;
      var cB = Math.round(255 - greenEase * 235);
      var mR = Math.round(255 - greenEase * 75);
      var mB = Math.round(255 - greenEase * 85);
      var coreR = greenEase * 100;
      var edgeR = Math.min(coreR + 25, 100);
      tbcEl.style.background = 'radial-gradient(circle at 50% 50%, rgb(' + cR + ',' + cG + ',' + cB + ') ' + coreR + '%, rgb(' + mR + ',255,' + mB + ') ' + edgeR + '%, #fff 100%)';
      tbcEl.style.webkitBackgroundClip = 'text';
      tbcEl.style.webkitTextFillColor = 'transparent';
      tbcEl.style.backgroundClip = 'text';
      var glowSize = greenEase * 15;
      var glowAlpha = greenEase * 0.4;
      tbcEl.style.textShadow = '0 0 ' + glowSize + 'px rgba(57,255,20,' + glowAlpha + ')';
      var tbcBlur = greenEase * 1.5;
      tbcEl.style.filter = 'blur(' + tbcBlur + 'px) brightness(' + (1 + greenEase * 0.25) + ')';
    }

    // --- Crossfade: TBC out, HYBRID in ---
    if (crossT > 0 && !crossStarted) crossStarted = true;
    if (crossStarted) {
      var ease = crossT * crossT * (3 - 2 * crossT);
      var crossBlur = Math.sin(crossT * Math.PI) * 6;
      tbcEl.style.opacity = String(1 - ease);
      var tbcBlurCross = 1.5 + crossBlur + ease * 5;
      tbcEl.style.filter = 'blur(' + tbcBlurCross + 'px) brightness(' + (1 + ease * 0.8) + ')';
      tbcEl.style.textShadow = '0 0 ' + (10 + ease * 20) + 'px rgba(57,255,20,' + (0.35 + ease * 0.3) + ')';
      tbcEl.style.background = 'rgb(57,255,20)';
      tbcEl.style.webkitBackgroundClip = 'text';
      tbcEl.style.webkitTextFillColor = 'transparent';
      tbcEl.style.backgroundClip = 'text';
      var hybCore = ease * 70;
      var hybEdge = Math.min(hybCore + 20, 100);
      hybridEl.style.opacity = String(ease);
      hybridEl.style.background = 'radial-gradient(circle at 50% 50%, rgb(57,255,20) ' + hybCore + '%, rgb(70,240,40) ' + hybEdge + '%, rgb(57,255,20) 100%)';
      hybridEl.style.webkitBackgroundClip = 'text';
      hybridEl.style.webkitTextFillColor = 'transparent';
      hybridEl.style.backgroundClip = 'text';
      var hybBlur = (1 - ease) * 8;
      hybridEl.style.filter = 'blur(' + hybBlur + 'px)';
      hybridEl.style.textShadow = '0 0 ' + (16 * ease) + 'px rgba(57,255,20,' + (0.4 * ease) + ')';
    }

    // --- HYBRID: transition gradient to full green during fade ---
    if (fadeT > 0) {
      var fadeEase = fadeT * fadeT * (3 - 2 * fadeT);
      var hybCoreFade = 70 + fadeEase * 30;
      var hybEdgeFade = Math.min(hybCoreFade + 15, 100);
      var outerR = Math.round(70 - fadeEase * 13);
      var outerG = Math.round(240 - fadeEase * (240 - 255));
      var outerB = Math.round(40 - fadeEase * 20);
      hybridEl.style.background = 'radial-gradient(circle at 50% 50%, rgb(57,255,20) ' + hybCoreFade + '%, rgb(' + outerR + ',' + outerG + ',' + outerB + ') ' + hybEdgeFade + '%, rgb(57,255,20) 100%)';
      hybridEl.style.webkitBackgroundClip = 'text';
      hybridEl.style.webkitTextFillColor = 'transparent';
      hybridEl.style.backgroundClip = 'text';
      hybridEl.style.filter = 'brightness(' + (1 + (1 - fadeEase) * 0.25) + ')';
      var glowEnvelope = Math.sin(fadeT * Math.PI);
      var hybGlowFade = 30 * glowEnvelope;
      var hybGlowAlpha = 0.6 * glowEnvelope;
      hybridEl.style.textShadow = hybGlowFade > 0.1 ? '0 0 ' + hybGlowFade + 'px rgba(57,255,20,' + hybGlowAlpha + '), 0 0 ' + (hybGlowFade * 2.5) + 'px rgba(57,255,20,' + (hybGlowAlpha * 0.3) + ')' : 'none';
    }

    // --- HYBRID elastic stretch ---
    if (crossT > 0 || fadeT > 0) {
      var hybFadeCubic = fadeT > 0 ? (1 - fadeT) * (1 - fadeT) * (1 - fadeT) : 1;
      var hybEnvelope = fadeT > 0 ? hybFadeCubic : 1;
      var hybShake = Math.sin(elapsed * 0.07) * 1.8 * hybEnvelope;
      var stretchElapsed = Math.max(rawPortalElapsed - BUILD_DUR, 0);
      var stretchDur = CROSS_DUR + FADE_DUR;
      var sp = Math.min(stretchElapsed / stretchDur, 1);
      var elasticStretch = sp === 1 ? 1 : 1 - Math.pow(2, -8 * sp) * Math.cos(sp * Math.PI * 3.5);
      var hybSX = HYB_START_SX + (1.0 - HYB_START_SX) * elasticStretch;
      var hybSY = TBC_END_SY + (1.0 - TBC_END_SY) * elasticStretch;
      hybridEl.style.transform = 'translateX(' + hybShake + 'px) scaleX(' + hybSX.toFixed(4) + ') scaleY(' + hybSY.toFixed(4) + ')';
    }

    // --- Particles: radial center-to-border appearance, soft falloff ---
    if (particleElapsed > 0) {
      var particleFadeIn = portalElapsed > 0 ? 1 : Math.min(particleElapsed / PARTICLE_EARLY, 1);
      for (var i = 0; i < wisps.length; i++) {
        var w = wisps[i];
        var dt = (now - (w._lastTime || now)) / 1000;
        w._lastTime = now;

        // Radial appearance: particles closer to center appear first
        var radialNorm = (w.baseRadius - 40) / 160; // 0 = center, 1 = edge
        var radialDelay = radialNorm * radialNorm; // quadratic: center-first
        var radialAppear = Math.max((particleFadeIn - radialDelay) / (1 - radialDelay + 0.001), 0);
        radialAppear = Math.min(radialAppear * radialAppear, 1); // smooth in

        var suckT = portalElapsed > 0 ? intensity : 0;
        var speedMul = Math.max(0.3 + suckT * 3.0, 0.15 * radialAppear);
        w.angle += w.speed * dt * speedMul;

        var realSpoutElapsed = Math.max(rawPortalElapsed - BUILD_DUR, 0);
        var spoutDur = CROSS_DUR + FADE_DUR;
        var fullSpoutT = Math.min(realSpoutElapsed / spoutDur, 1.5);

        if (fullSpoutT > 0) {
          var burstEase = 1 - Math.pow(1 - Math.min(fullSpoutT, 1), 2);
          w.radius += w.spoutSpeed * (300 + burstEase * 500) * dt; // wider explosion for full-screen
        } else if (portalElapsed > 0) {
          w.radius = w.baseRadius * (1 - suckT * 0.85);
        }

        var sizeScale = fullSpoutT > 0 ? Math.max(0.8 - fullSpoutT * 0.5, 0.1) : (1 - suckT * 0.6);
        var curSize = w.size * Math.max(sizeScale, 0.1);

        var x = pcx + Math.cos(w.angle) * w.radius;
        var y = pcy + Math.sin(w.angle) * w.radius * 0.6;

        // Soft radial vignette — uses viewport fraction, smooth quadratic falloff
        var nx = (x - pcx) / (pw * 0.55);
        var ny = (y - pcy) / (ph * 0.55);
        var vigDist = nx * nx + ny * ny;
        var vig = vigDist < 1 ? (1 - vigDist) * (1 - vigDist) : 0; // quadratic: smooth to 0 at border

        // Spout: radial + exponential time fade
        var radialFade = 1;
        if (fullSpoutT > 0) {
          var dist = Math.sqrt((x - pcx) * (x - pcx) + (y - pcy) * (y - pcy));
          var radialDim = Math.max(1 - dist / (pw * 0.45), 0); // wider falloff for screen-filling
          var timeFade = Math.exp(-3 * fullSpoutT * fullSpoutT);
          radialFade = radialDim * timeFade;
        }

        w.trail.push({x: x, y: y});
        if (w.trail.length > 6) w.trail.shift();

        for (var j = 0; j < w.trail.length; j++) {
          var tp = w.trail[j];
          var pAlpha = (fullSpoutT > 0 ? portalAlpha : Math.max(portalAlpha, radialAppear * 0.4)) * radialFade;
          var trailAlpha = (j / w.trail.length) * 0.3 * w.brightness * pAlpha * vig;
          ctx.globalAlpha = trailAlpha;
          ctx.fillStyle = '#39ff14';
          ctx.beginPath();
          ctx.arc(tp.x, tp.y, curSize * 0.6, 0, Math.PI * 2);
          ctx.fill();
        }

        var wPAlpha = (fullSpoutT > 0 ? portalAlpha : Math.max(portalAlpha, radialAppear * 0.4)) * radialFade;
        var wAlpha = w.brightness * wPAlpha * vig;
        ctx.globalAlpha = wAlpha;
        ctx.fillStyle = '#39ff14';
        ctx.shadowColor = '#39ff14';
        ctx.shadowBlur = Math.max(10 * intensity, 5 * radialAppear);
        ctx.beginPath();
        ctx.arc(x, y, curSize, 0, Math.PI * 2);
        ctx.fill();
      }

      // Central glow — soft radial
      if (portalAlpha > 0.1) {
        var grad = ctx.createRadialGradient(pcx, pcy, 0, pcx, pcy, 60 * intensity);
        grad.addColorStop(0, 'rgba(57,255,20,' + (0.15 * portalAlpha) + ')');
        grad.addColorStop(0.5, 'rgba(57,255,20,' + (0.05 * portalAlpha) + ')');
        grad.addColorStop(1, 'transparent');
        ctx.globalAlpha = 1;
        ctx.shadowBlur = 0;
        ctx.fillStyle = grad;
        ctx.beginPath();
        ctx.arc(pcx, pcy, 60 * intensity, 0, Math.PI * 2);
        ctx.fill();
      }

      // Radial bloom during crossfade — soft, no hard edges
      if (crossT > 0 && fadeT < 1) {
        var bloomPeak = Math.sin(crossT * Math.PI);
        var bloomFade = fadeT > 0 ? (1 - fadeT) : 1;
        var bloomAlpha = bloomPeak * bloomFade;
        var bloomRadius = 50 + bloomPeak * 60;
        var bGrad = ctx.createRadialGradient(pcx, pcy, 0, pcx, pcy, bloomRadius);
        bGrad.addColorStop(0, 'rgba(57,255,20,' + (0.5 * bloomAlpha) + ')');
        bGrad.addColorStop(0.4, 'rgba(57,255,20,' + (0.15 * bloomAlpha) + ')');
        bGrad.addColorStop(1, 'transparent');
        ctx.globalAlpha = 1;
        ctx.shadowBlur = 0;
        ctx.fillStyle = bGrad;
        ctx.beginPath();
        ctx.arc(pcx, pcy, bloomRadius, 0, Math.PI * 2);
        ctx.fill();
      }
    }

    ctx.globalAlpha = 1;
    ctx.shadowBlur = 0;
    ctx.restore();

    if (t < 1) {
      requestAnimationFrame(animate);
    } else {
      // Done — set final state
      ctx.save();
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      ctx.clearRect(0, 0, pw, ph);
      ctx.restore();

      tbcEl.style.cssText = 'opacity:0; position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); font-size:0.45em; letter-spacing:0.12em; white-space:nowrap;';
      hybridEl.style.opacity = '1';
      hybridEl.style.transform = 'scaleX(1) scaleY(1)';
      hybridEl.style.filter = '';
      hybridEl.style.background = '';
      hybridEl.style.webkitBackgroundClip = '';
      hybridEl.style.webkitTextFillColor = '';
      hybridEl.style.backgroundClip = '';

      // Persistent pulsing glow
      pulseActive = true;
      var pulseStart = performance.now();
      function pulseLoop(now) {
        if (!pulseActive) return;
        var pt = (now - pulseStart) / 1000;
        var rawSin = Math.sin(pt * Math.PI * 0.25);
        var pulse = rawSin > 0 ? Math.pow(rawSin, 0.4) : 0;
        hybridEl.style.color = 'rgb(57,255,20)';
        hybridEl.style.background = '';
        hybridEl.style.webkitBackgroundClip = '';
        hybridEl.style.webkitTextFillColor = '';
        hybridEl.style.backgroundClip = '';
        var gs = 12 + pulse * 22;
        var ga = pulse * 0.65;
        hybridEl.style.textShadow = '0 0 ' + gs + 'px rgba(57,255,20,' + ga + '), 0 0 ' + (gs * 2.5) + 'px rgba(57,255,20,' + (ga * 0.3) + ')';
        hybridEl.style.filter = 'brightness(' + (1 + pulse * 0.25) + ')';
        requestAnimationFrame(pulseLoop);
      }
      requestAnimationFrame(pulseLoop);
    }
  }
  requestAnimationFrame(animate);

  // Resize handler
  window.addEventListener('resize', function() {
    sizeCanvas();
    ctx = canvas.getContext('2d');
    ctx.scale(dpr, dpr);
  });
})();
