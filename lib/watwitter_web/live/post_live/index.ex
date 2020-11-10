defmodule WatwitterWeb.PostLive.Index do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias Watwitter.Timeline.Post

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    if connected?(socket), do: Timeline.subscribe()
    posts = Timeline.list_posts(page: 1)
    current_user = Accounts.get_user_by_session_token(token)

    socket =
      assign(socket,
        posts: posts,
        recent_posts: [],
        new_posts: [],
        page: 1,
        new_posts_count: 0,
        current_user: current_user
      )

    {:ok, socket, temporary_assigns: [posts: [], recent_posts: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Home")
    |> assign(:post, nil)
  end

  @impl true
  def handle_event("load-more", _, socket) do
    new_page = socket.assigns.page + 1
    posts = Timeline.list_posts(page: new_page)

    {:noreply, assign(socket, posts: posts, page: new_page)}
  end

  def handle_event("show-new-posts", _, socket) do
    new_posts = socket.assigns.new_posts

    socket =
      socket
      |> update(:recent_posts, fn posts -> new_posts ++ posts end)
      |> assign(new_posts_count: 0, new_posts: [], page_title: "Home")

    {:noreply, socket}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    socket =
      socket
      |> update(:new_posts_count, fn count -> count + 1 end)
      |> update(:new_posts, fn posts -> [post | posts] end)
      |> set_new_tweets_page_title()

    {:noreply, socket}
  end

  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  defp set_new_tweets_page_title(socket) do
    assign(socket, :page_title, "(#{socket.assigns.new_posts_count}) Home")
  end
end
