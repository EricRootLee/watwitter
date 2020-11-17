defmodule WatwitterWeb.ComposeLive do
  use WatwitterWeb, :live_view

  def render(assigns) do
    ~L"""
    <header class="header">
      <h1 class="header-title">Compose</h1>
    </header>
    """
  end
end
