---
layout: page
title: Tags
permalink: /tags/
---

<style>
  /* Override page wrapper width for tag cards grid */
  body .page-section:has(.tags-archive) > .max-w-4xl {
    max-width: 80rem; /* equivalent to max-w-6xl */
  }
</style>

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
      excerpt: {{ post.excerpt | strip_html | truncate: 200 | jsonify }}
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
  postsContainer.innerHTML = posts.map(post => `
    <article class="tag-post-card">
      <h2><a href="${post.url}">${post.title}</a></h2>
      <p class="post-date">${post.date}</p>
      <p class="post-excerpt">${post.excerpt}</p>
      <a href="${post.url}" class="btn btn-primary">Leggi tutto</a>
    </article>
  `).join('');
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
