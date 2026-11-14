# Lean 4 companion to the rewrite

Build (from this directory):

```
LEAN_PATH=.:$LEAN_PATH lean -o Seymour/Basic.olean      Seymour/Basic.lean
LEAN_PATH=.:$LEAN_PATH lean -o Seymour/Cycles.olean     Seymour/Cycles.lean
LEAN_PATH=.:$LEAN_PATH lean -o Seymour/Statements.olean Seymour/Statements.lean
```

(`lean` here is Lean 4.33.1 with Mathlib on `LEAN_PATH`, as installed in this VM.)

## What is machine-checked

| file | content | status |
|---|---|---|
| `Seymour/Basic.lean` | `OGraph` (irreflexive, antisymmetric relation), the set image `F`, the first and second out-neighbourhoods, non-neighbours; the lemmas that `F` is monotone, that a vertex is not at distance two from itself, that `N₂` is disjoint from `N₁`, and that `N₂ v ⊆ F (F {v})` | **proved** |
| `Seymour/Cycles.lean` | Corollary 6.1 of the paper: in a triangle-free oriented graph `N₂ v ⊆ nonNeighbours v`; the partition `n - 1 = d⁺ + d⁻ + |non-neighbours|`; and the three consequences (i), (ii), (iii), each proved from the hypothesis that some vertex is *good* | **proved** |
| `Seymour/Statements.lean` | the exact statements of Proposition 2.1, Proposition 4.1, Lemma 2.2 (subset deficit), Lemma 2.5 (blowup) and Lemma 3.3 (pruning), as `Prop`-valued definitions; and the assembly theorem `main_of_reduction_and_noConcavity`, which derives the main theorem from Propositions 2.1 and 4.1 | **proved** (the assembly) |
| `Seymour/Arithmetic.lean` | the two arithmetic facts the revision isolates: `ledger_weight_one` and `ledger_other_weight_fails` (the weight on uncovered points must be exactly 1), and `blowup_size_ok` (`m ≥ n` suffices for the blowup) | **proved** |

## What is *not* machine-checked

The three deep lemmas are **stated** but not proved:

* `SubsetDeficitStatement` (Lemma 2.2), the arc-deletion argument;
* `BlowupStatement` (Lemma 2.5), the transitive-tournament blowup;
* `PruningStatement` (Lemma 3.3), the pruning lemma with its rank argument;
* `Lemmas 3.6 and 3.8`, the kernel lemma and the matching bound inside it.

They appear as definitions of type `Prop`, not as axioms, so nothing in the development
depends on them: the only theorem that uses the two propositions takes them as explicit
hypotheses. This is deliberate. It makes precise which part of the paper is checked by the
machine (the definitions, the statements, the logical architecture, and Corollary 6.1) and
which part remains a human proof.
