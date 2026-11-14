# Critique: `rewrite-codex`

**What I reviewed.** Repository snapshot at commit `16f8281`. I read `README.md`,
`readability-plan.md`, `correctness-ledger.md`, `other-work-review.md`, `verification-scope.tex`,
`reader-guide.tex`, `historical-context.tex`, all six numbered sections, `main.tex`,
`talk.tex`, both Lean files and the two build logs. I rendered all 22 pages of `main.pdf` and
inspected the pages that carry figures, and I re-ran `check_finite.py` and reproduces its
numbers. Claims below are checked unless marked otherwise.

**Verdict.** This is the most *trustworthy* of the three rewrites — the best correctness
artefact, the most careful statement of scope, and a fidelity strategy (keep the original
text, add only explanation) that makes side-by-side checking possible. It is also the least
readable of the three on the one proof that matters: the pruning lemma is still the
original's four pages of unlabelled prose, and the reader is asked to reconstruct its
architecture. Its abstract also hedges about whether the theorem is proved, which its own
ledger contradicts.

Measured: 22 pages, 10 figures, 15 frames plus a separate 15-page speaker-notes PDF,
0 overfull boxes, 0 undefined references, 2 Lean files with 26 theorem declarations and no
`sorry`.

---

## 1. What it does better than my rewrite

