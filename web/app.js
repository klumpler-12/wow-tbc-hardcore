/* ============================================
   WoW TBC Hardcore — Interactive Concept Site
   ============================================ */

document.addEventListener('DOMContentLoaded', () => {
  initNav();
  initParticles();
  initScrollReveal();
  initPolls();
  animateCounters();
  initIdeasFilter();
  initPenaltySpin();
  initDeathTicker();
  initChaosWheel();
  initChaosWheel();
  initAchievementFeed();
  initDiscordFeed();
  initOnboarding();
  initGearBattle();
  initRulesetTags();
  initGithubProgress();
});

/* ─── Onboarding Flow ─── */
function initOnboarding() {
  const modal = document.getElementById('onboardingModal');
  if (!modal) return;

  // Check if user already completed onboarding
  if (localStorage.getItem('tbchc_onboarded')) {
    modal.style.display = 'none';
    return;
  }

  // Show modal
  modal.style.display = 'flex';

  window.setLang = function (lang) {
    // Basic lang implementation
    if (window.i18n && window.i18n.setLanguage) {
      window.i18n.setLanguage(lang);
    }
    document.querySelectorAll('.lang-selection button').forEach(b => {
      b.classList.remove('btn-primary');
      b.classList.add('btn-ghost');
      b.style.borderColor = 'rgba(255,255,255,0.2)';
    });
    const clicked = event.target;
    clicked.classList.remove('btn-ghost');
    clicked.classList.add('btn-primary');
    clicked.style.borderColor = 'transparent';
  };

  const roleBtns = modal.querySelectorAll('.role-btn');
  roleBtns.forEach(btn => {
    btn.addEventListener('click', (e) => {
      const role = e.currentTarget.dataset.role;
      localStorage.setItem('tbchc_onboarded', 'true');
      localStorage.setItem('tbchc_role', role);
      modal.style.display = 'none';

      if (role === 'viewer') {
        window.location.href = 'intro.html';
      } else if (role === 'streamer') {
        const strSection = document.getElementById('streamer');
        if (strSection) {
          strSection.scrollIntoView({ behavior: 'smooth' });
        }
      } else {
        const modesSection = document.getElementById('modes');
        if (modesSection) {
          modesSection.scrollIntoView({ behavior: 'smooth' });
        }
      }
    });
  });
}

/* ─── Navigation ─── */
function initNav() {
  const nav = document.getElementById('nav');
  const toggle = document.getElementById('navToggle');
  const links = document.getElementById('navLinks');

  if (nav) {
    // Scroll effect
    let lastScroll = 0;
    window.addEventListener('scroll', () => {
      const y = window.scrollY;
      nav.classList.toggle('scrolled', y > 60);
      lastScroll = y;
    }, { passive: true });
  }

  if (toggle && links) {
    // Mobile toggle
    toggle.addEventListener('click', () => {
      links.classList.toggle('open');
      const spans = toggle.querySelectorAll('span');
      if (links.classList.contains('open')) {
        spans[0].style.transform = 'rotate(45deg) translate(5px, 5px)';
        spans[1].style.opacity = '0';
        spans[2].style.transform = 'rotate(-45deg) translate(5px, -5px)';
      } else {
        spans[0].style.transform = '';
        spans[1].style.opacity = '';
        spans[2].style.transform = '';
      }
    });

    // Close menu on link click
    links.querySelectorAll('a').forEach(a => {
      a.addEventListener('click', () => {
        links.classList.remove('open');
        const spans = toggle.querySelectorAll('span');
        spans[0].style.transform = '';
        spans[1].style.opacity = '';
        spans[2].style.transform = '';
      });
    });
  }
}

/* ─── Hero Particles ─── */
function initParticles() {
  const container = document.getElementById('heroParticles');
  if (!container) return;

  const colors = ['green', 'purple', 'orange'];
  const count = 40;

  for (let i = 0; i < count; i++) {
    const p = document.createElement('div');
    p.classList.add('particle', colors[i % colors.length]);
    p.style.left = Math.random() * 100 + '%';
    p.style.animationDelay = Math.random() * 8 + 's';
    p.style.animationDuration = (6 + Math.random() * 6) + 's';
    const size = 2 + Math.random() * 4;
    p.style.width = size + 'px';
    p.style.height = size + 'px';
    container.appendChild(p);
  }
}

