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
