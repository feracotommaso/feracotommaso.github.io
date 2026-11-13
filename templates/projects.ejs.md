```{=html}
<div class="project-grid list">
<% for (const [index, item] of items.entries()) { %>
  <article class="project-card<%= item['project-featured'] ? ' project-card-featured' : '' %>" aria-labelledby="project-title-<%= index %>">
    <div class="project-card-content">
      <% if (item['project-area']) { %><p class="project-area"><%- item['project-area'] %></p><% } %>
      <h2 class="listing-title" id="project-title-<%= index %>"><a href="<%- item.path %>"><%- item.title %></a></h2>
      <% if (item['project-question']) { %><p class="project-question"><%- item['project-question'] %></p><% } %>
      <p class="project-contribution"><%- item['project-contribution'] || item.description %></p>
      <% if (item['project-note']) { %><p class="project-note"><%- item['project-note'] %></p><% } %>
      <div class="project-actions">
        <a class="resource-button" href="<%- item.path %>">Explore project <span aria-hidden="true">&rarr;</span></a>
        <% if (item['project-link-url']) { %><a class="resource-details" href="<%- item['project-link-url'] %>"><%- item['project-link-label'] %></a><% } %>
      </div>
    </div>
    <% if (item['project-featured'] && item.image) { %>
    <img class="project-feature-image" src="<%- item.image %>" alt="" width="480" height="480">
    <% } %>
  </article>
<% } %>
</div>
```
