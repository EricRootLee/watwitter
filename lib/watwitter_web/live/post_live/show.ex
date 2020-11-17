defmodule WatwitterWeb.PostLive.Show do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Repo
  alias Watwitter.Timeline
  alias WatwitterWeb.TimelineLive.PostComponent

  def mount(%{"id" => id}, session, socket) do
    post = Timeline.get_post!(id)
    current_user = Accounts.get_user_by_session_token(session["user_token"])

    {:ok, assign(socket, post: post, current_user: current_user)}
  end

  def handle_event("repost", _, socket) do
    {:ok, post} = Timeline.inc_reposts(socket.assigns.post)
    post = Repo.preload(post, replies: :user)

    {:noreply, assign(socket, :post, post)}
  end

  def handle_event("like", _, socket) do
    {:ok, post} = Timeline.like_post(socket.assigns.current_user, socket.assigns.post)
    post = Repo.preload(post, replies: :user)

    {:noreply, assign(socket, :post, post)}
  end
end
