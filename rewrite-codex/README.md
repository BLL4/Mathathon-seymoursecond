# Understanding the second-neighborhood proof

This folder contains a modified, illustrated exposition of the supplied OpenAI preprint of September 23, 2026. Original source files were not changed. The original work is licensed under Apache 2.0; see [the repository license](../LICENSE).

- [Illustrated article](main.pdf), with [LaTeX entry point](main.tex). It retains the complete argument, reorganizes the pruning proof into seven claims, and adds a reading guide, eleven figures, proof explanations, a worked pruning example, and a direct explanation of the vertex-weighted consequence.
- [Visual twenty-minute presentation](talk.pdf), with [source](talk.tex) and a separate [speaker-notes PDF](talk-notes.pdf): seventeen frames, with diagrams on all sixteen substantive frames. It emphasizes the constructions and main ideas. Notes allocate 0:00–20:00; this is a planned duration, not a measured rehearsal.
- [Technical presentation](talk-technical.pdf), with [source](talk-technical.tex), preserves the previous sixteen-frame deck and its detailed rank argument.
- [Visual revision and cross-review](slide-revision.md) explains the adopted ideas, timing, and figure checks.
- [Readability plan](readability-plan.md): initial draft, self-review, and revised specification, written before the mathematical rewrite.
- [Correctness ledger](correctness-ledger.md): mathematical dependencies, finite checks, presentation revisions, and limitations.
- [Lean structural checks](lean/SecondNeighborhood.lean): arbitrary-relation image identities, compatibility, proper fibers, diagonal membership and isolation, the uncovered-corner containment, neighborhood conventions, and integer accounting. This file uses only Lean's standard library.
- [Lean rank checks](lean/RankChecks.lean): the exact maximum-support-rank kernel lemma and its rank-one perturbation mechanism, independence and kernel dimension from the lifts under explicit coordinate hypotheses, and the rank bound for the commuting square, using mathlib v4.35.0. See the build logs for validation status.
- [Kernel restrictions](lean/KernelRestrictions.lean), [coverage lifts](lean/CoverageLifts.lean), and [connected pruning algebra](lean/PruningAlgebra.lean) close the restriction and normalized-lift steps, conditional on explicit spanning, support-rank, and square-commutation hypotheses.
- [Full reference proof and provenance](lean/reference/README.md), authored by Claude Opus 5.5 and rebuilt here from an attributed source snapshot. [ReferenceBridge.lean](lean/ReferenceBridge.lean) proves its conclusion in the image convention of this exposition.
- [Formalization status](formalization-status.md) separates the full reference proof from the independent component checks.
- [Response to the review](review-response.md) records the second revision.
- [Snapshot review of the other work directory](other-work-review.md).
- [Latest cross-review](updates-review.md) records newly checked specification errors, a correction to an earlier review, and the adopted readability improvements.
- [Lean statement audit](lean/ReviewCounterexamples.lean) and [adopted cycle consequences](lean/AdoptedCycleConsequences.lean) verify the new review findings and discharge the cycle companion's main-theorem hypothesis.
- [Finite-check program](check_finite.py) and [recorded results](finite-results.json).

## Build and verify

Run commands from this folder:

```sh
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
latexmk -pdf -interaction=nonstopmode -halt-on-error talk.tex
latexmk -pdf -interaction=nonstopmode -halt-on-error talk-notes.tex
latexmk -pdf -interaction=nonstopmode -halt-on-error talk-technical.tex
python3 check_slide_examples.py
python3 check_finite.py
lean +leanprover/lean4:v4.35.0 lean/SecondNeighborhood.lean
```

The LaTeX documents use pdfLaTeX, TikZ, Beamer, and standard TeX packages. `latexmk` runs BibTeX for the article. Final logs are `main.log`, `talk.log`, `article-build.txt`, and `talk-build.txt`. The finite program requires only Python's standard library and uses a fixed random seed.

`lean/build.log` records the standard-library Lean check. Its theorems contain no `sorry` and introduce no new axioms. The `#print axioms` output distinguishes elementary logical proofs from arithmetic proofs using Lean's standard logical axioms.

