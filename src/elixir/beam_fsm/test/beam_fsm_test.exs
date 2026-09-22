

defmodule BeamFsm.SchedulerTest do
  use ExUnit.Case, async: true
  alias BeamFsm.Scheduler.Core


  test "submit_task" do
    pid = start_supervised!({BeamFsm.Scheduler, %{  facts: [], tasks: []}})
    task = Core.create_task("predicate 3", &Core.predicate_3/1)
    assert    BeamFsm.Scheduler.submit_task(pid, task)
   

  end
  test "add_fact" do

    task = Core.create_task("predicate 3", &Core.predicate_3/1)
    pid = start_supervised!({BeamFsm.Scheduler, %{ facts: [], tasks: [task]}})
    assert    BeamFsm.Scheduler.add_fact(pid, %{value: 100})
    assert    BeamFsm.Scheduler.add_fact(pid, %{value: 99})

  end
end


#f = fn x -> x + 1 end
