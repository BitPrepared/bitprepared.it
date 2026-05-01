---
layout: blog
title: Blog
permalink: /blog/
---



<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
    {% for post in site.posts %}
        <article class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-base flex flex-col">
          {% if post.featured %}
          <div class="relative">
            <img src="/assets/{{ post.featured }}" alt="{{ post.title }}" width="400" height="300" loading="lazy" class="w-full h-56 object-cover">
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
    {% endfor %}
  </div>

{% if site.posts.size == 0 %}
  <div class="text-center">
    <p class="text-gray-600">Nessun articolo disponibile.</p>
  </div>
{% endif %}
