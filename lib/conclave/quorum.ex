defmodule Conclave.Quorum do
  use GenServer

  alias Conclave.Config

  require Logger

  defmodule State do
    defstruct [:config, members: []]
  end

  def start_link(%Config{} = config) do
    GenServer.start_link(__MODULE__, %State{config: config}, name: config.quorum_name)
  end

  @impl true
  def init(%State{} = state) do
    :net_kernel.monitor_nodes(true, node_type: :visible)

    {:ok, state, {:continue, :register}}
  end

  @impl true
  def handle_call(:which_members, _from, state) do
    reply(state.members, state)
  end

  @impl true
  def handle_cast({:register, node, opts}, state) do
    Logger.info("[#{state.config.name}] Registered member #{node}")

    if opts[:reply?], do: register_message(state, node, reply?: false)

    state
    |> checkin(node)
    |> noreply()
  end

  @impl true
  def handle_continue(:register, state) do
    Node.list()
    |> Enum.reduce(state, &register_message(&2, &1))
    |> notify_quorum()
    |> noreply()
  end

  @impl true
  def handle_info({:nodeup, node, _opts}, state) when node == node(), do: noreply(state)

  def handle_info({:nodeup, node, _opts}, state) do
    state
    |> register_message(node, reply?: false)
    |> noreply()
  end

  def handle_info({:nodedown, node, _opts}, state) do
    state
    |> checkout(node)
    |> noreply()
  end

  # def handle_info({:nodeup, _node, _opts}, %{main?: true} = state) do
  #   state |> monitor_main() |> noreply()
  # end
  # def handle_info({:nodeup, _node, _opts}, state), do: state |> noreply()
  # def handle_info({:nodedown, node, _opts}, %{main_node: node} = state) do
  #   state |> monitor_main() |> noreply()
  # end
  # def handle_info({:nodedown, _node, _opts}, state), do: state |> noreply()

  defp register_message(state, node, opts \\ []) do
    GenServer.cast(
      {state.config.quorum_name, node},
      {:register, node(),
       reply?: Keyword.get_lazy(opts, :reply?, fn -> node not in state.members end)}
    )

    state
  end

  defp checkin(state, node) do
    notify_quorum(%{state | members: Enum.uniq([node | state.members])})
  end

  defp checkout(state, node) do
    notify_quorum(%{state | members: Enum.reject(state.members, &(&1 == node))})
  end

  defp notify_quorum(%{config: config} = state) do
    GenServer.cast(
      config.dean_name,
      {:quorum_changed, length(state.members) + 1 >= config.min_quorum}
    )

    state
  end

  defp reply(msg, state), do: {:reply, msg, state}
  defp noreply(state), do: {:noreply, state}
end
