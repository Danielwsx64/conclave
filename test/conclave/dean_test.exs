defmodule Conclave.DeanTest do
  use Conclave.Case, async: true

  alias Conclave.Dean

  describe "Dean" do
    test "take the main role and active when has quorum" do
      {:ok, cluster} = LocalCluster.start_link(1)
      {:ok, [node]} = LocalCluster.nodes(cluster)

      assert Dean.function_name() == []
    end

    test "matar o main dean process para ver o monitoramento funcionando"
    test "qual o cenário onde é preciso do `force_new` no monitor_main"
  end
end
