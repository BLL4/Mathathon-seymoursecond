# SeymourLean: a Lean 4 formalization of Seymour's second neighbourhood conjecture

This is a formalization in Lean 4 (toolchain `v4.35.0`, Mathlib `v4.35.0`) of the proof in
`../paper/` (sections 2–4) and of Section 3 of the original preprint
(`original/build/source/03-incompatibility.tex`).

**Status: complete and unconditional.** `lake build` succeeds. No file contains `sorry`, `admit` or
a new `axiom`.

```
#print axioms Seymour.seymour_second_neighbourhood
-- [propext, Classical.choice, Quot.sound]
```

**Evidence without rebuilding.** `build.log` records a full `lake build`, the output of
`lake env lean CheckAxioms.lean` (the statement and `#print axioms` for the main theorem,
the pruning lemma and the theorems of the insights pass). To reproduce:

```sh
lake exe cache get && lake build && lake env lean CheckAxioms.lean
```

`lake-manifest.json` pins the Mathlib revision.

## Main theorem

```lean
theorem Seymour.seymour_second_neighbourhood (V : Type) [Fintype V] [DecidableEq V] [Nonempty V]
    (adj : V → V → Prop) [DecidableRel adj] (hor : IsOriented adj) :
    ∃ v, (N1 adj v).card ≤ (N2 adj v).card
```

The definitions are in `SeymourLean/Defs.lean`:
* `IsOriented adj := (∀ x, ¬ adj x x) ∧ ∀ x y, adj x y → ¬ adj y x`
* `N1 adj v := {w | adj v w}`
* `N2 adj v := {w | w ≠ v ∧ ¬ adj v w ∧ ∃ u, adj v u ∧ adj u w}` (directed distance exactly 2)

`Seymour.seymourStatement : SeymourStatement` states the same thing as a closed proposition.

## Theorems by file and the paper statements they formalize

