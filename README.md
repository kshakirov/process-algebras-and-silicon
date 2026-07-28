
# Process Algebras and Silicon

Formal verification, concurrency models, and hardware-level memory behavior studies.

## About the Project
This repository is an academic and engineering log exploring the fundamental dualism of concurrent systems: the trade-off between the mathematical abstractions of process calculi and the real-world microarchitectural constraints of physical silicon.

The project moves symmetrically through three domains:
1. **Silicon Physics:** Weak memory models (ARM), Total Store Order (x86), Store Buffers, and memory fences (`FENCE`).
2. **Process Algebras:** Hoare's Communicating Sequential Processes (CSP), Rendezvous channels, Deadlocks, and Livelocks ($\tau$-steps).
3. **Formal Verification:** Model Checking (NuSMV/nuXmv, SPIN) using Linear Temporal Logic (LTL) specifications.

## Repository Structure
* `/labs` — Executable virtual machine emulators (Python) and formal models (`.smv`).
* `/docs` — LaTeX sources and compiled architectural manifestos.

---
*Maintained via Emacs under Linux environment.*
