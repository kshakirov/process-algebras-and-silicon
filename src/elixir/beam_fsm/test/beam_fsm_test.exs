

defmodule BeamFsm.SchedulerTest do
  use ExUnit.Case, async: true

  test "стартует с начальным значением" do
    pid = start_supervised!({BeamFsm.Scheduler, 10})
    assert BeamFsm.Scheduler.get_status(pid) == 10
  end

  test "increment_status" do
    pid = start_supervised!({BeamFsm.Scheduler, 0})
    assert BeamFsm.Scheduler.increment_status(pid) == 1
    assert BeamFsm.Scheduler.increment_status(pid) == 2
    assert BeamFsm.Scheduler.get_status(pid) == 2
  end

  test "update_status" do
    pid = start_supervised!({BeamFsm.Scheduler, 5})
    assert BeamFsm.Scheduler.update_status(pid, 7) == 12
    assert BeamFsm.Scheduler.get_status(pid) == 12
  end
end
