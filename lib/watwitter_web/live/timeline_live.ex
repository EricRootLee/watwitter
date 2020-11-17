defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias WatwitterWeb.TimelineLive.PostComponent

  def mount(_params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    socket = assign(socket, posts: get_initial_posts(), current_user: current_user)

    {:ok, socket}
  end

  def handle_info({:post_created, post}, socket) do
    socket
    |> update(:posts, fn posts -> [post | posts] end)
    |> noreply()
  end

  def handle_info({:post_updated, %{id: id} = updated_post}, socket) do
    socket
    |> update(:posts, fn posts ->
      Enum.map(posts, fn
        %{id: ^id} -> updated_post
        post -> post
      end)
    end)
    |> noreply()
  end

  defp noreply(socket), do: {:noreply, socket}

  defp get_initial_posts do
    Timeline.list_posts(page: 1, per_page: 10)
  end
end
