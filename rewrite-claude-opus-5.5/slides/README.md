# Twenty-minute talk: how the proof works

`talk.tex` → `talk.pdf` (Beamer, 16:9, 23 frames). Build with
`latexmk -pdf talk.tex`.

## Timing plan (20 minutes)

| Frames | Topic | Time |
|---|---|---|
| 1–3 | Title, the conjecture, prior work | 0:00–2:15 |
| 4 | Proof at a glance (three stages) | 2:15–3:00 |
| 5–6 | Stage 1: minimal counterexample, subset deficit, deletion step | 3:00–5:30 |
| 7–8 | Stage 2: error term, blow-up; what remains (G1, G2) | 5:30–7:15 |
| 9 | Why pairs, why a grid: orientation lives on pairs, concavity lifts line by line, a fixed board | 7:15–8:30 |
| 10–13 | Stage 3: grid, conflicts, extremal set-up, improvement step | 8:30–12:00 |
| 14–16 | Pruning lemma, the exchange-rate example, the ledger | 12:00–14:15 |
| 17 | Pruning lemma: statement reminder, block picture (a + b ≤ 1 + ab), plan | 14:15–15:00 |
| 18–21 | Proof of the pruning lemma: Γ, NL = AB, dimension count, kernel trick | 15:00–18:45 |
| 22–23 | Main inventions; consequences | 18:45–20:00 |

If time is short, frames 20–21 (dimension count and kernel trick) can be
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
