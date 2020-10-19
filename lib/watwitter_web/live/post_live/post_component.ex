defmodule WatwitterWeb.PostLive.PostComponent do
  use WatwitterWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
      <div><%= @post.username %></div>
      <div><%= @post.body %></div>
      <div><%= @post.likes_count %></div>
      <div><%= @post.reposts_count %></div>

      <div>
        <span><%= live_redirect "Show", to: Routes.post_show_path(@socket, :show, @post) %></span>
        <span><%= link "Delete", to: "#", phx_click: "delete", phx_value_id: @post.id, data: [confirm: "Are you sure?"] %></span>
      </div>
    </div>
    """
  end
end
