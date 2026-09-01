# #1 — Define minimal scheduler protocol: submit to accepted

- State: OPEN
- Created: 2026-09-01T20:15:35Z
- Updated: 2026-09-01T20:15:35Z
- URL: <https://github.com/kshakirov/process-algebras-and-silicon/issues/1>

## Goal

Define and implement the smallest explicit protocol between a client and the
BEAM scheduler process.

## Current state

- the Mix/OTP application and supervision tree are running;
- `BeamFsm.Scheduler` has been migrated from a raw receive loop to `GenServer`;
- the process is registered and exposes provisional synchronous and asynchronous
  calls;
- the current status operations are placeholders and do not yet define scheduler
  semantics.

## Proposed protocol

```elixir
{:submit, client_pid, payload}
{:accepted, payload}
```

The exact meaning of `accepted` must be specified before it is used in a formal
model. In particular, acknowledgement of receipt must not be confused with a
scheduling or execution guarantee.

## Acceptance criteria

- a client submits one request;
- the scheduler receives it;
- the scheduler replies to that exact client;
- an automated test observes the reply;
- scheduler state has an explicit representation and semantics;
- synchronous replies and asynchronous state changes are tested;
- process restart behaviour is tested;
- no queue, priority, retry, fairness, deadline, or latency claim is introduced.

## Follow-up

After the observable protocol is stable, compare the raw-process and `GenServer`
implementations under equivalent semantics and measurement conditions.
