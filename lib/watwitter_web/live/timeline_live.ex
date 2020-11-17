defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])

    {:ok, assign(socket, current_user: current_user)}
  end

  def render(assigns) do
    ~L"""
    <header class="header">
      <img alt="user-avatar" class="avatar" src="<%= @current_user.avatar_url %>">
      <h1 class="header-title">Home</h1>
    </header>
    """
  end
end
