#!/bin/bash

set -e

MATRICE_DIR="src/matrici/images"
SOURCE_DIR="src/jekyll/assets/images"

echo "📦 Migrazione PNG originali → matrici..."

# Crea struttura directory
echo "📁 Creazione struttura..."
find "$SOURCE_DIR" -type d | while read dir; do
  target_dir=$(echo "$dir" | sed "s|$SOURCE_DIR|$MATRICE_DIR|")
  mkdir -p "$target_dir"
done

# Sposta PNG (tranne eccezioni)
echo "📸 Spostamento PNG..."
find "$SOURCE_DIR" -name "*.png" -type f | while read png; do
  filename=$(basename "$png")

  # Eccezioni: non spostare
  if [[ "$filename" == "favicon.png" ]] || \
     [[ "$filename" == "logo.png" ]] || \
     [[ "$filename" == "agesci_logo.png" ]]; then
    echo "   ⏭️  Skip (eccezione): $filename"
    continue
  fi

  # Sposta in matrici
  relative_path="${png#$SOURCE_DIR/}"
  target="$MATRICE_DIR/$relative_path"

  if [ ! -f "$target" ]; then
    mv "$png" "$target"
    echo "   ✅ Spostato: $filename"
  else
    echo "   ⚠️  Esiste già: $filename"
  fi
done

# Sposta originali con suffisso _orig
echo "📸 Spostamento _orig..."
find "$SOURCE_DIR" -name "*_orig.*" -type f | while read orig; do
  relative_path="${orig#$SOURCE_DIR/}"
  target="$MATRICE_DIR/$relative_path"
  mv "$orig" "$target"
  echo "   ✅ Spostato: $(basename "$orig")"
done

echo "✅ Migrazione completata!"
echo "📝 Prossimo step: esegui 'make optimize-images' per generare JPG"
