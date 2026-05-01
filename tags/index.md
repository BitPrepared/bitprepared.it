---
layout: tags
title: Tags
permalink: /tags/
---

<div class="tags-archive">
  <h1 id="tags-title">Tutti i Tag</h1>

  <div id="all-tags-view">
    <ul class="tags-list">
      {% for tag in site.tags %}
      <li>
        <a href="#" data-tag="{{ tag[0] }}" class="btn btn-tag">
          #{{ tag[0] }} <span class="tag-count">({{ tag[1].size }})</span>
        </a>
      </li>
      {% endfor %}
    </ul>
  </div>

  <div id="tag-view">
    <header class="tag-header">
      <a href="/tags/" class="back-link">← Torna a tutti i tag</a>
      <h1 id="tag-title">#<span id="current-tag"></span></h1>
      <p class="tag-count"><span id="tag-count"></span> post con questo tag</p>
    </header>

    <div id="tag-posts" class="tag-posts"></div>
  </div>
</div>

<script>
const tagsData = {
  {% for tag in site.tags %}
  "{{ tag[0] }}": [
    {% for post in tag[1] %}
    {
      title: "{{ post.title | escape }}",
      url: "{{ post.url }}",
      date: "{{ post.date | date: '%d %B %Y' }}",
      excerpt: {{ post.excerpt | strip_html | truncate: 150 | jsonify }},
      featured: "{{ post.featured }}"
    }{% unless forloop.last %},{% endunless %}
    {% endfor %}
  ]{% unless forloop.last %},{% endunless %}
  {% endfor %}
};

function checkHash() {
  let hash = window.location.hash.substring(1);
  hash = decodeURIComponent(hash);

  if (hash && tagsData[hash]) {
    showTag(hash);
  } else {
    showAllTags();
  }
}

function showAllTags() {
  document.getElementById('all-tags-view').style.display = 'block';
  document.getElementById('tag-view').style.display = 'none';
  document.getElementById('tags-title').style.display = 'block';
}

function showTag(tagName) {
  const posts = tagsData[tagName];
  document.getElementById('all-tags-view').style.display = 'none';
  document.getElementById('tag-view').style.display = 'block';
  document.getElementById('tags-title').style.display = 'none';

  document.getElementById('current-tag').textContent = tagName;
  document.getElementById('tag-count').textContent = posts.length;

  const postsContainer = document.getElementById('tag-posts');
  postsContainer.innerHTML = `<div class="grid grid-cols-1 md:grid-cols-3 gap-6">` + posts.map(post => {
    const featuredImage = post.featured ? `
      <div class="relative">
        <img src="/assets/${post.featured}" alt="${post.title}" width="400" height="300" loading="lazy" class="w-full h-56 object-cover" loading="lazy">
        <span class="absolute top-2 right-2 bg-accent text-dark px-3 py-1 rounded-full text-sm font-semibold">${post.date}</span>
      </div>
    ` : '';

    return `
      <article class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-base flex flex-col">
        ${featuredImage}
        <div class="p-6 flex flex-col flex-grow">
          <h3 class="text-2xl font-display font-bold text-primary mb-3">${post.title}</h3>
          <p class="text-gray-600 mb-4">${post.excerpt}</p>
          <div class="card-actions">
            <a href="${post.url}" class="btn btn-card">Leggi tutto</a>
          </div>
        </div>
      </article>
    `;
  }).join('') + `</div>`;
}

document.querySelectorAll('.btn-tag').forEach(link => {
  link.addEventListener('click', (e) => {
    e.preventDefault();
    const tag = link.getAttribute('data-tag');
    window.location.hash = tag;
    showTag(tag);
  });
});

window.addEventListener('hashchange', checkHash);
checkHash();
</script>
