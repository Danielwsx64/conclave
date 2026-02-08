# credo:disable-for-this-file Credo.Check.Warning.UnsafeToAtom
defmodule Conclave.Config do
  defstruct [
    :name,
    :overseer_name,
    :steward_name,
    :dean_name,
    :main_dean_name,
    :quorum_name,
    :min_quorum
  ]

  @default_min_quorum 1
  @default_name Conclave

  def build(opts \\ []) do
    name = Keyword.get(opts, :name, @default_name)

    %__MODULE__{
      name: name,
      overseer_name: overseer_name(name),
      steward_name: steward_name(name),
      dean_name: dean_name(name),
      main_dean_name: main_dean_name(name),
      quorum_name: quorum_name(name),
      min_quorum: max(Keyword.get(opts, :min_quorum, @default_min_quorum), @default_min_quorum)
    }
  end

  def quorum_name(name \\ @default_name), do: Module.concat(name, Quorum)
  def overseer_name(name \\ @default_name), do: Module.concat(name, Overseer)
  def steward_name(name \\ @default_name), do: Module.concat(name, Steward)
  def dean_name(name \\ @default_name), do: Module.concat(name, Dean)
  def main_dean_name(name \\ @default_name), do: Module.concat([name, Dean, Main])
end
