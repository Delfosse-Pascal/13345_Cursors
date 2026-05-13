/* =============================================================================
   script.js — Comportements communs (thème, lightbox, navigation iframe)
   ============================================================================= */

(function () {
  'use strict';

  /* ---- Mode sombre / clair (persisté via localStorage) --------------------- */
  const THEME_KEY = '13345_theme';
  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    try { localStorage.setItem(THEME_KEY, theme); } catch (e) { /* ignore */ }
    const btn = document.getElementById('btn-theme');
    if (btn) btn.textContent = (theme === 'light') ? 'Mode sombre' : 'Mode clair';
  }
  function initTheme() {
    let saved = 'dark';
    try { saved = localStorage.getItem(THEME_KEY) || 'dark'; } catch (e) { /* ignore */ }
    applyTheme(saved);
    const btn = document.getElementById('btn-theme');
    if (btn) btn.addEventListener('click', () => {
      const current = document.documentElement.getAttribute('data-theme') || 'dark';
      applyTheme(current === 'dark' ? 'light' : 'dark');
    });
  }

  /* ---- Lightbox image (clic = agrandir, Echap = fermer) -------------------- */
  function ensureLightbox() {
    let lb = document.getElementById('lightbox');
    if (lb) return lb;
    lb = document.createElement('div');
    lb.id = 'lightbox';
    lb.className = 'lightbox';
    lb.innerHTML =
      '<button class="lb-close" aria-label="Fermer">✕ Fermer</button>' +
      '<img alt="Aperçu agrandi">' +
      '<div class="lb-info"></div>';
    document.body.appendChild(lb);
    lb.addEventListener('click', (e) => {
      if (e.target === lb || e.target.classList.contains('lb-close')) {
        closeLightbox();
      }
    });
    return lb;
  }
  function openLightbox(src, info) {
    const lb = ensureLightbox();
    lb.querySelector('img').src = src;
    lb.querySelector('.lb-info').textContent = info || '';
    lb.classList.add('open');
  }
  function closeLightbox() {
    const lb = document.getElementById('lightbox');
    if (lb) lb.classList.remove('open');
  }
  function initLightbox() {
    document.addEventListener('click', (e) => {
      // Cas 1 : élément explicitement marqué data-lightbox
      let target = e.target.closest('[data-lightbox]');
      if (target) {
        e.preventDefault();
        const src = target.getAttribute('data-lightbox') || target.getAttribute('href');
        const info = target.getAttribute('data-info') || '';
        openLightbox(src, info);
        return;
      }
      // Cas 2 : clic sur l'aperçu d'un curseur (.cursor-card .preview)
      const preview = e.target.closest('.cursor-card .preview');
      if (preview) {
        e.preventDefault();
        const card = preview.closest('.cursor-card');
        const img = preview.querySelector('img');
        const src = img ? img.getAttribute('src') : '';
        if (!src) return;
        const name = card.querySelector('.filename')?.textContent || '';
        const meta = card.querySelector('.meta')?.textContent || '';
        openLightbox(src, name + ' — ' + meta);
      }
    });
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') closeLightbox();
    });
  }

  /* ---- Animation d'apparition progressive --------------------------------- */
  function staggerFadeIn() {
    const items = document.querySelectorAll('.cursor-card, .thumb');
    items.forEach((el, i) => {
      el.classList.add('fade-in');
      el.style.animationDelay = (Math.min(i, 30) * 0.02) + 's';
    });
  }

  /* ---- Init --------------------------------------------------------------- */
  document.addEventListener('DOMContentLoaded', () => {
    initTheme();
    initLightbox();
    staggerFadeIn();
  });

  /* ---- API publique (utilisé par index.html racine pour la musique) ------- */
  window.Site13345 = { applyTheme, openLightbox, closeLightbox };
})();
