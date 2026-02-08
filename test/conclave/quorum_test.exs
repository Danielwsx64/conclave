defmodule Conclave.QuorumTest do
  use Conclave.Case, async: true

  alias Conclave.Config
  alias Conclave.Quorum

  describe "Quorum" do
    test "when cluster has only one node and use default min_quorum" do
      {:ok, cluster} = LocalCluster.start_link(1)
      {:ok, [node]} = LocalCluster.nodes(cluster)

      config = Config.build()

      start_node_supervisor(node, [
        {EchoServer, name: config.dean_name, reply: self()},
        {Quorum, config}
      ])

      # Notify valid quorum
      assert_receive {:quorum_changed, true}

      assert GenServer.call({Config.quorum_name(), node}, :which_members) == []
    end

    test "when cluster has only one node and min_quorum is more than 1" do
      {:ok, cluster} = LocalCluster.start_link(1)
      {:ok, [node]} = LocalCluster.nodes(cluster)

      config = Config.build(min_quorum: 2)

      start_node_supervisor(node, [
        {EchoServer, name: config.dean_name, reply: self()},
        {Quorum, config}
      ])

      # Notify valid quorum
      assert_receive {:quorum_changed, false}

      assert GenServer.call({Config.quorum_name(), node}, :which_members) == []
    end

    test "when cluster achieve min quorum" do
      {:ok, cluster} = LocalCluster.start_link(2)
      {:ok, [node_one, node_two]} = LocalCluster.nodes(cluster)

      config = Config.build(min_quorum: 2)

      start_node_supervisor(node_one, [
        {EchoServer, name: config.dean_name, reply: self(), prefix: :node_one},
        {Quorum, config}
      ])

      start_node_supervisor(node_two, [
        {EchoServer, name: config.dean_name, reply: self(), prefix: :node_two},
        {Quorum, config}
      ])

      # Starts alone
      assert_receive {:node_one, {:quorum_changed, false}}
      assert_receive {:node_one, {:quorum_changed, true}}

      assert_receive {:node_two, {:quorum_changed, false}}
      assert_receive {:node_two, {:quorum_changed, true}}

      assert GenServer.call({Config.quorum_name(), node_one}, :which_members) == [node_two]
      assert GenServer.call({Config.quorum_name(), node_two}, :which_members) == [node_one]
    end

    test "when cluster nodes desconnect update quorum" do
      {:ok, cluster} = LocalCluster.start_link(2)

      {:ok, [{:member, _pid_1, node_one} = member_one, {:member, _pid_2, node_two}]} =
        LocalCluster.members(cluster)

      config = Config.build(min_quorum: 2)

      start_node_supervisor(node_one, [
        {EchoServer, name: config.dean_name, reply: self(), prefix: :node_one},
        {Quorum, config}
      ])

      start_node_supervisor(node_two, [
        {EchoServer, name: config.dean_name, reply: self(), prefix: :node_two},
        {Quorum, config}
      ])

      flush()

      assert GenServer.call({Config.quorum_name(), node_one}, :which_members) == [node_two]
      assert GenServer.call({Config.quorum_name(), node_two}, :which_members) == [node_one]

      # Node desconection
      assert LocalCluster.stop_member(member_one) == :ok

      assert_receive {:node_two, {:quorum_changed, false}}
      assert GenServer.call({Config.quorum_name(), node_two}, :which_members) == []
    end
  end
end
