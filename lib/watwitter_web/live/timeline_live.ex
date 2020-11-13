defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Timeline
  alias WatwitterWeb.TimelineLive.PostComponent

  def mount(_params, _session, socket) do
    socket = assign(socket, :posts, get_initial_posts())

    {:ok, socket}
  end

  defp get_initial_posts do
    Timeline.list_posts(page: 1, per_page: 10)
  end
end
