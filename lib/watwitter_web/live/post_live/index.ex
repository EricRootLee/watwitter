defmodule WatwitterWeb.PostLive.Index do
  use WatwitterWeb, :live_view

  alias Watwitter.Timeline
  alias Watwitter.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    posts = Timeline.list_posts(page: 1)
    {:ok, assign(socket, posts: posts, page: 1), temporary_assigns: [posts: []]}
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
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_event("load-more", _, socket) do
    new_page = socket.assigns.page + 1
    posts = Timeline.list_posts(page: new_page)

    {:noreply, assign(socket, posts: posts, page: new_page)}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end

  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end
end
