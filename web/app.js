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
});

/* ─── Navigation ─── */
function initNav() {
  const nav = document.getElementById('nav');
  const toggle = document.getElementById('navToggle');
  const links = document.getElementById('navLinks');

  // Scroll effect
  let lastScroll = 0;
  window.addEventListener('scroll', () => {
    const y = window.scrollY;
    nav.classList.toggle('scrolled', y > 60);
    lastScroll = y;
  }, { passive: true });

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
  // Initial update happens after polls init
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
