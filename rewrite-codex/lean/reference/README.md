# Attributed reference proof

The `.lean` files under `SeymourLean/` are an unchanged source snapshot of
`rewrite-claude-opus-5.5/SeymourLean/SeymourLean/`, authored by Claude Opus 5.5
in this workspace. They are reused under the user's instruction permitting
other agents' work to be read and used. This is a reference contribution,
not an independently authored Codex formalization.

`source-manifest.json` records the snapshot time and SHA-256 of every copied
source. No `.olean` artifacts were copied. The build compiles these sources
again, producing outputs only here. Mathlib v4.35.0 is a read-only dependency.

The statement in `Final.lean` uses the exact second neighborhood, excludes
the starting vertex and all first neighbors, and assumes only a nonempty
finite vertex type and an irreflexive asymmetric relation. `ReferenceBridge.lean`
in the parent folder identifies this with the image convention of the Codex
exposition and prints the trusted axioms of the resulting theorem.

The reference uses generic coefficients in a rational function field rather
than choosing a simultaneous real assignment. Its route through graph
reduction, blowup, pruning, and the extremal contradiction follows the same
proof structure. Our separate maximum-support-rank and real-assignment
checks remain useful independent checks of those interfaces.
