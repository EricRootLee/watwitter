defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.SVGHelpers

  def mount(_params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    posts = Timeline.list_posts()

    {:ok, assign(socket, posts: posts, new_posts_count: 0, current_user: current_user)}
  end

  def render(assigns) do
    ~L"""
    <header class="header">
      <img alt="user-avatar" class="avatar" src="<%= @current_user.avatar_url %>">
      <h1 class="header-title">Home</h1>
    </header>

    <div class="body">
      <%= if @new_posts_count > 0 do %>
        <div phx-click="show-new-posts" class="new-posts-notice" id="new-posts-notice">
          <%= ngettext("Show 1 post", "Show %{count} posts", @new_posts_count) %>
        </div>
      <% end %>
      <%= for post <- @posts do %>
        <%= live_component @socket, PostComponent, post: post %>
      <% end %>
    </div>

    <div class="new-post-button">
      <%= live_redirect to: Routes.compose_path(@socket, :new), id: "compose-button" do %>
        <%= SVGHelpers.compose_svg() %>
      <% end %>
    </div>
    """
  end

  def handle_event("show-new-posts", _, socket) do
    socket =
      socket
      |> assign(new_posts_count: 0, posts: Timeline.list_posts())
      |> set_page_title()

    {:noreply, socket}
  end

  def handle_info({:post_created, _post}, socket) do
    socket =
      socket
      |> update(:new_posts_count, fn count -> count + 1 end)
      |> set_page_title()

    {:noreply, socket}
  end

  defp set_page_title(socket) do
    count = socket.assigns.new_posts_count

    if count > 0 do
      assign(socket, :page_title, "(#{count}) Home")
    else
      assign(socket, :page_title, "Home")
    end
  end
end
