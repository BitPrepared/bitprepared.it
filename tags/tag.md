---
layout: page
permalink: /tags/:title/
---

<div class="tag-page">
  <header class="tag-header">
    <h1>#{{ page.title }}</h1>
    <p class="tag-count">{{ site.tags[page.title].size }} post con questo tag</p>
  </header>

  <div class="tag-posts">
    {% for post in site.tags[page.title] %}
    <article class="tag-post-card">
      <h2>
        <a href="{{ post.url }}">{{ post.title }}</a>
      </h2>
      {% if post.date %}
      <p class="post-date">
        <time datetime="{{ post.date | date_to_xmlschema }}">
          {{ post.date | date: "%d %B %Y" }}
        </time>
      </p>
      {% endif %}
      {% if post.excerpt %}
      <p class="post-excerpt">{{ post.excerpt | strip_html | truncate: 200 }}</p>
      {% endif %}
      <a href="{{ post.url }}" class="btn-primary">Leggi tutto</a>
    </article>
    {% endfor %}
  </div>
</div>

<style>
  .tag-page {
    max-width: 900px;
    margin: 0 auto;
    padding: var(--spacing-xl) var(--spacing-md);
  }

  .tag-header {
    text-align: center;
    margin-bottom: var(--spacing-xl);
    padding-bottom: var(--spacing-md);
    border-bottom: 2px solid var(--color-secondary);
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
