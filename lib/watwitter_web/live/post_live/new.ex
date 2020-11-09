defmodule WatwitterWeb.PostLive.New do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline.Post

  @impl true
  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:post, %Post{})
      |> assign(:page_title, "Compose Watweet")

    {:ok, socket}
  end
end
