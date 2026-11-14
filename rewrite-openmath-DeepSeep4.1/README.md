# A guided rewrite of "A proof of Seymour's second-neighborhood conjecture"

This directory contains a rewritten, figure-rich presentation of the preprint
*A proof of Seymour's second-neighborhood conjecture* (OpenAI, 23 September 2026), together with a
20-minute beamer talk, a computational verification suite and a Lean 4 companion.

The mathematics is unchanged: no statement is weakened, no case is removed, no proof step is
dropped. What is added is structure, pictures, motivation and an explicit record of how each step was
checked. The source in `../original/` was read only; nothing was written there.

## Where things are

| path | what it is |
|---|---|
| `plan/00-charter-draft-v1.md` | first draft of "what does it mean to make the write-up more readable" |
| `plan/01-charter-revised-v2.md` | the revised charter: the rules the rewrite is held to, and the record of how it was reviewed |
| `paper/main.pdf` | the rewritten paper (46 pages, 17 figures) |
| `paper/` | its LaTeX sources; build with `latexmk -pdf main.tex` |
| `slides/main.pdf` | the 20-minute beamer deck (21 frames) |
| `slides/` | its sources (`latexmk -pdf main.tex`) |
| `checks/verify.py` | the computational checks; run `python3 verify.py` in `checks/` |
| `critique/` | reviews of the two sibling rewrites (`rewrite-claude-opus-5.5`, `rewrite-codex`) |
| `checks/run.log` | the last recorded run: all checks pass |
| `lean/` | the Lean 4 companion; see `lean/README.md` |

## How to read the paper

`paper/00-howtoread.tex` (printed right after the abstract) gives three reading routes — five
minutes, an hour, a day — the conventions, the meaning of the four kinds of box, and a notation table.
The paper opens every section with a contract ("what goes in, what comes out, why") and closes it
with a summary; every statement is followed by an "In words" line and a proof plan.

Appendices: **A** the toolkit (König's theorem, rank–nullity, Sylvester, the minor–matching bound,
the Farkas alternative — everything taken from outside graph theory, with proofs), **B** alternative
proofs and dead ends, **C** the dependency graph, **D** the dictionary of notation and numbering
against the original, **E** the verification record, **F** the index.

## What changed in the revision pass

* The pruning lemma is factored into a **matching bound** (Lemma 3.8, the linear algebra) and
  **König's theorem** (Theorem A.1), with the pruning proof then being three paragraphs of counting.
* **Edmonds' rank formula is gone**: only the easy direction is used, and it is Lemma A.3.
* The **vertex-weighted forms are proved** from the main theorem (clusters of twins; then Farkas),
  so only the arc-weighted form is quoted from Seacrest.
* New: why the blowup is needed (with a 4-vertex witness), why the weight on uncovered points is
  exactly 1, a worked pruning example, a directed-triangle trace showing where strictness is used,
  a remark listing where each hypothesis is used, and `m ≥ n` in place of `m > n`.
* `checks/check_exhaustive5.py` checks the theorem and Proposition 4.1 on **all** oriented graphs
  with at most 5 vertices (59,809 graphs; none of the 16,292 with positive indegrees is strictly
  concave) — a larger range than the n ≤ 4 of the first version, adopted after a review noted that
  n = 5 is cheap.

## Errata fixed in the second commit

An independent review of this folder
(`rewrite-claude-opus-5.5/REVIEW_OF_rewrite-openmath-DeepSeep4.1.md`) found three things worth
recording, all now fixed:

1. **The Lean statement of the pruning lemma counted `Z` instead of `H`** and was therefore false;
   the paper was right, the formal statement was not. Fixed, and `lean/Seymour/PruningStatementCheck.lean`
   now proves the refutation of the wrong version by `decide` so it cannot return.
2. **The Lean statement of the blowup lemma was vacuous** (it quantified over an unspecified graph).
   It now refers to the explicit blowup on `V × Fin m`.
3. My exhaustive check stopped at n ≤ 4; `checks/check_exhaustive5.py` now covers n ≤ 5.

Two of the review's other points were accepted as improvements rather than errata: the slides' blowup
and subset-deficit figures were redrawn for legibility, and the word "collision" for the points of `H`
is now flagged in the paper (Remark 3.5) as a misnomer — the images collide at `z ∈ Z`, and `h ∈ H`
is the opposite corner of the conflict rectangle.
