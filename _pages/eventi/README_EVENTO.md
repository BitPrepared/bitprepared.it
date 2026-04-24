# Template `evento` — Guida all'uso

Il template **`evento`** è lo standard per tutte le pagine di eventi su bitprepared.it.
Sostituisce il vecchio template `epppi` ed è pensato per essere riutilizzabile per qualsiasi tipo di evento (campi EG, EPPPI, stage, ecc.).

---

## Quick Start

Crea un nuovo file in `_pages/eventi/nome-evento.md` con questo frontmatter minimo:

```yaml
---
layout: evento
permalink: /eventi/nome-evento/
title: Titolo evento | Città Date
subtitle: Sottotitolo descrittivo
tags: [bitprepared, evento, tag1, tag2]
modified: YYYY-MM-DD
image: /assets/images/locandina.jpg

hero:
  title: "Titolo dell'evento"
  subtitle: "Sottotitolo o domanda chiave"
  location: "Città"
  date: "8-10 Maggio 2026"
  target: "Rover e Scolte in cammino"

cta:
  primary:
    url: "https://buonacaccia.net/Event.aspx?e=XXXXX"
    text: "ISCRIVITI SUBITO"
  secondary:
    url: "https://buonacaccia.net/Event.aspx?e=XXXXX"
    text: "Prenota su buonacaccia.net"

logistica:
  quando:
    icon: "fa-calendar"
    label: "Quando"
    date: "8-10 Maggio 2026"
    arrivo: "8/5 mattina"
    partenza: "10/5 pomeriggio"
  dove:
    icon: "fa-map-marker"
    label: "Dove"
    citta: "Bologna"
    luogo: "Chiesa San Vincenzo de Paoli"
  per_chi:
    icon: "fa-users"
    label: "Per chi"
    text: "Rover e Scolte AGESCI"
  posti:
    icon: "fa-bullseye"
    label: "Posti"
    max: 24
    min: 8
    waiting: 8
  come_arrivare:
    icon: "fa-car"
    label: "Come arrivare"
    text: "Info dettagliate verranno inviate agli iscritti"
  cosa_portare:
    icon: "fa-backpack"
    label: "Cosa portare"
    items: "Sacco a pelo, Abbigliamento comodo, Quaderno e penna, Buona volontà :)"

faq:
  - q: "Domanda frequente?"
    a: "Risposta alla domanda."
---
```

---

## Campi del Frontmatter

### Campi OBBLIGATORI

| Campo | Tipo | Descrizione |
|-------|------|-------------|
| `layout` | string | Deve essere `evento` |
| `hero` | object | Sezione hero principale |
| `hero.title` | string | Titolo grande dell'evento |
| `hero.subtitle` | string | Sottotitolo o domanda |
| `hero.location` | string | Città dell'evento |
| `hero.date` | string | Data periodo (es: "8-10 Maggio 2026") |
| `hero.target` | string | Target destinatari (es: "Rover e Scolte") |
| `cta` | object | Call-to-action per iscrizioni |
| `cta.primary.url` | string | Link primario (buonacaccia) |
| `cta.primary.text` | string | Testo bottone primario |
| `cta.secondary.url` | string | Link secondario |
| `cta.secondary.text` | string | Testo bottone secondario |
| `logistica` | object | Informazioni logistiche |
| `logistica.quando` | object | Date e orari |
| `logistica.dove` | object | Luogo |
| `logistica.posti` | object | Numero posti |
| `faq` | array | Lista domande frequenti |

### Campi OPZIONALI

#### Sezione Benefits (griglia iconata)
```yaml
benefits:
  - icon: "fa-gamepad"
    title: "Titolo benefit"
    desc: "Descrizione breve"
```

#### Sezione Target Audience ("Questo evento è per te se...")
```yaml
target_audience:
  - icon: "fa-mobile-alt"
    text: "Vivi in un mondo sempre più connesso, ma ti senti spesso"
    highlight: "disconnesso"
    tail: "dalla realtà"
```

#### Sezione Programma
```yaml
programma:
  - title: "TITOLO ATTIVITÀ"
    desc: "Descrizione dettagliata dell'attività."
```

#### Sezione Highlights ("X motivi per cui...")
```yaml
highlights:
  - "Motivo 1"
  - "Motivo 2"
  - "Motivo 3"

highlights_title: "10 motivi per cui questo evento è unico"  # opzionale, default fornito
```

#### Sezione Outcomes ("Cosa porterai a casa")
```yaml
outcomes:
  - "Outcome 1 concreto"
  - "Outcome 2 concreto"
  - "Outcome 3 concreto"

outcomes_title: "Cosa porterai a casa"  # opzionale, default fornito
```

