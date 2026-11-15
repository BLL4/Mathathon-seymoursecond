# November 15: a talk about the ideas

## Design before editing

The user wants the main ideas of the proof and more figures. The existing
sixteen-frame talk includes pictures, but its long middle section asks the
audience to follow simultaneous minors, kernel lifts and a rank chain.
Those details hide the reason for making each construction. The revision
should let someone retell the argument without reproducing a calculation.
Every substantive frame should have a diagram with an explicit purpose:
show what changes, what is preserved, or what pays for the next move.

The narrative will follow the attempted improvement of a best object.
First explain how minimality gives information about sets. Then show why
blowing up vertices makes that information strong enough. Finally explain
why two families on a grid can be improved, what obstructs the improvement,
and how the pruning lemma removes that obstruction at an affordable price.
The technical proof of pruning must still have a visible place: it is a
matching problem whose size is controlled by commuting linear maps. It
must not be disguised as an elementary greedy deletion argument.

Figures will use blue circles for the left family, orange squares for the
right family, green for a common target Z, and purple for the opposite
corner H. The figures will distinguish family members from their images.
Coordinate motion follows graph arcs, not visual adjacency. In the linear
square, the second-coordinate maps instead run backward; that change of
direction must be stated. A vertex-cover diagram uses undirected edges,
unlike the original directed graph. No drawing purports to exhibit the
impossible counterexample graph.

## Review of the design

A page of boxes can be as opaque as a page of algebra. Include a concrete
three-vertex graph and its grid, and a fully checked pruning example in
which deleting more members is the right move. Keep the output-dependent
cost visible before explaining its proof. One colored cancellation is
enough for the closing ledger. Preserve the complete old technical deck
separately, rather than squeezing its calculations into small type.

## Revised specification

- Seventeen main frames, with a twenty-minute timing plan and separate notes.
- A mathematical figure on every substantive frame; no tiny matrix entries.
- At most one essential displayed relation per conceptual step, except the
  closing cancellation and the local statement of the pruning lemma.
- Explain why the diagonal is the seed, why rows/columns are usable, why
  uncovered points have value, and why the new pair remains admissible.
- Keep the rank proof at the level of its mechanism, with an explicit pointer
  to the technical deck and article for the omitted argument.
- Compile both decks and the notes, inspect every main frame, and check the
  finite examples directly. Revise for correctness and then for layout.

## Material reviewed and adopted

Reviewed the latest Claude slides through `0578d85`, their animation README,
`why_grid.py`/`engine.py`, and the DeepSeep presentation and new response to
our review. Claude's recent "why a grid" explanation is particularly useful:
orientation becomes disjoint images of the diagonal, and concavity acts
line by line on the same board. The exchange-rate example and the explicit
explanation of the two appearances of d' are also adopted in spirit.
The star example already occurs in our article; this revision makes it a
central visual in the talk. All diagrams here are newly drawn in TikZ.

DeepSeep's new update repairs the empty-type specifications and the two
prose errors we identified, and withdraws its proposed equality for our
zero-weight blowup. Its suggestion to clarify snapshot maintenance is
accepted in `formalization-status.md`. The article already attributes the
adopted cycle formalization in its final remark. Its corollary statements
come from the original preprint, not from the companion formalization.

## Timing of the revised main talk

| Frames | Topic | Time |
|---|---|---|
| 1–3 | Question and proof map | 0:00–2:15 |
| 4–5 | Deletion comparison and batches | 2:15–4:30 |
| 6–7 | Amplification and the resulting obstruction | 4:30–6:30 |
| 8–10 | Why a grid, the score, and the improvement plan | 6:30–10:15 |
| 11–12 | Conflict corners and the pruning trade | 10:15–13:00 |
| 13–14 | The cover mechanism and the algebraic size bound | 13:00–16:00 |
| 15–16 | Legality, cost, and cancellation | 16:00–19:00 |
| 17 | Three principles to remember | 19:00–20:00 |

## Revision and verification record

1. **Narrative pass:** replaced the rank-heavy middle with a grid dictionary,
   the score, the improvement loop, the star exchange example, and a cover
   picture. Preserved the old technical source and PDF separately. Kept the
   commuting-square mechanism on the main path, with its kernel argument in
   the notes and full calculations in the technical deck.
2. **Mathematical pass:** checked the local deletion example, all image cells
   in the directed-cycle board, both depicted prunings of the star, and the
   chosen cover of the local augmented graph. The checker also confirms the
   17 timing intervals are continuous and total 20 minutes. No figure is
   presented as a graph satisfying the impossible concavity hypothesis.
   Kept proper-support/full-support blowup cases distinct in the notes,
   distinguished forward coverage from reversed second-coordinate linear
   maps, and made d' an output count throughout.
3. **Layout pass:** rendered and inspected every main frame. Removed one
   overfull blowup diagram, shortened overlapping connector labels, avoided
   hyphenation in the proof map, clarified the family/image distinction,
   and enlarged the role of the diagrams. The final main deck, notes, and
   technical deck compile without overfull boxes or reference warnings.
   Also inspected the longest technical note page for clipping.

The main deck has 17 frames, with a mathematical diagram on all 16 frames
after the title. `talk-figures/diagrams.tex` contains the new vector figures;
colors are reinforced by circles, squares, diamonds, stars, and labels.
`slide-checks.txt` records the concrete checks. Planned times are not a
measured rehearsal. Existing formal proofs are unchanged.

## Last update checked: `e7337a2`

A new Claude/Fable insights pass arrived during this revision. Its
three-term-complex count is a useful simplification of the rank bookkeeping:
combine the two maps out of the left space, then subtract the two routes
into the right space. Since NL=AB the composite is zero. Thus the incoming
image lies in the outgoing kernel, and the two ranks add to at most the
middle dimension |Z|+|H|. The existing kernel lifts give incoming rank at
least ell+k, and the coverage rank gives outgoing rank at least t. This
immediately bounds the matching k+ell+t. I checked this derivation and
adopted its explanation in main frame 14 and the notes, with attribution.
The technical deck and the unchanged Lean snapshot keep the original
rank-nullity/Sylvester count. No conjectural local matching simplification
from the new experiments is used. The "move, then repair" interpretation
also agrees with the improvement loop already drawn in our new talk.
