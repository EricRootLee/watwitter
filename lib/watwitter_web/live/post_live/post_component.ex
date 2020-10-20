defmodule WatwitterWeb.PostLive.PostComponent do
  use WatwitterWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="flex flex-col mx-auto">
      <div class="rounded-lg border-solid border-2 border-gray-100">
        <div>
          <div class="text-gray-700 text-md"><%= @post.username %></div>
          <div class="flex-1"><%= @post.body %></div>
        </div>
        <div class="flex space-x-4 text-gray-700 text-md">
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

          <div><%= live_redirect "Show", to: Routes.post_show_path(@socket, :show, @post) %></div>
          <div><%= link "Delete", to: "#", phx_click: "delete", phx_value_id: @post.id, data: [confirm: "Are you sure?"] %></div>
        </div>
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
