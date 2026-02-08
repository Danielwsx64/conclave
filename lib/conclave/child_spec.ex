defmodule Conclave.ChildSpec do
  def build(child_spec) do
    child_spec
    |> Supervisor.child_spec([])
    |> randomize_child_id()
  end

  @big_number round(:math.pow(2, 32))
  defp randomize_child_id(%{start: {_mod, _fn, [opts]}} = child_spec) do
    if get_in(opts, [:conclave, :unique]) == true do
      child_spec
    else
      %{child_spec | id: "#{child_spec.id}_#{:rand.uniform(@big_number)}"}
    end
  end
end
