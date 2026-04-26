---
layout: page
title: Tags
permalink: /tags/
---

<div class="tags-archive">
  <h1 id="tags-title">Tutti i Tag</h1>

  <div id="all-tags-view">
    <ul class="tags-list">
      {% for tag in site.tags %}
      <li>
        <a href="#" data-tag="{{ tag[0] }}" class="tag-link">
          #{{ tag[0] }} <span class="tag-count">({{ tag[1].size }})</span>
        </a>
      </li>
      {% endfor %}
    </ul>
  </div>

  <div id="tag-view" style="display: none;">
    <header class="tag-header">
      <a href="/tags/" class="back-link">← Torna a tutti i tag</a>
      <h1 id="tag-title">#<span id="current-tag"></span></h1>
      <p class="tag-count"><span id="tag-count"></span> post con questo tag</p>
    </header>

    <div id="tag-posts" class="tag-posts"></div>
  </div>
</div>

<script src="/assets/js/tags.js"></script>
