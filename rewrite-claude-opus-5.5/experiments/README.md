# Experiments around the pruning lemma

Small computer searches that were used to look for simplifications of the
proof. They run with the Python environment of `../animation/.venv`
(numpy and networkx come with Manim):

```sh
cd experiments
../animation/.venv/bin/python matching_bound.py 4 3000 7
../animation/.venv/bin/python complex_check.py
../animation/.venv/bin/python z_saturation.py
../animation/.venv/bin/python move_and_repair.py
../animation/.venv/bin/python less_is_necessary.py 3
```

Notation is that of the paper: a relation on X = {0,…,n−1}, a left family
R and a right family C, conflict points Z, opposite corners H, the
bipartite graph Γ, and ν(Γ) its matching number. The pruning lemma rests
on ν(Γ) ≤ |Z| + |H|.

## What was found

**`complex_check.py` — a shorter rank count (used in the paper, §4.4).**
With the paper's matrices, NL = AB means that
ℝ^R → ℝ^Z ⊕ ℝ^H → ℝ^C, with maps (L;B) and (N,−A), is a complex, so
rank(L;B) + rank(N,A) ≤ |Z| + |H|. The matching gives
rank(L;B) ≥ ℓ + k and rank N = t. This replaces Sylvester's inequality
and rank–nullity for A. Checked at random real assignments on 1606
instances: the composite is zero, rank L = ℓ, rank N = t,
rank(L;B) ≥ ℓ + k, and the sum of the two ranks never exceeds |Z| + |H|
(it equals |Z| + |H| in about a third of the instances).

**`matching_bound.py` — the bound is tight, and greedy pruning fails.**
On random instances ν(Γ) = |Z| + |H| in 40 % (n = 3) down to 9 % (n = 5)
of the cases, so the bound cannot be improved in general. Deleting every
member that is in a conflict exceeds the budget |H| + |Z| in about 1 % of
the instances; the paper's new Example 4.4 is the extreme case
(cost n² + 1 against a budget of 2n).

**`z_saturation.py`, `star_bruteforce.py` — an unproven local form.**
For a maximum matching M let k be its number of conflict edges and
Z_α, Z_β the conflict points whose right, resp. left, copy is matched.
Then ν = k + |Z_α ∪ Z_β| + |Z_α ∩ Z_β|, so the bound would follow from

    k + |Z_α ∩ Z_β| ≤ |H|.                                          (*)

Each conflict edge of M and each doubly matched z has an opposite corner,
but these corners are not always distinct, and (*) fails for some maximum
matchings with the fewest conflict edges. Enumerating *all* maximum
matchings for 4926 random instances with at most 18 edges in Γ, there was
always some maximum matching satisfying (*). We do not know whether this
is true in general or whether it has a direct proof; see Remark 4.23 of
the paper.

**`move_and_repair.py` — the step is "move, then repair" (paper, Remark 3.12).**
For an admissible pair, |R| + |C| − d equals the formal value of the moved
pair (F₁P, F₂Q), and the pruned pair satisfies
val(P′,Q′) ≥ |R| + |C| − d. So in terms of the expansion
ε₁(S) = |F₁S| − |S|, ε₂(S) = |F₂S| − |S|,

    ε₁(P′) + ε₂(Q′) ≤ ε₁(F₁P) + ε₂(F₂Q),

and strict concavity says ε₁(F₁P) < ε₁(P), ε₂(F₂Q) < ε₂(Q). Both
identities were checked on random admissible pairs; F₁P ⊆ R was false in
every sampled case, so R is a genuinely different family with the same
count.

**`less_is_necessary.py`** builds the "blocks in a 4-cycle" graph
J → A → i₀ → s₀ → J with the pair (Δ,Δ). It was meant to realize the
n² + 1 example inside the application, but the instance is so symmetric
that the greedy pruning exactly meets the budget. It is kept as a worked
example of the engine; the paper uses the abstract instance instead.

## Caccetta–Häggkvist for triangles: `ch_triangle.py` (paper, Section 6.3)

Standard library only; the `lp` mode needs scipy (`python3 -I ch_triangle.py lp 5`).
Modes: `exhaustive N` (all labelled triangle-free oriented graphs with ≤ N
vertices), `random N TRIALS`, `weighted N TRIALS` (random positive integer
weights = blow-ups by independent sets), `lp N`, `circulant N`, `all N` (all
oriented graphs), `tournaments N`, `randomall N TRIALS`, `randomtour N TRIALS`.

For a triangle-free oriented graph write d⁺, d⁻ for the out-/in-degree and
d⁺⁺ = |N₂⁺(v)|. Statements tested (each one, if true for all triangle-free
oriented graphs, implies the Caccetta–Häggkvist conjecture for k = 3):