| Lean name | File | Meaning | Paper |
|---|---|---|---|
| `PruningLemma` (def) | Defs | statement of the pruning lemma (P1)–(P3), any finite `X`, any relation, any `R C ⊆ X×X` | sec4 Lemma `lem:pruning` |
| `no_strictlyConcave` | Contradiction | `PruningLemma →` there is no nonempty oriented graph with positive indegrees that is strictly concave (`\|U\|+\|F²U\| < 2\|FU\|` for all nonempty proper `U`) | original §3, Prop. `prop:no-concavity`; sec3 `sec:ledger` |
| `card_eq_sum_col`, `col_F1`, `fiber_sum_F1/F2` | Contradiction | `(F₁P)_j = F(P_j)`, and summing over columns or rows | sec3 eq. `eq:columnwise` |
| `disjoint_of_noConflict` | Contradiction | compatible ⇒ `F₁P ∩ F₂Q = ∅` | sec3 Lemma `lem:conflict-geometry`(b) |
| `seymour_of_closed` | Reduction | a nonempty proper set with no outgoing arc yields a Seymour vertex via the induced subgraph | sec2 Lemma `lem:strong` |
| `sum_of_steps`, `subset_deficit` | Reduction | subset deficit `\|F²S∖FS\| < \|FS∖S\|` in a minimal counterexample | sec2 Lemma `lem:subset-deficit` |
| `internal_estimate` | BlowUp | `\|T\|-2\|f T\|+\|f²T\| ≤ 1` in a transitive tournament (`f` is `τ` in the paper) | sec2 Lemma `lem:internal` |
| `blowup` | BlowUp | `D[T_m]` (`m > n`) is oriented, has positive indegrees and is strictly concave | sec2 Lemma `lem:blowup` |
| `seymour_of_noStrictlyConcave` | Main | minimal counterexample (strong induction on `(\|V\|, #arcs)`) + deficit + blow-up | sec2 Prop. `prop:reduction` |
| `seymour_of_pruningLemma` | Main | `PruningLemma → SeymourStatement` | — |
| `IsMatching`, `IsCover`, `card_le_cover`, `konig` | Konig | Kőnig's theorem for finite bipartite relations (via the defect form of Hall's theorem from Mathlib) | sec4 Claim `cl:konig` |
| `Gam`, `MatchingBound` (def), `pruning_of_matchingBound` | Gamma | the graph `Γ`; matching bound ⇒ pruning lemma | sec4 Def. `def:gamma`, Claims `cl:isolated`, `cl:cover-to-pruning` |
| `ColIndep`, `InSpan`, `ColIndep.card_le_rank`, `exists_colIndep_spanning`, `ColIndep.exists_matching`, `rank_mul_ge` | LinAlg | column independence; extracting a column basis; independent columns can be matched to rows with nonzero entries (Hall); Sylvester's rank inequality | used in sec4 `sec:rank`, `sec:generic` |
| `generic_indep`, `block_indep` | Generic | generic matrices: nonzero determinant by specialization; columns along a matching of the support are independent | sec4 fact (iii), Claim `cl:edmonds`(b) |
| `generic_kernel` | Generic | kernel lemma for a generic matrix | sec4 Lemma `lem:kernel` |
| `NL_eq_AB` | MatchingCore | `NL = AB` | sec4 Claim `cl:commute` |
| `kernel_claim` | MatchingCore | `u ∈ ker B`, `v ∈ ker Nᵀ`, `r,c` conflict ⇒ `u_r v_c = 0` | sec4 Claim `cl:conflict-kernel` |
| `rank_add_rank_le_of_mul_eq_zero`, `sideCols_mul_stackRows`, `complex_count` | ComplexCount | `G F = 0 ⇒ rank F + rank G ≤ dim(middle)`; `NL = AB ⇒ (N,-A)(L;B) = 0`; the count `k+ℓ+t ≤ \|Z\|+\|H\|` from independent columns of `L`, `Nᵀ` and kernel vectors of `L` with independent images under `B` | sec4 `sec:rank`, Claims `cl:rank-inequality`, `cl:kerA` |
| `dimension_count` | MatchingCore | `rank (L;B) + rank (N,-A) ≤ \|Z\|+\|H\|` for the matrices of the paper | sec4 Claim `cl:rank-inequality` |
| `core_bound` | MatchingCore | `k+ℓ+t ≤ \|Z\|+\|H\|` for a decomposed matching with the two maximality properties | sec4 Claims `cl:kerA`, `cl:rank-inequality` |
| `matchingBound` | MatchingBound | `ν(Γ) ≤ \|Z\|+\|H\|` | sec4 Prop. `prop:matching-bound` |
| `pruningLemma` | MatchingBound | the pruning lemma, proved | sec4 Lemma `lem:pruning` |
| `seymour_second_neighbourhood` | Final | the main theorem, unconditional | Theorem `thm:main` |
| `F1_F2_comm`, `kronecker_comm` | Insights | `F₁F₂ = F₂F₁`; `(aᵀ⊗I)(I⊗b) = (I⊗b)(aᵀ⊗I)` | sec4 Remark `rem:kronecker` |
| `diag_compatible_iff_oriented`, `exists_admissible_iff_oriented` | Insights | `(Δ,Δ)` compatible ⇔ oriented; an admissible pair exists ⇔ oriented | sec3 Lemma `lem:admissible-iff-oriented` |
| `conflict_swap`, `Zset_swap`, `Hset_swap` | Insights | reversing the relation swaps the roles in a conflict and exchanges `Z` and `H` | sec3 Remark `rem:reversal` |
| `gain_identity`, `moved_identity` | Insights | `\|R\|+\|C\|+Σκ = μ+2d`; `\|R\|+\|C\|-d` is the formal value of `(F₁P,F₂Q)` | sec3 Remark `rem:move-repair`, sec5 Remark `rem:algorithm` |
| `step_ledger`, `step_value` | Insights | for any relation and admissible `(P,Q)`: pruning the complements gives an admissible pair of value `≥ \|R\|+\|C\|-d = val(P,Q) - Σκ`, no concavity assumed | sec3 `sec:ledger` Steps 3–4, sec5 Remark `rem:algorithm` |
| `exists_two_out_add_in_le` | Triangles | oriented, no directed triangle ⇒ some `v` has `2 d⁺(v) + d⁻(v) + 1 ≤ n` | sec6 Corollary `cor:triangles` (i) |
| `ch3_symmetric`, `ch3_symmetric_loopless` | Triangles | all out- and in-degrees `≥ n/3` ⇒ a loop, a digon or a directed triangle (the symmetric Caccetta–Häggkvist case for `k = 3`) | sec6 Corollary `cor:triangles` (ii) |
| `regular_girth_four` | Triangles | `r`-regular, no directed triangle ⇒ `3r + 1 ≤ n` | sec6 Corollary `cor:triangles` (iii) |
| `triangleFree_iff_grid`, `seed_compatible_iff` | Triangles | no directed triangle ⇔ `F₁²Δ ∩ F₂Δ = ∅`; the seed `(Δ ∪ F₁Δ, Δ)` is compatible ⇔ oriented and triangle-free | sec6 Lemma `lem:girth-grid` |
| `inheavy_of_sink`, `inheavy_of_closed` | InHeavy | a sink is an in-heavy Seymour vertex; a minimal counterexample to Conjecture `conj:inheavy` has no closed nonempty proper set | sec6 Proposition `prop:inheavy-minimal` (a) |
| `inheavy_delArcs_mem`, `indeg_ge_outdeg_sub_one` | InHeavy | the in-heavy Seymour vertex of the arc-deleted graph lies in `S`; every vertex of a minimal counterexample has `d⁺(u) ≤ d⁻(u) + 1` (any class closed under arc deletion) | sec6 Proposition `prop:inheavy-minimal` (b) |
| `subset_deficit_inheavy`, `triangleFree_delArcs` | InHeavy | every nonempty set of in-heavy vertices with an arc leaving it has `\|F²S \ FS\| < \|FS \ S\|` in a minimal counterexample; triangle-freeness survives arc deletion | sec6 Proposition `prop:inheavy-minimal` (d) |
| `sullivan_min` | Related | some `v` has `2 min(d⁻(v), d⁺(v)) ≤ d⁺(v) + d⁺₂(v)` (Sullivan's Conjecture 6.7) | sec6 §6.4 (c) |
| `thomasse_nonneighbours` | Related | oriented, no directed triangle ⇒ some `v` has at most as many out-neighbours as non-neighbours (Thomassé's Conjecture 6.12) | sec6 §6.4 (a) |

## Where the formal proof differs from the paper (same mathematics, different route)

1. **Lemma `lem:strong`.** We do not use strongly connected components. We prove the property used
   later: in a minimal counterexample, every nonempty proper set `S` has an arc leaving it.
   Otherwise the induced subgraph on `S` is a smaller counterexample. Positive indegrees follow by
   taking `S = V ∖ {y}`.
2. **Minimality.** We use nested strong induction on `|V|` and then on the number of arcs (for a
   fixed vertex type), instead of a "minimal counterexample" object.
3. **Genericity.** We do not pick a real point. We work over the field
   `K = Frac(ℚ[x_(tag,u,w)])` and use the indeterminates themselves as the generic assignment
   (`a_pi = x_(false,p,i)`, `b_sj = x_(true,s,j)`, or `0` when there is no arrow). A determinant is
   shown to be nonzero by specializing it to the identity matrix (0/1 values). This is done block by
   block, because a variable `a_pi` is shared between blocks of `L`.
4. **Claim `cl:alpha-max` and Edmonds' rank = matching number.** We avoid augmenting paths and do
   not prove `rank L = ν(Γ_L)` in general. A matching of `Γ` is encoded as data
   `(R₁ → C, R_α → Z, C_β → Z)`. We choose data that maximizes `k+ℓ+t` and, subject to this,
   minimizes `k`. The exchange "drop the conflict edge at `r₀`, use a larger `α`" then gives
   directly: *no matching of `Γ_L` saturates `R_α ∪ {r₀}`*. The linear algebra uses only:
   (a) the columns `R_α` of `L` are independent (generic, from the matching `α`);
   (b) if the columns `R_α ∪ {r₀}` were independent, Hall's theorem would produce a matching of
   `Γ_L` saturating them. Hence `L e_{r₀} ∈ span{L e_a : a ∈ R_α}`.
   The bound `rank L ≥ ℓ` (resp. `rank N ≥ t`) follows from (a). The upper bound `rank L ≤ ℓ` is not
   needed separately.
5. **Kernel lemma.** "Φ has maximal rank among matrices with the same support" is proved as follows.
   Any matrix `Ψ` supported there has `rank Ψ` independent columns. Hall gives a matching of the
   support saturating them, so the same columns of the generic `Φ` are independent. The lemma is
   stated for `Φᵀ`, which is harmless.
6. **Rank inequality.** As in the paper (`sec:rank`), the count goes through the three-term complex
   `K^R → K^Z ⊕ K^H → K^C`: Sylvester's inequality (`rank_mul_ge` in `LinAlg`) applied to the zero
   product `(N,-A)(L;B) = NL - AB = 0` gives `rank (L;B) + rank (N,-A) ≤ |Z| + |H|`, and the matching
   gives `rank (L;B) ≥ ℓ + k` (independent columns `R_α` of `L` plus the vectors `(0, B u^r)`) and
   `rank (N,-A) ≥ rank N ≥ t`. An earlier version of the project used Sylvester twice
   (`rank L + rank N ≤ rank(NL) + |Z|` and `rank W + rank A ≤ |H|` for `AW = 0`).

## Notes on the mathematics

No error was found. Every step of sec2, sec3, sec4 and of original §3 was formalized as written, up
to the route changes listed above. Small observations:
* In the linear-algebra core (`core_bound`), injectivity of the map `R₁ → C` given by the conflict
  edges of the matching is not used. It is needed only in the exchange argument for the `β` side,
  where `C₁ ∩ C_β = ∅` must be preserved.
* Orientation (asymmetry) is used exactly where the paper says: in the losses step of the subset
  deficit (`c ≠ v`), in `D[T_m]` being oriented, and in `(Δ,Δ)` being compatible. The pruning lemma
  is proved for an arbitrary relation.