/* ─── Scroll Reveal ─── */
function initScrollReveal() {
  const reveals = document.querySelectorAll('.reveal');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.15,
    rootMargin: '0px 0px -40px 0px'
  });

  reveals.forEach((el, i) => {
    el.style.transitionDelay = (i % 4) * 0.1 + 's';
    observer.observe(el);
  });
}

/* ─── Community Voting System ─── */
const POLLS_DATA = [
  {
    id: 'death-penalty',
    question: 'What should happen when you die in Hardcore mode?',
    options: [
      'Character permanently voided (guild banned, marked dead)',
      'Gear + gold wiped, character continues',
      'Full character deletion (if possible)',
      'Score-only penalty, no gear/char impact'
    ]
  },
  {
    id: 'ssf-rules',
    question: 'How strict should Self-Found rules be?',
    options: [
      'Full SSF — no mail, no AH, no trading',
      'Guild-only trading allowed',
      'AH + guild trading allowed',
      'No trade restrictions'
    ]
  },
  {
    id: 'boost-58',
    question: 'Should level 58 boosts be allowed?',
    options: [
      'Yes, always allowed',
      'Only after reaching 70 on one character',
      'Only for alt characters',
      'No — level from 1 every time'
    ]
  },
  {
    id: 'dungeon-scoring',
    question: 'How should dungeon scoring work?',
    options: [
      'Flat points per dungeon cleared',
      'Scaling by dungeon difficulty tier',
      'Time-based bonus on top of base points',
      'First-clear bonus + diminishing returns'
    ]
  },
  {
    id: 'pvp-death',
    question: 'What should happen on PvP death?',
    options: [
      'Same penalty as PvE death',
      'Reduced penalty (half deduction)',
      'No penalty — PvP deaths are exempt',
      'PvP should be disabled entirely'
    ]
  },
  {
    id: 'scoring-formula',
    question: 'Which scoring approach do you prefer?',
    options: [
      'Quest + Dungeon points (activity-based)',
      'Level milestones (progression-based)',
      'Achievement / exploration based',
      'Hybrid of all above'
    ]
  }
];

function initPolls() {
  const grid = document.getElementById('pollsGrid');
  if (!grid) return;

  // Load saved votes
  const savedVotes = JSON.parse(localStorage.getItem('tbchc_votes') || '{}');
  // Load or init simulated community votes
  let communityData = JSON.parse(localStorage.getItem('tbchc_community') || 'null');
  if (!communityData) {
    communityData = generateCommunityData();
    localStorage.setItem('tbchc_community', JSON.stringify(communityData));
  }

  POLLS_DATA.forEach(poll => {
    const card = document.createElement('div');
    card.classList.add('poll-card', 'reveal');

    const userVote = savedVotes[poll.id];
    const pollData = communityData[poll.id];

    const totalVotes = pollData.reduce((a, b) => a + b, 0);

    let optionsHTML = '';
    poll.options.forEach((opt, i) => {
      const votes = pollData[i];
      const percent = totalVotes > 0 ? Math.round((votes / totalVotes) * 100) : 0;
      const isSelected = userVote === i;
      const hasVoted = userVote !== undefined;

      optionsHTML += `
        <div class="poll-option ${hasVoted ? 'voted' : ''} ${isSelected ? 'selected' : ''}"
             data-poll="${poll.id}" data-index="${i}">
          <div class="poll-option-bar" style="width: ${hasVoted ? percent : 0}%"></div>
          <div class="poll-option-content">
            <span class="poll-option-text">${opt}</span>
            <span class="poll-option-percent">${percent}%</span>
          </div>
        </div>
      `;
    });

    card.innerHTML = `
      <h3 class="poll-question">${poll.question}</h3>
      <div class="poll-options">${optionsHTML}</div>
      <div class="poll-total">${totalVotes.toLocaleString()} votes</div>
    `;

    grid.appendChild(card);
  });

  // Click handlers
  grid.addEventListener('click', (e) => {
    const option = e.target.closest('.poll-option');
    if (!option || option.classList.contains('voted')) return;

    const pollId = option.dataset.poll;
    const index = parseInt(option.dataset.index);

    // Save vote
    const votes = JSON.parse(localStorage.getItem('tbchc_votes') || '{}');
    votes[pollId] = index;
    localStorage.setItem('tbchc_votes', JSON.stringify(votes));

    // Update community data
    const community = JSON.parse(localStorage.getItem('tbchc_community'));
    if (!community || !community[pollId]) return;

    community[pollId][index]++;
    localStorage.setItem('tbchc_community', JSON.stringify(community));

    // Update UI
    const card = option.closest('.poll-card');
    const options = card.querySelectorAll('.poll-option');
    const pollData = community[pollId];
    const total = pollData.reduce((a, b) => a + b, 0);

    options.forEach((opt, i) => {
      const pct = Math.round((pollData[i] / total) * 100);
      opt.classList.add('voted');
      if (i === index) opt.classList.add('selected');
      opt.querySelector('.poll-option-bar').style.width = pct + '%';
      opt.querySelector('.poll-option-percent').textContent = pct + '%';
    });

    card.querySelector('.poll-total').textContent = total.toLocaleString() + ' votes';

    // Update global stats
    updateVotingStats();
  });

  // Init scroll reveal for dynamically added elements
  setTimeout(() => initScrollReveal(), 100);
  updateVotingStats();
}

