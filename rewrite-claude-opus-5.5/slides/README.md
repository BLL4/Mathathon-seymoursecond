# Twenty-minute talk: how the proof works

`talk.tex` → `talk.pdf` (Beamer, 16:9, 21 frames). Build with
`latexmk -pdf talk.tex`.

## Timing plan (20 minutes)

| Frames | Topic | Time |
|---|---|---|
| 1–3 | Title, the conjecture, prior work | 0:00–2:30 |
| 4 | Proof at a glance (three stages) | 2:30–3:30 |
| 5–6 | Stage 1: minimal counterexample, subset deficit, deletion step | 3:30–6:00 |
| 7–8 | Stage 2: error term, blow-up; what remains (G1, G2) | 6:00–8:00 |
| 9–12 | Stage 3: grid, conflicts, extremal set-up, improvement step | 8:00–12:00 |
| 13–15 | Pruning lemma, the exchange-rate example, the ledger | 12:00–14:30 |
| 16–19 | Proof of the pruning lemma: Γ, NL = AB, dimension count, kernel trick | 14:30–18:30 |
| 20–21 | Main inventions; consequences | 18:30–20:00 |

If time is short, frames 18–19 (dimension count and kernel trick) can be
compressed into one minute: "generic coefficients make rank L = ℓ and
rank N = t, and the conflict edges give k independent vectors in ker A".

## Revision history

1. First draft: 21 frames following the paper.
2. Layout pass: rendered every frame. Fixed crowded arrow labels in the proof
   map, a cut-off label in the ledger, and three overfull columns, and
   shortened one title.
3. Consistency pass: made the side conditions explicit (concavity applies to
   *nonempty proper* lines; κ_G(U) ≤ −m + n only when the support is proper),
   removed an unverified date, and defined I and E on the deletion slide.
