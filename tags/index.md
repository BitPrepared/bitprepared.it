---
layout: page
title: Tags
permalink: /tags/
---

<div class="tags-archive">
  <h1>Tutti i Tag</h1>
  <ul class="tags-list">
    {% for tag in site.tags %}
    <li>
      <a href="/tags/{{ tag[0] | slugify }}/">
        #{{ tag[0] }} <span class="tag-count">({{ tag[1].size }})</span>
      </a>
    </li>
    {% endfor %}
  </ul>
</div>

<style>
  .tags-archive {
    max-width: 800px;
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

  .tags-list a {
    display: inline-block;
    background: var(--color-secondary);
    color: var(--color-white);
    padding: 0.5rem 1rem;
    border-radius: 2rem;
    text-decoration: none !important;
    transition: all var(--transition-base);
  }

  .tags-list a:hover {
    background: var(--color-accent);
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
  }

  .tag-count {
    opacity: 0.7;
    font-size: 0.875rem;
  }
</style>
