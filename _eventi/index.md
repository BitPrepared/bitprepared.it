---
title: Eventi Bit Prepared
layout: page
permalink: /eventi/
tags: [bitprepared, eventi, campi, stage]
---

<style>
/* Percorso Scout - Timeline Layout */
.eventi-percorso {
  position: relative;
  padding: var(--spacing-xl) var(--spacing-md);
  min-height: 80vh;
  background:
    linear-gradient(rgba(22, 22, 22, 0.85), rgba(22, 22, 22, 0.85)),
    url("data:image/svg+xml,%3Csvg width='1200' height='600' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M 100 500 Q 300 300 400 350 T 700 250 T 1000 150' stroke='%231a7f1a' stroke-width='4' fill='none' stroke-dasharray='10,10'/%3E%3Ccircle cx='100' cy='500' r='15' fill='%231a7f1a'/%3E%3Ccircle cx='400' cy='350' r='15' fill='%231a7f1a'/%3E%3Ccircle cx='700' cy='250' r='15' fill='%231a7f1a'/%3E%3Ccircle cx='1000' cy='150' r='15' fill='%231a7f1a'/%3E%3C/svg%3E") no-repeat center center;
  background-size: cover;
}

.percorso-header {
  text-align: center;
  margin-bottom: var(--spacing-xl);
  position: relative;
  z-index: 2;
}

.percorso-header h1 {
  font-size: 2.5rem;
  color: var(--color-light);
  margin-bottom: var(--spacing-sm);
}

.percorso-subtitle {
  font-size: 1.25rem;
  color: var(--color-accent);
  font-family: var(--font-display);
}

/* Timeline Container */
.percorso-timeline {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  max-width: 1200px;
  margin: 0 auto;
  position: relative;
  gap: var(--spacing-lg);
  padding: var(--spacing-xl) 0;
}

/* Linea che collega le tappe */
.percorso-timeline::before {
  content: '';
  position: absolute;
  top: 100px;
  left: 15%;
  right: 15%;
  height: 4px;
  background: linear-gradient(90deg, var(--color-secondary) 0%, var(--color-accent) 100%);
  z-index: 0;
}

/* Tappa del percorso */
.percorso-tappa {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  z-index: 1;
  max-width: 320px;
}

.tappa-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: var(--color-secondary);
  border: 4px solid var(--color-accent);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: var(--spacing-md);
  position: relative;
  z-index: 2;
  transition: transform var(--transition-base);
}

/* Colori specifici per branca */
.percorso-tappa:nth-child(1) .tappa-icon {
  background: #1a7f1a; /* Verde - EG */
  border-color: #00d9ff;
}

.percorso-tappa:nth-child(2) .tappa-icon {
  background: #cc0000; /* Rosso - RS */
  border-color: #ff6b6b;
}

.percorso-tappa:nth-child(3) .tappa-icon {
  background: #8b008b; /* Viola - Coca */
  border-color: #da70d6;
}

.percorso-tappa:hover .tappa-icon {
  transform: scale(1.1);
}

.percorso-tappa:nth-child(1):hover .tappa-icon {
  box-shadow: 0 0 30px rgba(0, 217, 255, 0.5);
}

.percorso-tappa:nth-child(2):hover .tappa-icon {
  box-shadow: 0 0 30px rgba(255, 107, 107, 0.5);
}

.percorso-tappa:nth-child(3):hover .tappa-icon {
  box-shadow: 0 0 30px rgba(218, 112, 214, 0.5);
}

.tappa-icon img {
  width: 60px;
  height: 60px;
  object-fit: contain;
}

.tappa-card {
  background: var(--color-white);
  border-radius: var(--border-radius);
  padding: var(--spacing-md);
  border: 2px solid var(--color-secondary);
  transition: all var(--transition-base);
}

.percorso-tappa:hover .tappa-card {
  transform: translateY(-8px);
  box-shadow: var(--shadow-lg);
  border-color: var(--color-accent);
}

.tappa-label {
  text-align: center;
  margin-bottom: var(--spacing-sm);
  font-family: var(--font-display);
  font-weight: 700;
  font-size: 1.25rem;
  color: var(--color-light);
}

.tappa-eta {
  text-align: center;
  font-size: 0.875rem;
  color: var(--color-accent);
  margin-bottom: var(--spacing-sm);
  font-family: var(--font-display);
}

.tappa-card h3 {
  font-size: 1.25rem;
  color: var(--color-primary);
  margin-bottom: var(--spacing-sm);
  text-align: center;
}

.tappa-card p {
  font-size: 0.95rem;
  color: var(--color-text-muted);
  margin-bottom: var(--spacing-md);
  text-align: center;
  line-height: 1.5;
}

.tappa-card .btn-primary {
  width: 100%;
  font-size: 0.9rem;
}

/* Responsive Mobile */
@media (max-width: 768px) {
  .eventi-percorso {
    padding: var(--spacing-lg) var(--spacing-sm);
  }

  .percorso-timeline {
    flex-direction: column;
    align-items: center;
    gap: var(--spacing-xl);
    padding: var(--spacing-md) 0;
  }

  .percorso-timeline::before {
    left: 50%;
    top: 0;
    bottom: 0;
    width: 4px;
    height: auto;
    transform: translateX(-50%);
  }

  .percorso-tappa {
    max-width: 100%;
  }

  .tappa-icon {
    margin-bottom: var(--spacing-sm);
  }

  .percorso-header h1 {
    font-size: 2rem;
  }
}
</style>

<div class="eventi-percorso">
  <header class="percorso-header">
    <h1>Il Percorso Bit Prepared</h1>
    <p class="percorso-subtitle">Dagli EG ai Capi: un cammino di crescita digitale</p>
  </header>

  <div class="percorso-timeline">

    <!-- Tappa 1: EG -->
    <article class="percorso-tappa">
      <div class="tappa-icon">
        <img src="/assets/images/loghi_branche/eg.png" alt="EG">
      </div>
      <p class="tappa-label">Esploratori/Guide</p>
      <p class="tappa-eta">11-16 anni</p>
      <div class="tappa-card">
        <h3>Campo di Competenza</h3>
        <p>Google, social network, fotoritocco, video editing, coding. Scopri le tecnologie mantenendo lo stile scout!</p>
        <a href="/eventi/campo-eg/" class="btn-primary">Scopri il campo</a>
      </div>
    </article>

    <!-- Tappa 2: R/S -->
    <article class="percorso-tappa">
      <div class="tappa-icon">
        <img src="/assets/images/loghi_branche/rs.png" alt="RS">
      </div>
      <p class="tappa-label">Rover/Scolte</p>
      <p class="tappa-eta">16-21 anni</p>
      <div class="tappa-card">
        <h3>EPPPI</h3>
        <p>La scelta politica nelle società iperconnesse. Come usare i social per agire? Workshop intensivi su cittadinanza digitale.</p>
        <a href="/eventi/epppi/" class="btn-primary">Scopri EPPPI</a>
      </div>
    </article>

    <!-- Tappa 3: Capi -->
    <article class="percorso-tappa">
      <div class="tappa-icon">
        <img src="/assets/images/loghi_branche/coca.png" alt="Capi">
      </div>
      <p class="tappa-label">Capi</p>
      <p class="tappa-eta">Adulti</p>
      <div class="tappa-card">
        <h3>Stage per Capi</h3>
        <p>Essere scout nell'era del Web 2.0. La legge scout riletta per il sempre connesso. Strumenti per la tua comunità.</p>
        <a href="/eventi/stage/" class="btn-primary">Scopri lo stage</a>
      </div>
    </article>

  </div>
</div>
