defmodule WatwitterWeb.PostComponent do
  use WatwitterWeb, :live_component

  alias Watwitter.Timeline
  alias WatwitterWeb.DateHelpers
  alias WatwitterWeb.SVGHelpers

  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
      <img class="avatar" src="<%= @post.user.avatar_url %>">
      <div class="post-content">
        <div class="post-header">
          <span class="post-user-info">
            <span class="post-user-name">
              <%= @post.user.name %>
            </span>
            <span class="post-user-username">
              @<%= @post.user.username %>
            </span>
          </span>
          <span class="post-date-info">
            <span class="post-date-separator">.</span>
            <span class="post-date">
              <%= DateHelpers.format_short(@post.inserted_at) %>
            </span>
          </span>
        </div>
        <div class="post-body">
          <%= @post.body %>
        </div>

        <div class="post-actions">
          <%= if current_user_liked?(assigns) do %>
            <a class="post-action post-liked" href="#" phx-click="like" phx-target="<%= @myself %>" data-role="like-button">
              <%= SVGHelpers.liked_svg() %>
              <span data-role="like-count" class="post-action-count"><%= @post.likes_count %></span>
            </a>
          <% else %>
            <a class="post-action" href="#" phx-click="like" phx-target="<%= @myself %>" data-role="like-button">
              <%= SVGHelpers.like_svg() %>
              <span data-role="like-count" class="post-action-count"><%= @post.likes_count %></span>
            </a>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("like", _, socket) do
    post = socket.assigns.post
    current_user = socket.assigns.current_user
    Timeline.like_post!(post, current_user)

    {:noreply, socket}
  end

  defp current_user_liked?(assigns) do
    post = assigns.post
    current_user = assigns.current_user

    current_user.id in Enum.map(post.likes, & &1.user_id)
  end
end
