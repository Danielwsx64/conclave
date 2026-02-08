defmodule Conclave.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Conclave.Case
      alias Support.EchoServer
    end
  end

  def start_node_supervisor(node, children, opts \\ []) when is_list(children) do
    opts = Keyword.merge([name: RootSupervisor, strategy: :one_for_one], opts)

    {:ok, _pid} = :rpc.block_call(node, Supervisor, :start_link, [children, opts])
  rescue
    ex ->
      raise """


      ================================================================
      Failed to start Node Supervisor on node #{node}
      ================================================================


      #{Exception.message(ex)}
      """
  end

  def flush do
    receive do
      _ -> flush()
    after
      0 -> :ok
    end
  end
end
