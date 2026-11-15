# Formalization status after resuming work

The directory now contains a complete, attributed reference proof of the
unweighted theorem and a separate set of Codex component proofs. They have
different provenance and should not be conflated.

## Full reference theorem

Author: **Claude Opus 5.5**. The twelve source files were copied unchanged
from the other work directory into `lean/reference/SeymourLean/` after the
initial Codex commit. The snapshot's origin, time, and source hashes are in
`lean/reference/source-manifest.json`. No compiled objects were copied.

`lean/check-reference.py` verifies those hashes and compiles every source
in dependency order, writing only here. The rebuild checks the minimality
reduction, subset deficit, blowup, matching and pruning proof, extremal
contradiction, and final assembly. The reference theorem is
`Seymour.seymour_second_neighbourhood`.

`lean/ReferenceBridge.lean`, authored here, proves that the reference exact
second neighborhood agrees with our second image minus the first image
under asymmetry. Its final theorem, `second_neighborhood_theorem`, states
that a nonempty finite asymmetric relation has a vertex with the desired
cardinality inequality in this exposition's notation. It has no pruning,
rank, matching, or reduction hypothesis.

Both final theorems print exactly:

```
[propext, Classical.choice, Quot.sound]
```

The reference source has nonfatal deprecation and unused-section-variable
warnings. They do not introduce logical assumptions; the snapshot is left
unchanged. The reference route uses the fraction field of a multivariate
polynomial ring over the rationals for its generic coefficients, whereas
the article presents a simultaneous real coefficient assignment.

## Independent Codex component development

Seven files contain 39 checked component theorem declarations, with no
warnings, unfinished proofs, or custom axioms:

| File | Checked content | Explicit boundary |
|---|---|---|
| `SecondNeighborhood.lean` | Coordinate images, diagonal geometry, proper fibers, old uncovered corners, exact-neighborhood convention, integer accounting | Does not construct the finite extremal maximizer |
| `RankChecks.lean` | Maximum-support-rank kernel lemma; independence from normalized lifts; commuting-square rank count | Rank and spanning inputs are explicit |
| `KernelRestrictions.lean` | Full corner equations restrict to both auxiliary kernels; conflict product; normalized right witness kills the left coordinate | Auxiliary maximum-rank conditions are explicit |
| `CoverageLifts.lean` | Construct normalized lifts from spanning coverage columns; derive kernel dimension with coordinate vanishing | Coverage spanning is explicit |
| `PruningAlgebra.lean` | Connect the actual corner maps, right probes, left lifts, and kernel dimension | Assumes the square identity, auxiliary rank maximality, and coverage spans |
| `GenericAssignment.lean` | Shared-variable polynomial nonvanishing, simultaneous nonsingular minors, simultaneous full ranks | Selected determinant polynomials are assumed nonzero |
| `MatchingMinor.lean` | A diagonal matching and distinct variable names certify a nonzero sparse determinant by identity specialization | Does not assemble all block minors and matching normalization |

The matching-minor and simultaneous-assignment checks include empty minors
and empty lists of conditions. Variables may be shared between different
minors; distinctness is required only within the one minor receiving its
matching specialization.

The separate Codex proof chain has not yet replaced the reference graph
reduction and matching assembly. Its value is an additional check of the
paper's real-assignment and maximum-support-rank interfaces, rather than a
second claim of an independently completed graph formalization.

## Reproduce

From `rewrite-codex`, with a compiled mathlib v4.35.0 checkout:

```sh
python3 lean/check.py --mathlib-root /path/to/mathlib
python3 lean/check-reference.py --mathlib-root /path/to/mathlib
```

The helper recognizes mathlib installations whose dependencies live inside
the checkout or alongside it in a Lake packages directory. All compiled
outputs and logs are written inside `rewrite-codex`.

## Additional cross-review and adopted consequences

`ReviewCounterexamples.lean` imports a hash-recorded snapshot of the
DeepSeep4.1 statements and proves their `PruningStatement`,
`NoConcavityStatement`, and `BlowupStatement` false as written. It also
proves that their reduction can always choose the empty target and that
an empty competitor rules out nonempty graphs under their minimality
specification. These are statements about that companion's definitions,
not counterexamples to the original paper or the complete reference proof.

`AdoptedCycleConsequences.lean` reuses the companion's correct cycle lemmas,
checks first- and second-neighborhood equality with the full reference
formalization, and supplies the good vertex from the main theorem. The
triangle-free degree bound, semidegree triangle conclusion, and regular
order bound are thereby checked without an unproved main-theorem input.

Only imports were narrowed in the compiled review snapshot; mathematical
bodies are unchanged and checked against their originals. The corresponding
originals, hashes, adaptation, build instructions, and attribution are in
`lean/review-target/`. The audit and cycle theorems print only standard Lean
axioms. They are not included in the count of 39 component theorems above.

Final update check at `99e1cbb`: the live companion repairs the H/Z charge
and specifies the actual blowup in `f6f6460`. Those two refutations concern
our recorded earlier snapshot. Its live empty-graph issues remain; see
`updates-review.md`. A numerical budget trace was added in response to the
new critique of our older snapshot.

## Snapshot maintenance (November 15)

The attributed reference tree is a pinned historical snapshot, with no
automatic synchronization to the other agent's directory. Its manifest and
checker validate our included bytes; they do not claim to detect every
upstream change. Any adoption of later proof changes requires a deliberate
source comparison, a new recorded snapshot, and a rebuild. The review-target
snapshot is likewise historical: the live companion has now repaired its
empty-type specifications and the prose defects. Its earlier definitions
are kept here for reproducible regression evidence, not as a description of
its current status. The visual slide revision changes no Lean theorem.
