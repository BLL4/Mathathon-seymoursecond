#!/usr/bin/env python3
"""Finer probes around the Caccetta-Haggkvist triangle case (paper, Section 6.3).

Conjecture 6.4 asks for a Seymour vertex v with d-(v) >= d+(v); for triangle-free oriented
graphs it implies CH_3.  This script tests sharper statements that would suggest a proof.

MEDIAN ORDERS.  For tournaments, Havet-Thomasse: the last vertex of every local median
order is a Seymour vertex (and it has d- >= d+ by maximality), which proves Conjecture 6.4
for tournaments.  Tested here on triangle-free oriented graphs:
  MO_all : the last vertex of EVERY median order (max number of forward arcs) is Seymour;
  MO_some: the last vertex of SOME median order is Seymour;
  LMO_all: the last vertex of every LOCAL median order (feedback property) is Seymour.

AVERAGING (Fisher-type).  For a probability vector p put
  alpha(p) = sum_u p(N-(u)) = p-average out-degree,
  beta(p)  = sum_u p(N+(u)) = p-average in-degree,
  gamma(p) = sum_u p(N--(u)) = p-average of |N2+|.
A vertex with d++ + d- >= 2 d+ (statement (b) of Lemma 6.5, hence CH_3) exists as soon as
gamma(p) + beta(p) >= 2 alpha(p) for some p.  For p "out-heavy everywhere"
(p(N+(u)) >= p(N-(u)) for all u; such p always exist by Ville's theorem) beta >= alpha, so
gamma(p) >= alpha(p) would suffice.  Tested by LP:
  FISH_out: min over out-heavy p of gamma - alpha   (>= 0 would give a Fisher-style proof)
  FISH_in : min over in-heavy p of gamma - alpha
  S1AVG   : min over out-heavy p of gamma + beta - 2 alpha
  S2LP    : the fractional form of Conjecture 6.4 (an eta with eta(N2+) >= eta(N1+) and
            eta(N-) >= eta(N1+) everywhere)

Usage:
  python3 ch_probe.py median N TRIALS [tournaments]   (needs n <= 8)
  python3 ch_probe.py lp N TRIALS                      (needs scipy)
  python3 ch_probe.py s2lp N TRIALS
"""
import itertools
import os
import random
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ch_triangle import (arcs_of, bits, members, neighbourhoods,  # noqa: E402
                         random_triangle_free, triangle_free_graphs)


def random_tournament(n, rng):
    out = [0] * n
    inn = [0] * n
    for x, y in itertools.combinations(range(n), 2):
        if rng.random() < 0.5:
            x, y = y, x
        out[x] |= 1 << y
        inn[y] |= 1 << x
    return out, inn


# ---------------------------------------------------------------- median orders

def forward_arcs(order, out):
    pos = {v: i for i, v in enumerate(order)}
    return sum(1 for x in order for y in members(out[x]) if pos[y] > pos[x])


def is_local_median(order, out, inn):
    """Feedback property: for i < j, v_i has >= as many out- as in-neighbours in
    v_{i+1..j}, and v_j has >= as many in- as out-neighbours in v_{i..j-1}."""
    n = len(order)
    for i in range(n):
        o = inn_ = 0
        for j in range(i + 1, n):
            w = order[j]
            if out[order[i]] >> w & 1:
                o += 1
            elif inn[order[i]] >> w & 1:
                inn_ += 1
            if o < inn_:
                return False
    for j in range(n):
        o = inn_ = 0
        for i in range(j - 1, -1, -1):
            w = order[i]
            if out[order[j]] >> w & 1:
                o += 1
            elif inn[order[j]] >> w & 1:
                inn_ += 1
            if inn_ < o:
                return False
    return True


def median_probe(n, out, inn):
    nb = neighbourhoods(n, out, inn)
    seymour = [bits(c) >= bits(a) for a, b, c in nb]
    best = -1
    medians = []
    for order in itertools.permutations(range(n)):
        f = forward_arcs(order, out)
        if f > best:
            best, medians = f, [order]
        elif f == best:
            medians.append(order)
    mo_all = all(seymour[o[-1]] for o in medians)
    mo_some = any(seymour[o[-1]] for o in medians)
    lmo_all = True
    for order in itertools.permutations(range(n)):
        if not seymour[order[-1]] and is_local_median(order, out, inn):
            lmo_all = False
            break
    return {"MO_all": mo_all, "MO_some": mo_some, "LMO_all": lmo_all}


def random_oriented(n, rng):
    out = [0] * n
    inn = [0] * n
    dens = rng.uniform(0.3, 1.0)
    for x, y in itertools.combinations(range(n), 2):
        if rng.random() > dens:
            continue
        if rng.random() < 0.5:
            x, y = y, x
        out[x] |= 1 << y
        inn[y] |= 1 << x
    return out, inn