function generateCommunityData() {
  const data = {};
  POLLS_DATA.forEach(poll => {
    data[poll.id] = poll.options.map(() =>
      Math.floor(80 + Math.random() * 400)
    );
  });
  return data;
}

function updateVotingStats() {
  const community = JSON.parse(localStorage.getItem('tbchc_community') || '{}');
  let total = 0;
  Object.values(community).forEach(arr => {
    if (Array.isArray(arr)) total += arr.reduce((a, b) => a + b, 0);
  });

  const totalEl = document.getElementById('totalVotes');
  const votersEl = document.getElementById('votersCount');
  if (totalEl) animateNumber(totalEl, total);
  if (votersEl) animateNumber(votersEl, Math.floor(total / POLLS_DATA.length));
}

/* ─── Counter Animation ─── */
function animateCounters() {
  const counterSection = document.getElementById('featuresCounter');
  if (!counterSection) return;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const nums = entry.target.querySelectorAll('.strip-num');
        nums.forEach(num => {
          const target = parseInt(num.getAttribute('data-target'));
          animateNumber(num, target);
        });
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.5 });

  observer.observe(counterSection);
}

function animateNumber(el, target) {
  const duration = 1200;
  const start = parseInt(el.textContent.replace(/,/g, '')) || 0;
  const startTime = performance.now();

  function update(now) {
    const elapsed = now - startTime;
    const progress = Math.min(elapsed / duration, 1);
    // Ease out cubic
    const eased = 1 - Math.pow(1 - progress, 3);
    const current = Math.round(start + (target - start) * eased);
    el.textContent = current.toLocaleString();
    if (progress < 1) requestAnimationFrame(update);
  }

  requestAnimationFrame(update);
}

/* ─── Ideas Lab Category Filter ─── */
function initIdeasFilter() {
  const container = document.getElementById('ideaCategories');
  const grid = document.getElementById('ideasGrid');
  if (!container || !grid) return;

  container.addEventListener('click', (e) => {
    const btn = e.target.closest('.idea-cat-btn');
    if (!btn) return;

    // Update active button
    container.querySelectorAll('.idea-cat-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    const cat = btn.dataset.cat;
    const cards = grid.querySelectorAll('.idea-card');

    cards.forEach(card => {
      if (cat === 'all' || card.dataset.category === cat) {
        card.style.opacity = '0';
        card.style.transform = 'translateY(12px)';
        card.style.display = '';
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            card.style.transition = 'opacity 0.35s ease, transform 0.35s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
          });
        });
      } else {
        card.style.transition = 'opacity 0.2s ease';
        card.style.opacity = '0';
        setTimeout(() => { card.style.display = 'none'; }, 200);
      }
    });
  });
}

