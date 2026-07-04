# Conclave

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `conclave` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:conclave, "~> 0.1.0"}
  ]
end
```

```elixir
  # @impl true
  # def handle_call({:start_child, child_spec}, _from, %{main?: true} = state) do
  #   state.config
  #   |> Steward.start_child(child_spec)
  #   |> reply(state)
  # end
  #
  # @impl true
  # def handle_call({:terminate_child, pid}, _from, state) do
  #   pid_node = node(pid)
  #
  #   if node() == pid_node do
  #     state.config
  #     |> Steward.terminate_child(pid)
  #     |> reply(state)
  #   else
  #     {state.config.dean_name, pid_node}
  #     |> GenServer.call({:terminate_child, pid})
  #     |> reply(state)
  #   end
  # end
  #
  # @impl true
  # def handle_call(:which_children, _from, state) do
  #   Node.list()
  #   |> Enum.reduce([{node(), inner_which_children(state.config)}], fn node, acc ->
  #     [{node, GenServer.call({state.config.dean_name, node}, :inner_which_children)} | acc]
  #   end)
  #   |> reply(state)
  # end
  #
  # def handle_call(:inner_which_children, _from, state) do
  #   state.config
  #   |> inner_which_children()
  #   |> reply(state)
  # end
  #
  # @impl true
  #
  # def handle_call(msg, _from, %{main?: false} = state) do
  #   state.main_pid
  #   |> GenServer.call(msg)
  #   |> reply(state)
  # end
  #
  #
  # defp inner_which_children(config) do
  #   Steward.which_children(config)
  # end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/conclave>.

