#!/bin/bash

set -e

MATRICE_DIR="src/matrici/images"
SOURCE_DIR="src/jekyll/assets/images"

echo "📦 Migrazione PNG originali → matrici..."

# Validate source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ Errore: Directory sorgente non trovata: $SOURCE_DIR"
  exit 1
fi

# Crea struttura directory
echo "📁 Creazione struttura..."
while IFS= read -r dir; do
  target_dir=$(echo "$dir" | sed "s|$SOURCE_DIR|$MATRICE_DIR|")
  mkdir -p "$target_dir"
done < <(find "$SOURCE_DIR" -type d)

# Sposta PNG (tranne eccezioni)
echo "📸 Spostamento PNG..."
while IFS= read -r -d '' png; do
  filename=$(basename "$png")

  # Eccezioni: non spostare
  if [[ "$filename" == "favicon.png" ]] || \
     [[ "$filename" == "logo.png" ]] || \
     [[ "$filename" == "agesci_logo.png" ]] || \
     [[ "$dirname" == *"loghi_branche" ]] || \
     [[ "$dirname" == *"pages" ]]; then
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
done < <(find "$SOURCE_DIR" -name "*.png" -type f -print0)

# Sposta originali con suffisso _orig
echo "📸 Spostamento _orig..."
while IFS= read -r -d '' orig; do
  relative_path="${orig#$SOURCE_DIR/}"
  target="$MATRICE_DIR/$relative_path"

  if [ ! -f "$target" ]; then
    mv "$orig" "$target"
    echo "   ✅ Spostato: $(basename "$orig")"
  else
    echo "   ⚠️  Esiste già: $(basename "$orig")"
  fi
done < <(find "$SOURCE_DIR" -name "*_orig.*" -type f -print0)

echo "✅ Migrazione completata!"
echo "📝 Prossimo step: esegui 'make optimize-images' per generare JPG"
