defmodule WatwitterWeb.PostLive.PostComponent do
  use WatwitterWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
     <div>
        <div><%= @post.username %></div>
        <div><%= @post.body %></div>
      </div>
      <div>
        <div>
          <a href="#" phx-click="like" phx-target="<%= @myself %>">
            Like <%= @post.likes_count %>
          </a>
        </div>
        <div>
          <a href="#" phx-click="repost" phx-target="<%= @myself %>">
            Repost <%= @post.reposts_count %>
          </a>
        </div>
      </div>

      <div>
        <span><%= live_redirect "Show", to: Routes.post_show_path(@socket, :show, @post) %></span>
        <span><%= link "Delete", to: "#", phx_click: "delete", phx_value_id: @post.id, data: [confirm: "Are you sure?"] %></span>
      </div>
    </div>
    """
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
