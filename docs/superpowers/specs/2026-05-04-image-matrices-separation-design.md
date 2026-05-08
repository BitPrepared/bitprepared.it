# Design Document: Separazione Matrici/Immagini Ottimizzate

**Data:** 2026-05-04
**Status:** Design Approved
**Autore:** Claude + User

## Panoramica

Separare immagini originali (PNG) da versioni ottimizzate (JPG) creando archivio `src/matrici/images/` per originali, mantenendo `src/jekyll/assets/images/` solo per versioni produzione.

## Problema

Attualmente `src/jekyll/assets/images/` contiene sia PNG originali che JPG ottimizzati, creando confusione e spreco spazio. Vuoi separare netta: originali in `matrici/`, ottimizzati in `images/`.

## Soluzione

**Approccio 1 (Approvato): Rifattoria Completa**

Sposta `src/jekyll/assets/matrici/` → `src/matrici/images/` (fuori da Jekyll), aggiorna tutti script per leggere da `matrici/` e scrivere in `images/`.

## Architettura

```
src/matrici/images/ (PNG originali)
    ↓ [make optimize-images]
src/jekyll/assets/images/ (JPG ottimizzati)
    ↓ [jekyll build]
output/_site/assets/images/ (pubblicati)
```

**Principi:**
- `src/matrices/` = archivio originali (non toccato da Jekyll)
- `src/jekyll/assets/images/` = solo versioni ottimizzate per produzione
- Script leggono da `src/matrici/images/`, scrivono in `src/jekyll/assets/images/`
- Placeholder in `src/matrici/images/` segnalano originali mancanti
- Validazione verifica solo `src/jekyll/assets/images/`

## Struttura Directory

```
src/
├── matrici/                    # NUOVO - archivio originali
│   └── images/                 # specchia structure di jekyll/assets/images/
│       ├── _fullsize/
│       ├── campo-eg/
│       │   └── locandina_campo-eg_*.png
│       ├── epppi/
│       │   ├── locandina_epppi_*.png
│       │   └── epppi-*-featured.png
│       ├── loghi_branche/
│       ├── pages/
│       ├── agesci_logo.png
│       ├── favicon.png
│       ├── generic-featured.png
│       └── header_orig.jpg
│
└── jekyll/
    └── assets/
        └── images/             # solo versioni ottimizzate JPG
            ├── _fullsize/
            ├── campo-eg/
            │   └── locandina_campo-eg_*.jpg
            ├── epppi/
            │   ├── locandina_epppi_*.jpg
            │   └── epppi-*-featured.jpg
            ├── loghi_branche/
            ├── pages/
            ├── agesci_logo.png  # eccezione: grafica piccola
            ├── favicon.ico      # eccezione: formato speciale
            ├── generic-featured.jpg
            └── header.jpg
```

**Eccezioni (non ottimizzate):**
- Grafica piccola (< 50KB): `favicon.png`, `logo.png`, `agesci_logo.png`
- Format speciali: `favicon.ico`
- Questi restano solo in `src/jekyll/assets/images/`

## Componenti

### 1. Makefile

**Nuove variabili:**
```makefile
MATRICE_DIR = src/matrici/images
OPTIMIZE_DIR = src/jekyll/assets/images
```

**Target aggiornati:**
- `optimize-volantini`: Legge PNG da `MATRICE_DIR`, genera JPG in `OPTIMIZE_DIR`
- `optimize-featured`: Stesso pattern
- `optimize-generic`: Con fallback se non esiste matrice

**Nuovi target:**
- `migrate-images`: Esegue script migrazione
- `validate-images`: Valida specifiche JPG ottimizzati

### 2. Script Migrazione

**File:** `scripts/migrate-images-to-matrici.sh`

**Logica:**
1. Crea struttura directory speculare in `src/matrici/images/`
2. Sposta PNG da `src/jekyll/assets/images/` → `src/matrici/images/`
3. Mantiene eccezioni in place (favicon.png, logo.png, agesci_logo.png)
4. Sposta file `*_orig.*` (originali con suffisso)
5. Non sovrascrive se esiste già

### 3. Script Placeholder

**Modifiche:**
- `scripts/generate-image-placeholders.js`: Genera in `src/matrici/images/`
- `scripts/check-image-placeholders.js`: Controlla solo `src/matrici/images/`

**Logica:**
- Placeholder = manca originale PNG
- CI blocca se trova placeholder in matrici

### 4. Script Validazione

