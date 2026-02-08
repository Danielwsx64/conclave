defmodule Conclave.ChildSpecTest do
  use ExUnit.Case, async: true

  alias Conclave.ChildSpec

  describe "build/0" do
    test "generate a child_spec with random id" do
      assert %{id: id, start: {Support.Pong, :start_link, [[]]}} =
               ChildSpec.build(Support.Pong)

      assert String.starts_with?(id, "Elixir.Support.Pong_")
    end

    test "Keep child spec id when has unique opt" do
      assert ChildSpec.build({Support.Pong, [conclave: [unique: true]]}) == %{
               id: Support.Pong,
               start: {Support.Pong, :start_link, [[conclave: [unique: true]]]}
             }
    end
  end
end
