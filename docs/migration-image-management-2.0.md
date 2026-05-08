# Migration Guide: Image Management 2.0

This guide explains how to migrate from the old image management system to Image Management 2.0.

## Overview

Image Management 2.0 introduces a structured, manifest-based approach to image processing that provides better organization, automatic optimization, and controlled conversions.

## Key Changes

### 1. New Directory Structure
```
src/matrici/images/
├── .locked                 # Protected images (no conversion)
├── .rules                  # Conversion rules
├── production/            # Main image categories
│   ├── eventi/            # Event posters and featured images
│   ├── software/          # Software screenshots
│   ├── loghi-branche/     # Branch logos
│   └── root/              # Global images (favicon, etc.)
├── source-icons/          # SVG sources for icon generation
├── supporto/             # Support files (excluded from processing)
└── _fullsize/           # Full-size source images
```

### 2. Manifest Files
- **`.locked`**: Defines images that should not be converted or optimized
- **`.rules`**: Defines conversion rules for different categories

### 3. New Scripts
- `generate-icons-from-svg.js`: Generates multiple icon sizes from SVG source
- `generate-image-placeholders.js`: Creates placeholder images for missing content
- `optimize-with-manifest.js`: Applies manifest rules to optimize images

## Migration Steps

### Step 1: Backup Existing Images
```bash
# Create a backup of current images
cp -r src/matrici/images src/matrici/images.backup
```

### Step 2: Organize Images into Categories
Move existing images into the appropriate production subdirectories:

```bash
# Event-related images
mv src/matrici/images/eventi/* src/matrici/images/production/eventi/

# Software screenshots  
mv src/matrici/images/software/* src/matrici/images/production/software/

# Branch logos
mv src/matrici/images/loghi/* src/matrici/images/production/loghi-branche/

# Root-level images
mv src/matrici/images/favicon* src/matrici/images/production/root/
mv src/matrici/images/apple-touch* src/matrici/images/production/root/
```

### Step 3: Set Up Manifest Files

#### .locked File
Protect images that should not be converted:
```
# Immagini "congelate" - non ottimizzare né convertire
generic-featured.png
agesci_logo.png
placeholder-blog.png
placeholder-news.png
```

#### .rules File
Define conversion rules for each category:
```
[production/eventi]
convert_to: jpg
dimensions: 3508x4961
quality: 85

[production/software]
convert_to: png
copy_only: true

[production/loghi-branche]
convert_to: png
copy_only: true

[production/root]
convert_to: jpg
dimensions: 1200x630
quality: 85
```

### Step 4: Create SVG Source Icon
Create an SVG source for generating icons:
```bash
# Create SVG source file
touch src/matrici/images/source-icons/site-icon.svg
```

Example SVG content:
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <rect width="512" height="512" fill="#003366"/>
  <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="white" font-size="48" font-family="Arial">BP</text>
</svg>
```

### Step 5: Generate Icons
Generate multiple icon sizes from SVG source:
```bash
node scripts/generate-icons-from-svg.js
```

This will create:
- Apple touch icons (72x72, 114x114, 144x144)
- Fallback Apple touch icon
- manifest.json for PWA support

### Step 6: Create Placeholders for Missing Images
Generate placeholder images for events and posts:
```bash
# Generate placeholders only for missing images
node scripts/generate-image-placeholders.js

# Force overwrite existing placeholders
node scripts/generate-image-placeholders.js --force
```

### Step 7: Optimize Images with Manifest Rules
Apply the manifest rules to optimize all production images:
```bash
node scripts/optimize-with-manifest.js
```

This will:
- Copy locked files without conversion
- Apply conversion rules based on category
- Skip supporto/ directory entirely
- Process only images in production/ directory

### Step 8: Update Jekyll References
Update Jekyll layouts and templates to use new image paths:
- Update image references in `_layouts/*.html`
- Update CSS paths in `assets/css/*.css`
- Update frontmatter references in pages

### Step 9: Test the Migration
```bash
# Validate image processing
make validate-graphics

# Check for broken links
make check-links

# Run visual regression tests
make visual-baseline
```

### Step 10: Clean Up Old Files
Remove old directories and files after successful migration:
```bash
# Remove old directories (after backup)
rm -rf src/matrici/images/old-directory

# Remove obsolete files
rm src/matrici/images/legacy-script.js
```

## New Commands

### Image Management
```bash
# Generate icons from SVG
node scripts/generate-icons-from-svg.js

# Generate image placeholders
node scripts/generate-image-placeholders.js

# Optimize images with manifest rules
node scripts/optimize-with-manifest.js
```

### Validation
```bash
# Validate image processing
make validate-graphics

# Check for broken links
make check-links

# Generate visual regression baseline
make visual-baseline
```

## Troubleshooting

### Common Issues

**1. Images not being processed**
- Check that files are in `production/` directory
- Verify file extensions are `.png`
- Check permissions on directories and files

**2. Conversion errors**
- Verify `.rules` file syntax
- Check that dimensions are valid (e.g., "1200x630")
- Ensure quality values are between 1-100

**3. Icon generation fails**
- Verify SVG file exists and is valid
- Check sharp package is installed
- Verify output directory permissions

**4. Placeholders not created**
- Check that YAML data files exist
- Verify event and ambientazione data
- Use `--force` flag to overwrite existing

### Getting Help

- Check `docs/IMAGE_GUIDE.md` for detailed specifications
- Review `README.md` for available commands
- Check script output for error messages

## Benefits of Migration

1. **Better Organization**: Structured directory system
2. **Automatic Optimization**: Images are converted based on category
3. **Protected Assets**: Locked files are preserved
4. **Icon Generation**: Automatic generation of multiple icon sizes
5. **Placeholder System**: Automatic placeholder creation
6. **Manifest-Based**: Rules defined in configuration files
7. **Support Exclusion**: Support files are automatically excluded

## Next Steps

After completing the migration:
- Update CI/CD pipelines to use new scripts
- Document new workflow for team members
- Establish regular maintenance schedule
- Monitor image processing performance