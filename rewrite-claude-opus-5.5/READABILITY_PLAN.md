# What it means to make this write-up more readable

*Working document, written before the rewrite (per AGENTS.md). Draft 1 is
below; the "Review" section records what I changed after rereading it, and
the final plan is the revised version that the rewrite follows.*

## 0. Who the reader is

The target reader is a graduate student or researcher in combinatorics who
knows what a directed graph, a matching, König's theorem and the rank of a
matrix are, but who has **not** seen Seymour's conjecture literature in
detail and has not read the original preprint. The reader should be able to
(a) understand the architecture of the proof after reading the overview,
(b) verify every step with pencil and paper, and (c) remember the two or
three ideas that make the proof work.

A second reader is the expert who wants to check correctness quickly. For
that reader, every claim should be stated as a numbered statement with
explicit hypotheses, and every "clearly" should be replaced by the one-line
reason.

## 1. Diagnosis of the original

The original is mathematically complete and very compressed (15 pages including references).
Its main readability problems:

1. **The architecture is only visible after you understand it.** The
   "Proof strategy" paragraph of the introduction mentions families of
   ordered pairs, coordinate images, compatibility, uncovered points and a
   pruning lemma in one breath, before any of these objects has been
   defined or motivated. A first-time reader cannot use it as a map.
2. **Notation is dense and partly overloaded.** `F`, `F_D`, `F_G`, `F_1`,
   `F_2`, `f` are all image operators; `P,Q` versus `R, C` versus
   `P', Q'` are families; `Z` is used both for the set of "conflict points"
   in the pruning lemma and for non-neighbours in Section 5; `D` is the
   counterexample graph and also a matrix `D^{p,i}`; `A` is both an arc set
   and a matrix; `M` is a number (`|P|+|Q|`) in Section 3 and a matching
   `\mathcal M` in Section 2.
3. **No pictures of the key objects.** There is exactly one figure (a
   four-vertex path). The proof is full of geometric objects that are much
   easier to see than to read: the deletion step in Lemma 2.2, the
   lexicographic blow-up, columns/rows of a set of pairs in the grid
   `X × X`, the coordinate images `F_1`, `F_2` as "moving a point
   horizontally/vertically", conflicts as two pairs whose images collide,
   the commuting square `NL = AB`, the augmented bipartite graph.
4. **The reason each step is needed is postponed or missing.** E.g.
   why the objective is `M + d` and not `M`; why the pruning lemma must charge
   cost to points uncovered *after* pruning; why the minimal counterexample
   must be chosen with minimum order *and then* minimum number of arcs; why
   one passes to a blow-up at all.
5. **Long proofs have no internal signposting.** The pruning proof
   (Section 2) is ~4 pages with only three run-in headings. The reader does
   not know in advance that the goal is "max matching ≤ |Z| + |H|" and that
   this splits into three rank conditions.
