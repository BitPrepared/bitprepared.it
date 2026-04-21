#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'date'

class BlogPostGenerator
  def initialize(event_file, options = {})
    @event_file = event_file
    @options = options
    @event_data = load_event_data
  end

  def generate
    validate_event_file
    blog_data = extract_blog_data
    content = generate_content(blog_data)
    write_post(content)
  end

  private

  def load_event_data
    file_content = File.read(@event_file)

    # Split frontmatter and content
    if file_content =~ /^---$(.*?)^---$(.*)/m
      frontmatter = YAML.safe_load($1, permitted_classes: [Date, Time, Symbol])
      # Convert Date/Time objects to strings
      frontmatter = convert_dates_to_strings(frontmatter)
      content = $2
      { frontmatter: frontmatter, content: content }
    else
      raise "Formato file non valido. Manca frontmatter YAML."
    end
  end

  def convert_dates_to_strings(obj)
    case obj
    when Hash
      obj.transform_values { |v| convert_dates_to_strings(v) }
    when Array
      obj.map { |v| convert_dates_to_strings(v) }
    when Date, Time
      obj.strftime('%Y-%m-%d')
    else
      obj
    end
  end

  def validate_event_file
    unless File.exist?(@event_file)
      raise "File evento non trovato: #{@event_file}"
    end

    required_fields = ['title', 'hero', 'cta']
    required_fields.each do |field|
      unless @event_data[:frontmatter][field]
        raise "Campo richiesto mancante: #{field}"
      end
    end
  end

  def extract_blog_data
    frontmatter = @event_data[:frontmatter]
    hero = frontmatter['hero'] || {}
    cta = frontmatter['cta'] || {}
    logistica = frontmatter['logistica'] || {}

    # Extract date for filename and post
    event_date_str = hero['date']

    {
      # Frontmatter
      layout: 'post',
      title: frontmatter['title'],
      description: hero['subtitle'] || frontmatter['title'],
      modified: frontmatter['modified'] || Time.now.strftime('%Y-%m-%d'),
      author: 'bitprepared',
      category: 'eventi',
      tags: (frontmatter['tags'] || []) + ['blog'],
      featured: frontmatter['image'],
      comments: true,
      share: true,
      permalink: generate_permalink(frontmatter['title'], event_date_str),

      # Content data
      event_title: hero['title'],
      event_subtitle: hero['subtitle'],
      event_date: hero['date'],
      event_location: hero['location'],
      event_target: hero['target'],
      cta_text: cta.dig('primary', 'text'),
      cta_url: cta.dig('primary', 'url'),
      posti_max: logistica.dig('posti', 'max'),
      posti_min: logistica.dig('posti', 'min'),
      posti_waiting: logistica.dig('posti', 'waiting'),

      # Date for filename
      event_date_obj: event_date_str
    }
  end

  def generate_permalink(title, date_str)
    # Extract year from date string (format: "8-10 Maggio 2026")
    year = if date_str =~ /(\d{4})/
             $1
           else
             '2026'  # Fallback to current year
           end

    # Extract city and slugify title
    title_slug = title.downcase
                    .gsub(/[^a-z0-9\s-]/, '') # Remove special chars except space and hyphen
                    .gsub(/\s+/, '-') # Replace spaces with hyphens
                    .gsub(/-+/, '-') # Replace multiple hyphens with single
                    .gsub(/^-|-$/, '') # Remove leading/trailing hyphens

    "/blog/#{year}/#{title_slug}/"
  end

  def slugify(title)
    title.downcase
        .gsub(/[^a-z0-9\s-]/, '')
        .gsub(/\s+/, '-')
        .gsub(/-+/, '-')
        .gsub(/^-|-$/, '')
  end

  def generate_content(data)
    <<~MARKDOWN
---
layout: #{data[:layout]}
title: #{data[:title]}
description: "#{data[:description]}"
modified: #{data[:modified]}
author: #{data[:author]}
category: #{data[:category]}
tags: #{data[:tags].to_s.gsub('[', '').gsub(']', '').gsub('"', '')}
featured: #{data[:featured]}
comments: #{data[:comments]}
share: #{data[:share]}
permalink: #{data[:permalink]}
---

# #{data[:event_title]}

**#{data[:event_subtitle]}**

