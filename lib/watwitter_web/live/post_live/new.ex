defmodule WatwitterWeb.PostLive.New do
  use WatwitterWeb, :live_view

  alias Watwitter.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:post, %Post{})
      |> assign(:page_title, "Compose Watweet")

    {:ok, socket}
  end
end
