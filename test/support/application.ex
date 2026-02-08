defmodule Support.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [{Conclave, min_quorum: 1}],
      strategy: :one_for_one,
      name: __MODULE__
    )
  end
end
