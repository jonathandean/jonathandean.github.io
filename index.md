---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
---

<ul class="post-list">
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url | prepend: site.baseurl }}">
        <time datetime="{{ page.date | date: "%Y-%m-%d" }}" pubdate>{{ post.date | date: "%B %d, %Y" }}</time>
        <header>{{ post.title }}</header>
      </a>
    </li>
  {% endfor %}
</ul>