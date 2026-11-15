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
