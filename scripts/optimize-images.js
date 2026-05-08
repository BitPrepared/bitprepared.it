console.log('🖼️  Ottimizzazione immagini con manifesti...');
const { execSync } = require('child_process');

try {
  execSync('node scripts/optimize-with-manifest.js', { stdio: 'inherit' });
  console.log('✅ Ottimizzazione completata');
} catch (error) {
  console.error('❌ Errore ottimizzazione:', error);
  process.exit(1);
}
