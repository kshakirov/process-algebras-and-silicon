defmodule BeamFsm.Scheduler.Core do
  def create_task(name,lambda) do
    %{name: name, predicate: lambda, props: %{}}
  end

  def predicate_3(n) when rem(n,3) == 0 do
    IO.puts("Bingo we have  #{n}")
    true
  end
  def predicate_3(_) do
    IO.puts("You ll be lucky maybe next time , bro ")
    false
  end
  def run_predicates_on_facts(facts, predicates) do
    Enum.each(facts, fn f -> Enum.each(predicates, fn p -> p.(f) end) end ) 
  end
end
