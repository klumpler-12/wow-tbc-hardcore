// Death Sequence (Battle Log) — v3: 2 lifes, looping
(function() {
  var section = document.getElementById('deathSequence');
  if (!section) return;
  var logBody = document.getElementById('dsLogBody');
  var overlay = document.getElementById('dsOverlay');
  var pips = section.querySelectorAll('.ds-pip');
  var livesLabel = section.querySelector('.ds-lives-label');

  // 2 death sequences: first death = revive, second death = permadeath
  var COMBAT_LOG = [
    { lines: [
      { time: '23:44:12', text: 'Prince Malchezaar begins casting Enfeeble' },
      { time: '23:44:14', text: 'Theron is Enfeebled (HP set to 1)' },
      { time: '23:44:14', text: 'Infernal lands \u2014 Theron takes <span class="ds-dmg">9,999</span> [Hellfire]' },
      { time: '23:44:14', text: '<span class="ds-death">Theron has died.</span> 1 life remaining \u2014 revived', die: true }
    ]},
    { lines: [
      { time: '23:52:30', text: 'Prince Malchezaar casts Shadow Word: Pain on Theron' },
      { time: '23:52:31', text: 'Theron takes <span class="ds-dmg">3,200</span> [Shadow Nova]' },
      { time: '23:52:32', text: 'Theron casts Holy Light (<span class="ds-heal">+2,800</span>)' },
      { time: '23:52:33', text: 'Infernal lands \u2014 Theron takes <span class="ds-dmg">8,420</span> [Hellfire] (CRUSHING)' },
      { time: '23:52:33', text: '<span class="ds-death">Theron has died.</span> 0 lifes remaining \u2014 PERMADEATH', die: true }
    ]}
  ];

  var currentLife = 2;
  var playing = false;

  function addEntry(html) {
    var el = document.createElement('div');
    el.className = 'ds-entry';
    el.innerHTML = html;
    logBody.appendChild(el);
    setTimeout(function() { el.classList.add('visible'); }, 30);
    logBody.scrollTop = logBody.scrollHeight;
  }

  function loseLife() {
    currentLife--;
    var pipIdx = 1 - currentLife;
    if (pips[pipIdx]) {
      pips[pipIdx].classList.remove('full');
      pips[pipIdx].classList.add('empty');
    }
    if (livesLabel) livesLabel.textContent = currentLife + ' / 2';
  }

  function resetState() {
    currentLife = 2;
    logBody.innerHTML = '';
    overlay.classList.remove('active');
    pips.forEach(function(p) { p.classList.remove('empty'); p.classList.add('full'); });
    if (livesLabel) livesLabel.textContent = '2 / 2';
  }

  function playSequence(seqIdx, startDelay) {
    var seq = COMBAT_LOG[seqIdx];
    seq.lines.forEach(function(line, li) {
      setTimeout(function() {
        addEntry('<span class="ds-time">[' + line.time + ']</span> ' + line.text);
        if (line.die) loseLife();
      }, startDelay + li * 500);
    });
  }

  function runFullAnimation() {
    if (playing) return;
    playing = true;
    resetState();

    // Death 1: one-shot, revive
    playSequence(0, 400);
    // Death 2: second attempt, permadeath
    playSequence(1, 3500);

    // Show death overlay after final death
    setTimeout(function() {
      overlay.classList.add('active');
    }, 7000);

    // Reset and allow replay after pause
    setTimeout(function() {
      playing = false;
    }, 10000);
  }

  var obs = new IntersectionObserver(function(entries) {
    if (entries[0].isIntersecting && !playing) {
      runFullAnimation();
    }
  }, { threshold: 0.1 });
  obs.observe(section);
})();
