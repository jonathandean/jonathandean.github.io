---
layout: default
title: Posts
permalink: /posts/
---

<ul class="post-list">
  {% for post in site.posts %}
    <li class="{% for tag in post.tags %}post-tag-{{ tag }} {% endfor %}">
      <a href="{{ post.url | prepend: site.baseurl }}">
        <time datetime="{{ page.date | date: "%Y-%m-%d" }}" pubdate>{{ post.date | date: "%B %d, %Y" }}</time>
        <header>
           {% if post.tags contains "tweets" %}
             <span class="icon ss-icon ss-social ss-twitter"></span>
           {% endif %}
          <span class="post-title">{{ post.title }}</span>
        </header>
      </a>
    </li>
  {% endfor %}
</ul>