6. **Small facts are proved inline and then used much later** (e.g. "an
   initially conflict-free member is isolated in Γ"), so they are hard to
   find again. These should be stated as numbered claims.
7. **Quantifier-heavy sentences.** E.g. "The families are compatible when
   the first-coordinate image of the left family and the second-coordinate
   image of the right family are disjoint." Better: a definition display,
   followed by a picture and a one-line equivalent (no conflicting pair).

## 2. Principles for the rewrite

**P1. Top-down structure with a roadmap.** Open with the statement, one
paragraph of history, then a *one-page proof map*: a flow diagram

  counterexample → (Lemma A: subset deficit) → (Lemma B: blow-up) →
  graph with strict "concavity" |U| + |F²U| < 2|FU| →
  (extremal pair of families + Pruning Lemma) → contradiction.

Each box names the section where it is proved and the one idea it uses.

**P2. Every section starts with "What we do here and why" and ends with
"What we have achieved".** A two-to-four sentence intuition paragraph before
each lemma; a short recap after each long proof, stating exactly what will
be used later.

**P3. Toy examples and sanity checks.** For each new definition give a tiny
example: a directed 3-cycle (where the conjecture is tight: |N1| = |N2|... in
fact |N2| = 0 < 1, so it is not a counterexample only because ... — check!),
a transitive tournament on 4 vertices for the internal block estimate,
a 3×3 grid for coordinate images.

**P4. Figures.** Target 12–15 TikZ figures, each with a caption that can
be read on its own:
 - first and second out-neighbourhoods of a vertex;
 - the proof map (flow chart);
 - the deletion step in the subset-deficit lemma: S, I = F(S)∩S,
   E = F(S)\S, T, Q, C;
 - the lexicographic blow-up D[T_m] and the internal image f(T);
 - the grid X×X with a column P_j and its image F_1;
 - the coordinate images F_1 (vertical move in our drawing convention) and
   F_2 (horizontal move);
 - a conflict between r = (p,j) and c = (i,s): the "rectangle"
   (p,j) → (i,j) ← (i,s) and the opposite corner (p,s);
 - the commuting square R^R → R^Z → R^C and R^R → R^H → R^C;
 - the augmented bipartite graph Γ (a small example);
 - the König alternating-path cover;
 - the accounting picture: M + 2d gained, d + d' lost, d' regained.

**P5. Consistent, non-overlapping notation.** Planned changes:
 - `D` = counterexample digraph throughout; matrices get letters that
   are not used for graphs (`Φ^{p,i}` instead of `D^{p,i}`).
 - `N(S)` would clash with neighbourhoods; keep the original `F(S)` for the
   out-image ("forward image") but write `F_1`, `F_2` as `F_{\mathrm{v}}`,
   ... — **reconsider**: renaming against the source increases the risk of
   errors and makes cross-checking with the original harder. Decide in the
   review below.
 - Conflict points `Z` in the pruning lemma vs. non-neighbours `Z(v)`: rename
   non-neighbours to `\overline{N}(v)`.
 - The matching is `\mathcal M`; the number `|P|+|Q|` becomes `m(P,Q)`
   or `\Sigma`... decide in review.
 - A notation table at the end of the introduction.

**P6. Split long proofs into claims.** The pruning lemma proof becomes:
 Step 0 (reduction to a vertex cover of the augmented graph Γ),
 Step 1 (König: enough to bound the maximum matching),
 Step 2 (normalising the maximum matching),
 Step 3 (four matrices and NL = AB),
 Step 4 (the rank inequality |H| ≥ k + ℓ + t − |Z|, assuming three
         conditions),
 Step 5 (generic choice of coefficients),
 Step 6 (the kernel lemma and dim ker A ≥ k).
Each step states its claim in a box before proving it.

**P7. Explain the "magic".** For the two non-obvious inventions, add a
paragraph of heuristics:
 - *Why maximise M + d?* Summing the concavity inequality over the columns
   of P gains 2 per column-unit relative to F_1 P; complementing doubles
   the gain; the pruning lemma pays d (old uncovered) + d' (new uncovered);
   the d' cancels because it is in the objective. Show this as a ledger.
 - *Why linear algebra in the pruning lemma?* Matching bounds by
   determinants (Edmonds); two factorisations of the same "conflict matrix"
   through Z and through H; generic coefficients turn combinatorial
   structure into rank structure. Explain on a single conflict first, then
   on the whole picture.

**P8. Correctness first.** Every inequality that the original asserts in
a single line is expanded so that each step can be checked; every use of
a hypothesis (orientation, positive indegree, minimality of arcs, m > n)
is flagged at the point of use. Where I find a gap, I fix it and mark it
in a "Remarks on the original" appendix.

**P9. Keep it self-contained but cite precisely.** The main theorem
should need nothing beyond linear algebra and König's theorem (both with
proofs sketched or cited). Seacrest's equivalences are only needed for the
weighted corollaries; I give a direct proof of the vertex-weighted form
(i) via blow-ups by independent sets, so that only the arc-weighted form
depends on an external result.

**P10. Typesetting.** Theorem environments with names, cleveref,
coloured boxes only for the 4–5 "key statements" (main theorem,
Proposition A, Proposition B, Pruning Lemma), short paragraphs, displayed
formulas for anything with more than one quantifier.

## 3. Review of draft 1 (self-critique)

Rereading the plan above:

* **P3, the 3-cycle example is wrong as written.** In the directed 3-cycle
  `a→b→c→a`, `N_1^+(a)={b}` and `N_2^+(a)={c}`, so |N1|=|N2|=1: every vertex
  satisfies the conjecture with equality. That is a good example of
  tightness. Fix the text.
