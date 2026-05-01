---
layout: page
title: News
permalink: /news/
---

<section class="max-w-6xl mx-auto px-6 py-16" aria-labelledby="news-title">
  <h1 id="news-title" class="text-3xl font-display font-bold text-center text-light mb-8">News Bit Prepared</h1>
  
  <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
    {% for post in site.posts %}
      {% if post.type == 'news' %}
        <article class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-base flex flex-col">
          <div class="p-6 flex flex-col flex-grow">
            {% if post.date %}
              <span class="text-gray-500 text-sm mb-2">{{ post.date | date: "%d %B %Y" }}</span>
            {% endif %}
            <h3 class="text-2xl font-display font-bold text-primary mb-3">{{ post.title }}</h3>
            {% if post.excerpt %}
              <p class="text-gray-600 mb-4 flex-grow">{{ post.excerpt | strip_html | truncate: 150 }}</p>
            {% endif %}
            <div class="card-actions">
              <a href="{{ post.url }}" class="btn btn-event">Leggi tutto</a>
            </div>
          </div>
        </article>
      {% endif %}
    {% endfor %}
  </div>
</section>

{% if site.posts.size == 0 or site.posts.type == 'news' %}
  <div class="max-w-6xl mx-auto px-6 py-16 text-center">
    <p class="text-gray-600">Nessuna notizia disponibile.</p>
  </div>
{% endif %}
