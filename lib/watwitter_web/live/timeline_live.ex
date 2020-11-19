defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.SVGHelpers

  def mount(params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    page = 1
    per_page = String.to_integer(params["per_page"] || "10")
    posts = Timeline.list_posts(page: page, per_page: per_page)

    {
      :ok,
      assign(socket,
        page: page,
        per_page: per_page,
        posts: posts,
        new_posts_count: 0,
        current_user: current_user
      ),
      temporary_assigns: [posts: []]
    }
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

      <div id="posts" phx-update="append">
        <%= for post <- @posts do %>
          <%= live_component @socket, PostComponent, id: post.id, post: post, current_user: @current_user %>
        <% end %>
      </div>

      <div class="load-more-placeholder" id="load-more" phx-hook="InfiniteScroll">
        Loading ...
      </div>
    </div>

    <div class="new-post-button">
      <%= live_redirect to: Routes.compose_path(@socket, :new), id: "compose-button" do %>
        <%= SVGHelpers.compose_svg() %>
      <% end %>
    </div>

    <footer class="footer">
      <div class="footer-items">
        <%= SVGHelpers.home_svg() %>
      </div>
    </footer>
    """
  end

  def handle_event("show-new-posts", _, socket) do
    socket = push_redirect(socket, to: Routes.timeline_path(socket, :index))

    {:noreply, socket}
  end

  def handle_event("load-more", _, socket) do
    socket =
      socket
      |> update(:page, fn page -> page + 1 end)
      |> fetch_posts()

    {:noreply, socket}
  end

  def handle_info({:post_updated, post}, socket) do
    socket =
      socket
      |> update(:posts, fn posts -> [post | posts] end)

    {:noreply, socket}
  end

  def handle_info({:post_created, _post}, socket) do
    socket =
      socket
      |> update(:new_posts_count, fn count -> count + 1 end)
      |> set_page_title()

    {:noreply, socket}
  end

  defp fetch_posts(socket) do
    page = socket.assigns.page
    per_page = socket.assigns.per_page
    posts = Timeline.list_posts(page: page, per_page: per_page)

    socket
    |> update(:posts, fn existing -> existing ++ posts end)
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
