defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.SVGHelpers

  def mount(_params, session, socket) do
    if connected?(socket), do: timer().send_interval(1000, self(), :check_new_posts)
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
        <div class="new-posts-notice" id="new-posts-notice">
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

  def handle_info(:check_new_posts, socket) do
    in_memory = socket.assigns.posts
    from_db = Timeline.list_posts()

    case List.myers_difference(in_memory, from_db) do
      [ins: inserted] ->
        new_posts_count = length(inserted)
        {:noreply, assign(socket, :new_posts_count, new_posts_count)}

      _ ->
        {:noreply, socket}
    end
  end

  defp timer do
    Application.get_env(:watwitter, :timeline_timer, Watwitter.Timer.Impl)
  end
end
