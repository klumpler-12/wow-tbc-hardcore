// House Scores — data-driven rendering + count-up + toggle + resolve
(function() {
  var container = document.getElementById('housesVisual');
  if (!container) return;

  // Render house cards from HCData
  var leftTeam = container.querySelector('.houses-team-left');
  var rightTeam = container.querySelector('.houses-team-right');
  var houseData = window.HCData && window.HCData.houses || [];
  houseData.forEach(function(h) {
    var card = document.createElement('div');
    card.className = 'house-card';
    card.setAttribute('data-weekly', h.weekly);
    card.setAttribute('data-total', h.total);
    card.innerHTML = '<div class="house-name">' + h.name + '</div>' +
      '<div class="house-score" data-target="' + h.weekly + '">0 pts</div>' +
      '<div class="house-detail">Leader: ' + h.leader + ' \u2022 ' + h.detail + '</div>';
    if (h.fraction === 'left') leftTeam.appendChild(card);
    else rightTeam.appendChild(card);
  });

  var cards = container.querySelectorAll('.house-card');
  var fired = false;
  var currentMode = 'weekly';
  var flashInterval = null;

  function countUp(el, from, to) {
    HCUtils.countUp(el, from, to, ' pts');
  }

  function setScores(mode) {
    currentMode = mode;
    cards.forEach(function(card) {
      var target = parseInt(card.getAttribute('data-' + mode)) || 0;
      var scoreEl = card.querySelector('.house-score');
      scoreEl.setAttribute('data-target', target);
      countUp(scoreEl, 0, target);
    });
    highlightLeading();
  }

  function highlightLeading() {
    var allScores = container.querySelectorAll('.house-score');
    var maxScore = 0;
    allScores.forEach(function(s) {
      var v = parseInt(s.getAttribute('data-target')) || 0;
      if (v > maxScore) maxScore = v;
    });
    allScores.forEach(function(s) {
      var v = parseInt(s.getAttribute('data-target')) || 0;
      s.closest('.house-card').classList.toggle('leading', v === maxScore);
    });
  }

  // Toggle buttons
  var toggleBtns = document.querySelectorAll('#housesToggle .ht-btn');
  toggleBtns.forEach(function(btn) {
    btn.addEventListener('click', function() {
      toggleBtns.forEach(function(b) { b.classList.remove('active'); });
      btn.classList.add('active');
      var mode = btn.getAttribute('data-mode');
      setScores(mode);
      var cd = document.getElementById('housesCountdown');
      if (cd) cd.style.display = mode === 'weekly' ? 'flex' : 'none';
      var result = document.getElementById('housesResult');
      if (result) result.classList.remove('show');
      container.classList.remove('resolved');
      container.querySelector('.houses-team-left').classList.remove('winner', 'loser');
      container.querySelector('.houses-team-right').classList.remove('winner', 'loser');
    });
  });

  // Resolve Week button
  var resolveBtn = document.getElementById('hcResolve');
  if (resolveBtn) {
    resolveBtn.addEventListener('click', function() {
      if (flashInterval) { clearInterval(flashInterval); flashInterval = null; }
      var leftCards = container.querySelectorAll('.houses-team-left .house-card');
      var rightCards = container.querySelectorAll('.houses-team-right .house-card');
      var leftTotal = 0, rightTotal = 0;
      leftCards.forEach(function(c) { leftTotal += parseInt(c.querySelector('.house-score').getAttribute('data-target')) || 0; });
      rightCards.forEach(function(c) { rightTotal += parseInt(c.querySelector('.house-score').getAttribute('data-target')) || 0; });

      var winnerText, loserText;
      var leftWins = leftTotal >= rightTotal;
      if (leftWins) {
        winnerText = 'Winner: Fraction Alpha (+' + leftTotal.toLocaleString() + ' pts)';
        loserText = 'Fraction Omega: +' + rightTotal.toLocaleString() + ' pts';
      } else {
        winnerText = 'Winner: Fraction Omega (+' + rightTotal.toLocaleString() + ' pts)';
        loserText = 'Fraction Alpha: +' + leftTotal.toLocaleString() + ' pts';
      }

      container.classList.add('resolved');
      var lt = container.querySelector('.houses-team-left');
      var rt = container.querySelector('.houses-team-right');
      if (leftWins) { lt.classList.add('winner'); rt.classList.add('loser'); lt.classList.remove('loser'); rt.classList.remove('winner'); }
      else { rt.classList.add('winner'); lt.classList.add('loser'); rt.classList.remove('loser'); lt.classList.remove('winner'); }

      var result = document.getElementById('housesResult');
      if (document.getElementById('hrText')) document.getElementById('hrText').textContent = winnerText;
      if (document.getElementById('hrLoser')) document.getElementById('hrLoser').textContent = loserText;
      if (result) result.classList.add('show');
    });
  }

  // IntersectionObserver — pause/resume flash interval (fixes memory leak)
  var obs = new IntersectionObserver(function(entries) {
    if (entries[0].isIntersecting) {
      if (!fired) { fired = true; setScores(currentMode); }
      if (!flashInterval) startFlash();
    } else {
      if (flashInterval) { clearInterval(flashInterval); flashInterval = null; }
    }
  }, { threshold: 0.2 });
  obs.observe(container);

  function startFlash() {
    flashInterval = setInterval(function() {
      if (container.classList.contains('resolved')) return;
      var allCards = container.querySelectorAll('.house-card');
      var idx = Math.floor(Math.random() * allCards.length);
      var card = allCards[idx];
      var bonus = ['+50', '+25', '+100', '+75'][Math.floor(Math.random() * 4)];
      var flash = document.createElement('span');
      flash.className = 'score-flash';
      flash.textContent = bonus + ' pts';
      card.appendChild(flash);
      setTimeout(function() { flash.classList.add('visible'); }, 30);
      setTimeout(function() {
        flash.classList.add('fade-out');
        setTimeout(function() { flash.remove(); }, 500);
      }, 1500);

      var scoreEl = card.querySelector('.house-score');
      var curTarget = parseInt(scoreEl.getAttribute('data-target')) || 0;
      var newTarget = curTarget + parseInt(bonus);
      scoreEl.setAttribute('data-target', newTarget);
      card.setAttribute('data-' + currentMode, newTarget);
      scoreEl.textContent = newTarget.toLocaleString() + ' pts';
      highlightLeading();
    }, 3000);
  }
})();
