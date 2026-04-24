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

<script>
  // Tag data from Jekyll
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

  // Check URL hash for tag
  function checkHash() {
    let hash = window.location.hash.substring(1); // Remove #
    hash = decodeURIComponent(hash); // Decode URL encoding (spaces, etc)

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
        <h2>
          <a href="${post.url}">${post.title}</a>
        </h2>
        <p class="post-date">${post.date}</p>
        <p class="post-excerpt">${post.excerpt}</p>
        <a href="${post.url}" class="btn-primary">Leggi tutto</a>
      </article>
    `).join('');
  }

  // Event listeners
  document.querySelectorAll('.tag-link').forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const tag = link.getAttribute('data-tag');
      window.location.hash = tag;
      showTag(tag);
    });
  });

  // Listen for hash changes
  window.addEventListener('hashchange', checkHash);

  // Check on page load
  checkHash();
</script>

<style>
  .tags-archive {
    max-width: 900px;
    margin: 0 auto;
    padding: var(--spacing-xl) var(--spacing-md);
  }

  .tags-archive h1 {
    text-align: center;
    color: var(--color-accent);
    margin-bottom: var(--spacing-lg);
  }

  .tags-list {
    display: flex;
    flex-wrap: wrap;
    gap: var(--spacing-md);
    justify-content: center;
    list-style: none;
    padding: 0;
  }

  .tags-list li {
    margin: 0;
  }

  .tag-link {
    display: inline-block;
    background: var(--color-secondary);
    color: #ffffff !important;
    padding: 0.5rem 1rem;
    border-radius: 2rem;
    text-decoration: none !important;
    transition: all var(--transition-base);
    border: none !important;
    box-shadow: none !important;
    outline: none !important;
  }

  .tag-link:hover,
  .tag-link:focus,
  .tag-link:active {
    background: #2563eb !important;
    color: #ffffff !important;
    transform: translateY(-2px);
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1) !important;
    outline: none !important;
    text-decoration: none !important;
    border: none !important;
  }

  .tag-count {
    color: #ffffff !important;
    font-size: 0.875rem;
    font-weight: 600;
    margin-left: 0.25rem;
  }

  .tag-header {
    text-align: center;
    margin-bottom: var(--spacing-xl);
    padding-bottom: var(--spacing-md);
    border-bottom: 2px solid var(--color-secondary);
  }

  .back-link {
    display: inline-block;
    color: var(--color-accent);
    text-decoration: none;
    margin-bottom: var(--spacing-md);
  }

  .back-link:hover {
    text-decoration: underline;
  }

  .tag-header h1 {
    color: var(--color-accent);
    font-size: 2.5rem;
    margin-bottom: var(--spacing-sm);
  }

  .tag-count {
    color: var(--color-text-muted);
    font-size: 1.1rem;
  }

  .tag-posts {
    display: grid;
    gap: var(--spacing-lg);
  }

  .tag-post-card {
    background: var(--color-white);
    border-radius: var(--border-radius);
    padding: var(--spacing-md);
    border: 2px solid var(--color-secondary);
    transition: all var(--transition-base);
  }

  .tag-post-card:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow-lg);
    border-color: var(--color-accent);
  }

  .tag-post-card h2 {
    margin-bottom: var(--spacing-sm);
  }

  .tag-post-card h2 a {
    color: var(--color-primary);
    text-decoration: none;
  }

  .tag-post-card h2 a:hover {
    color: var(--color-accent);
  }

  .post-date {
    color: var(--color-text-muted);
    font-size: 0.9rem;
    margin-bottom: var(--spacing-sm);
  }

  .post-excerpt {
    color: var(--color-light);
    line-height: 1.6;
    margin-bottom: var(--spacing-md);
  }

  @media (max-width: 768px) {
    .tag-header h1 {
      font-size: 2rem;
    }

    .tag-posts {
      gap: var(--spacing-md);
    }
  }
</style>
