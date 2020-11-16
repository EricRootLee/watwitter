defmodule WatwitterWeb.PostLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias Watwitter.Timeline.Post
  alias WatwitterWeb.DateHelpers

  def mount(params, session, socket) do
    changeset = Timeline.change_post(%Post{})
    current_user = Accounts.get_user_by_session_token(session["user_token"])

    socket =
      socket
      |> assign(changeset: changeset, current_user: current_user)
      |> set_reply_status(params)

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

  defp set_reply_status(socket, %{"reply_to" => post_id}) do
    post = Timeline.get_post!(post_id)
    assign(socket, :reply_to, post)
  end

  defp set_reply_status(socket, _), do: socket
end
