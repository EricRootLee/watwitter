defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias WatwitterWeb.TimelineLive.PostComponent

  def mount(_params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    posts = get_top_posts()

    {:ok, assign(socket, posts: posts, new_posts_count: 0, current_user: current_user)}
  end

  def handle_event("show-new-posts", _, socket) do
    socket
    |> update(:posts, fn _ -> get_top_posts() end)
    |> update(:new_posts_count, fn _ -> 0 end)
    |> update_page_title()
    |> noreply()
  end

  def handle_info({:post_created, _post}, socket) do
    socket
    |> update(:new_posts_count, fn count -> count + 1 end)
    |> update_page_title()
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

  defp update_page_title(socket) do
    new_posts_count = socket.assigns.new_posts_count

    if new_posts_count > 0 do
      assign(socket, :page_title, "(#{new_posts_count}) Home")
    else
      assign(socket, :page_title, "Home")
    end
  end

  defp noreply(socket), do: {:noreply, socket}

  defp get_top_posts do
    Timeline.list_posts(page: 1, per_page: 10)
  end
end
