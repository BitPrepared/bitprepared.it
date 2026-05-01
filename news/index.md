---
layout: page
title: News
permalink: /news/
---

<h1 id="news-title">News Bit Prepared</h1>

<div class="news-grid">
  {% for post in site.posts %}
    {% if post.type == 'news' %}
      <article class="news-card">
        {% if post.date %}
          <span class="post-date">{{ post.date | date: '%d %B %Y' }}</span>
        {% endif %}
        <h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
        {% if post.excerpt %}
          <p class="post-excerpt">{{ post.excerpt | strip_html | truncate: 200 }}</p>
        {% endif %}
        <a href="{{ post.url }}" class="btn btn-primary">Leggi tutto</a>
      </article>
    {% endif %}
  {% endfor %}
</div>

{% if site.posts.size == 0 or site.posts.type == 'news' %}
  <p>Nessuna notizia disponibile.</p>
{% endif %}