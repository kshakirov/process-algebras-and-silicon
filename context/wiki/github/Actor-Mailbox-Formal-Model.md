# Actor–Mailbox Formal Model

> **Status:** research hypothesis, not an accepted architecture or a proved
> equivalence.

## Objective

Build the smallest formal model that connects the Elixir/BEAM scheduler stand
to established theories of communicating processes. The first target is not a
complete semantics of BEAM. It is a model precise enough to state and test the
protocol between a client and a scheduler.

## Core state

An actor-like process is represented by:

```text
ActorState = <pid, behavior, local_state, mailbox, links>
SystemState = PID -> ActorState
```

- `pid` is the process address.
- `behavior` determines which messages can be handled and the next state.
- `local_state` is private to the process.
- `mailbox` is an ordered collection of pending messages.
- `links` records failure-propagation relationships when that feature is in
  scope.

The minimal transition families are:

```text
send(p, q, m):     append m to q.mailbox; p does not rendezvous with q
receive(q, m):     select a matching m from q.mailbox and update q's state
spawn(p, behavior): create a fresh pid with an initial actor state
exit(p, reason):   terminate p and propagate signals according to its links
```

BEAM selective receive is stronger than simply taking the mailbox head: the
first message matching the active receive clauses is selected, while unmatched
messages remain pending. Any abstraction that replaces this rule with a FIFO
queue must state what behavior it loses.

## A `GenServer.call` is a protocol

A synchronous-looking call is not a primitive rendezvous in the actor model. It
is modeled as a request and a correlated reply, with waiting on the caller side:

```text
client --request(ref, payload)--> scheduler
client <--reply(ref, result)----- scheduler
```

This distinction matters when comparing the implementation with CSP: one CSP
event can model an atomic rendezvous, whereas the mailbox implementation has at
least two observable communication steps and an intermediate state.

## Modeling ladder

| Scope | Candidate formalism | What it captures |
| --- | --- | --- |
| One `GenServer` | Labeled transition system / Mealy machine | State and request-driven transitions |
| Fixed processes with FIFO mailboxes | Communicating finite-state machines | Asynchronous messages and channel contents |
| Dynamic spawn and PID passing | Actor calculus or asynchronous pi-calculus | Fresh identities and changing communication topology |
| Selective receive, links, exits | Core Erlang operational semantics | BEAM-relevant language behavior |
| Synchronous comparison model | CSP | Rendezvous, choice, traces, refusal-style properties |

These levels are complementary. None is assumed to be a lossless translation of
all the others.

## CSP correspondence — and its limits

| CSP notion | Actor/mailbox candidate | Qualification |
| --- | --- | --- |
| Process | Actor behavior plus local state | A runtime actor also has identity and a mailbox |
| Channel event | Send/receive protocol | Asynchronous send splits one rendezvous into multiple transitions |
| External choice | Selective receive clauses | Similar control role, different mailbox and readiness semantics |
| Parallel composition | Actor configuration | Actor topology may change through spawn and PID passing |
| Recursion | Receive/callback loop | Operationally useful correspondence |
| Hiding / internal event | Local computation | The chosen observation boundary must be explicit |
| No direct primitive | Supervisor/link structure | Failure propagation needs an explicit encoding in CSP |

Therefore we should compare observable traces or stated properties, not claim
that CSP processes and BEAM processes are the same objects.

## First experimental boundary

The initial system contains one client and one supervised scheduler process. Its
first protocol is:

```text
submit(job) -> accepted(job_id)
```

At this stage, `accepted` means only that the scheduler has completed the
specified acceptance transition. We have **not** yet defined:

- a scheduling policy;
- a job queue;
- fairness or starvation freedom;
- deadlines or latency guarantees;
- execution, completion, retry, or cancellation semantics.

Those properties must be introduced one at a time, together with an executable
experiment and a formal statement.

## Open questions

1. Is `accepted` merely a reply receipt, or evidence of a durable state
   transition?
2. Which mailbox ordering assumptions are necessary for the first protocol?
3. Can selective receive be abstracted without changing the properties under
   study?
4. Is fairness a scheduler guarantee, a runtime assumption, or an environmental
   assumption?
5. Which failures are represented as messages, exits, links, or supervisor
   restarts?

## Next experiment

Describe the same `submit -> accepted` protocol in three forms:

1. executable Elixir using `GenServer`;
2. a small communicating-state-machine model;
3. a CSP comparison model.

Then compare their traces and mark every abstraction boundary. Only after the
three agree on the first stated property should the stand acquire queueing or
scheduling policy.

## Primary references

- Daniel Brand and Pitro Zafiropulo, [On Communicating Finite-State
  Machines](https://research.ibm.com/publications/on-communicating-finite-state-machines).
- Gul Agha et al., [Towards a Theory of Actor
  Computation](https://osl.cs.illinois.edu/publications/conf/concur/AghaMST92.html).
- Roberto M. Amadio, Ilaria Castellani, and Davide Sangiorgi, [On Bisimulations
  for the Asynchronous Pi-Calculus](https://www.sciencedirect.com/science/article/pii/S0304397597002235).
- Péter Bereczky et al., [A Formalisation of Core Erlang, a Concurrent Actor
  Language](https://www.mdpi.com/2073-431X/13/11/276).
