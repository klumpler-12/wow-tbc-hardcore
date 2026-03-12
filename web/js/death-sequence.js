// Death Sequence (Battle Log)
(function() {
  var section = document.getElementById('deathSequence');
  if (!section) return;
  var logBody = document.getElementById('dsLogBody');
  var overlay = document.getElementById('dsOverlay');
  var pips = section.querySelectorAll('.ds-pip');
  var livesLabel = section.querySelector('.ds-lives-label');

  // 3 death sequences, each is a mini combat log
  var COMBAT_LOG = [
    // Death 1: Fel Reaver in Hellfire (2 sec fight)
    { lines: [
      { time: '14:32:05', text: 'Theron takes <span class="ds-dmg">2,841</span> from Fel Reaver [Stomp]' },
      { time: '14:32:06', text: 'Theron casts Flash of Light (<span class="ds-heal">+1,200</span>)' },
      { time: '14:32:07', text: 'Theron takes <span class="ds-dmg">8,420</span> from Fel Reaver [Melee] (CRUSHING)' },
      { time: '14:32:07', text: '<span class="ds-death">Theron has died.</span> Life lost (2 remaining)', die: true }
    ]},
    // Death 2: Shadow Labs bad pull (4 sec)
    { lines: [
      { time: '19:07:41', text: 'Theron takes <span class="ds-dmg">1,640</span> from Cabal Shadow Priest [Mind Flay]' },
      { time: '19:07:42', text: 'Theron casts Holy Light (<span class="ds-heal">+2,800</span>)' },
      { time: '19:07:43', text: 'Cabal Ritualist casts Fear \u2014 Theron flees into pack' },
      { time: '19:07:44', text: 'Theron takes <span class="ds-dmg">4,200</span> from 3 adds (extra pull)' },
      { time: '19:07:45', text: '<span class="ds-death">Theron has died.</span> Life lost (1 remaining)', die: true }
    ]},
    // Death 3: Prince Malchezaar (instant — Enfeeble + Infernal)
    { lines: [
      { time: '23:44:12', text: 'Prince Malchezaar begins casting Enfeeble' },
      { time: '23:44:14', text: 'Theron is Enfeebled (HP set to 1)' },
      { time: '23:44:15', text: 'Infernal lands \u2014 Theron takes <span class="ds-dmg">9,999</span> [Hellfire]' },
      { time: '23:44:15', text: '<span class="ds-death">Theron has died.</span> 0 lives remaining', die: true }
    ]}
  ];

  var currentLife = 3;
  var fired = false;

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
    pips[2 - currentLife].classList.remove('full');
    pips[2 - currentLife].classList.add('empty');
    if (livesLabel) livesLabel.textContent = currentLife + ' / 3';
  }

  function playSequence(seqIdx, startDelay) {
    var seq = COMBAT_LOG[seqIdx];
    seq.lines.forEach(function(line, li) {
      setTimeout(function() {
        addEntry('<span class="ds-time">[' + line.time + ']</span> ' + line.text);
        if (line.die) loseLife();
      }, startDelay + li * 700);
    });
  }

  var obs = new IntersectionObserver(function(entries) {
    if (entries[0].isIntersecting && !fired) {
      fired = true;
      obs.disconnect();

      // Play 3 death sequences with pauses between
      playSequence(0, 500);       // Death 1 starts at 0.5s
      playSequence(1, 4500);      // Death 2 starts at 4.5s
      playSequence(2, 9000);      // Death 3 starts at 9s

      // Show death overlay after final death
      setTimeout(function() {
        overlay.classList.add('active');
      }, 12500);
    }
  }, { threshold: 0.1 });
  obs.observe(section);
})();
