// Instance Lives Expand/Collapse
(function() {
  document.querySelectorAll('.il-expand-btn').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var target = document.getElementById(btn.getAttribute('data-target'));
      if (!target) return;
      var hidden = target.style.display === 'none';
      target.style.display = hidden ? '' : 'none';
      btn.textContent = hidden ? 'Show less' : btn.getAttribute('data-label') || 'Show all';
      if (!btn.getAttribute('data-label')) btn.setAttribute('data-label', btn.textContent);
    });
  });
})();
