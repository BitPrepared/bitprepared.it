#!/bin/bash
# Create simple Bit Prepared logo using ImageMagick

convert -size 512x512 xc:none \
  -fill "#0a3d0a" \
  -font DejaVu-Sans-Bold \
  -pointsize 80 \
  -gravity center \
  -annotate +0-30 "Bit" \
  -annotate +0+50 "Prepared" \
  assets/images/logo.png

if [ -f assets/images/logo.png ]; then
  echo "✅ Logo created: assets/images/logo.png"
  identify assets/images/logo.png
else
  echo "❌ Logo creation failed"
fi
