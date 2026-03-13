// Side navigation — dot indicator + click-to-scroll
(function() {
  var sideNav = document.getElementById('sideNav');
  if (!sideNav) return;

  var dots = sideNav.querySelectorAll('.side-nav-dot');
  var sections = [];

  dots.forEach(function(dot) {
    var id = dot.getAttribute('data-section');
    var el = document.getElementById(id);
    if (el) sections.push({ dot: dot, el: el, id: id });

    dot.addEventListener('click', function() {
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });

  // Update active dot on scroll
  var ticking = false;
  window.addEventListener('scroll', function() {
    if (!ticking) {
      requestAnimationFrame(function() {
        var scrollY = window.scrollY + window.innerHeight / 3;
        var active = sections[0];
        for (var i = 0; i < sections.length; i++) {
          if (sections[i].el.offsetTop <= scrollY) {
            active = sections[i];
          }
        }
        dots.forEach(function(d) { d.classList.remove('active'); });
        if (active) active.dot.classList.add('active');
        ticking = false;
      });
      ticking = true;
    }
  });

  // Hide side nav on top of page, show after scrolling past hero
  window.addEventListener('scroll', function() {
    sideNav.classList.toggle('visible', window.scrollY > 300);
  });
})();