/* ─── Penalty Spin Wheel ─── */
const PE_ITEMS = [
  { name: 'Krol Blade', type: 'epic', icon: 'inv_sword_16' },
  { name: 'Lionheart Champion', type: 'epic', icon: 'inv_sword_62' },
  { name: 'Swift Zulian Tiger', type: 'legendary', icon: 'ability_mount_jungletiger' },
  { name: 'Jade Defender', type: 'rare', icon: 'inv_shield_30' },
  { name: 'Justicar Crown', type: 'epic', icon: 'inv_helmet_15' },
  { name: 'Boots of the Righteous Path', type: 'uncommon', icon: 'inv_boots_plate_06' },
  { name: 'Band of Eternal Defender', type: 'epic', icon: 'inv_jewelry_ring_47' },
  { name: 'Cloak of the Pit Stalker', type: 'rare', icon: 'inv_misc_cape_18' },
  { name: 'Aldor Legacy Defender', type: 'epic', icon: 'inv_shield_31' },
  { name: 'Dragonspine Trophy', type: 'epic', icon: 'inv_misc_gem_pearl_04' }
];

function initPenaltySpin() {
  const reel = document.getElementById('penaltyReel');
  const status = document.getElementById('penaltyStatus');
  const header = document.getElementById('peHeader');
  if (!reel || !status || !header) return;

  const ITEM_WIDTH = 65; // 50px item + 15px gap
  const TOTAL_ITEMS = 80;

  function buildReel(sequence) {
    reel.innerHTML = sequence.map(item => `
      <div class="pe-item ${item.type}">
        <img src="https://wow.zamimg.com/images/wow/icons/medium/${item.icon}.jpg" alt="${item.name}">
      </div>
    `).join('');
  }

  function playSpinSequence() {
    let sequence = [];
    for (let i = 0; i < TOTAL_ITEMS; i++) {
      sequence.push(PE_ITEMS[Math.floor(Math.random() * PE_ITEMS.length)]);
    }

    // Choose winning index around item 55-65
    const winIndex = 55 + Math.floor(Math.random() * 10);
    const winningItem = sequence[winIndex];

    buildReel(sequence);
    status.textContent = "Spinning roulette...";
    status.className = "pe-status";
    header.textContent = "Rolling for penalty item...";
    header.style.color = "var(--text-secondary)";
    reel.style.transition = 'none';
    reel.style.transform = 'translateX(0px)';
    reel.classList.remove('pe-reel-shake');

    setTimeout(() => {
      // Container is max 380px wide. We need the selector box center
      const windowWidth = document.querySelector('.pe-window').clientWidth;
      const selectorCenterPos = windowWidth / 2;
      // offset within the item for a slightly random stop
      const itemOffset = Math.random() * 20 - 10;
      const itemCenterPos = (winIndex * ITEM_WIDTH) + (50 / 2) + itemOffset;
      const targetX = selectorCenterPos - itemCenterPos;

      // Spin
      reel.style.transition = 'transform 4s cubic-bezier(0.15, 0.85, 0.35, 1)';
      reel.style.transform = `translateX(${targetX}px)`;

      // Handle spin end
      setTimeout(() => {
        status.textContent = `${winningItem.name} selected!`;

        // Destroy animation after a brief pause
        setTimeout(() => {
          const items = reel.querySelectorAll('.pe-item');
          if (items[winIndex]) {
            items[winIndex].classList.add('destroyed');
          }
          reel.classList.add('pe-reel-shake');
          status.textContent = `${winningItem.name} DESTROYED!`;
          status.classList.add('danger');
          header.textContent = "Penalty Executed";
          header.style.color = "var(--blood-red)";

          // Reset and spin again loop
          setTimeout(playSpinSequence, 4000);
        }, 1200);

      }, 4100);
    }, 100);
  }

  // Use intersection observer to start only when visible
  const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
      playSpinSequence();
      observer.disconnect();
    }
  }, { threshold: 0.5 });
  observer.observe(reel.parentElement);
}

/* ─── Death Ticker ─── */
function initDeathTicker() {
  const track = document.getElementById('tickerTrack');
  if (!track) return;

  const DEATHS = [
    { name: 'Zuzu (Priest)', cause: 'Fel Reaver — Hellfire Peninsula', pts: '−300' },
    { name: 'Hexmaw (Warlock)', cause: 'Disconnected in Slave Pens', pts: '−450' },
    { name: 'Thokk (Warrior)', cause: 'Feared into extra pack — Shadow Labs', pts: '−280' },
    { name: 'Lightbane (Paladin)', cause: 'Pat aggro — Shattered Halls', pts: '−520' },
    { name: 'Frostleaf (Mage)', cause: 'Resisted Frost Nova — Nagrand', pts: '−180' },
    { name: 'Grimjaw (Rogue)', cause: 'Stealth broken by AoE — Mechanar', pts: '−340' },
    { name: 'Moonwhisper (Druid)', cause: 'OOM in bear form — Mana Tombs', pts: '−260' },
    { name: 'Darkshot (Hunter)', cause: 'Pet pulled boss — Karazhan', pts: '−600' },
    { name: 'Soulrender (Warlock)', cause: 'Hellfire self-kill at 2% HP', pts: '−150' },
    { name: 'Ironvow (Warrior)', cause: 'Charge into void zone — Gruul', pts: '−550' },
  ];

  const html = DEATHS.map(d => `
    <div class="ticker-item">
      <span class="skull">💀</span>
      <span>${d.name}</span>
      <span style="color:var(--text-muted)">— ${d.cause}</span>
      <span class="pts">${d.pts} pts</span>
    </div>
  `).join('');

  // Double it for seamless loop
  track.innerHTML = html + html;
}

