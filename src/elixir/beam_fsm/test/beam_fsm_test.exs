

defmodule BeamFsm.SchedulerTest do
  use ExUnit.Case, async: true

  test "стартует с начальным значением" do
    pid = start_supervised!({BeamFsm.Scheduler, %{counter: 0, fact: 0, predicate: true, task: nil, facts: []}})
    assert BeamFsm.Scheduler.get_status(pid) ==0
  end

  test "increment_status" do
    pid = start_supervised!({BeamFsm.Scheduler, %{counter: 0, fact: 0, predicate: true, task: nil, facts: []}})
    BeamFsm.Scheduler.increment_status(pid)
    BeamFsm.Scheduler.increment_status(pid)
    assert BeamFsm.Scheduler.get_status(pid) == 2
  end

  test "update_status" do
    pid = start_supervised!({BeamFsm.Scheduler, %{counter: 5, fact: 0, predicate: true, task: nil, facts: []}})
    BeamFsm.Scheduler.update_status(pid, 7) 
    assert BeamFsm.Scheduler.get_status(pid) == 12
  end


  test "submit_task" do
    pid = start_supervised!({BeamFsm.Scheduler, %{counter: 5, fact: 0, predicate: true, task: fn x -> x + 1 end,  facts: []}})
    assert    BeamFsm.Scheduler.submit_task(pid, fn x-> x * 10 end) == 20

  end
  test "add_fact" do
    pid = start_supervised!({BeamFsm.Scheduler, %{counter: 5, fact: 0, predicate: true, task: fn x -> x + 1 end,  facts: []}})
 assert    BeamFsm.Scheduler.add_fact(pid, %{value: 100}) == 101

  end
end


#f = fn x -> x + 1 end