**Nuovo file:** `scripts/validate-optimized-images.js`

**Validazioni per tipo:**
- **Volantini** (`locandina_*.jpg`): 3508×4961px, JPG, max 500KB
- **Featured** (`*-featured.jpg`): 1200×630px, JPG, max 200KB
- **Generic** (`generic-featured.jpg`): 1200×630px, JPG, max 300KB

**Controlla solo** `src/jekyll/assets/images/` (versioni finali).

## Documentazione

**Aggiornamenti `docs/IMAGE_GUIDE.md`:**

1. Nuova sezione "Archivio Originali (Matrici)" dopo "Panoramica"
2. Aggiorna "Metodo 1": spiega flusso matrici → ottimizzazione → images
3. Aggiorna "Workflow Completo": sostituisci riferimenti directory

**Nuovi comandi Makefile `help`:**
- `migrate-images` - Sposta PNG originali in src/matrici/images/
- `validate-images` - Valida specifiche immagini ottimizzate

## Testing

### 1. Test Migrazione
```bash
chmod +x scripts/migrate-images-to-matrici.sh
./scripts/migrate-images-to-matrici.sh

# Verifica
find src/matrici/images/ -name "*.png" | wc -l  # > 0
test -f src/jekyll/assets/images/favicon.png  # eccezione ok
test -f src/jekyll/assets/images/logo.png  # eccezione ok
```

### 2. Test Ottimizzazione
```bash
make optimize-images

# Verifica
find src/jekyll/assets/images/ -name "locandina_*.jpg" | wc -l
test -f src/jekyll/assets/images/generic-featured.jpg
```

### 3. Test Placeholder
```bash
make generate-placeholders

# Verifica posizione
find src/matrici/images/ -name "*.png" -exec grep -l '<placeholder>' {} \;
```

### 4. Test Validazione
```bash
make validate-images  # deve passare senza errori
```

### 5. Test Jekyll Build
```bash
make build

# Verifica
test -d output/_site/assets/images/  # pubblicato
test ! -d output/_site/matrici/  # NON pubblicato
```

### 6. Test Regressioni Visive
```bash
make validate-graphics
```

## Checklist Implementazione

1. **Setup struttura**
   - [ ] Crea `src/matrici/images/` vuoto
   - [ ] Test: directory creata

2. **Script migrazione**
   - [ ] Crea `scripts/migrate-images-to-matrici.sh`
   - [ ] Rendi eseguibile
   - [ ] Test: esegui migrazione
   - [ ] Verifica: PNG spostati, eccezioni rimaste

3. **Aggiorna Makefile**
   - [ ] Modifica `optimize-volantini`
   - [ ] Modifica `optimize-featured`
   - [ ] Modifica `optimize-generic`
   - [ ] Aggiungi `validate-images` target
   - [ ] Aggiungi `migrate-images` target
   - [ ] Test: `make optimize-images`

4. **Script placeholder**
   - [ ] Modifica `scripts/generate-image-placeholders.js`
   - [ ] Modifica `scripts/check-image-placeholders.js`
   - [ ] Test: placeholder in `src/matrici/images/`

5. **Script validazione**
   - [ ] Crea `scripts/validate-optimized-images.js`
   - [ ] Test: `make validate-images`

6. **Documentazione**
   - [ ] Aggiorna `docs/IMAGE_GUIDE.md`
   - [ ] Aggiorna Makefile `help`

7. **Test finali**
   - [ ] `make build`
   - [ ] Verifica output: no `matrici/` in `_site`
   - [ ] `make validate-graphics`

## Trade-offs

**Vantaggi:**
- Pulito: `matrici/` completamente separato da assets
- Jekyll non tocca matrici (niente exclude)
- Facile manutenzione
- Nessuna sovrapposizione file

**Svantaggi:**
- Più lavoro iniziale (aggiornare tutti script)

## Alternative Considerate

**Approccio 2 (Scartato):** Minimale con `exclude:` in `_config.yml`
- Meno pulito: `matrici/` ancora dentro assets
- Jekyll processa exclude ogni build

**Approccio 3 (Scartato):** Ibrido con flag
- Complessità inutile per questo caso d'uso

## Riferimenti

- **Design document:** questo file
- **Implementation plan:** `docs/superpowers/plans/2026-05-04-image-matrices-separation.md` (da creare)
- **IMAGE_GUIDE.md:** `docs/IMAGE_GUIDE.md` (da aggiornare)
- **Makefile:** `Makefile` root progetto