/* ─── Chaos Wheel ─── */
function initChaosWheel() {
  const wheel = document.getElementById('chaosWheel');
  const btn = document.getElementById('chaosSpinBtn');
  const result = document.getElementById('chaosResult');
  if (!wheel || !btn || !result) return;

  const SEGMENTS = [
    { label: '🗺️ Zone Lock', color: '#e74c3c' },
    { label: '🗡️ Melee Only', color: '#9b59f0' },
    { label: '🚫 No Potions', color: '#ff6b2b' },
    { label: '⏱️ Speed Run', color: '#00d4aa' },
    { label: '🔇 No Healing', color: '#e67e22' },
    { label: '👁️ Viewer Dare', color: '#3498db' },
    { label: '🏃‍♂️ Zone Rush', color: '#c0392b' },
    { label: '🎲 Wild Card', color: '#f1c40f' },
  ];

  const segAngle = 360 / SEGMENTS.length;

  // Build conic-gradient
  let gradient = 'conic-gradient(';
  SEGMENTS.forEach((seg, i) => {
    const start = i * segAngle;
    const end = (i + 1) * segAngle;
    gradient += `${seg.color} ${start}deg ${end}deg`;
    if (i < SEGMENTS.length - 1) gradient += ', ';
  });
  gradient += ')';
  wheel.style.background = gradient;

  // Add text labels as absolutely-positioned spans
  SEGMENTS.forEach((seg, i) => {
    const lbl = document.createElement('div');
    lbl.style.cssText = `
      position: absolute;
      width: 100%;
      height: 100%;
      top: 0;
      left: 0;
      display: flex;
      align-items: flex-start;
      justify-content: center;
      padding-top: 22px;
      font-size: 0.7rem;
      font-weight: 600;
      color: white;
      text-shadow: 0 1px 4px rgba(0,0,0,0.7);
      pointer-events: none;
      transform: rotate(${i * segAngle + segAngle / 2}deg);
    `;
    lbl.textContent = seg.label;
    wheel.appendChild(lbl);
  });

  let currentRotation = 0;
  let spinning = false;

  function spin() {
    if (spinning) return;
    spinning = true;
    btn.disabled = true;
    result.classList.remove('landed');
    result.textContent = 'Spinning...';

    // 3-7 full rotations + random offset
    const extraRotations = (3 + Math.floor(Math.random() * 5)) * 360;
    const randomAngle = Math.random() * 360;
    const totalRotation = currentRotation + extraRotations + randomAngle;

    wheel.style.transition = 'transform 5s cubic-bezier(0.17, 0.67, 0.12, 0.99)';
    wheel.style.transform = `rotate(${totalRotation}deg)`;
    currentRotation = totalRotation;

    setTimeout(() => {
      // Which segment is at the top (pointer)?
      const normalised = ((totalRotation % 360) + 360) % 360;
      // Pointer is at top (0°), wheel rotates clockwise
      // segment at pointer = (360 - normalised) mapped to index
      const pointerAngle = (360 - normalised + 360) % 360;
      const segIndex = Math.floor(pointerAngle / segAngle) % SEGMENTS.length;
      const landed = SEGMENTS[segIndex];

      result.textContent = landed.label + ' — ACTIVATED!';
      result.classList.add('landed');

      spinning = false;
      btn.disabled = false;

      if (landed.label.includes('Zone Rush')) {
        setTimeout(() => {
          const modal = document.getElementById('zoneRushModal');
          if (modal) modal.classList.add('active');
        }, 800);
      }

    }, 5200);
  }

  btn.addEventListener('click', spin);

  const closeBtn = document.getElementById('zrmCloseBtn');
  if (closeBtn) {
    closeBtn.addEventListener('click', () => {
      document.getElementById('zoneRushModal').classList.remove('active');
    });
  }

  // Auto-spin on scroll into view
  const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
      spin();
      observer.disconnect();
    }
  }, { threshold: 0.4 });
  observer.observe(wheel);
}

