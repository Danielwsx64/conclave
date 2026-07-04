defmodule Conclave.Dean do
  use GenServer

  alias Conclave.Config

  require Logger

  defmodule State do
    defstruct [:config, :main_ref, :main_pid, :main_node, main?: false, active?: false]
  end

  def start_link(%Config{} = config) do
    GenServer.start_link(__MODULE__, %State{config: config}, name: config.dean_name)
  end

  @impl true
  def init(%State{} = state), do: {:ok, state}

  @impl true
  def handle_call(_msg, _from, %{active?: false} = state) do
    reply({:error, :not_active}, state)
  end

  def handle_call(:main_node?, _from, state), do: reply({:ok, state.main?}, state)

  @impl true
  def handle_cast({:quorum_changed, true}, %{active?: false} = state) do
    state
    |> active()
    |> monitor_main()
    |> noreply()
  end

  def handle_cast({:quorum_changed, true}, %{main?: false} = state) do
    state |> monitor_main() |> noreply()
  end

  def handle_cast({:quorum_changed, _value}, state), do: noreply(state)
  def handle_cast({:took_over, pid}, state), do: state |> set_monitor(pid) |> noreply()

  def handle_cast(:notify_taking_over, state) do
    state.config.name
    |> Conclave.which_members()
    |> Enum.each(fn node ->
      GenServer.cast({state.config.dean_name, node}, {:took_over, self()})
    end)

    state |> take_main() |> noreply()
  end

  def handle_cast({:cluster_debug_log, opts}, state) do
    members = Conclave.which_members(state.config.name)

    Logger.debug("""
    [#{state.config.name}] DEBUG LOG
      active?: #{state.active?}
      main?: #{state.main?}
      main_node: #{state.main_node}
      members_count: #{length(members)}

      #{inspect(members)}
    """)

    if Keyword.get(opts, :reply) do
      Enum.each(members, fn node ->
        GenServer.cast({state.config.dean_name, node}, {:cluster_debug_log, [reply: false]})
      end)
    end

    noreply(state)
  end

  @impl true
  def handle_info({:DOWN, main_ref, _atom, _pid, _reason}, %{main_ref: main_ref} = state) do
    state |> monitor_main(force_new: true) |> noreply()
  end

  defp monitor_main(state, opts \\ []) do
    self = self()

    case :global.whereis_name(state.config.main_dean_name) do
      :undefined ->
        take_main(state)

      ^self ->
        take_over(state)

      pid ->
        if opts[:force_new] == true and pid == state.main_pid do
          monitor_main(state, opts)
        else
          set_monitor(state, pid)
        end
    end
  end

  defp take_main(state) do
    case :global.register_name(state.config.main_dean_name, self(), &resolve_main_conflict/3) do
      :yes -> take_over(state)
      :no -> monitor_main(state)
    end
  end

  defp resolve_main_conflict(_name, main_pid, _dean) do
    GenServer.cast(main_pid, :notify_taking_over)

    main_pid
  end

  defp set_monitor(%{main_pid: pid} = state, pid) do
    Logger.info("[#{state.config.name}] Already monitoring main Dean on pid: #{inspect(pid)}")

    state
  end

  defp set_monitor(state, pid) do
    Logger.info("[#{state.config.name}] Monitoring main Dean on pid: #{inspect(pid)}")

    main_node = node(pid)

    if state.main_ref, do: Process.demonitor(state.main_ref)

    %{
      state
      | main?: false,
        main_ref: Process.monitor(pid),
        main_pid: pid,
        main_node: main_node
    }
  end

  defp active(%{active?: false} = state) do
    Logger.info("[#{state.config.name}] Was activated by min quorum: #{state.config.min_quorum}")

    %{state | active?: true}
  end

  defp take_over(%{main?: true} = state) do
    Logger.info("[#{state.config.name}] Current node is already the main Dean")

    state
  end

  defp take_over(state) do
    Logger.info("[#{state.config.name}] Current node is the main Dean")

    if state.main_ref, do: Process.demonitor(state.main_ref)

    %{state | main?: true, main_ref: nil, main_pid: nil, main_node: nil}
  end

  defp reply(msg, state), do: {:reply, msg, state}
  defp noreply(state), do: {:noreply, state}
end
