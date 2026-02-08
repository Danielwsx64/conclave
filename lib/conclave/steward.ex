defmodule Conclave.Steward do
  use Supervisor

  alias Conclave.Config

  def start_link(%Config{} = config) do
    Supervisor.start_link(__MODULE__, [], name: config.steward_name)
  end

  @impl true
  def init(_opts) do
    Supervisor.init([], strategy: :one_for_one)
  end

  def start_child(%Config{steward_name: name}, child_spec) do
    Supervisor.start_child(name, child_spec)
  end

  def terminate_child(%Config{steward_name: name}, pid) do
    Supervisor.terminate_child(name, pid)
  end

  def which_children(%Config{steward_name: name}) do
    Supervisor.which_children(name)
  end
end