/* ─── Gear Battle Animation ─── */
function initGearBattle() {
  const container = document.getElementById('duelContainer');
  const hp1 = document.getElementById('duelHp1');
  const hp2 = document.getElementById('duelHp2');
  const p1 = document.getElementById('duelP1');
  const p2 = document.getElementById('duelP2');
  const statusEl = document.getElementById('duelStatusText');

  if (!container || !hp1 || !hp2) return;

  let hp1Val = 100;
  let hp2Val = 100;
  let battleActive = false;

  function runBattle() {
    if (hp1Val <= 0 || hp2Val <= 0) return;

    // Random damage ticks
    const dmg1 = Math.random() * 15;
    const dmg2 = Math.random() * 20; // P2 takes slightly more on avg for demo

    hp1Val = Math.max(0, hp1Val - dmg1);
    hp2Val = Math.max(0, hp2Val - dmg2);

    hp1.style.width = hp1Val + '%';
    hp2.style.width = hp2Val + '%';

    // Color shifts on low HP
    if (hp1Val < 30) hp1.style.background = 'var(--blood-red)';
    else if (hp1Val < 60) hp1.style.background = 'var(--ember-orange)';

    if (hp2Val < 30) hp2.style.background = 'var(--blood-red)';
    else if (hp2Val < 60) hp2.style.background = 'var(--ember-orange)';

    if (hp1Val === 0 || hp2Val === 0) {
      statusEl.classList.remove('blinking');

      if (hp2Val === 0) {
        p2.style.opacity = '0.3';
        p2.style.filter = 'grayscale(100%)';
        p1.classList.add('winner-pulse');
        statusEl.innerHTML = `<span style="color:var(--highlight-green)">ZUZU WINS!</span><br><span style="color:var(--blood-red)">Thokk loses Nightblade (-300 Score)</span>`;
      } else {
        p1.style.opacity = '0.3';
        p1.style.filter = 'grayscale(100%)';
        p2.classList.add('winner-pulse');
        statusEl.innerHTML = `<span style="color:var(--highlight-green)">THOKK WINS!</span><br><span style="color:var(--blood-red)">Zuzu loses Destiny (-300 Score)</span>`;
      }
      return;
    }

    setTimeout(runBattle, 500 + Math.random() * 800);
  }

  const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting && !battleActive) {
      battleActive = true;
      setTimeout(runBattle, 1000);
      observer.disconnect();
    }
  }, { threshold: 0.5 });

  observer.observe(container);
}

/* ─── Live Achievement Feed ─── */
function initAchievementFeed() {
  const feed = document.getElementById('achieveFeed');
  if (!feed) return;

  const EVENTS = [
    { type: 'milestone', icon: '⚔️', title: 'Unlocked Outland', desc: 'Pupi reached level 58 in 3d 14h · 0 deaths · HC Plus', score: '+100', scoreClass: 'pos', time: '14:32' },
    { type: 'unlock', icon: '🏆', title: 'Reached Level 70', desc: 'Pupi — first char to 70 · 8d 7h total · 0 deaths', score: '+500', scoreClass: 'pos', time: '22:15' },
    { type: 'pvp', icon: '⚔️', title: 'Gear Battle Won', desc: 'Pupi defeated Thokk — won Nightblade', score: '+75', scoreClass: 'pos', time: '23:41' },
    { type: 'death', icon: '💀', title: 'Character Voided — Zuzu', desc: 'Killed by Fel Reaver · Hellfire Peninsula lvl 62', score: '−300', scoreClass: 'neg', time: '03:12' },
    { type: 'milestone', icon: '🏰', title: 'Cleared Karazhan', desc: 'Pupi — full clear, 0 wipes, HC Plus guild run', score: '+800', scoreClass: 'pos', time: '01:05' },
    { type: 'unlock', icon: '🔓', title: 'Score Unlock: Epic Gear', desc: 'Pupi crossed 3,000 pts — Epic items now equippable', score: '+0', scoreClass: 'pos', time: '01:06' },
  ];

  EVENTS.forEach(ev => {
    const entry = document.createElement('div');
    entry.className = `af-entry ${ev.type}`;
    entry.innerHTML = `
      <div class="af-time">Today — ${ev.time}</div>
      <div class="af-body">
        <div class="af-icon">${ev.icon}</div>
        <div class="af-text">
          <strong>${ev.title}</strong>
          <span>${ev.desc}</span>
        </div>
        <div class="af-score ${ev.scoreClass}">${ev.score}</div>
      </div>
    `;
    feed.appendChild(entry);
  });

  // Staggered reveal
  const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
      const items = feed.querySelectorAll('.af-entry');
      items.forEach((item, i) => {
        setTimeout(() => item.classList.add('visible'), i * 300);
      });
      observer.disconnect();
    }
  }, { threshold: 0.2 });
  observer.observe(feed);
}

