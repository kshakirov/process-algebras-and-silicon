# 002 — Minimal Scheduler Protocol

## Status

Open.

GitHub: <https://github.com/kshakirov/process-algebras-and-silicon/issues/1>

## Question

What is the smallest explicit protocol between a client and the scheduler that
lets us observe both message delivery and a reply without introducing a queue or
scheduling policy prematurely?

## Proposed First Step

Add one request shape carrying the client PID:

```elixir
{:submit, client_pid, payload}
```

and one reply shape:

```elixir
{:accepted, payload}
```

## Acceptance Criteria

- a client sends one request;
- the scheduler receives it;
- the scheduler replies to that exact client;
- an automated test observes the reply;
- message shapes and assumptions are documented;
- no queue, priority, retry, fairness, or deadline semantics are added.

## Open Questions

- Should the scheduler echo the payload or assign an identifier?
- Is `:accepted` merely an acknowledgement of receipt, or a state transition?

The second question must be answered before `accepted` is used in a formal model.

## Progress Note — 2026-09-01

### Completed

- reviewed the Elixir semantic core needed for the stand: pattern matching,
  guards, modules, immutable data, processes, links, errors, behaviours, and
  `GenServer`;
- replaced the scheduler's manual `spawn_link`/`receive` implementation with a
  supervised, registered `GenServer` prototype;
- connected a public synchronous API to `handle_call/3`;
- connected a public asynchronous API to `handle_cast/2`;
- verified interactive calls from project IEx;
- established a practical Emacs workflow using IEx inside `vterm`.

### Learned

- public API functions are the client side of a `GenServer` protocol;
- `handle_call/3` and `handle_cast/2` are the server-side callbacks executed by
  the generic receive loop;
- callback return tuples describe both the response and the next server state;
- a module name and a registered process name can be the same atom, but they are
  distinct concepts.

### Still Required

- define the actual meaning and representation of scheduler state;
- replace the provisional constant status operations with state-preserving,
  testable semantics;
- implement `submit → accepted` without prematurely adding queue semantics;
- add automated tests for synchronous replies, asynchronous state changes, and
  process restart behaviour;
- decide whether the raw receive-loop baseline belongs in a separate module or
  only in repository history;
- measure raw-process and `GenServer` implementations only after their observable
  protocols are equivalent.
