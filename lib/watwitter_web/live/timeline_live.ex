defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.SVGHelpers

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    posts = Timeline.list_posts()

    {:ok, assign(socket, posts: posts, current_user: current_user)}
  end

  def render(assigns) do
    ~L"""
    <header class="header">
      <img alt="user-avatar" class="avatar" src="<%= @current_user.avatar_url %>">
      <h1 class="header-title">Home</h1>
    </header>

    <div class="body">
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
end
