defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Timeline
  alias WatwitterWeb.TimelineLive.PostComponent

  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    socket = assign(socket, :posts, get_initial_posts())

    {:ok, socket}
  end

  def handle_event("like", %{"post_id" => id}, socket) do
    id
    |> Timeline.get_post!()
    |> Timeline.inc_likes()

    {:noreply, socket}
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