**1.1 Fidelity as a strategy, not a compromise.** The proof text is retained nearly
verbatim and everything added sits *around* it: a reading guide, interface paragraphs, a
worked example, figures, a scope section. Consequence: the numbering of every statement
matches the preprint exactly (Lemma 3.2 is the kernel lemma in both). A reader who is
checking the rewrite against `original/build/source` never renumbers. My rewrite pays for
its clearer prose with a numbering shift that I then have to document; theirs does not.
**[adopted in spirit]** — I keep my numbering (my charter's rule R11 needs the renames) but
I now annotate the four load-bearing statements with the original's numbers, which is the
part of their advantage that costs nothing.

**1.2 `correctness-ledger.md` is the best correctness document in the three folders.** It
walks the proof interface by interface (reduction, blowup, pruning, extremal step,
consequences) and for each says what the hypothesis is used for — e.g. "orientation excludes
a return to `v` through `Q`", "arc minimality applies to the same vertex set, even if the
deleted graph is disconnected or has a sink", "the two charges are bounded by `d` and `d'`;
no claim `d' ≤ d` is needed". That last one is a real trap that neither of the other two
write-ups flags. **[adopted]** — my verification appendix becomes a per-step table of this
kind rather than a list of scripts.

**1.3 A worked pruning example with verified numbers.** `X = {0,1,2}`, arrows `0→1`, `0→2`,
`𝓛 = {(0,1),(0,2)}`, `𝓡 = {(1,0),(2,0)}`. I recomputed: all four pairs conflict,
`Z = {1,2}×{1,2}`, `H = {(0,0)}`; deleting a whole family costs 2 but leaves `q = 0`, so the
bound `2 ≤ |H| + q = 1` fails; keeping only `(0,1)` costs 3 deletions and leaves `q = 2`,
so `3 = 1 + 2` holds. Every number is right. **[adopted]** — I add the same example (with
the deletion count and the two `q`-values in a small table), and I credit that both
`rewrite-codex` and `rewrite-claude-opus-5.5` found it independently, which suggests it is
the canonical one.

**1.4 A direct proof of the vertex-weighted form (i).** Theirs goes through blocks of size
`0` for zero weights and uses only containment `N₂(clone) ⊆` union of blocks of `N₂(v)`,
which is slightly more robust than requiring exactness. It removes Seacrest from the
dependency list for (i). **[adopted]** — I prove (i) and (ii) directly and leave only the
arc-weighted (iii) to Seacrest; see the note on P6 below for the one place where their
version and mine differ.

**1.5 Honest scope.** `verification-scope.tex` says exactly what the Lean development does
*not* cover, and the README repeats it. Given that the folder ships claims of the form "26
checked declarations", this honesty is what makes the claims usable.

**1.6 Speaker notes.** A separate notes PDF with a minute-by-minute allocation is a good
artefact; my slides carry the timing in a README instead, which is less useful to a speaker
who is actually presenting.

---

## 2. What I verified independently

| claim | result |
|---|---|
| `check_finite.py` reproduces `finite-results.json` | yes: 1/3/27/729/59,049 oriented graphs for `n = 1..5`; 4,096 two-point relation/family triples; 1,000 seeded `n = 3,4` samples; 10,000 increment identities |
| worked pruning example (all numbers) | correct, including `Z`, `H`, the failure at `q = 0` and the success at `q = 2` |
| reader-guide example (`v→a,b; a→b,c; b→c`) | correct: `N₁(v) = {a,b}`, `F²({v}) = {b,c}`, `N₂(v) = {c}`; `c` is a sink, so the graph is not a counterexample |
| counts "26 checked theorem declarations", "no `sorry`" | confirmed by grep: 22 + 4 declarations, no `sorry`, no `axiom` |
| 0 overfull boxes, 0 undefined references | confirmed in `article-build.txt` |
| the claim that the talk allocates 20 minutes | the frame list carries timings and the arithmetic adds to 20:00 |

---

## 3. Problems, in the order I would fix them

**P1 (substance, and the one thing I would change first). The abstract contradicts the
folder's own conclusion.** `main.tex` says: *"The supplied preprint presents Theorem 1.1 as
a resolution of the conjecture"* and *"The main contribution of this version is exposition;
it is not an independent claim of priority."* `correctness-ledger.md` says: *"No gap was
found in the main proof during this review."* A reader of the PDF alone cannot tell whether
the author believes the theorem. The hedging was written into the plan *before* the
mathematics was audited ("must not silently repair a gap", "if the source has a gap, change
the deliverable to a faithful, clearly qualified account") and then survived the audit that
found no gap. Fix: in the abstract and §1, state the theorem plainly — the preprint proves
it, this document explains the proof — and keep the qualifications in
`verification-scope.tex`, where they already are and where they belong.

**P2 (substance). The hardest proof is still the original's.** Pages 9–14 reproduce the
pruning proof with three run-in italic headings and no numbered steps. The added
"Proof itinerary" paragraph names five checkpoints, but it does not replace labelled steps:
a reader still has to discover that the goal is `ν(Γ) ≤ |Z| + |H|`, that a maximum matching
splits as `k + ℓ + t`, and that three rank conditions then suffice. When I put the two PDFs
side by side, the pruning proof reads the same in both; `rewrite-claude-opus-5.5`'s eleven
claims read very differently. Fix: keep the text, but break it with `\paragraph{Step 3:
$\rank L = \ell$ and $\rank N^{\mathsf T} = t$.}` markers at the seven places where the
argument changes target. This is a one-hour edit with the largest readability payoff in the
folder.

**P3 (substance). The notation clashes that the plan promised to remove are all still
there.** `readability-plan.md` says "Notation should have one meaning, with direction
conventions made explicit", but: `D` is the counterexample graph and the matrix `D^{p,i}`
(and the generic matrix `D` of the kernel lemma); `A` is the arc set `A(D)` and the matrix
`A` of the commuting square; `Z` is the set of conflict points and the non-neighbours
`Z(v)`; `M` is `|P| + |Q|` and `\mathcal M` the matching. Each is harmless to an expert and
costly to the reader this rewrite is for. Fix: three renames (`D^{p,i} → Φ^{p,i}`,
`Z(v) → \overline N(v)`, `|P|+|Q| → μ`), each one line in the dictionary appendix.

**P4 (substance). The extremal step has no numerical trace.** The ledger figure
(`figures/objective.tex`) is qualitative: it draws "gain", "cost", "refund" as boxes with no
values. There is therefore no page in the paper where a reader can check the arithmetic
`|𝓛| + |𝓡| > M + 2d`, `deletions ≤ d + d'`, `new value > M + d` on concrete numbers. Fix:
add one worked instance — any small graph with positive indegrees, the diagonal pair, the
four numbers, and the closing inequality — and it becomes possible to see the ledger close.
(The example need not satisfy the hypothesis; the point is the arithmetic.)

**P5 (substantive, small). "Why this objective?" stops one step short.** §3 says: *"Pruning
can cost `d+d'`, so adding `d'` to the new objective exactly pays for its output cost."*
That explains why `u` appears in the objective; it does not explain why the coefficient is
exactly 1 and not, say, 2. With value `|P|+|Q|+λu` the ledger closes for all `d,d' ≥ 0` iff
`λ = 1`, because the comparison is `μ+d+(λ−1)d' ≥ μ+λd`, i.e. `(λ−1)(d'−d) ≥ 0`. One
display closes the gap and turns a plausible choice into a forced one.

**P6 (correctness, minor). The two direct proofs of the weighted form (i) are not the same
statement.** Theirs proves `N₂(clone) ⊆` union of `N₂(v)`-blocks, which gives the inequality
one way; `rewrite-claude-opus-5.5` proves equality `N₂(v') = ⋃_{w∈N₂(v)} B_w`, using
disjointness of blocks and `v ∉ F²{v}`. Equality is available and is worth stating, because
it is what makes the reduction to the unweighted theorem *exact* rather than one-sided. No
error; just a place where the stronger statement is free.

**P7 (presentation). Figures are thin, and one is missing at the point of use.** Ten figures
in 22 pages, several of them pure schematics — the kernel figure is a labelled rectangle
whose caption has to say "The rectangle represents a subspace, not a numerical matrix",
which is a signal that the figure is not carrying an inference. The one picture the pruning
section really needs is absent: the conflict *rectangle* with corners `(p,s)`, `(p,j)`,
`(i,s)`, `(i,j)` and the two routes between the last two. Their grid figure states the
coordinate convention, which is not the same thing.

**P8 (presentation). The talk introduces the pruning lemma before the problem it solves.**
Verified frame order: 3–5 reduction, 6–11 pruning, 12–13 the extremal pair. The audience
meets `|H| + q` eleven minutes before learning why anything of that shape is wanted. Swap
frames 12–13 to precede 6, and the "cost charged to what stays uncovered" idea lands.

**P9 (reproducibility, minor). The Lean rank checks depend on another agent's folder.**
`lean/rank-build.log` records a build against
`../rewrite-claude-opus-5.5/SeymourLean/.lake/packages/mathlib`. The README is explicit about
this, and `mathlib-env.py` is a reasonable workaround, but the check is not reproducible from
`rewrite-codex` alone and breaks if that sibling folder is cleaned. Fix: pin a toolchain and
manifest in this folder, or record the maths as a `Prop`-valued hypothesis (as my Lean does)
so that only standard-library reasoning is needed.

---

## 4. What I did not adopt, and why

* **The retained-verbatim strategy.** It buys numbering fidelity and costs the one thing I
  was asked for: a proof *explained*. My rewriting keeps every step but reorganises them
  under labelled steps and boxes; the price (renumbering) I pay in a dictionary.
* **The hedged framing** (P1). Not a matter of taste: an exposition that says "presents as a
  resolution" while its own ledger says "no gap found" is internally inconsistent.
* **Their `Z(v)` for non-neighbours.** I use `\overline N(v)`, for the reason in P3.

## 5. What I would do next in that folder

1. Rewrite the abstract and the first paragraph of §1 to assert the theorem (P1).
2. Insert seven `\paragraph{Step ...}` markers in the pruning proof (P2) — largest
   readability gain per minute of work in either folder.
3. Three renames and one worked numerical instance (P3, P4).
4. Add the `λ` display (P5), swap two talk frames (P8), and make the Lean check
   self-contained (P9).
