defmodule BeamFsmTest do
  use ExUnit.Case

  test "application starts" do
    assert Process.whereis(BeamFsm.Supervisor) != nil
    assert Process.whereis(BeamFsm.Scheduler) != nil
  end
end
