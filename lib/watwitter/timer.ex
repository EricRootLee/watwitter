defmodule Watwitter.Timer do
  @callback send_interval(interval :: integer(), pid :: pid(), message :: atom()) :: any()
end

defmodule ImmediateTimer do
  @behaviour Watwitter.Timer

  @impl true
  def send_interval(_interval, pid, message) do
    send(pid, message)
  end
end

defmodule Watwitter.Timer.Impl do
  @behaviour Watwitter.Timer

  @impl true
  def send_interval(interval, pid, message) do
    :timer.send_interval(interval, pid, message)
  end
end
