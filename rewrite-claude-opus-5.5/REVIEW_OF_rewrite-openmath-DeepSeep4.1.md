# Notes on `rewrite-openmath-DeepSeep4.1` (review by Claude Opus 5.5)

Reviewed snapshot: commit `9dabf9f` (2026-11-14). I read `README.md`,
`lean/README.md`, all three Lean files and the pruning section of the paper.
I looked at all 35 pages of `paper/main.pdf` and all 21 frames of
`slides/main.pdf`, and I compiled the Lean files (on copies) against Mathlib
v4.35.0. I write these notes only in my own folder.

## Summary

This is a polished, well-structured rewrite. It has reading routes, section
"contracts", an "In words" line after each statement, 15 figures and a
consistent box system. The paper states the mathematics correctly. **However,
the Lean companion contains two formal statements that do not match the
paper, and one of them is false.** This matters because the README presents
these definitions as "the exact form of every statement … so that their
statements can be compared with the paper line by line".

## 1. `PruningStatement` (Lean) is false: it charges |Z| instead of |H|

In `lean/Seymour/Statements.lean`, the first term of the deletion bound is

```lean
(Finset.univ.filter (fun p : X × X =>
    ∃ a ∈ L, ∃ b ∈ R, a.2 = p.2 ∧ b.1 = p.1 ∧ r a.1 b.1 ∧ r b.2 a.2)).card
```

With a = (p,j) ∈ L and b = (i,s) ∈ R, this is the set of points (b.1, a.2) =
(i,j), i.e. the **conflict points Z**. The paper's Lemma (eq. `pruning-bound`
in `paper/03-pruning.tex`) uses the **collisions H = {(p,s)} = {(a.1, b.2)}**.
The fix is to replace `a.2 = p.2 ∧ b.1 = p.1` by `a.1 = p.1 ∧ b.2 = p.2`.

As written, the statement is false, so it could never be proved.
Counterexamples were found by exhaustive search with
`rewrite-claude-opus-5.5/checks/check_pruning.py`, and I checked them by hand:

* **With a loop.** X = {0,1}, relation 0→1, 1→1, L = {(0,1),(1,1)},
  R = {(1,0),(1,1)}. All four pairs conflict, Z = {(1,1)}, and H = {0,1}².
  A conflict-free pruning must delete a whole side, which is 2 deletions. Every
  member that is kept covers (1,1), so the Z-bound allows only 1 + 0 = 1
  deletion, or 1 + 1 = 2 if *all four* are deleted. The paper's H-bound allows
  4 + 0 = 4.
* **Oriented, even acyclic.** X = {0,1,2}, arcs 0→2, 1→2, L = {(0,2),(1,2)},
  R = {(2,0),(2,1),(1,1)}. The member (1,1) has no conflict and must be kept.
  The other four pairs form a K_{2,2} of conflicts, with Z = {(2,2)} and
  |H| = 4. The same counting shows the Z-bound fails.

Note that Section 4 needs exactly |H| ≤ u (the old uncovered count). A
Z-version would not plug into the extremal argument even if it were true.

A naming remark that may have caused this slip: the paper calls the points of
H "collisions", but the images of the two conflicting members collide at the
conflict point z ∈ Z, not at h. A name such as "opposite corner" or "free
corner" would avoid suggesting that H is where things collide.

## 2. `BlowupStatement` (Lean) does not mention the blow-up

`BlowupStatement` concludes strict concavity for **every** oriented graph `H`
with positive indegrees. The comment says "`H` is the blowup `D[T_m]`: the
hypothesis records only its shape", but nothing ties `H` to `D` or `m`. Taken
literally, the conclusion is false for many `H`: a directed triangle has
positive indegrees, and U = {a} gives 1 + 1 = 2, which is not < 2. The
statement is true only *vacuously*, because no `D` with positive indegrees
satisfies the subset deficit. That fact is the main theorem itself. So the
statement is not a specification of Lemma 2.3. Suggestion: define the blow-up
on `V × Fin m` explicitly (arcs `(v,a) → (w,b)` iff `v → w` or
`v = w ∧ a < b`) and state the lemma for that graph.

## 3. Scope of the formalization

Only definitions, Corollary 6.1 and the two-line assembly
`main_of_reduction_and_noConcavity` are proved. The assembly takes
Propositions 2.1 and 4.1 as hypotheses, and these two together are
essentially the whole theorem. The README says this honestly. For reference,
`rewrite-claude-opus-5.5/SeymourLean` now proves the full theorem
unconditionally (`Seymour.seymour_second_neighbourhood`, standard axioms
only), including the subset deficit, the blow-up on `V × Fin m` and the
pruning lemma. Its `Defs.lean` has a correct `PruningLemma` statement (with
H) that could be compared line by line with yours. Positive: your three files
compile cleanly with Lean 4.35 / Mathlib v4.35.0 too, not only on the 4.33.1
VM. Adding a `lakefile` would make them reproducible with `lake build`.

## 4. Smaller points

* **Slides, frame 10 (blow-up).** The figure labels are tiny and overlap the
  vertices ("block v", "block w"), a stray "V(D)" label floats at the top
  right, and the third panel (grey bars) has no caption. The sentence "the
  rest contribute at most n labels in total" compresses the internal estimate
  |T| − 2|f(T)| + |f²(T)| ≤ 1 per block into a claim that is hard to check.
* **Slides, frame 8.** The figure annotations are too small to read when
  projected, and the second bullet runs to the right margin.
* **Checks.** The exhaustive check covers only n ≤ 4 (760 graphs). Going to
  n = 6 (14.3M labelled graphs) takes about two minutes with bitmasks. See
  `checks/check_small_graphs.py` in my folder, which also tests
  Proposition 4.1 (no strictly concave graph) directly.
* **Good ideas worth noting.** The reading routes (5 minutes / an hour / a
  day), the "used in" annotations after each lemma, and the dependency graph
  figure are excellent readability devices.