For the complete Lean development, use an existing compiled Lean/mathlib v4.35.0 installation. The build script compiles all seven component files in dependency order and records the logs in this folder:

```sh
python3 lean/check.py --mathlib-root ../rewrite-claude-opus-5.5/SeymourLean/.lake/packages/mathlib
```

The path above is the read-only dependency used in this workspace. Any compatible compiled mathlib checkout can be supplied instead. `mathlib-env.py` sets the library search paths without writing to that installation. The build script writes the `.olean` outputs here, including those needed to resolve imports among our files; these outputs are ignored by Git.

The seven component files compile without warnings, unfinished proofs, or custom axioms and contain 39 component theorem declarations. The logs are `lean/build.log`, `lean/rank-build.log`, `lean/restrictions-build.log`, `lean/lifts-build.log`, `lean/algebra-build.log`, `lean/generic-build.log`, and `lean/minor-build.log`. The final algebra theorem derives the kernel-dimension bound from the corner equations and spanning conditions, rather than accepting arbitrary lifts or coordinate vanishing as inputs.

## What was checked

The finite experiments cover every labeled oriented graph through five vertices (59,809 graphs total), all 4,096 two-point relation/family triples for pruning, 1,000 deterministic larger samples, and 10,000 potential-increment identities. All passed. The article, slides, and speaker-notes PDFs were compiled, all eleven figures were rendered and inspected, and all seventeen current main slides were visually checked. The concrete examples and continuous twenty-minute allocation are checked by `check_slide_examples.py`; results are in `slide-checks.txt`. The ledger records mathematical checks at the proof's interfaces.

A **complete attributed reference formalization** is now included under `lean/reference/`. It is an unchanged source snapshot of Claude Opus 5.5's formalization from the other work directory, rebuilt here without copying its compiled objects. The build checks the snapshot hashes, compiles the graph reductions, blowup, pruning, and extremal contradiction, and checks our definition bridge:

```sh
python3 lean/check-reference.py --mathlib-root ../rewrite-claude-opus-5.5/SeymourLean/.lake/packages/mathlib
```

`reference-checks.txt`, `lean/reference/Final-build.log`, and `lean/reference-build.log` record the full rebuild and final trusted axioms: `propext`, `Classical.choice`, and `Quot.sound`. The reference snapshot has nonfatal deprecation and unused-parameter warnings, retained to preserve its exact source; the seven Codex component files compile without warnings. This full proof is a credited contribution by Claude Opus 5.5, not an independently authored Codex proof.

The separate Codex algebra development remains conditional at its frontier: `kernel_dimension_from_pruning_data` assumes the square identity, maximum auxiliary support ranks, and coverage-spanning conditions, then constructs the normalized lifts and derives the kernel-dimension bound. Further files now check simultaneous nonvanishing of selected polynomial minors and a matching certificate for a sparse minor. They have not yet been assembled into a separate Codex proof of the full graph theorem. The reference proof uses a rational function field for generic coefficients; the exposition's real-assignment route is supported by our additional polynomial checks.

The historical survey and externally cited equivalences are retained from the supplied source; this project did not independently verify the current literature or those external papers.

## Reproduce the new review checks

The review snapshot and import-only adapter are documented in [lean/review-target/README.md](lean/review-target/README.md). To check the exact reviewed definitions, their counterexamples, and the adopted cycle consequences:

```sh
python3 check_review_cases.py
python3 lean/check-review.py --mathlib-root /path/to/mathlib --cycles
```

The checker verifies original and adapted source hashes, confirms that only imports differ, and builds any missing objects locally. The cycle bridge uses the complete reference proof; the checker builds that prerequisite if absent. `--force` recompiles current local objects as well. `review-checks.txt`, `lean/review-build.log`, and `lean/cycles-build.log` record the checks. These review proofs are separate from the seven Codex component files and the full reference theorem.

## Maintenance

`prepare_rewrite.py`, `enrich.py`, `revise.py`, and `refine-*.py` record one-time construction steps. They are not build scripts; rerunning them can overwrite subsequent edits. Build from the final `.tex` sources using the commands above.

Rendered review images are in `previews/` and are ignored by Git. The sources and PDFs are the intended deliverables.
