# 001 — Walking Scheduler Skeleton

## Status

Completed on 2026-08-25 in commit `d0f57bd`.

## Goal

Create the smallest executable BEAM stand in which a supervised scheduler process
can receive a message from a client.

## Implemented

- a Mix/OTP application in `src/elixir/beam_fsm`;
- a root supervisor using the `:one_for_one` strategy;
- a named `BeamFsm.Scheduler` process;
- a raw mailbox loop based on `receive` and tail recursion;
- manual client interaction through IEx;
- a test confirming that the supervisor and scheduler are alive.

## Demonstrated Trace

```text
IEx client
→ send(BeamFsm.Scheduler, {:submit, "hello"})
→ scheduler mailbox
→ receive
→ observable output
→ loop
```

## Explicit Non-Goals

- no queue;
- no task state;
- no selection policy;
- no temporal guarantees;
- no latency claims;
- no production readiness claim.

## Evidence

`mise exec -- mix test` passes with one test and zero failures.
