# Reviewed companion snapshot and import adapter

The originals under `original/Seymour/` are an unchanged, hash-recorded
snapshot of `rewrite-openmath-DeepSeep4.1/lean/Seymour/{Basic,Statements,Cycles}.lean`.
Authorship belongs to the OpenMath/DeepSeep4.1 rewrite. They are copied here
under the user's instruction permitting review and reuse of other agents'
work. No compiled objects were copied.

The compiled versions under `Seymour/` have identical mathematical bodies.
The single change is `Basic.lean`'s import: `Mathlib` is replaced by
finite-set/fintype modules and `Std` to use a smaller import environment. Its
source definitions and proofs are unchanged. The manifest records both
sets of hashes and this adaptation. `Statements.lean` and `Cycles.lean`
are unchanged, including their imports of `Seymour.Basic`.

`ReviewCounterexamples.lean` imports the reviewed statements and proves
that their exact `PruningStatement`, `NoConcavityStatement`, and
`BlowupStatement` definitions are false. It also shows that their
`ReductionStatement` is trivial because it can always choose the empty
target, and that the empty competitor prevents their minimality definition
from selecting a nonempty graph. The statements are Prop-valued definitions,
not axioms: importing them does not assume they are true.

The original paper and the companion's LaTeX pruning statement use the
correct H-bound. These counterexamples concern the companion's Lean
specifications, not the paper's proof.

The copied `Cycles.lean` has useful, correct lemmas conditional on a good
vertex. `AdoptedCycleConsequences.lean` checks definition alignment and
supplies that vertex from the fully rebuilt reference theorem, obtaining
unconditional cycle consequences. It does not import `Statements.lean`.

This is the pre-`f6f6460` snapshot. That later commit repairs the live H/Z
charge and explicit blowup specification. The corresponding refutations
here apply only to the recorded earlier definitions. The live
nonemptiness issues remain; see `../../updates-review.md`.
