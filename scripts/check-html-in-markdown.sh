#!/usr/bin/env bash
# Verifica che non ci sia HTML nei file markdown Jekyll
# Uso: ./check-html-in-markdown.sh [directory...]
# Default: controlla solo src/

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FOUND_HTML=0
TOTAL_FILES=0
FILES_WITH_HTML=()

# Pattern HTML da cercare (evita falsi positivi come commenti HTML in markdown)
HTML_PATTERN="<[a-zA-Z][^>]*>"

# Directory da controllare (default: src)
DIRS=("${@:-src}")

echo -e "${YELLOW}Verifica HTML nei file markdown Jekyll...${NC}"
echo "Directory: ${DIRS[*]}"
echo ""

# Trova tutti i file markdown nelle directory specificate
while IFS= read -r -d '' file; do
    TOTAL_FILES=$((TOTAL_FILES + 1))

    # Controlla se il file contiene tag HTML
    if grep -qE "$HTML_PATTERN" "$file" 2>/dev/null; then
        FOUND_HTML=$((FOUND_HTML + 1))
        FILES_WITH_HTML+=("$file")

        # Mostra le linee con HTML
        echo -e "${RED}✗ HTML trovato in: $file${NC}"
        grep -nE "$HTML_PATTERN" "$file" | sed 's/^/    /'
        echo ""
    fi
done < <(find "${DIRS[@]}" -type f \( -name "*.md" -o -name "*.markdown" \) -not -path "*/node_modules/*" -print0)

# Riassunto
echo "----------------------------------------"
echo "File totali controllati: $TOTAL_FILES"
echo -e "File con HTML: ${RED}$FOUND_HTML${NC}"

if [ $FOUND_HTML -gt 0 ]; then
    echo ""
    echo -e "${RED}✗ Fallimento: Trovato HTML in $FOUND_HTML file markdown${NC}"
    echo ""
    echo "File con HTML:"
    printf '  - %s\n' "${FILES_WITH_HTML[@]}"
    exit 1
else
    echo -e "${GREEN}✓ Successo: Nessun HTML trovato nei file markdown${NC}"
    exit 0
fi
