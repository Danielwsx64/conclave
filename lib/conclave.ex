defmodule Conclave do
  use Supervisor

  alias Conclave.ChildSpec
  alias Conclave.Config

  def start_link(opts) do
    config =
      opts
      |> Keyword.put_new(:name, __MODULE__)
      |> Config.build()

    Supervisor.start_link(__MODULE__, config, name: config.overseer_name)
  end

  @impl true
  def init(%Config{} = config) do
    Supervisor.init(
      [
        {Conclave.Dean, config},
        {Conclave.Quorum, config}
        # {Conclave.Steward, config}
      ],
      strategy: :one_for_one
    )
  end

  def cluster_debug_log(name \\ __MODULE__) do
    name
    |> Config.dean_name()
    |> GenServer.cast({:cluster_debug_log, reply: true})
  end

  def which_children(name \\ __MODULE__) do
    name
    |> Config.dean_name()
    |> GenServer.call(:which_children)
  end

  def terminate_child(name \\ __MODULE__, pid) when is_pid(pid) do
    name
    |> Config.dean_name()
    |> GenServer.call({:terminate_child, pid})
  end

  def start_child(name \\ __MODULE__, child_spec) do
    name
    |> Config.dean_name()
    |> GenServer.call({:start_child, ChildSpec.build(child_spec)})
  end

  def main_node?(name \\ __MODULE__) do
    name
    |> Config.dean_name()
    |> GenServer.call(:main_node?)
  end

  def which_members(name \\ __MODULE__) do
    name
    |> Config.quorum_name()
    |> GenServer.call(:which_members)
  end
end