#### Sezione Social
```yaml
social:
  title: "Condividi con la tua comunità"
  description: "Passaparola tra rover, scolte e capi."
  hashtags: "#AGESCI #BrancaRS #Evento"
```

---

## Icone FontAwesome

Puoi usare qualsiasi icona FontAwesome Free:
- Icone: `fa-calendar`, `fa-map-marker`, `fa-users`, `fa-gamepad`, `fa-newspaper`, `fa-globe`, `fa-handshake`, etc.
- Riferimento: [FontAwesome Free Icons](https://fontawesome.com/icons?d=gallery&m=free)

---

## SEO e Schema.org

Il template include automaticamente il markup **Schema.org JSON-LD** per i motori di ricerca:
- Tipo: `Event`
- Include: nome, date, luogo, capacità massima, link iscrizione

Non serve modificare nulla, i dati vengono presi dal frontmatter.

---

## Struttura della Pagina

L'ordine delle sezioni renderizzate è:

1. **Hero Section** — Titolo, sottotitolo, info chiave, CTA
2. **Benefits** (opzionale) — Griglia benefit
3. **Highlights** (opzionale) — Lista "X motivi"
4. **Target Audience** — "Questo evento è per te se..."
5. **Programma** (opzionale) — Lista attività
6. **Outcomes** (opzionale) — "Cosa porterai a casa"
7. **Logistica** — Quando, dove, posti, come arrivare, cosa portare
8. **FAQ** — Domande frequenti
9. **Locandina** — Immagine dell'evento
10. **Social** — Hashtag e condivisione
11. **Content** — Eventuale contenuto markdown aggiuntivo

---

## Customizzazione CSS

Il template usa le classi CSS `.evento-*` definite in `assets/css/evento-custom.css`.

Per customizzazioni specifiche di un evento, puoi usare inline styles nel frontmatter o nel content markdown.

---

## Esempio Completo

Vedi `_pages/eventi/epppi_rs.md` per un esempio completo di tutti i campi utilizzati.

---

## Nuove Features (2026)

### Event Status Badge

Mostra automaticamente un badge animato in base allo stato dell'evento:

```yaml
event_status: upcoming  # upcoming, past, soldout, last_chance
event_date: 2026-07-29  # YYYY-MM-DD (richiesto per upcoming, opzionale per altri)
```

**Valori possibili:**
- `upcoming` — Badge verde "PROSSIMO EVENTO" (con animazione pulse)
- `soldout` — Badge grigio "SOLD OUT" (senza animazione)
- `last_chance` — Badge rosso "ULTIMI POSTI" (con animazione pulse)
- `past` — Nessun badge (evento passato)

### Benefits Section

Sezione di cards iconate per mostrare i vantaggi dell'evento:

```yaml
benefits_title: "Perché partecipare"
benefits:
  - icon: "fa-camera"
    title: "Fotografia"
    desc: "Descrizione breve del benefit"
  - icon: "fa-map-marked-alt"
    title: "Mapping"
    desc: "Descrizione breve del benefit"
  # ... minimo 4 benefits raccomandati
```

**Note:**
- Minimo 4 benefits raccomandati per layout grid bilanciato
- Usa icone FontAwesome Free (prefisso `fa-`)
- Le cards hanno hover effect con lift e shadow

### Countdown Timer (Opzionale)

Timer dinamico per eventi futuri:

```yaml
event_status: upcoming
event_date: 2026-07-29  # YYYY-MM-DD
```

Il countdown appare automaticamente per eventi con `event_status: upcoming` e `event_date` definito.

**Nota:** Richiede JavaScript `/assets/js/countdown.js` (implementazione futura)

---

## Note Importanti

- **Immagini**: Carica le locandine in `assets/images/`
- **Permalink**: Usa `/eventi/nome-evento/` per URL puliti
- **Date aggiorna**: Aggiorna sempre il campo `modified` quando modifichi
- **Buonacaccia**: Usa link buonacaccia.net per le iscrizioni ufficiali
- **Tag**: Includi sempre `bitprepared` più tag specifici dell'evento

---

## Troubleshooting

### L'evento non compare nella homepage
- Controlla che `tags` includa `bitprepared`
- Verifica che il file sia in `_pages/eventi/`

### La sezione outcomes non appare
- Assicurati di avere l'array `outcomes:` nel frontmatter
- La sezione è condizionale: appare solo se `outcomes` è definito

### Icone non mostrano
- Verifica che il nome icona sia corretto (inizia con `fa-`)
- Controlla che FontAwesome sia caricato nel sito

### CSS non funziona
- Controlla che il file `assets/css/evento-custom.css` esista
- Verifica che `_includes/edit-button.html` includa il CSS corretto
