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
