// House Scores Count-Up + Toggle + Resolve
(function() {
  var container = document.getElementById('housesVisual');
  if (!container) return;
  var scoreEls = container.querySelectorAll('.house-score');
  var cards = container.querySelectorAll('.house-card');
  var fired = false;
  var currentMode = 'weekly';
  var flashInterval = null;

  function countUp(el, from, to) {
    var current = from || 0;
    var step = Math.ceil(Math.abs(to - current) / 30) || 1;
    var interval = setInterval(function() {
      current += step;
      if (current >= to) {
        current = to;
        clearInterval(interval);
      }
      el.textContent = current.toLocaleString() + ' pts';
    }, 30);
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
      if (flashInterval) clearInterval(flashInterval);
      var leftCards = container.querySelectorAll('.houses-team-left .house-card');
      var rightCards = container.querySelectorAll('.houses-team-right .house-card');
      var leftTotal = 0, rightTotal = 0;
      leftCards.forEach(function(c) { leftTotal += parseInt(c.querySelector('.house-score').getAttribute('data-target')) || 0; });
      rightCards.forEach(function(c) { rightTotal += parseInt(c.querySelector('.house-score').getAttribute('data-target')) || 0; });

      var winnerText, loserText;
      var leftWins = leftTotal >= rightTotal;
      if (leftWins) {
        winnerText = 'Winner: Team Alpha (+' + leftTotal.toLocaleString() + ' pts)';
        loserText = 'Team Omega: +' + rightTotal.toLocaleString() + ' pts';
      } else {
        winnerText = 'Winner: Team Omega (+' + rightTotal.toLocaleString() + ' pts)';
        loserText = 'Team Alpha: +' + leftTotal.toLocaleString() + ' pts';
      }

      container.classList.add('resolved');
      var leftTeam = container.querySelector('.houses-team-left');
      var rightTeam = container.querySelector('.houses-team-right');
      if (leftWins) {
        leftTeam.classList.add('winner');
        rightTeam.classList.add('loser');
        leftTeam.classList.remove('loser');
        rightTeam.classList.remove('winner');
      } else {
        rightTeam.classList.add('winner');
        leftTeam.classList.add('loser');
        rightTeam.classList.remove('loser');
        leftTeam.classList.remove('winner');
      }

      var result = document.getElementById('housesResult');
      var hrText = document.getElementById('hrText');
      var hrLoser = document.getElementById('hrLoser');
      if (hrText) hrText.textContent = winnerText;
      if (hrLoser) hrLoser.textContent = loserText;
      if (result) {
        result.classList.add('show');
      }
    });
  }

  // IntersectionObserver — initial count-up
  var obs = new IntersectionObserver(function(entries) {
    if (entries[0].isIntersecting && !fired) {
      fired = true;
      obs.disconnect();
      setScores(currentMode);

      // Add periodic flash events
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

        // Update score
        var scoreEl = card.querySelector('.house-score');
        var curTarget = parseInt(scoreEl.getAttribute('data-target')) || 0;
        var newTarget = curTarget + parseInt(bonus);
        scoreEl.setAttribute('data-target', newTarget);
        card.setAttribute('data-' + currentMode, newTarget);
        scoreEl.textContent = newTarget.toLocaleString() + ' pts';
        highlightLeading();
      }, 3000);
    }
  }, { threshold: 0.2 });
  obs.observe(container);
})();
