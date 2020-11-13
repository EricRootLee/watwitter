defmodule WatwitterWeb.PostLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias Watwitter.Timeline.Post

  def mount(_params, session, socket) do
    changeset = Timeline.change_post(%Post{})
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    socket = assign(socket, changeset: changeset, current_user: current_user)

    {:ok, socket}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    %{current_user: current_user} = socket.assigns
    params = Map.put(post_params, "user_id", current_user.id)

    case Timeline.create_post(params) do
      {:ok, _post} ->
        socket
        |> put_flash(:info, "Post created")
        |> push_redirect(to: Routes.timeline_path(socket, :index))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:changeset, changeset)
        |> noreply()
    end
  end

  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      %Post{}
      |> Timeline.change_post(post_params)
      |> Map.put(:action, :validate)

    socket
    |> assign(:changeset, changeset)
    |> noreply()
  end

  defp noreply(conn), do: {:noreply, conn}
end
