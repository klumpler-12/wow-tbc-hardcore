// Intersection observer for scroll-triggered animations
(function() {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, { threshold: 0 });

  document.querySelectorAll('.fade-in, .reveal-up, .house-card, .achievement, .mockup-frame').forEach(el => {
    observer.observe(el);
  });
})();
