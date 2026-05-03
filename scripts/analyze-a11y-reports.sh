#!/bin/bash
# Analizza report accessibilità e genera summary

REPORTS_DIR="${1:-output/accessibility/reports}"
SCRIPT_DIR="$(dirname "$0")"

echo "# Accessibility Audit Summary"
echo ""
echo "Generated: $(date)"
echo ""

# Find all Lighthouse reports (both .json and no-extension files)
LIGHTHOUSE_FILES=()
if [ -d "$REPORTS_DIR/lighthouse" ]; then
  while IFS= read -r file; do
    [[ ! "$file" =~ \.report\.json$ ]] && LIGHTHOUSE_FILES+=("$file")
  done < <(find "$REPORTS_DIR/lighthouse" -type f \( -name "*.json" -o -type f ! -name "*" \) 2>/dev/null | sort)
fi

# Find all axe-core reports
AXE_FILES=()
if [ -d "$REPORTS_DIR/axe" ]; then
  while IFS= read -r file; do
    AXE_FILES+=("$file")
  done < <(find "$REPORTS_DIR/axe" -type f -name "*.json" 2>/dev/null | sort)
fi

if [ ${#LIGHTHOUSE_FILES[@]} -eq 0 ] && [ ${#AXE_FILES[@]} -eq 0 ]; then
  echo "⚠️  No reports found in $REPORTS_DIR"
  echo "Run 'make accessibility-audit' first"
  exit 1
fi

# Analyze each Lighthouse report
for lighthouse_file in "${LIGHTHOUSE_FILES[@]}"; do
  page_name=$(basename "$lighthouse_file" .json)
  echo "## Lighthouse: $page_name"
  echo ""
  node "$SCRIPT_DIR/analyze-lighthouse.js" "$lighthouse_file"
  echo ""
done

# Analyze each axe-core report
for axe_file in "${AXE_FILES[@]}"; do
  page_name=$(basename "$axe_file" .json)
  echo "## axe-core Violations: $page_name"
  echo ""
  node "$SCRIPT_DIR/analyze-axe.js" "$axe_file"
  echo ""
  node "$SCRIPT_DIR/analyze-fixes.js" "$axe_file"
  echo ""
done

echo "## Files Analyzed"
echo "**Lighthouse reports:** ${#LIGHTHOUSE_FILES[@]}"
for file in "${LIGHTHOUSE_FILES[@]}"; do
  echo "- \`$file\`"
done
echo ""
echo "**axe-core reports:** ${#AXE_FILES[@]}"
for file in "${AXE_FILES[@]}"; do
  echo "- \`$file\`"
done
