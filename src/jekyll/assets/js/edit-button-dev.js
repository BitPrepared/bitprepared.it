/**
 * Development-only Edit Button
 *
 * Caricato solo in development environment (jekyll.environment == 'development')
 * Apre MarkText per modificare il file markdown corrente
 *
 * Dipendenze: Data attributes sul tag <script>
 *   - data-project-path: PATH del progetto (da _config.yml)
 *   - data-page-path: PATH della pagina corrente
 */

(function() {
  'use strict';

  // Leggi configurazione dai data attributes dello script tag
  const scriptTag = document.currentScript || document.querySelector('script[src*="edit-button-dev.js"]');
  if (!scriptTag) {
    console.error('[Edit Button] Script tag non trovato');
    return;
  }

  const projectPath = scriptTag.getAttribute('data-project-path');
  const pagePath = scriptTag.getAttribute('data-page-path');

  if (!projectPath || !pagePath) {
    console.error('[Edit Button] Data attributes mancanti:', { projectPath, pagePath });
    return;
  }

  const markdownPath = `${projectPath}/${pagePath}`;
  console.log('[Edit Button] Inizializzato:', markdownPath);

  /**
   * Apre MarkText con il file markdown corrente
   */
  function openMarkText() {
    console.log('[Edit Button] Click icona modifica');

    if (!markdownPath) {
      console.error('[Edit Button] Nessun path markdown disponibile');
      showNotification('❌ Path markdown non trovato', 'error');
      return;
    }

    try {
      console.log('[Edit Button] File path:', markdownPath);
      const editorUri = `marktext://file/${markdownPath}`;
      console.log('[Edit Button] URI scheme:', editorUri);
      window.location.href = editorUri;
      showNotification('✅ Apertura MarkText...');
    } catch (error) {
      console.error('[Edit Button] Errore:', error);
      showNotification('❌ Errore apertura editor', 'error');
    }
  }

  /**
   * Mostra notifica temporanea
   * @param {string} message - Messaggio da mostrare
   * @param {string} type - 'success' o 'error'
   */
  function showNotification(message, type = 'success') {
    // Rimuovi notifica esistente
    const existing = document.querySelector('.edit-button-notification');
    if (existing) existing.remove();

    const notification = document.createElement('div');
    notification.className = 'edit-button-notification';
    notification.textContent = message;

    // Inline styles per notifica (development-only)
    notification.style.cssText = [
      'position: fixed',
      'top: 20px',
      'right: 20px',
      `background: ${type === 'error' ? '#ef4444' : '#10b981'}`,
      'color: white',
      'padding: 15px 20px',
      'border-radius: 8px',
      'box-shadow: 0 4px 12px rgba(0,0,0,0.15)',
      'z-index: 10001',
      'font-weight: 500',
      'font-family: system-ui, sans-serif'
    ].join(';');

    document.body.appendChild(notification);

    setTimeout(() => notification.remove(), 3000);
  }

  // Inizializza quando il DOM è pronto
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      window.editButtonOpenMarkText = openMarkText;
    });
  } else {
    window.editButtonOpenMarkText = openMarkText;
  }

  console.log('[Edit Button] Pronto');
})();
