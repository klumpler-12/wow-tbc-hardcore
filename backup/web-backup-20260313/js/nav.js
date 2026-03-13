// Nav scroll effect + mobile toggle + smooth scroll
(function() {
  const nav = document.getElementById('nav');
  window.addEventListener('scroll', HCUtils.throttleRAF(function() {
    nav.classList.toggle('scrolled', window.scrollY > 50);
  }));

  // Mobile nav toggle
  const navToggle = document.getElementById('navToggle');
  const navLinks = document.getElementById('navLinks');
  navToggle.addEventListener('click', () => {
    navLinks.classList.toggle('open');
    navToggle.classList.toggle('open');
  });

  // Smooth scroll
  document.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener('click', e => {
      e.preventDefault();
      const target = document.querySelector(a.getAttribute('href'));
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        navLinks.classList.remove('open');
        navToggle.classList.remove('open');
      }
    });
  });
})();
