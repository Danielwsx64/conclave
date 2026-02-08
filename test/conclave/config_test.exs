defmodule Conclave.ConfigTest do
  use ExUnit.Case, async: true

  alias Conclave.Config

  describe "build/1" do
    test "build default configuration struct" do
      assert Config.build() == %Config{
               dean_name: Conclave.Dean,
               main_dean_name: Conclave.Dean.Main,
               min_quorum: 1,
               name: Conclave,
               overseer_name: Conclave.Overseer,
               quorum_name: Conclave.Quorum,
               steward_name: Conclave.Steward
             }
    end

    test "change default name" do
      assert Config.build(name: CustomName) == %Config{
               dean_name: CustomName.Dean,
               main_dean_name: CustomName.Dean.Main,
               min_quorum: 1,
               name: CustomName,
               overseer_name: CustomName.Overseer,
               quorum_name: CustomName.Quorum,
               steward_name: CustomName.Steward
             }
    end

    test "change min_quorum" do
      assert Config.build(min_quorum: 5).min_quorum == 5
    end
  end
end
