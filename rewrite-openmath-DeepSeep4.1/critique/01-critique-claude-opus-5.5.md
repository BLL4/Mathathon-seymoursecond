# Critique: `rewrite-claude-opus-5.5`

**What I reviewed.** Repository snapshot at commit `16f8281`. I read `README.md`,
`READABILITY_PLAN.md`, `REVIEW_OF_rewrite-codex.md`, all seven `.tex` files of
`paper/`, `slides/talk.tex`, `slides/README.md`, the three scripts in `checks/`, and all nine
Lean modules under `SeymourLean/SeymourLean/`. I rendered all 28 pages of `paper/main.pdf`
and all 21 frames of `slides/talk.pdf` and looked at every one. I re-ran the three check
scripts and re-derived several of the paper's claims by hand. Numbers below are measured,
not estimated.

**Verdict.** This is the strongest of the three rewrites on structure and on the two
places where the original is most opaque (why the blowup is needed; why the objective is
`|P|+|Q|+u`). It is the weakest of the three on reproducibility of its formalisation and on
numbering discipline. Its central structural decision — motivation before tools — is right,
and I adopted it. Five of my revisions come directly from this folder; they are marked
**[adopted]** below.

Measured: 28 pages, 13 figures, 21 frames, 9 Lean modules with 42 declarations and no
`sorry`, 0 unbuildable-from-scratch evidence (see P1).

---

## 1. What it does better than my rewrite

**1.1 Motivation before tools.** They move the grid, the coordinate images, compatibility,
the objective and the *ledger* into §3, ahead of the pruning lemma in §4
(`paper/sec3-pairs.tex`, `paper/sec4-pruning.tex`). The reader therefore meets
`|H| + #uncovered-after` already knowing why a bound of that shape is wanted. In my rewrite
the pruning lemma comes first and the reader is told its purpose only in a "used in" line
and one bullet of an *Idea* box. **[adopted]** — I keep the order (the lemma is
self-contained and some readers want it early) but I now open my pruning section with the
ledger in words and point forward to §4 explicitly.

**1.2 `κ(S)` as a second difference, and Remark 2.3 ("the error term").** They introduce
`κ(S) = |S| − 2|F(S)| + |F²(S)|`, observe that a plain combination of cardinalities is what
one can sum over many sets, and then show
`κ(S) ≤ (|F²S∖FS| − |FS∖S|) + |S∖FS|`.
That inequality is exactly the reason the blowup is needed: the subset deficit controls the
bracket, and `|S∖F(S)|` is an error term that does not add up. My Remark 2.7 says the same
thing in block-by-block form but only *after* the blowup proof. **[adopted]** — I add the
`κ(S)` identity before the blowup, with the exact equivalence
`κ(S)<0 ⟺ (|F²S∖FS|−|FS∖S|) < |FS∖F²S|−|S∖FS|`, which makes precise which quantity the
deficit fails to control. Verified as a set identity on 3000 random graphs and all their
subsets.

**1.3 Remark "Why this particular value" — the weight on uncovered points is forced.** They
show that with value `|P|+|Q|+λu` the ledger closes for all `d,d'` only when `λ = 1`. This
answers the sharpest "why is the proof like this" question in the whole paper, and neither
my rewrite nor `rewrite-codex` has it. **[adopted]**, with the computation written as
`(λ−1)(d'−d) ≥ 0` and the observation that strictness at `λ = 1` comes from the strict gain,
not from the weight. Their algebra is correct; my own spot-check confirms that `λ = 1/2`
with `d' > d` fails and `λ = 3/2` with `d' < d` fails.

**1.4 Numbered claims in the pruning proof, and Sylvester's inequality named.** Eleven
`claim` environments (`sec4-pruning.tex`) replace the original's run-in headings, and the
step `rank(NL) ≥ rank L + rank N − |Z|` is called what it is. **[adopted]** — I name
Sylvester, and I factor the matching bound out as its own statement so that a reader can
see the two-part shape (bound the matching; König turns it into a cover) before the algebra.

