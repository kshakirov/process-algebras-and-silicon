

defmodule BeamFsm.SchedulerTest do
  use ExUnit.Case, async: true

  test "стартует с начальным значением" do
    pid = start_supervised!({BeamFsm.Scheduler, %{counter: 0, fact: 0, predicate: true}})
    assert BeamFsm.Scheduler.get_status(pid) ==0
  end

  test "increment_status" do
    pid = start_supervised!({BeamFsm.Scheduler, %{counter: 0, fact: 0, predicate: true}})
    BeamFsm.Scheduler.increment_status(pid)
    BeamFsm.Scheduler.increment_status(pid)
    assert BeamFsm.Scheduler.get_status(pid) == 2
 end

  test "update_status" do
    pid = start_supervised!({BeamFsm.Scheduler, %{counter: 5, fact: 0, predicate: true}})
    BeamFsm.Scheduler.update_status(pid, 7) 
    assert BeamFsm.Scheduler.get_status(pid) == 12
  end
end
