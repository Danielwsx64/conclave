defmodule Support.EchoServer do
  use GenServer

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @impl true
  def init(state), do: {:ok, Map.new(state)}

  @impl true
  def handle_cast(msg, state) do
    if state[:reply], do: reply(state.reply, msg, state)

    {:noreply, state}
  end

  @impl true
  def handle_call(msg, _from, state) do
    if state[:reply], do: send(state[:reply], msg)

    {:reply, :ok, state}
  end

  defp reply(pid, msg, %{prefix: prefix}), do: send(pid, {prefix, msg})
  defp reply(pid, msg, _state), do: send(pid, msg)
end
