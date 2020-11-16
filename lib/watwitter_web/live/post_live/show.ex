defmodule WatwitterWeb.PostLive.Show do
  use WatwitterWeb, :live_view

  alias Watwitter.Repo
  alias Watwitter.Timeline
  alias WatwitterWeb.TimelineLive.PostComponent

  def mount(%{"id" => id}, _session, socket) do
    post = Timeline.get_post!(id)

    {:ok, assign(socket, post: post)}
  end

  def handle_event("repost", _, socket) do
    {:ok, post} = Timeline.inc_reposts(socket.assigns.post)
    post = Repo.preload(post, replies: :user)

    {:noreply, assign(socket, :post, post)}
  end

  def handle_event("like", _, socket) do
    {:ok, post} = Timeline.inc_likes(socket.assigns.post)
    post = Repo.preload(post, replies: :user)

    {:noreply, assign(socket, :post, post)}
  end
end