Un evento imperdibile per #{data[:event_target]} a #{data[:event_location]}, dal #{data[:event_date]}.

## 📋 Quando e Dove

- **Quando**: #{data[:event_date]}
- **Dove**: #{data[:event_location]}
- **Posti**: #{data[:posti_max]} massimo

## 🎯 Perché Partecipare

<!--
CUSTOM DESCRIPTION SECTION
============================
Modifica questa sezione con il tuo contenuto personalizzato.
Suggerimenti:
- Racconta perché questo evento è unico
- Condividi un aneddoto dello staff
- Spiega l'origine del tema
- Aggiungi una testimonianza di anni passati
-->

[DESCRIZIONE PERSONALIZZATA DA AGGIUNGERE QUI]

### Highlights dell'Evento

- L'unico evento che unisce POLITICA e TECNOLOGIA
- Non solo teoria: tocchi con mano realtà che funzionano
- Porti a casa strumenti concreti, non solo idee
- Hike urbano: scopri cooperative sociali ed economia solidale
- Simulazione Parlamento Europeo: sperimenta la democrazia

### Cosa Imparerai

- Consapevolezza su come il digitale influenza le tue scelte
- Strumenti pratici per riconoscere fake news e verificare informazioni
- Reti reali - Banca Etica, cooperative, comunità di impegno civile
- Esperienza democratica attraverso simulazione

## 📚 Programma

Il programma include sessioni interattive, laboratori pratici e momenti di riflessione.

## 💰 Costi e Iscrizioni

<!--
ISCRIZIONI SECTION
==================
Aggiungi qui informazioni su:
- Quota di partecipazione
- Deadline iscrizioni
- Modalità di pagamento
- Sconto early bird (se applicabile)
-->

Quota di partecipazione: [INSERISCI QUOTA]
Deadline iscrizioni: [INSERISCI DATA]

Posti disponibili: #{data[:posti_max]} massimo
Waiting list: #{data[:posti_waiting]} posti

## 🚀 Iscriviti Ora

Posti limitati! Non perdere l'opportunità di partecipare a questo evento unico.

[**#{data[:cta_text]}**](#{data[:cta_url]})

## ❓ Domande Frequenti

**L'evento è riservato a chi?**
Questo evento è riservato a #{data[:event_target]}.

**Come faccio a iscrivermi?**
Clicca sul pulsante sopra e segui le istruzioni su buonacaccia.net.

**Ho altre domande?**
Scrivi a info@bitprepared.it

---

*Evento organizzato da BitPrepared - Digito ergo sum*
MARKDOWN
  end

  def write_post(content)
    # Generate filename from date and title
    date_str = @event_data[:frontmatter]['hero']['date']
    if date_str =~ /(\d{1,2})-(\d{1,2}) (\w+) (\d{4})/
      year = $4
      day = sprintf('%02d', $1.to_i)
      # Default to month 05 if can't parse Italian month
      month = '05'
    else
      # Fallback to current date (approximate)
      year = '2026'
      month = '05'
      day = '08'
    end

    title_slug = slugify(@event_data[:frontmatter]['title'].split('|').first.strip)
    filename = "_posts/#{year}-#{month}-#{day}-#{title_slug}.md"

    # Check if file exists
    if File.exist?(filename) && !@options[:force]
      puts "⚠️  File esiste: #{filename}"
      puts "Usa --force per sovrascrivere"
      return
    end

    # Create _posts directory if it doesn't exist
    FileUtils.mkdir_p('_posts')

    # Write file
    File.write(filename, content)
    puts "✅ Blog post generato: #{filename}"
  end
end

# Parse command line arguments
if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts "Uso: ruby #{$PROGRAM_NAME} <evento_file> [--force]"
    puts ""
    puts "Esempio:"
    puts "  ruby #{$PROGRAM_NAME} _pages/eventi/epppi_rs.md"
    puts "  ruby #{$PROGRAM_NAME} _pages/eventi/epppi_rs.md --force"
    exit 1
  end

  event_file = ARGV[0]
  options = { force: ARGV.include?('--force') }

  begin
    generator = BlogPostGenerator.new(event_file, options)
    generator.generate
  rescue => e
    puts "❌ Errore: #{e.message}"
    exit 1
  end
end
