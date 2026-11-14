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
| `Seymour/Statements.lean` | the exact statements of Proposition 2.1, Proposition 4.1, Lemma 2.2 (subset deficit), Lemma 2.5 (blowup) and Lemma 3.4 (pruning), as `Prop`-valued definitions; and the assembly theorem `main_of_reduction_and_noConcavity`, which derives the main theorem from Propositions 2.1 and 4.1 | **proved** (the assembly) |
| `Seymour/Arithmetic.lean` | the two arithmetic facts the revision isolates: `ledger_weight_one` and `ledger_other_weight_fails` (the weight on uncovered points must be exactly 1), and `blowup_size_ok` (`m ≥ n` suffices for the blowup) | **proved** |
| `Seymour/PruningStatementCheck.lean` | a computer-checked counterexample to the *earlier* (wrong) statement of the pruning lemma, and the values `|Z| = 1`, `|H| = 4` of that example | **proved** (by `decide`) |
| `Seymour/SpecificationCheck.lean` | computer-checked refutations of the *earlier* versions of `NoConcavityStatement` (false on the empty graph), `ReductionStatement` (trivially satisfiable by an empty output) and `IsMinimalCounterexample` (satisfied by no nonempty graph, because the empty graph was a competitor) | **proved** |

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

## Erratum (fixed in the second commit)

An independent review (`rewrite-claude-opus-5.5/REVIEW_OF_rewrite-openmath-DeepSeep4.1.md`,
commit `f3a8838`) found two defects in this development, both of which were real and are now fixed.

1. **`PruningStatement` counted the wrong set.** The first term of the deletion bound was
   `{(b.1, a.2)}`, the conflict points `Z`, where the paper's bound has the collisions
   `H = {(a.1, b.2)}`. With `Z` the statement is *false*: on `X = {0,1}` with `0 → 1`, `1 → 1`,
   `L = {(0,1),(1,1)}`, `R = {(1,0),(1,1)}` one has `|Z| = 1`, `|H| = 4`, and the cheapest
   compatible pruning costs 2 deletions, so the `Z`-version claims `2 ≤ 1`. The statement is fixed,
   and `Seymour/PruningStatementCheck.lean` now proves `z_version_fails` by `decide` so that the
   wrong version cannot come back unnoticed.
2. **`BlowupStatement` was vacuous.** It quantified over an arbitrary graph `H` with positive
   indegrees and asked for strict concavity, which is true only because no `D` satisfies the subset
   deficit. It now refers to the explicit blowup `blowup D m` on `V × Fin m` (arcs `(v,a) → (w,b)`
   iff `v → w`, or `v = w` and `a < b`), so the statement is the paper's Lemma 2.5.

Both defects were in statements, not in the paper's mathematics; the paper's Lemma 3.4 was and is
the `H`-version.

**A note on what this development does and does not achieve.** It checks the definitions, the
statements, the assembly `Propositions 2.1 and 4.1 ⟹ Theorem 1.1`, Corollary 6.1, and two
arithmetic facts; the three deep lemmas are stated but not proved. A *complete* formalization now
exists in the sibling folder `../rewrite-claude-opus-5.5/SeymourLean` (`seymour_second_neighbourhood`,
standard axioms only, which was in progress when this file was first written and is reported
complete at commit `852a03a`). That development is the reference for machine-checked confidence;
this one is the reference for the *statements* in the notation of this rewrite. I could not rebuild
the sibling project in this VM (it needs Lean 4.35 with a Mathlib cache), so I report its status as
claimed by its author.

## Erratum 2 (fixed in the third commit): nonemptiness

A second review (in `../rewrite-codex/updates-review.md`) found that four of the specifications were
satisfied or falsified only through the **empty graph**, because `IsCounterexample` and "strictly
concave" are both vacuous on the empty vertex set:

* `NoConcavityStatement` was *false*: the empty graph satisfies both hypotheses, so the statement
  denied a true proposition;
* `ReductionStatement` was *trivially true*: an empty output always satisfies the conclusion;
* `IsMinimalCounterexample` was satisfied by *no* graph: the empty graph is a smaller competitor whose
  `IsCounterexample` holds vacuously;
* `BlowupStatement` (the pre-`f6f6460` version, quantified over an arbitrary `H`) was *false*, not
  merely vacuous: with the empty base and `m = 1` the premises hold and an unrelated directed triangle
  refutes the conclusion. My commit message called it "vacuous", which was wrong.

All four are fixed by requiring `Nonempty` exactly where the paper requires a nonempty graph, and
`Seymour/SpecificationCheck.lean` now proves the refutations of the earlier shapes
(`old_noConcavity_is_false`, `old_reduction_is_trivial`, `old_minimality_is_empty`). The assembly
theorem takes `[Nonempty V]`, as the paper's theorem does.

**Lesson.** Both errata are of one kind: a formal statement is a *specification*, and the two ways to
get a specification wrong without writing a false theorem about graphs are to name the wrong one of two
similar sets, and to forget that the empty object satisfies every pointwise hypothesis. Both are
cheap to test and neither is visible by reading the mathematics.

## Scope, restated

After these fixes, what is machine-checked in this folder is: the definitions; the exact statements of
Propositions 2.1, 4.1, Lemmas 2.2, 2.5, 3.3 and of the auxiliary blowup; the assembly
`Propositions 2.1 and 4.1 ⟹ Theorem 1.1`; Corollary 6.1; two arithmetic facts; and the two
specification tests above. The three deep lemmas are **not** proved here. A complete formalization
exists in `../rewrite-claude-opus-5.5/SeymourLean` (`seymour_second_neighbourhood`, standard axioms,
Lean 4.35), which I did not rebuild in this VM; `../rewrite-codex/lean/reference/` carries a
hash-checked copy of it with a definition bridge.