**1.5 A self-contained proof of the vertex-weighted forms.** Their (i) blows up by
*independent* sets of size `k_x` with `η(x) = k_x/K`, and their (ii) is Farkas duality
applied to the reversed graph. Both are correct; I checked the exactness step that matters
(`N₂(v') = ⋃_{w∈N₂(v)} B_w` holds because `N₁(v')` is a union of blocks and blocks are
disjoint) and the limit argument for general real weights. Only (iii), the arc-weighted
form, is left to Seacrest. **[adopted]** — this is a real strengthening of the paper's
dependency list and it removes the need to cite Seacrest for (i) and (ii).

**1.6 A hypothesis ledger.** Remark 5.8 ("Where the hypotheses were used") lists the four
places where orientation enters and the two where positive indegree enters. That is the
question every reader of this proof eventually asks (and the one that catches errors: see
their own statement that orientation is what excludes a return to `v` through `Q`). I have
the same information scattered across steps and footnotes; collecting it into one remark is
better. **[adopted]** — my §4 gains a "where each hypothesis is used" remark with the same
content, cross-referenced to the steps.

**1.7 Two smaller things.** The directed-triangle tightness example in Figure 1(b)
(`|N₁| = |N₂| = 1` at every vertex, so the inequality cannot be strict) is the right
counterweight to the sink remark; and the self-review in `READABILITY_PLAN.md` §3 catches
its own wrong 3-cycle claim (*"in fact |N2| = 0 < 1, so it is not a counterexample only
because … — check!"*), which is exactly what a review pass should do.

---

## 2. What I verified independently

| claim | result |
|---|---|
| `checks/check_small_graphs.py` | reproduces: 1, 3, 27, 729, 59,049 oriented graphs for `n ≤ 5`; 16,168 with positive indegrees; **none** strictly concave; theorem holds in all |
| `checks/check_pruning.py` | reproduces: 3000 random instances, matching bound tight in 778 = 25.9% (they say "about 25%" — accurate) |
| `checks/check_reduction.py` | reproduces: blow-up and increment checks ×5000, extremal set-up on 3481 compatible pairs |
| Example 4.3 / `ex:K22` numbers | `Z = {1,2}²`, `H = {(0,0)}`, 3 deletions `= 1+2` — all correct |
| their claim "the construction in the proof deletes all four" | correct: with the natural maximum matching `{z_L(1,1)–c₁, z_L(2,2)–c₂, r₁–z_R(2,1), r₂–z_R(1,2)}` the alternating-path cover contains all four original members |
| weighted (i), exactness of `N₂(v')` | correct, including the role of orientation (`v ∉ F²{v}`) |
| the `λ`-weight computation | correct |
| no `sorry`, no `axiom` in `SeymourLean` | confirmed by grep; 42 theorem/lemma declarations |

Their Lean is **stronger than mine** in architecture. `Main.lean` contains
`seymour_of_noStrictlyConcave` (the full minimal-counterexample induction) and
`seymour_of_pruningLemma : PruningLemma → SeymourStatement`, and `Reduction.lean`
formalises Lemma 2.2 itself (`subset_deficit`, with counterexample + strong connectivity +
arc-induction as explicit hypotheses), `BlowUp.lean` formalises the blowup, `Konig.lean`
proves König. My development assumes both propositions; theirs assumes only the pruning
lemma (and, inside it, `MatchingBound`). If I had time for one more formalisation pass, the
thing to port is their shape, not mine.

---

## 3. Problems, in the order I would fix them

**P1 (blocking, reproducibility). The Lean project cannot be rebuilt from the folder.**
There is no `.lake` directory, no build log, and no record of a `#print axioms` run. I could
not compile it here, so every Lean claim in `README.md` and Appendix B rests on the author's
word. `rewrite-codex` ships `lean/build.log` and `lean/rank-build.log`; that difference
matters. Fix: ship a build log, a `lake-manifest.json` pin (they have one — point at it)
and one command line that a reviewer can paste.

**P2 (substance). Numbering drift makes cross-checking with the original painful.**
Their Lemma 2.4 is the internal estimate, 2.6 is the blowup, Proposition 2.7 is the
reduction — the original has Lemma 2.3 = blowup and Proposition 2.1 = reduction. Displays
are cited as "(5)", "(6)", "(9)" while the labels are `eq:error-term` and friends. The
dictionary appendix mitigates this, but a reader who is checking the rewrite against the
preprint has to renumber on every page. Fix: put "(= Prop. 2.1 of the original)" in the
statement line of the four load-bearing results, and let cleveref produce the rest.

**P3 (substance). `f` survives next to `F`.** Their own plan §P5 flags `F, F_D, F_G, F₁, F₂,
f` as the worst clash in the original, and the review section decides to keep the original
letters "whenever there is no genuine clash". But `f` *is* a genuine clash: it is the image
operator of the transitive tournament and it appears in the same displays as `F` (e.g.
`|T_v| − 2|f(T_v)| + |f²(T_v)|` immediately after a line about `F(S)`). Renaming it costs
one line in the dictionary. In a rewrite whose stated audience has not seen the original,
this is the one rename worth paying for.

**P4 (presentation). Two figures are marginal at 100% zoom.** Figure 1(a): the arc `w₂ → v`
runs under the shaded `N₁⁺(v)` box, and the caption has to explain which of two shaded
regions is which. Figure 12 (the ledger): `yscale=0.42` squeezes five stacked labels to
roughly 4pt; at print size they are barely legible. Both are fixable by redrawing (put the
return arc outside the boxes; draw the ledger as a table-like bar chart with horizontal
labels).

**P5 (presentation). The ledger is done twice.** Figure 12 draws the four-step inequality,
and §5 then repeats the same four steps in symbols with the same names. Their own plan warns
against "repeating the same intuition three times". One of the two should go, or the figure
should carry the numbers and the text only the two-line summary.

**P6 (precision). Two glosses overreach.** (i) "In words: no set *grows* as much in its
second step as in its first" is not what the subset deficit says: the right-hand side is
`|F(S)∖S|`, the exterior part of the first image, not the whole first image. For `S` with
a large `S ∩ F(S)` the gloss is misleading — exactly the subtlety their own Remark 2.3
later makes precise. (ii) "Sylvester's rank inequality" is quoted in the form
`rank(NL) ≥ rank L − dim ker N`; that is Sylvester's inequality followed by rank–nullity,
not Sylvester's inequality alone. Both are one-sentence fixes.

**P7 (minor).** The "Why this particular value" remark says "This closes up for every
`d,d' ≥ 0` only when `λ = 1`" without the one-line reason `(λ−1)(d'−d) ≥ 0`; with that
line it stops being a computation to be redone and becomes an argument to be remembered.

---

## 4. What I did not adopt, and why

* **Full renaming of `F₁, F₂` to `\Ff, \Fs` while keeping `f`.** I renamed `f → τ` and kept
  `Φ₁, Φ₂`; two different renamings of the same clash is worse than one consistent one, and
  in any case theirs leaves the clash that matters.
* **The long independent-set detour for the weighted forms in the main text.** Their proof
  is right, but it is a consequence, not part of the theorem; I put it in the consequences
  section as a two-paragraph proof with the exactness argument spelled out.
* **Their numbering.** I keep the original's statement numbers wherever the statement is
  the same, and record the exceptions in a dictionary; the reverse (renumber and translate)
  costs the checker more than it gives the first-time reader.

## 5. What I would do next in that folder

1. Ship the Lean build log and one `#print axioms` dump (P1); that single file would move
   the folder from "claims" to "evidence".
2. Rename `f → τ` and add the two "(= original 2.1)" annotations (P2, P3).
3. Redraw Figures 1 and 12; delete the duplicated ledger (P4, P5).
4. Replace the two overreaching glosses (P6) and add the `(λ−1)(d'−d)` line (P7).
