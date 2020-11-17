defmodule WatwitterWeb.ComposeLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias Watwitter.Timeline.Post
  alias WatwitterWeb.SVGHelpers

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    changeset = Timeline.change_post(%Post{})

    {:ok, assign(socket, changeset: changeset, current_user: current_user)}
  end

  def render(assigns) do
    ~L"""
    <header class="header">
      <%= live_redirect to: Routes.timeline_path(@socket, :index), id: "back" do %>
        <%= SVGHelpers.back_svg() %>
      <% end %>
      <h1 class="header-title">Compose</h1>
    </header>

    <div class="body">
      <div class="compose-wrapper">
        <%= f = form_for @changeset, "#", phx_submit: "save", phx_change: "validate", id: "new-post", class: "compose-form" %>
          <div class="compose-fields">
            <div class="compose-box">
              <%= textarea f, :body, placeholder: "What's happening?", class: "compose-textarea" %>
            </div>
            <div>
              <%= error_tag f, :body %>
            </div>
          </div>

          <div class="compose-actions">
            <%= submit "Post", phx_disable_with: "Posting...", class: "compose-btn" %>
          </div>
        </form>
      </div>
    </div>
    """
  end

  def handle_event("validate", %{"post" => post_params}, socket) do
    %Post{}
    |> Timeline.change_post(post_params)
    |> Ecto.Changeset.apply_action(:insert)
    |> case do
      {:ok, _data} -> {:noreply, socket}
      {:error, changeset} -> {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    params = Map.put(post_params, "user_id", socket.assigns.current_user.id)

    case Timeline.create_post(params) do
      {:ok, _post} ->
        {:noreply, push_redirect(socket, to: Routes.timeline_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
