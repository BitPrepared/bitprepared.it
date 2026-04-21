# Checklist Sviluppo BitPrepared

Checklist rapida per verificare passi prima di commit/merge.

## ✅ Prima di Commit Locale

- [ ] **Modifiche testate localmente**
  - [ ] `make serve` funziona
  - [ ] Pagina/i modificate caricate correttamente
  - [ ] Nessun errore in console browser

- [ ] **Visual regression eseguita** (se modifiche CSS/layout/template)
  - [ ] `make validate-graphics` passato
  - [ ] `screenshots/report/index.html` reviewato (se fallito)
  - [ ] Baseline aggiornata se differenze accettabili

- [ ] **Codice pulito**
  - [ ] Nessun `console.log` lasciato
  - [ ] Codice formattato
  - [ ] Commenti chiari se necessario

---

## ✅ Prima di Aprire PR

- [ ] **Branch pulito**
  - [ ] `rebase main` eseguito
  - [ ] Nessun commit di merge
  - [ ] Commit messaggi chiari

- [ ] **Test completi**
  - [ ] Visual regression passata
  - [ ] Tutte le pagine nuove funzionano
  - [ ] Nessun regressione

- [ ] **Documentazione**
  - [ ] CHANGELOG aggiornato
  - [ ] Nuove pagine documentate se necessario
  - [ ] README aggiornato se cambia workflow

- [ ] **Baseline**
  - [ ] `tests/visual-baseline/` committata se aggiornata
  - [ ] Capture.js aggiornato se nuove pagine

---

## ✅ Prima di Merge in Main

- [ ] **PR approvata**
  - [ ] Code review completata
  - [ ] Tutti i commenti indirizzati

- [ ] **CI/CD verde**
  - [ ] GitHub Actions passati
  - [ ] Nessun errore build

- [ ] **Visual regression finale**
  - [ ] `make validate-graphics` eseguito su branch aggiornato
  - [ ] Report HTML reviewato
  - [ ] Zero failures

- [ ] **Deployment preparato**
  - [ ] Backup backup站点 fatto (se necessario)
  - [ ] Finestra di manutenzione pianificata (se production)

---

## 🎨 Modifica Grafica/CSS

- [ ] **Pre-modifica**
  - [ ] Backup CSS corrente (git stash o branch)
  - [ ] Screenshot prima page modifiche
  - [ ] Baseline esistente salvata

- [ ] **Durante sviluppo**
  - [ ] Test in tutti i viewports (desktop, tablet, mobile)
  - [ ] Test cross-browser (Chrome, Firefox)
  - [ ] Verifica responsive design

- [ ] **Post-modifica**
  - [ ] `make validate-graphics` eseguito
  - [ ] Diff images reviewate
  - [ ] Bug grafici fixati OR baseline aggiornata
  - [ ] Commit con messaggio descrittivo

---

## 📄 Nuova Pagina

- [ ] **Creazione**
  - [ ] File creato in `_pages/` con frontmatter valido
  - [ ] Layout assegnato correttamente
  - [ ] Titolo e meta tag impostati

- [ ] **Contenuto**
  - [ ] Contenuto completo e formattato
  - [ ] Link testati
  - [ ] Immagini ottimizzate

- [ ] **Navigation**
  - [ ] Link da altre pagine aggiunto
  - [ ] Menu aggiornato se necessario
  - [ ] Breadcrumb funzionante

- [ ] **Visual regression**
  - [ ] Pagina aggiunta a `scripts/visual-regression/capture.js`
  - [ ] `make visual-baseline` eseguito
  - [ ] Baseline committata

---

## 🔧 Modifica Template Jekyll

- [ ] **Pre-modifica**
  - [ ] Template originale salvato (git diff)
  - [ ] Impatto valutato su tutte le pagine

- [ ] **Testing**
  - [ ] Tutte le pagine che usano template testate
  - [ ] Edge cases verificati
  - [ ] Visual regression passata

- [ ] **Post-modifica**
  - [ ] `make validate-graphics` eseguito
  - [ ] Report reviewato per regressioni
  - [ ] Baseline aggiornata se necessario

---

## 🚨 Modifiche Critiche (Produzione)

⚠️ **Richiede attenzione extra**

- [ ] **Backup completo**
  - [ ] Database backup fatto
  - [ ] File system backup fatto
  - [ ] Git tag per rollback veloce

- [ ] **Testing esteso**
  - [ ] Visual regression su tutti i 57 test
  - [ ] Manual testing su pagine critiche
  - [ ] Load testing se necessario

- [ ] **Deployment plan**
  - [ ] Rollback plan testato
  - [ ] Monitoring configurato
  - [ ] Notifiche impostate

---

## 🐛 Bug Fix (Non Grafico)

- [ ] **Identificazione**
  - [ ] Bug riprodotto localmente
  - [ ] Root cause identificata

- [ ] **Fix**
  - [ ] Fix implementato
  - [ ] Fix testato
  - [ ] Regression testing fatto

- [ ] **Validazione**
  - [ ] `make validate-graphics` opzionale ma consigliato
  - [ ] Dovrebbe passare senza modifiche

---

## 📋 Quick Commands

```bash
# Server test
make serve

# Visual regression
make validate-graphics      # Valida
make visual-baseline        # Aggiorna baseline
make visual-clean          # Pulisci

# Mostra workflow completo
make workflow

# Mostra questa checklist
cat docs/CHECKLIST.md
```

---

**Versione**: 1.0.0
**Aggiornamento**: 2026-04-21

**Uso**: Stampa questo documento o tienilo aperto in side panel durante sviluppo.
