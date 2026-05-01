---
layout: page
title: Blog
permalink: /blog/
---

<h1 id="blog-title">Blog Bit Prepared</h1>

<div class="blog-grid">
  {% for post in site.posts %}
    {% if post.type == 'blog' or post.type == nil %}
      <article class="blog-card">
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