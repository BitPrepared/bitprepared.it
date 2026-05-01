const fs = require('fs');

// Create a minimal 512x512 PNG placeholder
// This is a base64 encoded 1x1 green PNG, scaled
const pngPlaceholder = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==', 'base64');

fs.writeFileSync('assets/images/logo.png', pngPlaceholder);
console.log('✅ Logo placeholder created: assets/images/logo.png');
console.log('⚠️  This is a placeholder - replace with actual Bit Prepared logo design');
