const fs = require('fs');

// Extract critical CSS manually (simplified approach)
const criticalCSS = `
/* Critical CSS - Above the fold styles */
.hero-title{color:#E8F5E8}
.hero-subtitle{color:#E8F5E8}
.hero{background:linear-gradient(135deg,#0a3d0a 0%,#1a7f1a 100%)}
.bg-white{background-color:#fff}
.text-brand-dark{color:#0a3d0a}
.text-light{color:#E8F5E8}
.btn{display:inline-block;text-align:center;text-decoration:none;font-weight:600;padding:0.75rem 1.5rem;border-radius:2rem;cursor:pointer;transition:all 150ms ease-out}
.btn-event{background:#1a7f1a;color:#fff}
`;

fs.writeFileSync('assets/css/critical.css', criticalCSS.trim());
console.log('✅ Critical CSS extracted');
console.log('📄 File size:', criticalCSS.trim().length, 'bytes');