/* ─── Discord Feed ─── */
function initDiscordFeed() {
  const container = document.getElementById('discordMessages');
  if (!container) return;

  const MESSAGES = [
    {
      avatar: '🤖', name: 'TBC-HC Bot', bot: true,
      text: '💀 **Zuzu** (Shadow Priest, Lvl 62) has been **VOIDED**',
      embed: { text: 'Killed by Fel Reaver in Hellfire Peninsula\n`[HCP]` `[Guild: Destiny]` `[1 Death Used]`\n**Score impact:** −300 pts', cls: '' }
    },
    {
      avatar: '🤖', name: 'TBC-HC Bot', bot: true,
      text: '🏆 **Pupi** reached **Level 70** — first in guild!',
      embed: { text: '`[HCP]` `[Guild: OnlyFangs]` `[SSF]`\n8d 7h playtime · 0 deaths\n**Score:** +500 pts · **Rank:** #3', cls: 'green' }
    },
    {
      avatar: '🎮', name: 'xXhunterXx', bot: false,
      text: 'GG Pupi! That was insane, no deaths the entire run 🔥'
    },
    {
      avatar: '🤖', name: 'TBC-HC Bot', bot: true,
      text: '⚔️ **Gear Battle** — Pupi vs Thokk',
      embed: { text: '`[HCP]` `[PvP: Gear Wager]`\nItem wagered: Nightblade (Rare)\n**Winner:** Pupi · +75 pts · Title: "Duelist"', cls: 'gold' }
    },
    {
      avatar: '🤖', name: 'TBC-HC Bot', bot: true,
      text: '📊 **Leaderboard Update** — Season 1, Week 4',
      embed: { text: '1. Ziqø — 4,890 pts\n2. Xaryu — 4,120 pts\n3. Pupi — 3,475 pts', cls: 'purple' }
    },
  ];

  let idx = 0;
  let started = false;

  function addMessage() {
    if (idx >= MESSAGES.length) {
      // Reset after delay
      setTimeout(() => {
        container.innerHTML = '';
        idx = 0;
        addMessage();
      }, 5000);
      return;
    }

    const msg = MESSAGES[idx];
    const el = document.createElement('div');
    el.className = 'dc-msg';

    let embedHTML = '';
    if (msg.embed) {
      embedHTML = `<div class="dc-embed ${msg.embed.cls}">${msg.embed.text.replace(/\n/g, '<br>')}</div>`;
    }

    el.innerHTML = `
      <div class="dc-avatar ${msg.bot ? 'bot' : ''}">${msg.avatar}</div>
      <div class="dc-content">
        <div class="dc-name">
          ${msg.name}
          ${msg.bot ? '<span class="bot-tag">BOT</span>' : ''}
          <span class="dc-time">Today at ${String(10 + idx).padStart(2, '0')}:${String(Math.floor(Math.random() * 59)).padStart(2, '0')}</span>
        </div>
        <div class="dc-text">${msg.text}</div>
        ${embedHTML}
      </div>
    `;

    container.appendChild(el);
    // Trigger animation
    requestAnimationFrame(() => {
      requestAnimationFrame(() => el.classList.add('visible'));
    });

    idx++;
    setTimeout(addMessage, 2200);
  }

  // Start on scroll
  const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting && !started) {
      started = true;
      addMessage();
      observer.disconnect();
    }
  }, { threshold: 0.3 });
  observer.observe(container);
}

