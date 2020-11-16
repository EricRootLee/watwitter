defmodule WatwitterWeb.PostLive.PostComponent do
  use WatwitterWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
      <img class="avatar" src="<%= @post.user.avatar_url %>" />

      <div class="post-content">
        <p class="post-header">
          <span class="post-user-info">
            <span class="post-user-name">
              <%= @post.user.name %>
            </span>
            <span class="post-user-username">
              @<%= @post.user.username %>
            </span>
          </span>
          <span class="post-date-info">
            <span class="post-date-separator">·</span>
            <span class="post-date">
              <%= format_date(@post.inserted_at) %>
            </span>
          </span>
        </p>

        <div class="post-body"><%= live_redirect @post.body, to: Routes.post_show_path(@socket, :show, @post) %></div>

        <div class="post-actions">
          <a class="post-action" href="#">
            <%= WatwitterWeb.SVGHelpers.reply_svg() %>
          </a>
          <a class="post-action" href="#" data-role="repost-button" phx-click="repost" phx-target="<%= @myself %>">
            <%= WatwitterWeb.SVGHelpers.repost_svg() %>
            <span data-role="repost-count" class="post-action-count"><%= @post.reposts_count %></span>
          </a>
          <a class="post-action" href="#" data-role="like-button" phx-click="like" phx-target="<%= @myself %>">
            <%= WatwitterWeb.SVGHelpers.like_svg() %>
            <span data-role="like-count" class="post-action-count"><%= @post.likes_count %></span>
          </a>
          <a class="post-action" href="#">
            <%= WatwitterWeb.SVGHelpers.export_svg() %>
          </a>
        <div>
      </div>
    </div>
    """
  end

  defp format_date(datetime) do
    "#{format_month(datetime.month)} #{datetime.day}"
  end

  def handle_event("like", _, socket) do
    Watwitter.Timeline.inc_likes(socket.assigns.post)
    {:noreply, socket}
  end

  def handle_event("repost", _, socket) do
    Watwitter.Timeline.inc_reposts(socket.assigns.post)
    {:noreply, socket}
  end
end
