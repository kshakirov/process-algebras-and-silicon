# BEAM Stand

## Location

`src/elixir/beam_fsm`

## Runtime

`mise.toml` pins:

- Elixir 1.16.2 compiled for OTP 26;
- Erlang/OTP 26.2.5.

`mise` selects tool versions. Mix builds and runs the Elixir project. Hex will
resolve external packages when dependencies are introduced.

## Startup Chain

```text
mise exec -- iex -S mix
→ Mix reads mix.exs
→ OTP calls BeamFsm.Application.start/2
→ BeamFsm.Supervisor starts
→ BeamFsm.Scheduler starts
→ scheduler waits in receive
```

## Current Process Tree

```text
BeamFsm.Supervisor
└── BeamFsm.Scheduler
```

The first scheduler version deliberately used a raw `receive` loop to expose the
BEAM process mechanics. The current prototype has moved to `GenServer`, with
public `call`/`cast` functions and corresponding callbacks. Its status operations
remain provisional and do not yet constitute scheduler semantics.

The raw version remains the conceptual and future measurement baseline; the
`GenServer` version is the main engineering stand.

## Useful Commands

```bash
mise exec -- mix format --check-formatted
mise exec -- mix test
mise exec -- iex -S mix
mise exec -- mix run --no-halt
```

Inside IEx:

```elixir
Process.whereis(BeamFsm.Supervisor)
Process.whereis(BeamFsm.Scheduler)
Supervisor.which_children(BeamFsm.Supervisor)
send(BeamFsm.Scheduler, {:submit, "hello"})
```

For ordinary code changes use `recompile()`. Changes to the supervision tree may
require stopping and starting `:beam_fsm`, or a clean VM restart.
