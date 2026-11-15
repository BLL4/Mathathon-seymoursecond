# Seymour's second-neighborhood conjecture: a readable rewrite (Claude Opus 5.5)

This folder is my work on the Mathaton task in `../AGENTS.md`. The goal was
to make the OpenAI preprint in `../original` (read-only) easier to understand.

| What                                                                          | Where                                                                        |
| ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| Readability plan (draft, self-review, final plan), written before the rewrite | [`READABILITY_PLAN.md`](READABILITY_PLAN.md)                                 |
| **Rewritten paper**, 42 pages, 17 TikZ figures                                | [`paper/main.pdf`](paper/main.pdf) (source: `paper/*.tex`)                   |
| **20-minute Beamer talk**, 23 frames, with timing plan                        | [`slides/talk.pdf`](slides/talk.pdf), [`slides/README.md`](slides/README.md) |
| **Animations** (Manim): why the grid (prologue); one improvement step worked out on a 4-vertex graph | [`animation/WhyGrid.mp4`](animation/WhyGrid.mp4), [`animation/ImprovementStep.mp4`](animation/ImprovementStep.mp4), [`animation/README.md`](animation/README.md) |
| **Experiments**: computer searches behind the new remarks (three-term complex, tightness of the matching bound, an unproven local form) | [`experiments/README.md`](experiments/README.md) |
| **Transcript** of the whole Claude Code session (user messages and replies verbatim, tool calls as one-liners); regenerate with `python3 tools/export_transcript.py` | [`transcript.md`](transcript.md) |
| Computer checks (Python, standard library only)                               | [`checks/`](checks/)                                                         |
| Lean 4 / Mathlib formalization                                                | [`SeymourLean/`](SeymourLean/) (see its README)                              |
| Review of the other agents' work                                              | [`REVIEW_OF_rewrite-codex.md`](REVIEW_OF_rewrite-codex.md), [`REVIEW_OF_rewrite-openmath-DeepSeep4.1.md`](REVIEW_OF_rewrite-openmath-DeepSeep4.1.md) |
| Response to criticism of this folder                                          | [`RESPONSE_TO_CRITIQUES.md`](RESPONSE_TO_CRITIQUES.md)                       |

## How the rewrite differs from the original

* A one-page **proof map** (Figure 2), plus a "what this section does" box at
  the start and a recap at the end of each section.
* Section 3 (the grid of pairs) has a table of the two sides (left family =
  first coordinate moves = vertical = columns; right family = second
  coordinate moves = horizontal = rows). It also has a remark saying that
  "left/right" are names, not positions, and a worked example on the
  directed triangle that shows exactly where strictness is needed. All grid
  figures draw left members to the left of right members.
* The proof is reorganized so that **motivation comes before tools**. The grid
  of pairs, the objective `val = |P| + |Q| + #uncovered` and the accounting
  ("ledger", Figure 6) are explained *before* the pruning lemma, so the reader
  knows why its odd-looking cost bound is exactly what is needed. Remark 3.7
  shows that the weight 1 on uncovered points is forced.
* The four-page proof of the pruning lemma is split into **numbered claims**
  with a stated plan. It uses a worked example (Example 4.3) showing that the
  bound is an exchange rate, not a bound on the minimum number of deletions.
  The commuting square NL = AB is drawn *on the conflict rectangle* of the
  grid (Figure 10), and Sylvester's inequality is named.
* The reduction has an explanation of **why the blow-up is needed** (the error
  term |S \ F(S)|, Remark 2.3) and an exact block-by-block computation.
* Notation clashes in the original (D, A, M, Z each used for two things) are
  removed. Appendix A has a dictionary to the original numbering.
* A **self-contained proof of the vertex-weighted forms** (Corollary 6.1(i),
  (ii)) by blowing up into independent sets and using Farkas/Ville. Only the
  arc-weighted form (iii) still relies on Seacrest's equivalence.

## Correctness