* **S1**: some v has d⁺⁺(v) + d⁻(v) ≥ 2d⁺(v) (Lemma 6.5(b));
* **S2**: some Seymour vertex has d⁻(v) ≥ d⁺(v) (Conjecture 6.4);
* **S3**: some Seymour vertex satisfies S1; **S4**: some vertex of minimum
  outdegree is a Seymour vertex;
* **LP**: a probability vector η with η(N₂⁺(v)) ≥ η(N₁⁺(v)) and
  η(N⁻(v)) ≥ η(N₁⁺(v)) for every v (the fractional form of S2);
* **VAL**: the game value max_p min_v p(N₁⁺(v)) (the fractional CH₃ value).

**Findings (no counterexample anywhere).** S1–S4 hold on all 4,200,048
labelled triangle-free oriented graphs with ≤ 6 vertices (the 6-vertex run
takes 14 s), on random triangle-free oriented graphs with 7–15 vertices
(585,000 graphs) and on their weighted forms with random weights in {1,…,5}
(all graphs with ≤ 5 vertices × 30 weightings, plus the random graphs). The LP
form holds on all triangle-free oriented graphs with ≤ 5 vertices; the maximal
game value there is 1/4 (the directed 4-cycle), well below 1/3. S2 (which
makes sense for every oriented graph) holds on all 14,408,716 labelled
oriented graphs with ≤ 6 vertices (53 s for n = 6), on all tournaments with
≤ 7 vertices (where it is a theorem: the last vertex of a median order), on
random tournaments with 9, 11, 14 and 20 vertices (350,000) and on random
oriented graphs with 8–16 vertices (350,000). For the triangle-free circulants
Z_n with connection set {1,…,⌊(n−1)/3⌋} the inequality of S1 is tight, so S1 is
best possible if true.

## Finer probes: `ch_probe.py` (paper, Remarks on barriers and the median-order conjecture)

`python3 -I ch_probe.py median N TRIALS [tournaments|all]`, `lp N TRIALS`, `s2lp N TRIALS`
(needs scipy for the LP modes; `median` enumerates all N! orders, so N ≤ 9).

* **Median orders.** For tournaments the last vertex of every (local) median order is a
  Seymour vertex (Havet–Thomassé; the sanity run on 300 random 6-tournaments confirms
  it). For oriented graphs this fails: among the 59,049 oriented graphs with 5 vertices,
  180 have a median order ending in a non-Seymour vertex, and 2,100 have such a local
  median order; failures persist for random triangle-free graphs with 6–8 vertices. But
  **some median order ends in a Seymour vertex** in every graph tested: all oriented
  graphs with ≤ 5 vertices, all triangle-free ones with ≤ 5 vertices, random oriented,
  triangle-free and tournament graphs with 6–9 vertices. This is Conjecture 6.11 of the
  paper; it implies Conjecture 6.4 because the last vertex of a median order has d⁻ ≥ d⁺.
* **No single distribution.** The fractional form of Conjecture 6.4 (one probability
  vector η with η(N₂⁺(v)) ≥ η(N₁⁺(v)) and η(N⁻(v)) ≥ η(N₁⁺(v)) at every vertex) holds for
  all triangle-free oriented graphs with ≤ 5 vertices but fails for 222 of 60,000 random
  triangle-free graphs on 6 vertices, 401 of 30,000 on 7, 432 of 15,000 on 8 and 295 of
  6,000 on 9. Exact certificate for the 6-vertex graph with arcs 03, 10, 15, 20, 24, 34,
  35, 41, 52 (found by brute force over integer weights ≤ 3): ξ = (0,1,1,1,0,0),
  ζ = (3,0,0,0,3,3) give ξ(N₂⁺(v)) + ζ(N⁻(v)) < (ξ+ζ)(N₁⁺(v)) at all six vertices.
* **No Fisher-type averaging.** Over probability vectors p that are out-heavy at every
  vertex (p(N₁⁺(u)) ≥ p(N⁻(u))), the minimum of Σ p(v)(d⁺⁺(v) − d⁺(v)) is negative for
  36 of the 549 triangle-free graphs on 4 vertices and 3,470 of 30,535 on 5 (minimum −1),
  and the same holds for Σ p(v)(d⁺⁺ + d⁻ − 2d⁺); over in-heavy p it fails almost always.
* **Structured search** (`ch_triangle.py structured N TRIALS SEED [tf]`). Proposition 6.8
  says a minimal counterexample to Conjecture 6.4 is strongly connected with d⁻ ≥ d⁺ − 1
  at every vertex. Random oriented graphs repaired to have these properties (about
  112,000 graphs with 7–15 vertices, and 9,800 triangle-free ones with 8–13 vertices)
  all have an in-heavy Seymour vertex.
