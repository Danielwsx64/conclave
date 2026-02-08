defmodule Support.ClusterHelpers do
  @cookie :valid_cookie

  def initilize_cluster(name \\ :first) do
    Node.start(name, :shortnames)

    Node.set_cookie(@cookie)
  end

  def connect_cluster do
    :os.system_time()
    |> to_string()
    |> String.slice(-4..-1)
    |> then(&"#{Enum.random(["alfa", "beta", "delta", "sigma"])}#{&1}")
    |> String.to_atom()
    |> initilize_cluster()

    "first@#{:net_adm.localhost()}"
    |> String.to_atom()
    |> Node.connect()
  end
end

defmodule Support.Dev do
  def start_application do
    Support.Application.start(:normal, [])
  end
end

import Support.ClusterHelpers
import Support.Dev