* **P5 renaming.** Renaming everything makes cross-referencing the original
  painful and is a source of transcription errors. Revised decision: keep
  the original letters whenever there is no genuine clash
  (`F, F_1, F_2, P, Q, \mathcal R, \mathcal C, Z, H, L, N, A, B, \Gamma`);
  only rename the real clashes:
   - number `M=|P|+|Q|` → `\mu(P,Q)` (the matching keeps `\mathcal M`);
   - matrix `D^{p,i}` → `\Phi^{p,i}`;
   - non-neighbours `Z(v)` → `\overline N(v)`;
   - arc set `A(D)` → `E(D)` is impossible because E is used in Lemma A; use
     `\mathrm{Arc}(D)`.
   - the weighted objective `M+d` becomes `\Phi`? No — `\Phi` is now a
     matrix. Use `\operatorname{val}(P,Q)=|P|+|Q|+d(P,Q)`.
  Add a short table mapping new notation to the original.
* **Drawing convention for X × X.** I must fix once and for all how a pair
  `(i,j)` is drawn. Choose: first coordinate = row index (vertical axis,
  top to bottom), second coordinate = column index (horizontal axis). Then
  the "column" `P_j = {p : (p,j)∈P}` really is a column, `F_1` moves points
  vertically inside a column, `F_2` moves points horizontally inside a row
  `Q_i`, and the diagonal is the usual diagonal. This matches the words
  "columns of P" and "rows of Q" used in the original. Check this
  consistency in every figure.
* **Missing from draft 1: what is *not* the difficulty.** A reader benefits
  from knowing that Sections 1 (reduction) and the final extremal step are
  short and elementary, and that the real novelty is the pruning lemma
  (which holds for every relation, not only for oriented graphs). Say this
  in the introduction and make the pruning section the heart of the paper.
* **Missing: dependency of hypotheses.** Make an explicit list of where
  orientation is used: (1) `v ∉ F(Q)` in Lemma A, (2) `N_2^+(v) =
  F^2(v) \ F(v)` in the introduction, (3) Δ compatible in the extremal step,
  (4) the blow-up is oriented. Positive indegree is used in (a) columns are
  proper, (b) the case S = V(D) of the blow-up. Put this in a remark.
* **Missing: a worked toy computation for the pruning lemma.** A complete
  example of Γ with 2–3 conflicts would help a lot, but it must be correct.
  Use a tiny relation and compute Z, H, Γ, a maximum matching and the cover
  by hand; double-check with a small script.
* **Length.** The rewrite will be 2–3× longer. That is acceptable if
  every addition is either a figure, an intuition paragraph or an expanded
  verification. Avoid repeating the same intuition three times: say it once
  in the roadmap, once (more precisely) at the start of the section.
* **Lean.** Formalising generic-rank arguments is expensive. Plan to
  formalise the purely combinatorial parts first (definitions, the
  extremal/accounting step given the pruning lemma as a hypothesis, the
  blow-up inequality, the subset deficit), and the pruning lemma as far as
  time allows. Be honest in the write-up about what is and is not
  formalised.

## 4. Final plan (revised)

1. Introduction: statement, picture of N1/N2, the 3-cycle tightness
   example, history (condensed), proof map figure, "where the novelty is",
   notation table.
2. Section "From a counterexample to strict concavity" = original §1, with
   figures for the deletion step and the blow-up, the internal-block
   computation done on an example, a recap box.
3. Section "Pairs, coordinate images and the extremal setup": definitions of
   F_1, F_2 with the grid picture, compatibility = no conflicts,
   the objective val = |P|+|Q|+d, and the ledger heuristic. (This moves the
   *definitions* of original §3 before the pruning lemma so the reader knows
   why the lemma is wanted.)
4. Section "The pruning lemma": statement, a worked example,
   then the proof in Steps 0–6 with figures (Γ, commuting square,
   kernel lemma).
5. Section "The contradiction": the remainder of original §3 with the
   ledger.
6. Consequences (weighted, directed cycles), with the direct proof of the
   vertex-weighted form.
7. Appendix: dependence on hypotheses; remarks on the original; status of
   the Lean formalisation.
