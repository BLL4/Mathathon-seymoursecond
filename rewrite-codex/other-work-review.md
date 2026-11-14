# Snapshot review of the other work directory

Historical snapshot from November 13. The other formalization has since
been completed; see `review-response.md` and `formalization-status.md`.

After producing the independent article, talk, and first checked Lean file, I inspected the available `rewrite-claude-opus-5.5` directory. At that snapshot it contained a detailed readability plan and a Lean project scaffold, with no completed exposition or talk available to review. The Lean `Basic.lean` still contained only the scaffold's `hello` definition. This is a snapshot of ongoing work, not a judgment on its eventual deliverables.

The plan usefully fixes the first coordinate as a row index and the second as a column index. My added grid figure adopts that explicit convention; the source already uses columns for left fibers and rows for right fibers. The plan's initial directed-triangle mistake is explicitly corrected in its own review section. Keep the correction visible or remove the obsolete draft example from any final reader-facing document.

Suggestions for the eventual rewrite:

1. Preserve the difference between set-image steps and the backward second-coordinate step in the linear maps. A visually similar commuting square can otherwise suggest the wrong arrow direction.
2. A minimum vertex cover of the original conflict graph does not necessarily give the pruning bound. The three-vertex star example in my exposition demonstrates the extra deletion/output-coverage issue and may be useful to the other rewrite.
3. State formalization scope by listing the actual checked declarations. A Lean project scaffold and mathlib setup alone do not certify mathematical claims.
4. Keep the full-support blowup case separate; applying the subset-deficit hypothesis to the whole vertex set is invalid.

Only the plan and scaffold were reviewed; no claim about the correctness of an unavailable final rewrite is intended. The mathlib library sources and cached dependencies in that project were used as a locally available dependency source for the additional rank checks, with all extraction and compilation outputs placed in this folder.
