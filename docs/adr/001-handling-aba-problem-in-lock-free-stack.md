# 1. Handling ABA Problem in Treiber Lock-Free Stack

## Status
Proposed

## Context
We are implementing a concurrent, lock-free Treiber Stack. The standard implementation relies on a single `Head` pointer updated via an atomic `CAS` (Compare-And-Swap) operation.

However, `CAS` is blind to structural history. If a thread reads head `A`, and gets preempted, a concurrent thread can perform multiple operations, effectively recycling address `A` (ABA sequence). The preempted thread will blindly succeed its `CAS`, potentially setting `Head` to a dangling, freed pointer `B`, causing catastrophic memory corruption (Segmentation Fault).

## Decision
We decide to augment the logical `Addr` type of the `Head` pointer with a generational epoch counter (Version), effectively transforming the type into a pair: $\langle \text{Address}, \text{Version} \rangle$. Every structural mutation (`PUSH` or `POP`) must atomically increment the version, forcing a mismatch in the stale `CAS` comparison.

## Consequences
* **Positive:** The ABA problem is mathematically eliminated; stale `CAS` operations will fail safely due to version mismatch ($0 \neq 2$).
* **Negative:** We increase memory pressure and spatial overhead. To update both Address and Version in a single atomic step, the hardware must support Double-Width CAS instructions (e.g., `CMPXCHG16B` on x86-64 or bit-tagging fields inside a single 64-bit word).

## Alternatives Considered
* **Hazard Pointers:** Memory management technique where threads declare "hazards" on specific nodes to prevent allocation recycling. Rejected due to high runtime scanning overhead.
* **Garbage Collection (GC):** Relying on a runtime GC that guarantees a node's memory is never reclaimed or reused as long as any thread holds a reference to it. Rejected because we target raw silicon/bare-metal environments where automatic GC is non-existent.
