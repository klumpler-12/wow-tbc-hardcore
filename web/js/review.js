// Review & Annotation Mode (v3 — streamlined + Claude export)
(function() {
  var NK = 'hcplus_notes_v2', EK = 'hcplus_elems_v2';
  function load(k) { try { return JSON.parse(localStorage.getItem(k) || '[]'); } catch(e) { return []; } }
  function persist(k, v) { localStorage.setItem(k, JSON.stringify(v)); }
  var active = false, tool = 'rect', color = '#ff4444';
  var notes = load(NK), elems = load(EK), selId = null, history = [];
  var $ = function(id) { return document.getElementById(id); };
  var toggle = $('reviewToggle'), ovl = $('elemOverlay'), panel = $('reviewPanel');
  var notesList = $('reviewNotes'), ta = $('reviewText');
  var btnClose = $('reviewClose'), btnExport = $('reviewExport'), btnClear = $('reviewClear');
  var btnUndo = $('undoBtn'), btnClearAll = $('clearAllBtn');
  var btnClaude = $('reviewCopyForClaude');

  function uid() { return 'e' + Date.now().toString(36) + Math.random().toString(36).substr(2,4); }
  function esc(s) { var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }
  function elemNum(id) { var i = elems.findIndex(function(e) { return e.id === id; }); return i >= 0 ? i + 1 : 0; }

  var _rt = null;
  function resizeAll() { ovl.style.height = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight) + 'px'; }
  function debResize() { clearTimeout(_rt); _rt = setTimeout(resizeAll, 150); }
  window.addEventListener('resize', debResize);
  new ResizeObserver(debResize).observe(document.body);

  // Find nearest section for an element's position
  function findSection(el) {
    if (el.type !== 'rect') return null;
    ovl.style.display = 'none';
    var cx = el.x + (el.w || 0) / 2, cy = el.y + (el.h || 0) / 2;
    var vx = cx - window.scrollX, vy = cy - window.scrollY;
    var result = null;
    if (vx >= 0 && vy >= 0) {
      var hits = document.elementsFromPoint(vx, vy);
      for (var i = 0; i < hits.length; i++) {
        var sec = hits[i].closest('section[id], header[id], footer, [id]');
        if (sec && sec.id && sec.id !== 'elemOverlay' && sec.id !== 'reviewPanel') {
          var h2 = sec.querySelector('h2, h3');
          result = { id: sec.id, title: h2 ? h2.textContent.trim().substring(0, 60) : sec.id };
          break;
        }
      }
    }
    ovl.style.display = ''; ovl.classList.add('active');
    return result;
  }

  function captureContext(el) {
    if (el.type !== 'rect') return [];
    var results = []; ovl.style.display = 'none';
    var sx = el.x, sy = el.y, ex = el.x + (el.w || 0), ey = el.y + (el.h || 0), seen = {};
    [[sx+10,sy+10],[(sx+ex)/2,(sy+ey)/2],[ex-10,ey-10],[sx+10,(sy+ey)/2],[(sx+ex)/2,sy+10],[ex-10,sy+10],[(sx+ex)/2,ey-10]].forEach(function(p) {
      var vx = p[0] - window.scrollX, vy = p[1] - window.scrollY;
      if (vx < 0 || vy < 0) return;
      document.elementsFromPoint(vx, vy).forEach(function(elem) {
        if (elem === document.body || elem === document.documentElement) return;
        if (elem.id === 'elemOverlay' || elem.closest('#reviewPanel') || elem.closest('#reviewToggle')) return;
        var key = elem.tagName + (elem.id || '') + (elem.className || '').substring(0, 30);
        if (seen[key]) return; seen[key] = true;
        var txt = (elem.textContent || '').trim().substring(0, 200).replace(/\s+/g, ' ');
        if (!txt && !elem.id) return;
        results.push({ tag: elem.tagName.toLowerCase(), id: elem.id || undefined, class: (elem.className && typeof elem.className === 'string') ? elem.className.split(' ').slice(0, 3).join(' ') : undefined, text: txt || undefined });
      });
    });
    ovl.style.display = ''; ovl.classList.add('active');
    return results.slice(0, 5);
  }

  function mkElem(el) {
    var d = document.createElement('div');
    d.className = 'review-elem elem-rect'; d.dataset.id = el.id; applyPos(d, el);
    var b = document.createElement('span'); b.className = 'elem-badge'; b.textContent = '#' + elemNum(el.id); d.appendChild(b);
    var ctrls = document.createElement('div'); ctrls.className = 'elem-controls';
    ctrls.innerHTML = '<button class="elem-ctrl elem-del" title="Delete">&times;</button>'; d.appendChild(ctrls);
    var rh = document.createElement('div'); rh.className = 'elem-resize-handle'; d.appendChild(rh);
    return d;
  }
  function applyPos(d, el) {
    d.style.left = el.x + 'px'; d.style.top = el.y + 'px';
    d.style.width = (el.w || 100) + 'px'; d.style.height = (el.h || 60) + 'px';
    d.style.borderColor = el.color || color;
  }
  function renderElems() { ovl.innerHTML = ''; elems.forEach(function(el) { ovl.appendChild(mkElem(el)); }); }
  function refreshBadges() { elems.forEach(function(el, i) { var d = ovl.querySelector('[data-id="' + el.id + '"]'); if (d) { var b = d.querySelector('.elem-badge'); if (b) b.textContent = '#' + (i+1); } }); }

  function select(id) {
    deselect(); selId = id;
    var d = ovl.querySelector('[data-id="' + id + '"]'); if (d) d.classList.add('selected');
    ta.placeholder = 'Comment on Box #' + elemNum(id) + '...\nPress Enter to add.'; ta.focus();
  }
  function deselect() {
    if (!selId) return;
    var d = ovl.querySelector('[data-id="' + selId + '"]'); if (d) d.classList.remove('selected');
    selId = null; ta.placeholder = 'Type a note and press Enter...';
  }
  function removeElem(id) {
    var d = ovl.querySelector('[data-id="' + id + '"]'); if (d) d.remove();
    elems = elems.filter(function(e) { return e.id !== id; }); persist(EK, elems);
    if (selId === id) deselect(); refreshBadges(); renderNotes();
  }

  var dm = null, dt = null, ds = null;
  function startDrag(mode, e, id) {
    dm = mode; ds = { px: e.pageX, py: e.pageY };
    if (mode === 'move') { var el = elems.find(function(x) { return x.id === id; }); ds.ox = el.x; ds.oy = el.y; ds.id = id; dt = ovl.querySelector('[data-id="' + id + '"]'); }
    if (mode === 'resize') { var el2 = elems.find(function(x) { return x.id === id; }); ds.ow = el2.w || 0; ds.oh = el2.h || 0; ds.id = id; dt = ovl.querySelector('[data-id="' + id + '"]'); }
    if (mode === 'create') { dt = document.createElement('div'); dt.className = 'review-elem elem-rect elem-preview'; dt.style.borderColor = color; dt.style.left = e.pageX + 'px'; dt.style.top = e.pageY + 'px'; dt.style.width = '0'; dt.style.height = '0'; ovl.appendChild(dt); }
    document.addEventListener('mousemove', onDrag); document.addEventListener('mouseup', endDrag); e.preventDefault();
  }
  function onDrag(e) {
    var dx = e.pageX - ds.px, dy = e.pageY - ds.py;
    if (dm === 'move') { var el = elems.find(function(x) { return x.id === ds.id; }); el.x = ds.ox + dx; el.y = ds.oy + dy; dt.style.left = el.x + 'px'; dt.style.top = el.y + 'px'; }
    if (dm === 'resize') { var el2 = elems.find(function(x) { return x.id === ds.id; }); el2.w = Math.max(30, ds.ow + dx); el2.h = Math.max(20, ds.oh + dy); dt.style.width = el2.w + 'px'; dt.style.height = el2.h + 'px'; }
    if (dm === 'create') { var x = Math.min(ds.px, e.pageX), y = Math.min(ds.py, e.pageY); dt.style.left = x + 'px'; dt.style.top = y + 'px'; dt.style.width = Math.abs(dx) + 'px'; dt.style.height = Math.abs(dy) + 'px'; }
  }
  function endDrag() {
    document.removeEventListener('mousemove', onDrag); document.removeEventListener('mouseup', endDrag);
    if (dm === 'move' || dm === 'resize') persist(EK, elems);
    if (dm === 'create' && dt) {
      var x = parseInt(dt.style.left), y = parseInt(dt.style.top), w = parseInt(dt.style.width), h = parseInt(dt.style.height); dt.remove();
      if (w > 10 && h > 10) { var el = { id: uid(), type: 'rect', x: x, y: y, w: w, h: h, color: color }; elems.push(el); persist(EK, elems); ovl.appendChild(mkElem(el)); history.push({ t: 'elem', id: el.id }); setTool('select'); select(el.id); }
    }
    dm = dt = ds = null;
  }

  ovl.addEventListener('mousedown', function(e) {
    if (!active) return;
    if (e.target.classList.contains('elem-resize-handle')) { e.stopPropagation(); startDrag('resize', e, e.target.closest('.review-elem').dataset.id); return; }
    var ctrl = e.target.closest('.elem-ctrl');
    if (ctrl) { e.stopPropagation(); var id = ctrl.closest('.review-elem').dataset.id; if (ctrl.classList.contains('elem-del')) removeElem(id); return; }
    if (tool === 'rect') { startDrag('create', e, null); return; }
    var ed = e.target.closest('.review-elem');
    if (ed && tool === 'select') { select(ed.dataset.id); startDrag('move', e, ed.dataset.id); return; }
    if (tool === 'select') deselect();
  });

  function setTool(t) { tool = t; ovl.classList.toggle('tool-select', t === 'select'); ovl.classList.toggle('tool-create', t === 'rect'); if (t !== 'select') deselect(); }
  btnUndo.addEventListener('click', function() { if (!history.length) return; var a = history.pop(); if (a.t === 'elem') removeElem(a.id); });
  btnClearAll.addEventListener('click', function() { if (!elems.length && !notes.length) return; if (!confirm('Clear all boxes and notes?')) return; elems = []; notes = []; history = []; persist(EK, elems); persist(NK, notes); renderElems(); renderNotes(); deselect(); });

  function renderNotes() {
    notesList.innerHTML = '';
    if (!notes.length) { notesList.innerHTML = '<div style="color:var(--text-dim);font-size:0.72rem;padding:16px;text-align:center;line-height:1.8;">No notes yet.<br>Draw a box, then type below.</div>'; return; }
    notes.forEach(function(n, i) {
      var div = document.createElement('div'); div.className = 'review-note';
      var badge = '';
      if (n.eid) { var num = elemNum(n.eid); badge = num > 0 ? '<span class="note-badge" data-eid="' + n.eid + '">#' + num + '</span>' : '<span class="note-badge" style="opacity:0.4">#?</span>'; }
      div.innerHTML = '<div class="review-note-text">' + badge + esc(n.text) + '</div><div class="review-note-time">' + n.time + '</div><button class="review-note-del" data-idx="' + i + '">&times;</button>';
      notesList.appendChild(div);
    });
    notesList.querySelectorAll('.note-badge[data-eid]').forEach(function(b) { b.addEventListener('click', function() { var id = b.dataset.eid; setTool('select'); select(id); var d = ovl.querySelector('[data-id="' + id + '"]'); if (d) d.scrollIntoView({ behavior: 'smooth', block: 'center' }); }); });
    notesList.querySelectorAll('.review-note-del').forEach(function(btn) { btn.addEventListener('click', function() { notes.splice(parseInt(btn.dataset.idx), 1); persist(NK, notes); renderNotes(); }); });
    notesList.scrollTop = notesList.scrollHeight;
  }

  ta.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); var txt = ta.value.trim(); if (!txt) return; var t = new Date().toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' }); notes.push({ text: txt, eid: selId || null, time: t }); persist(NK, notes); ta.value = ''; renderNotes(); }
  });

  // JSON Export
  btnExport.addEventListener('click', function() {
    if (!notes.length && !elems.length) { btnExport.textContent = 'Nothing'; setTimeout(function() { btnExport.textContent = 'Export'; }, 1200); return; }
    var elemData = elems.map(function(el, i) {
      var obj = { ref: '#' + (i+1), type: 'rect', x: Math.round(el.x), y: Math.round(el.y), color: el.color };
      if (el.w) obj.w = Math.round(el.w); if (el.h) obj.h = Math.round(el.h);
      obj.section = findSection(el);
      obj.context = captureContext(el);
      var elNotes = notes.filter(function(n) { return n.eid === el.id; });
      if (elNotes.length) obj.notes = elNotes.map(function(n) { return n.text; });
      return obj;
    });
    var generalNotes = notes.filter(function(n) { return !n.eid; }).map(function(n) { return { text: n.text, time: n.time }; });
    var data = { exportedAt: new Date().toISOString(), elements: elemData, generalNotes: generalNotes, summary: elems.length + ' boxes, ' + notes.length + ' notes' };
    var json = JSON.stringify(data, null, 2);
    function copyFB(t) { var el = document.createElement('textarea'); el.value = t; el.style.cssText = 'position:fixed;left:-9999px'; document.body.appendChild(el); el.select(); try { document.execCommand('copy'); } catch(ex) {} document.body.removeChild(el); }
    if (navigator.clipboard && navigator.clipboard.writeText) { navigator.clipboard.writeText(json).catch(function() { copyFB(json); }); } else { copyFB(json); }
    var blob = new Blob([json], { type: 'application/json' }); var url = URL.createObjectURL(blob); var a = document.createElement('a'); a.href = url; a.download = 'review-export.json'; a.click(); URL.revokeObjectURL(url);
    btnExport.textContent = 'Copied!'; setTimeout(function() { btnExport.textContent = 'Export'; }, 1500);
  });

  // Copy for Claude — markdown format
  if (btnClaude) {
    btnClaude.addEventListener('click', function() {
      if (!notes.length && !elems.length) { btnClaude.textContent = 'Nothing'; setTimeout(function() { btnClaude.textContent = 'Claude'; }, 1200); return; }
      var md = '## Site Review \u2014 ' + new Date().toLocaleString('de-DE') + '\n\n';
      md += '**Page:** ' + document.title + '  \n';
      md += '**URL:** ' + location.pathname + '\n\n';

      elems.forEach(function(el, i) {
        var sec = findSection(el);
        var sectionLabel = sec ? sec.title + ' (`#' + sec.id + '`)' : 'Unknown section';
        md += '### Box #' + (i+1) + ' \u2014 Section: ' + sectionLabel + '\n';
        md += '- **Position:** x=' + Math.round(el.x) + ', y=' + Math.round(el.y);
        if (el.w) md += ', ' + Math.round(el.w) + 'x' + Math.round(el.h);
        md += '\n';

        var ctx = captureContext(el);
        if (ctx.length) {
          md += '- **Elements:** ';
          md += ctx.map(function(c) {
            var parts = [];
            if (c.id) parts.push('#' + c.id);
            if (c.class) parts.push('.' + c.class.split(' ')[0]);
            if (!c.id && !c.class) parts.push(c.tag);
            return parts.join('');
          }).join(', ');
          md += '\n';
        }

        var elNotes = notes.filter(function(n) { return n.eid === el.id; });
        if (elNotes.length) {
          md += '- **Notes:**\n';
          elNotes.forEach(function(n) { md += '  - ' + n.text + '\n'; });
        }
        md += '\n';
      });

      var generalNotes = notes.filter(function(n) { return !n.eid; });
      if (generalNotes.length) {
        md += '### General Notes\n';
        generalNotes.forEach(function(n) { md += '- ' + n.text + '\n'; });
        md += '\n';
      }

      md += '---\n*Exported from Hardcore Plus review mode for Claude*\n';

      function copyFB(t) { var el = document.createElement('textarea'); el.value = t; el.style.cssText = 'position:fixed;left:-9999px'; document.body.appendChild(el); el.select(); try { document.execCommand('copy'); } catch(ex) {} document.body.removeChild(el); }
      if (navigator.clipboard && navigator.clipboard.writeText) { navigator.clipboard.writeText(md).catch(function() { copyFB(md); }); } else { copyFB(md); }
      btnClaude.textContent = 'Copied!'; setTimeout(function() { btnClaude.textContent = 'Claude'; }, 1500);
    });
  }

  btnClear.addEventListener('click', function() { if (!notes.length) return; if (!confirm('Clear all notes?')) return; notes = []; persist(NK, notes); renderNotes(); });

  function open() { active = true; document.documentElement.classList.add('review-active'); panel.classList.remove('review-hidden'); ovl.classList.add('active'); toggle.classList.add('active'); toggle.innerHTML = '&#10006;'; setTimeout(function() { resizeAll(); }, 320); setTool('rect'); renderNotes(); }
  function close() { active = false; document.documentElement.classList.remove('review-active'); panel.classList.add('review-hidden'); ovl.classList.remove('active'); toggle.classList.remove('active'); toggle.innerHTML = '&#9998;'; deselect(); }
  toggle.addEventListener('click', function() { active ? close() : open(); });
  btnClose.addEventListener('click', close);

  document.addEventListener('keydown', function(e) {
    if (e.target.tagName === 'TEXTAREA' || e.target.tagName === 'INPUT') return;
    if (!active && (e.key === 'r' || e.key === 'R')) { e.preventDefault(); open(); return; }
    if (!active) return;
    var k = e.key.toLowerCase();
    if (k === 'r') { e.preventDefault(); close(); return; }
    if (k === 'escape') { deselect(); return; }
    if ((k === 'delete' || k === 'backspace') && selId) { e.preventDefault(); removeElem(selId); return; }
    if (k === 'b') { e.preventDefault(); setTool('rect'); return; }
    if (k === 'v') { e.preventDefault(); setTool('select'); return; }
    if (e.key === 'z' && (e.ctrlKey || e.metaKey)) { e.preventDefault(); btnUndo.click(); }
  });

  renderElems(); renderNotes(); resizeAll();
})();
