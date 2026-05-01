const fs = require('fs');
const path = require('path');
const xml2js = require('xml2js');

async function extractPagesFromSitemap() {
  const sitemapPath = path.join(__dirname, '../../_site/sitemap.xml');

  if (!fs.existsSync(sitemapPath)) {
    console.error('❌ Sitemap non trovata: _site/sitemap.xml');
    console.error('   Esegui prima: make build');
    process.exit(1);
  }

  const xmlContent = fs.readFileSync(sitemapPath, 'utf8');

  try {
    const parser = new xml2js.Parser();
    const result = await parser.parseStringPromise(xmlContent);

    const urls = result.urlset.url
      .map(item => item.loc[0])
      .filter(url => {
        // Filtra URL di sistema e non valide
        return !url.includes('node_modules') &&
               !url.includes('test-lookup.html') &&
               !url.includes('/screenshots/') &&
               !url.includes('vendor/') &&
               !url.includes('/scripts/') &&
               (url.startsWith('https://www.bitprepared.it/') ||
                url.startsWith('http://localhost:4000/') ||
                url.startsWith('http://0.0.0.0:4000/'));
      })
      .map(url => {
        // Normalizza URL per testing (rimuovi dominio)
        if (url.startsWith('https://www.bitprepared.it')) {
          return url.replace('https://www.bitprepared.it', '');
        } else if (url.startsWith('http://localhost:4000')) {
          return url.replace('http://localhost:4000', '');
        } else if (url.startsWith('http://0.0.0.0:4000')) {
          return url.replace('http://0.0.0.0:4000', '');
        }
        return url;
      })
      .filter(url => url.length > 0); // Rimuovi stringhe vuote

    return urls;
  } catch (error) {
    console.error('❌ Errore parsing sitemap:', error.message);
    process.exit(1);
  }
}

// Se eseguito direttamente, stampa le pagine
if (require.main === module) {
  extractPagesFromSitemap().then(pages => {
    console.log(`\n📄 ${pages.length} pagine trovate nella sitemap:\n`);
    pages.forEach((page, index) => {
      console.log(`   ${index + 1}. ${page}`);
    });
  }).catch(error => {
    console.error('Errore:', error);
    process.exit(1);
  });
}

module.exports = { extractPagesFromSitemap };
