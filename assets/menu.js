/* =============================================================================
   menu.js — Repli local pour le menu injecté dans <header></header>
   Utilisé si le script externe (filedn.eu) ne charge pas.
   ============================================================================= */

(function () {
  'use strict';
  const header = document.querySelector('header:not(.site-header)');
  if (!header || header.children.length > 0) return;

  header.className = 'site-header';
  header.innerHTML =
    '<h1>13345 Curseurs</h1>' +
    '<p class="subtitle">Collection locale de curseurs Windows ' +
    '— animés et statiques</p>';
})();
