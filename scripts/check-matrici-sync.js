#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Function to check if files from matrici production are present in assets
function main() {
    try {
        const matriciDir = path.join(__dirname, '..', 'src', 'matrici', 'images');
        const assetsDir = path.join(__dirname, '..', 'src', 'jekyll', 'assets', 'images');
        const productionDir = path.join(matriciDir, 'production');

        // Check if directories exist
        if (!fs.existsSync(matriciDir)) {
            console.error('❌ Matrici images directory not found:', matriciDir);
            process.exit(1);
        }

        if (!fs.existsSync(assetsDir)) {
            console.error('❌ Assets images directory not found:', assetsDir);
            process.exit(1);
        }

        if (!fs.existsSync(productionDir)) {
            console.error('❌ Production directory not found:', productionDir);
            process.exit(1);
        }

        console.log('🔍 Checking matrici → assets sync...');

        // Get all PNG files from production directory
        const pngFiles = [];
        function findPngFiles(dir) {
            const items = fs.readdirSync(dir);
            for (const item of items) {
                const fullPath = path.join(dir, item);
                const stat = fs.statSync(fullPath);

                if (stat.isDirectory()) {
                    findPngFiles(fullPath);
                } else if (item.toLowerCase().endsWith('.png')) {
                    const relativePath = path.relative(productionDir, fullPath);
                    pngFiles.push({
                        sourcePath: relativePath,
                        sourceFull: fullPath,
                        baseName: path.basename(relativePath, '.png')
                    });
                }
            }
        }

        findPngFiles(productionDir);
        console.log(`📊 Found ${pngFiles.length} PNG files in matrici/production/`);

        let syncedCount = 0;
        let missingCount = 0;

        // Check locked files first
        const lockedFile = path.join(matriciDir, '.locked');
        const lockedFiles = [];
        if (fs.existsSync(lockedFile)) {
            const lockedContent = fs.readFileSync(lockedFile, 'utf8');
            lockedFiles.push(...lockedContent.split('\n').filter(line => line.trim() && !line.startsWith('#')));
        }

        // Check each file exists in assets (with correct extension)
        for (const file of pngFiles) {
            let found = false;

            // Check if converted file exists (for events: png -> jpg)
            if (file.sourcePath.startsWith('eventi/')) {
                const jpgPath = path.join(assetsDir, file.sourcePath.replace('.png', '.jpg'));
                if (fs.existsSync(jpgPath)) {
                    found = true;
                    syncedCount++;
                }
            }
            // Check if copied file exists (for software, loghi-branche: png -> png)
            else if (file.sourcePath.startsWith('software/') || file.sourcePath.startsWith('loghi-branche/')) {
                const pngPath = path.join(assetsDir, file.sourcePath);
                if (fs.existsSync(pngPath)) {
                    found = true;
                    syncedCount++;
                }
            }
            // Check if converted file exists (for root: png -> jpg)
            else if (file.sourcePath.startsWith('root/')) {
                // Check both converted JPG version and original PNG version for locked files
                const jpgPath = path.join(assetsDir, file.sourcePath.replace('.png', '.jpg'));
                const pngPath = path.join(assetsDir, file.sourcePath);

                if (fs.existsSync(jpgPath)) {
                    found = true;
                    syncedCount++;
                } else if (fs.existsSync(pngPath)) {
                    found = true;
                    syncedCount++;
                }
            }
            // Check if copied file exists (for pages: png -> png)
            else if (file.sourcePath.startsWith('pages/')) {
                const pngPath = path.join(assetsDir, file.sourcePath);
                if (fs.existsSync(pngPath)) {
                    found = true;
                    syncedCount++;
                }
            }

            if (!found) {
                console.log(`❌ Missing in assets: ${file.sourcePath}`);
                missingCount++;
            }
        }

        console.log('\n📋 Summary:');
        console.log(`✅ Syncronized: ${syncedCount}`);
        console.log(`❌ Missing: ${missingCount}`);

        if (missingCount > 0) {
            console.log('\n❌ Matrici and assets are out of sync!');
            console.log('Run: make optimize-images');
            process.exit(1);
        } else {
            console.log('✅ Matrici and assets are synchronized!');
        }

    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = { main };