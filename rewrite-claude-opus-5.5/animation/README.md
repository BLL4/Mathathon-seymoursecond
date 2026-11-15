# Animations: why the grid, and one improvement step

Watch them in this order:

1. [`WhyGrid.mp4`](WhyGrid.mp4) (70 s): the story behind Stage 3 (paper
   §3.1, slide 9).
2. [`ImprovementStep.mp4`](ImprovementStep.mp4) (80 s): one step of the
   proof on a concrete graph.

## Prologue: why pairs, why a grid

Source: [`why_grid.py`](why_grid.py), scene `WhyGrid`.

1. **Concavity alone is not contradictory.** The complete digraph on 4
   vertices with all opposite arcs satisfies (G1) and (G2) (checked by
   `engine.py`). So the proof must use "no opposite arcs".
2. **Orientation lives on pairs.** On the digraph 1⇄2, 2→3, 3→1, the
   vertical image F₁Δ = Aᵀ and the horizontal image F₂Δ = A of the diagonal
   meet at (1,2) and (2,1): opposite arcs are a conflict. After deleting
   2→1 the graph is oriented and the images are disjoint.
3. **Concavity lifts line by line:** a column for F₁, a row for F₂.
4. **A fixed board.** Disjoint images give |X|² = |F₁P| + |F₂Q| + unc, so
   val = |X|² − (|F₁P| − |P|) − (|F₂Q| − |Q|). Concavity says expansion
   shrinks one step later, which frees cells for the new families.

## One improvement step, worked out

[`ImprovementStep.mp4`](ImprovementStep.mp4) (80 s, 1080p, white background)
runs the key step of Section 5 on a concrete graph.

**The graph.** G has vertices 1–4 and arcs 1→3, 3→2, 3→4, 4→1, 4→2. Every
vertex has an in-neighbour.

**What the video shows:**

1. The grid X×X. F₁ moves the first coordinate along an arc (vertical) and
   F₂ moves the second (horizontal).
2. **The old pair.** P = Δ ∪ {(1,3)} (blue disks) and Q = Δ ∪ {(1,4)}
   (orange squares). They cover F₁P and F₂Q and never cover a point twice.
   μ = 10, d = 3, val = 13.
3. **Concavity.** κ is computed on every column of P and every row of Q;
   Σκ = −4.
4. **The new families.** R = X² ∖ F₂²Q and C = X² ∖ F₁²P, with
   |R| + |C| = 20 = μ + 2d − Σκ.
5. **The conflicts.** There are four, all with the same corner h = (4,4).
   They form a complete K₂,₂ block, with |Z| = 4 and |H| = 1. The point h
   was uncovered before, so |H| ≤ d.
6. **Pruning.** All four members of the block are deleted. This uncovers all
   four conflict points, and 4 ≤ |H| + 4.
7. **The new pair.** val(P′,Q′) = 8 + 8 + 4 = 20 > 13.
8. **Why a real graph escapes.** In the next step some lines have κ ≥ 0,
   and even the best pruning gives value 18 < 20. In a counterexample every
   line would have κ ≤ −1, so every step would gain. That is impossible,
   since val ≤ 3|X|².

All numbers are computed by [`engine.py`](engine.py), not typed in. For the
pruning, the engine searches all prunings that satisfy (P1)–(P3) of the
pruning lemma and takes one of maximum value. The example was chosen by an
exhaustive search over oriented graphs on 4 vertices (all indegrees
positive) and starting pairs Δ plus at most one point each. The search
required a positive concavity gain, at least one uncovered conflict point,
at most 4 conflicts, and Z ≠ H.

**Note.** No graph satisfies strict concavity (that is the theorem), so no
example can show the step working "as in the proof" on every line. Here
Σκ < 0 overall, but some columns have κ = +1.

## Rebuilding

The video uses [Manim Community](https://www.manim.community/) 0.22. That is
the maintained fork of 3b1b's manim, and it renders headless to a video file.

```sh
cd animation
python3.14 -m venv .venv && .venv/bin/pip install manim   # needs cairo, pango, ffmpeg, LaTeX
.venv/bin/manim -qh --media_dir media improvement_step.py ImprovementStep
.venv/bin/manim -qh --media_dir media why_grid.py WhyGrid
```

Use `-ql` instead of `-qh` for a quick 480p draft.