def run_median(n, trials, tournaments=False, seed=3, allgraphs=False):
    rng = random.Random(seed)
    fails = {"MO_all": 0, "MO_some": 0, "LMO_all": 0}
    ex = {}
    t0 = time.time()
    if tournaments:
        gen = (random_tournament(n, rng) for _ in range(trials))
    elif allgraphs:
        from ch_triangle import all_oriented_graphs
        gen = all_oriented_graphs(n) if n <= 5 else (random_oriented(n, rng) for _ in range(trials))
    else:
        gen = (random_triangle_free(n, rng) for _ in range(trials))
    if not tournaments and not allgraphs and n <= 5:
        gen = triangle_free_graphs(n)
    cnt = 0
    for out, inn in gen:
        cnt += 1
        res = median_probe(n, out, inn)
        for k, v in res.items():
            if not v:
                fails[k] += 1
                ex.setdefault(k, arcs_of(n, out))
    if tournaments:
        kind = "tournaments"
    elif allgraphs:
        kind = "all oriented graphs" if n <= 5 else "random oriented graphs"
    else:
        kind = "all triangle-free" if n <= 5 else "random triangle-free"
    print(f"n={n} {kind}: {cnt} graphs, {time.time()-t0:.0f} s")
    for k in fails:
        print(f"  {k:8s} fails in {fails[k]}" + (f"   e.g. {ex[k]}" if k in ex else ""))
    sys.stdout.flush()


# ---------------------------------------------------------------- LP probes

def lp_min(n, nb, objective_coeffs, heavy):
    """Minimise sum_v p(v)*coeff(v) over probability vectors p that are out-heavy
    ('out': p(N+(u)) >= p(N-(u)) for all u) or in-heavy ('in')."""
    import numpy as np
    from scipy.optimize import linprog
    rows = []
    for a, b, c in nb:
        r = np.zeros(n)
        for u in members(a):
            r[u] -= 1 if heavy == "out" else -1
        for u in members(b):
            r[u] += 1 if heavy == "out" else -1
        rows.append(r)           # row . p <= 0
    res = linprog(np.array(objective_coeffs, dtype=float), A_ub=np.array(rows),
                  b_ub=np.zeros(n), A_eq=np.ones((1, n)), b_eq=[1.0],
                  bounds=[(0, None)] * n, method="highs")
    return res.fun if res.status == 0 else None


def run_lp(n, trials, seed=5):
    rng = random.Random(seed)
    worst = {"FISH_out": (1e9, None), "FISH_in": (1e9, None), "S1AVG": (1e9, None)}
    neg = {k: 0 for k in worst}
    t0 = time.time()
    gen = triangle_free_graphs(n) if n <= 5 else (random_triangle_free(n, rng) for _ in range(trials))
    cnt = 0
    for out, inn in gen:
        cnt += 1
        nb = neighbourhoods(n, out, inn)
        dp = [bits(a) for a, b, c in nb]
        dm = [bits(b) for a, b, c in nb]
        dpp = [bits(c) for a, b, c in nb]
        # sum_v p(v) d++(v) = gamma, sum_v p(v) d+(v) = alpha, sum_v p(v) d-(v) = beta
        tests = {
            "FISH_out": ([dpp[v] - dp[v] for v in range(n)], "out"),
            "FISH_in": ([dpp[v] - dp[v] for v in range(n)], "in"),
            "S1AVG": ([dpp[v] + dm[v] - 2 * dp[v] for v in range(n)], "out"),
        }
        for k, (coef, heavy) in tests.items():
            val = lp_min(n, nb, coef, heavy)
            if val is None:
                continue
            if val < -1e-9:
                neg[k] += 1
            if val < worst[k][0]:
                worst[k] = (val, arcs_of(n, out))
    print(f"n={n}: {cnt} graphs, {time.time()-t0:.0f} s")
    for k in worst:
        print(f"  {k:8s} negative in {neg[k]}; minimum {worst[k][0]:.4f} at {worst[k][1]}")
    sys.stdout.flush()


def run_s2lp(n, trials, seed=9):
    from ch_triangle import lp_eta
    rng = random.Random(seed)
    t0 = time.time()
    fails = 0
    ex = None
    for _ in range(trials):
        out, inn = random_triangle_free(n, rng)
        nb = neighbourhoods(n, out, inn)
        if not lp_eta(n, nb):
            fails += 1
            ex = ex or arcs_of(n, out)
    print(f"n={n} random triangle-free: {trials} graphs; fractional Conjecture 6.4 fails in "
          f"{fails}" + (f" e.g. {ex}" if ex else "") + f"; {time.time()-t0:.0f} s")
    sys.stdout.flush()


def main():
    mode = sys.argv[1]
    n = int(sys.argv[2])
    trials = int(sys.argv[3]) if len(sys.argv) > 3 else 1000
    if mode == "median":
        flag = sys.argv[4] if len(sys.argv) > 4 else ""
        run_median(n, trials, tournaments=(flag == "tournaments"), allgraphs=(flag == "all"))
    elif mode == "lp":
        run_lp(n, trials)
    elif mode == "s2lp":
        run_s2lp(n, trials)
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
