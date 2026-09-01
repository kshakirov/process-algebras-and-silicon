# Research Direction

## Central Question

Can a practically useful low-latency dispatcher be built in which candidate
storage, transition admissibility, selection policy, and temporal guarantees form
one formally analyzable mechanism?

## Key Separation

```text
admissibility ≠ selection ≠ temporal obligation
```

- Transition rules determine what may happen now.
- A policy chooses among currently allowed transitions.
- Temporal properties constrain complete execution traces.

## Method

```text
problem
→ minimal model
→ experiment
→ formalization
→ implementation
→ measurement
→ comparison
```

No universal scheduler primitive is introduced merely because an existing system
contains one. Queue semantics, fairness, retries, priorities, and deadlines must
each arise from a concrete experimental need.

## Current Boundary

The present stand demonstrates only a supervised process receiving a message.
It does not yet implement scheduling in the technical sense.