I verified every step of the original by hand and found no mathematical
error (see Appendix A of the paper for the points that are only implicit in
the original). Independent checks:

* `checks/check_pruning.py`: the pruning lemma and the matching bound
  ν(Γ) ≤ |Z| + |H| on thousands of random relations, including exhaustive
  search for valid prunings. The bound is tight in about 25% of the
  instances.
* `checks/check_reduction.py`: the blow-up master inequality, the increment
  identity of the subset-deficit proof, and the diagonal and corner claims of
  the extremal step, all on random instances.
* `checks/check_small_graphs.py`: the theorem, and the nonexistence of
  strictly concave graphs with positive indegrees, on **all** labelled oriented
  graphs with at most 5 vertices (and 6 vertices, see `checks/small6.log`).

Run: `python3 -I checks/<script>.py`.

## Building

```sh
cd paper  && latexmk -pdf main.tex
cd slides && latexmk -pdf talk.tex
cd SeymourLean && lake build      # needs Mathlib cache: `lake exe cache get`
```

## Lean

**The whole proof is formalized.** `lake build` in `SeymourLean/` checks

```lean
theorem Seymour.seymour_second_neighbourhood (V : Type) [Fintype V] [DecidableEq V] [Nonempty V]
    (adj : V → V → Prop) [DecidableRel adj] (hor : IsOriented adj) :
    ∃ v, (N1 adj v).card ≤ (N2 adj v).card
```

with no `sorry` and only the standard axioms `propext`, `Classical.choice`
and `Quot.sound`. The build and the `#print axioms` output are recorded in
[`SeymourLean/build.log`](SeymourLean/build.log). This includes the pruning lemma for an arbitrary relation:
König's theorem from Hall's theorem, generic matrices, the kernel lemma and
the matching bound. `SeymourLean/README.md` maps each Lean theorem to the
paper and lists the few steps that are argued differently. No mathematical
error was found.

The claims added in the insights pass are formalized too:
`SeymourLean/ComplexCount.lean` proves the matching bound's count through the
three-term complex ℝ^R → ℝ^Z ⊕ ℝ^H → ℝ^C (and `core_bound` now uses it), and
`SeymourLean/Insights.lean` proves that F₁ and F₂ commute, that the Kronecker
operators aᵀ⊗I and I⊗b commute, that an admissible pair exists exactly when
the relation is oriented, that reversing the relation swaps Z and H, the
exact gain identity |R| + |C| + Σκ = μ + 2d, and the ledger
val(P′,Q′) ≥ val(P,Q) − Σκ for an arbitrary relation (no concavity assumed).
`SeymourLean/Triangles.lean` proves Corollary 6.2: without directed
triangles a Seymour vertex has 2d⁺(v) + d⁻(v) + 1 ≤ n, so a digraph with all
out- and in-degrees at least n/3 has a directed cycle of length at most 3
(the symmetric Caccetta–Häggkvist case for triangles, `ch3_symmetric`), and
an r-regular triangle-free oriented graph has at least 3r + 1 vertices; it
also proves that triangle-freeness is the grid statement F₁²Δ ∩ F₂Δ = ∅.
`CheckAxioms.lean` prints the axioms of these theorems as well.

## Caccetta–Häggkvist for triangles

Section 6.3 of the paper records what the theorem gives for the
Caccetta–Häggkvist conjecture with k = 3: the symmetric case (minimum in- and
out-degree ≥ n/3) is now a sharp theorem; the full case would follow from a
strengthening of Seymour's theorem, Conjecture 6.4 ("some Seymour vertex has
d⁻(v) ≥ d⁺(v)"), which is proved for tournaments via median orders and tested
by `experiments/ch_triangle.py` on all oriented graphs with ≤ 6 vertices, all
tournaments with ≤ 7 vertices and random graphs with up to 20 vertices.
Remark 6.9 explains why the proof's three stages do not see the hypothesis
δ⁺ ≥ n/3.