/* ─── GM Ruleset Tags Update ─── */
function initRulesetTags() {
  window.updateRulesetTags = function () {
    const container = document.getElementById('dynamicRulesetTags');
    const trading = document.getElementById('toggleTrading');
    const ah = document.getElementById('toggleAH');
    const chrono = document.getElementById('toggleChrono');
    const drop = document.getElementById('toggleDrop');

    if (!container || !trading || !ah || !chrono || !drop) return;

    // Clear existing rule tags, keep mode tag
    const modeTagHTML = '<span class="tag tag-mode">Hybrid</span>';
    const tagClassLimit = '<span class="tag tag-rule">Max 5 per Class</span>'; // Static for demo

    let html = modeTagHTML + tagClassLimit;

    if (trading.classList.contains('active')) {
      html += '<span class="tag tag-rule" data-feature="trading" style="background: rgba(46, 204, 113, 0.1); color: var(--highlight-green);">Trading: ON</span> ';
    } else {
      html += '<span class="tag tag-rule" data-feature="trading" style="background: rgba(230, 57, 70, 0.1); color: var(--blood-red);">Trading: OFF</span> ';
    }

    if (ah.classList.contains('active')) {
      html += '<span class="tag tag-rule" data-feature="ahl" style="background: rgba(230, 57, 70, 0.1); color: var(--blood-red);">AH: Locked</span> ';
    } else {
      html += '<span class="tag tag-rule" data-feature="ahl" style="background: rgba(46, 204, 113, 0.1); color: var(--highlight-green);">AH: Open</span> ';
    }

    if (chrono.classList.contains('active')) {
      html += '<span class="tag tag-rule" data-feature="chr">Chronoboon: ON</span> ';
    } else {
      html += '<span class="tag tag-rule" data-feature="chr">Chronoboon: OFF</span> ';
    }

    if (drop.classList.contains('active')) {
      html += '<span class="tag tag-rule" data-feature="drp" style="background: rgba(230, 57, 70, 0.1); color: var(--blood-red);">Drop Item on Death</span> ';
    }

    container.innerHTML = html;
  };
}

/* ─── GitHub Milestone Progress ─── */
function initGithubProgress() {
  const progressText = document.getElementById('githubProgressText');
  const progressBar = document.getElementById('githubProgressBar');
  const statsText = document.getElementById('githubMilestoneStats');

  if (!progressText || !progressBar || !statsText) return;

  // Use the public GitHub repo
  fetch('https://api.github.com/repos/klumpler-12/wow-tbc-hardcore/milestones?state=all')
    .then(res => res.json())
    .then(milestones => {
      if (!Array.isArray(milestones) || milestones.length === 0) {
        statsText.innerText = "No milestones tracked yet.";
        progressText.innerText = "0%";
        return;
      }

      let totalIssues = 0;
      let closedIssues = 0;
      let closedMilestones = 0;

      milestones.forEach(m => {
        totalIssues += (m.open_issues + m.closed_issues);
        closedIssues += m.closed_issues;
        if (m.state === 'closed') closedMilestones++;
      });

      // We can combine issue completion and milestone completion for a smooth percentage
      // If no issues exist, just base it on closed milestones vs total milestones.
      let percentage = 0;
      if (totalIssues > 0) {
        // We weight issues heavily, but add milestone completion scaling too if desired
        percentage = Math.round((closedIssues / totalIssues) * 100);
      } else {
        percentage = Math.round((closedMilestones / milestones.length) * 100);
      }

      // Failsafe bounds
      percentage = Math.max(0, Math.min(100, percentage));

      // Animate in
      setTimeout(() => {
        progressText.innerText = percentage + '%';
        progressBar.style.width = percentage + '%';
      }, 500);

      const infoLabel = totalIssues > 0 ? `${totalIssues} tracking` : `Milestones`;
      statsText.innerHTML = `Tracking ${milestones.length} Milestones <span style="margin: 0 6px; opacity: 0.5;">|</span> ${closedMilestones} Completed <span style="margin: 0 6px; opacity: 0.5;">|</span> ${infoLabel} Tasks`;
    })
    .catch(err => {
      console.error('Failed to fetch github milestones:', err);
      statsText.innerText = "Failed to load project progress from GitHub.";
    });
}
