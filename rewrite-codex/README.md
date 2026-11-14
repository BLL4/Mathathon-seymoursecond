# Understanding the second-neighborhood proof

This folder contains a modified, illustrated exposition of the supplied OpenAI preprint of September 23, 2026. Original source files were not changed. The original work is licensed under Apache 2.0; see [the repository license](../LICENSE).

- [Illustrated article](main.pdf), with [LaTeX entry point](main.tex). It retains the complete proof text, adds a reading guide, ten figures, proof explanations, a worked pruning example, and a direct explanation of the vertex-weighted consequence.
- [Twenty-minute Beamer presentation](talk.pdf), with [source and timed speaker notes](talk.tex): fifteen frames, with a separate [speaker-notes PDF](talk-notes.pdf). Notes allocate 0:00–20:00; this is a planned duration, not a measured rehearsal.
- [Readability plan](readability-plan.md): initial draft, self-review, and revised specification, written before the mathematical rewrite.
- [Correctness ledger](correctness-ledger.md): mathematical dependencies, finite checks, presentation revisions, and limitations.
- [Lean structural checks](lean/SecondNeighborhood.lean): arbitrary-relation image identities, compatibility, proper fibers, diagonal membership and isolation, the uncovered-corner containment, neighborhood conventions, and integer accounting. This file uses only Lean's standard library.
- [Lean rank checks](lean/RankChecks.lean): the exact maximum-support-rank kernel lemma and its rank-one perturbation mechanism, independence and kernel dimension from the lifts under explicit coordinate hypotheses, and the rank bound for the commuting square, using mathlib v4.35.0. See the build logs for validation status.
- [Snapshot review of the other work directory](other-work-review.md).
- [Finite-check program](check_finite.py) and [recorded results](finite-results.json).

## Build and verify

Run commands from this folder:

```sh
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
latexmk -pdf -interaction=nonstopmode -halt-on-error talk.tex
latexmk -pdf -interaction=nonstopmode -halt-on-error talk-notes.tex
python3 check_finite.py
lean +leanprover/lean4:v4.35.0 lean/SecondNeighborhood.lean
```

The LaTeX documents use pdfLaTeX, TikZ, Beamer, and standard TeX packages. `latexmk` runs BibTeX for the article. Final logs are `main.log`, `talk.log`, `article-build.txt`, and `talk-build.txt`. The finite program requires only Python's standard library and uses a fixed random seed.

`lean/build.log` records the standard-library Lean check. Its theorems contain no `sorry` and introduce no new axioms. The `#print axioms` output distinguishes elementary logical proofs from arithmetic proofs using Lean's standard logical axioms.

For the mathlib rank file, use a Lean/mathlib v4.35.0 project with its normal compiled dependencies. For example, from that project's directory:

```sh
lake env lean /absolute/path/to/rewrite-codex/lean/RankChecks.lean
```

The check in this workspace used the existing v4.35.0 mathlib installation as a read-only dependency, via:

```sh
python3 lean/mathlib-env.py --mathlib-root ../rewrite-claude-opus-5.5/SeymourLean/.lake/packages/mathlib lean +leanprover/lean4:v4.35.0 lean/RankChecks.lean
```

`lean/rank-build.log` records the check. Both Lean files compile successfully with no warnings, unfinished proofs, or custom axioms; together they contain 26 checked theorem declarations. The mathematical Lean file is independent of that particular installation path. Copying selected cache files into a separate directory did not preserve the dependency installation's interpreter initialization, so that experimental cache is not the supported build route.

## What was checked

The finite experiments cover every labeled oriented graph through five vertices (59,809 graphs total), all 4,096 two-point relation/family triples for pruning, 1,000 deterministic larger samples, and 10,000 potential-increment identities. All passed. The article, slides, and speaker-notes PDFs were compiled, all ten figures were rendered and inspected, and all fifteen slides were visually checked. The ledger records mathematical checks at the proof's interfaces.

This is not a complete Lean formalization of the theorem. The minimal-counterexample argument, the whole blowup construction, generic simultaneous minors, matching/lift constructions, and the full finite extremal optimization remain outside the formal development. In particular, the rank bound takes the kernel-dimension bound as an explicit hypothesis; the generic lift-independence argument is checked, but its actual matching lifts and coordinate-vanishing hypotheses still have to be constructed. No result here claims those assumptions were discharged in Lean.

The historical survey and externally cited equivalences are retained from the supplied source; this project did not independently verify the current literature or those external papers.

## Maintenance

`prepare_rewrite.py`, `enrich.py`, and `revise.py` record one-time construction steps. They are not build scripts; rerunning them can overwrite subsequent edits. Build from the final `.tex` sources using the commands above.

Rendered review images are in `previews/` and are ignored by Git. The sources and PDFs are the intended deliverables.
