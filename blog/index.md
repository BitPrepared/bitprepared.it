---
layout: page
title: Blog
permalink: /blog/
---

<section class="max-w-6xl mx-auto px-6 py-16" aria-labelledby="blog-title">
  <h1 id="blog-title" class="text-3xl font-display font-bold text-center text-light mb-8">Blog Bit Prepared</h1>
  
  <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
    {% for post in site.posts %}
      {% if post.type == 'blog' or post.type == nil %}
        <article class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-base flex flex-col">
          {% if post.featured %}
          <div class="relative">
            <img src="/assets/{{ post.featured }}" alt="{{ post.title }}" width="400" height="300" loading="lazy" class="w-full h-48 object-cover">
            {% if post.date %}
            <span class="absolute top-2 right-2 bg-accent text-dark px-3 py-1 rounded-full text-sm font-semibold">{{ post.date | date: "%d %b %Y" }}</span>
            {% endif %}
          </div>
          {% endif %}
          <div class="p-6 flex flex-col flex-grow">
            <h3 class="text-2xl font-display font-bold text-primary mb-3">{{ post.title }}</h3>
            {% if post.excerpt %}
            <p class="text-gray-600 mb-4">{{ post.excerpt | strip_html | truncate: 150 }}</p>
            {% endif %}
            <div class="card-actions">
              <a href="{{ post.url }}" class="btn btn-card">Leggi tutto</a>
            </div>
          </div>
        </article>
      {% endif %}
    {% endfor %}
  </div>
</section>
