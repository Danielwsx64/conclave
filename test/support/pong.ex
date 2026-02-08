defmodule Support.Pong do
  use GenServer

  require Logger

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def ping(name \\ __MODULE__, msg), do: GenServer.call(name, msg)
  def kill(name \\ __MODULE__), do: GenServer.cast(name, :kill)

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)
    Logger.info("[#{__MODULE__}] Initilizing with name: #{opts[:name]}")
    {:ok, opts} |> IO.inspect()
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.info("[#{__MODULE__}] Pong with name: #{state[:name]}")
    {:reply, {:pong, msg}, state}
  end

  @impl true
  def handle_cast(:kill, state) do
    Logger.info("[#{__MODULE__}] Kill was called name: #{state[:name]}")
    {:stop, :normal, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info(
      "[#{__MODULE__}] Terminating name: #{state[:name]} with reason: #{inspect(reason)}"
    )
  end
end
