---
layout: default
title: Test Lookup
---

## Testing Liquid Lookup

{% for evento in site.eventi %}
  <h2>{{ evento.title }}</h2>
  <p>Slug: {{ evento.slug }}</p>
  <p>Permalink: {{ evento.permalink }}</p>
  <p>URL: {{ evento.url }}</p>
  <hr>
{% endfor %}

## Testing where clause

{% assign test_event = site.eventi | where: "slug", "campo-eg" | first %}
<h3>Found by slug:</h3>
<p>Title: {{ test_event.title }}</p>
<p>Permalink: {{ test_event.permalink }}</p>
<p>URL: {{ test_event.url }}</p>
