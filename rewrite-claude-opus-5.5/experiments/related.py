#!/usr/bin/env python3
"""Conjectures related to Seymour's second-neighbourhood theorem: quick counterexample search.

For an oriented graph D on n vertices write d+(v), d-(v) for the out- and in-degree and
dk+(v) = |Nk+(v)| for the number of vertices at out-distance exactly k (so d2+ = |N2+|),
and similarly d2-(v) for the second in-neighbourhood.  A *Seymour vertex* has d2+ >= d+.
The statements tested are

  SEY    some v has d2+ >= d+                     (the theorem; sanity check)
  SUL    some v has d2+ >= d-                     (Sullivan, Conj. 6.6 in his 2006 survey)
  SUL4   some v has d+ + d2+ >= 2 d-              (Sullivan, Conj. 6.4 there)
  SULSEY some v has d2+ >= max(d+, d-)            (a vertex that is Seymour and Sullivan)
  TWO    if D has no sink then it has >= 2 Seymour vertices
                                                  (Havet-Thomasse for tournaments; open)
  MATCH  some v has a complete matching from N+(v) into N2+(v) along arcs
                                                  (Bai-Li-Park 2026, arXiv:2607.18047)
  DIST   every vertex of out-degree k is within distance k of a Seymour vertex
                                                  (Burckel, Conj. 6.14 in Sullivan's survey)
  MINOUT some vertex of minimum out-degree is a Seymour vertex
  ALLMIN every vertex of minimum out-degree is a Seymour vertex (true for n <= 6, false
         for the 8-vertex tournament in `verify` below)
  BOTH   some v has d2+ >= d+ and d2- >= d-        (Seymour in both directions)
  BUR3   [triangle-free] some v has d3+ >= d2+     (Burckel, Conj. 6.13 with k = 3)
  BUR4   [girth >= 5]    some v has d4+ >= d3+     (Conj. 6.13 with k = 4)
  EUL    [Eulerian: d+ = d- everywhere]  sum_v d2+(v) >= sum_v d+(v)
                                                  (Seymour / Jackson, Conj. 6.15 there)
  TK     [Eulerian] with at least n^2/3 arcs there is a directed triangle
                                                  (Thomasse-Kral, Conj. 6.16 there)
  DIGON  [digraphs, digons allowed] some v has d2+ >= d+ - s(v), where s(v) is the number
         of digons at v (the theorem gives d2+ >= d+ - 2 s(v) by deleting all digons)
  DEVOS  [triangle-free] a probability vector p with p(N+(v)) >= p(N-(v)) and
         p(N2-(v)) >= p(N-(v)) for every v (DeVos, Conj. 6.28 there; LP, needs scipy)

Standard library only, except DEVOS.  Every counterexample found is re-verified from
scratch and printed as an arc list.

Usage:
  python3 related.py all N              all labelled oriented graphs with n <= N (N <= 6)
  python3 related.py random N TRIALS    random oriented graphs on N vertices
  python3 related.py tf N               all labelled triangle-free graphs, n <= N  (BUR3)
  python3 related.py girth5 N           all labelled graphs of girth >= 5, n <= N  (BUR4)
  python3 related.py eulerian N         all labelled Eulerian oriented graphs, n <= N (N <= 7)
  python3 related.py randeul N TRIALS   random Eulerian oriented graphs on N vertices
  python3 related.py tk N               TK on all Eulerian oriented graphs with >= n^2/3 arcs, n <= N
  python3 related.py randtf N TRIALS    random triangle-free graphs (BUR3, BUR4 if girth 5)
  python3 related.py digon N            all loopless digraphs with n <= N (N <= 5)
  python3 related.py randdigon N TRIALS random loopless digraphs
  python3 related.py devos N TRIALS     DEVOS on the 6-vertex certificate graph and on
                                        random triangle-free graphs on N vertices
"""
import itertools
import random
import sys
import time


def bits(x):
    return x.bit_count()


def members(mask):
    while mask:
        low = mask & -mask
        yield low.bit_length() - 1
        mask ^= low


# ---------------------------------------------------------------- neighbourhoods

def second_out(n, out, v):
    m = 0
    for u in members(out[v]):
        m |= out[u]
    return m & ~out[v] & ~(1 << v)


def second_in(n, inn, v):
    m = 0
    for u in members(inn[v]):
        m |= inn[u]
    return m & ~inn[v] & ~(1 << v)


def levels(n, out, v, kmax):
    """Exact out-distance levels N1, ..., Nkmax of v (bitmasks)."""
    seen = 1 << v
    cur = 1 << v
    res = []
    for _ in range(kmax):
        nxt = 0
        for u in members(cur):
            nxt |= out[u]
        nxt &= ~seen
        res.append(nxt)
        seen |= nxt
        cur = nxt
    return res


def has_matching(n, out, v, n2):
    """Complete matching from N+(v) into n2 (a bitmask) along arcs u -> w."""
    left = list(members(out[v]))
    match = {}  # right vertex -> left vertex

    def try_(u, seen):
        for w in members(out[u] & n2):
            if w in seen:
                continue
            seen.add(w)
            if w not in match or try_(match[w], seen):
                match[w] = u
                return True
        return False

    for u in left:
        if not try_(u, set()):
            return False
    return True


def dist_to_set(n, out, v, target):
    """Directed distance from v to the vertex set `target` (bitmask); None if unreachable."""
    if target >> v & 1:
        return 0
    seen = 1 << v
    cur = 1 << v
    d = 0
    while cur:
        d += 1
        nxt = 0
        for u in members(cur):
            nxt |= out[u]
        nxt &= ~seen
        if nxt & target:
            return d
        seen |= nxt
        cur = nxt
    return None


# ---------------------------------------------------------------- the statements

def evaluate(n, out, inn):
    """Return dict name -> bool for the statements about oriented graphs."""
    dp = [bits(out[v]) for v in range(n)]
    dm = [bits(inn[v]) for v in range(n)]
    n2 = [second_out(n, out, v) for v in range(n)]
    d2 = [bits(m) for m in n2]
    sey_mask = 0
    for v in range(n):
        if d2[v] >= dp[v]:
            sey_mask |= 1 << v
    res = {}
    res["SEY"] = sey_mask != 0
    res["SUL"] = any(d2[v] >= dm[v] for v in range(n))
    res["SUL4"] = any(dp[v] + d2[v] >= 2 * dm[v] for v in range(n))
    res["SULSEY"] = any(d2[v] >= max(dp[v], dm[v]) for v in range(n))
    res["TWO"] = (min(dp) == 0) or bits(sey_mask) >= 2
    res["MATCH"] = any(has_matching(n, out, v, n2[v]) for v in range(n))
    res["DIST"] = all(
        (lambda d: d is not None and d <= dp[v])(dist_to_set(n, out, v, sey_mask))
        for v in range(n))
    mo = min(dp)
    res["MINOUT"] = any(dp[v] == mo and d2[v] >= dp[v] for v in range(n))
    res["ALLMIN"] = all(d2[v] >= dp[v] for v in range(n) if dp[v] == mo)
    res["BOTH"] = any(d2[v] >= dp[v] and bits(second_in(n, inn, v)) >= dm[v]
                      for v in range(n))
    return res


def evaluate_levels(n, out, girth5):
    """BUR3 (needs triangle-free) and BUR4 (needs girth >= 5)."""
    res = {}
    lv = [levels(n, out, v, 4) for v in range(n)]
    res["BUR3"] = any(bits(lv[v][2]) >= bits(lv[v][1]) for v in range(n))
    if girth5:
        res["BUR4"] = any(bits(lv[v][3]) >= bits(lv[v][2]) for v in range(n))
    return res


def eulerian_sum(n, out, inn):
    return sum(bits(second_out(n, out, v)) for v in range(n)) >= sum(bits(out[v]) for v in range(n))


def digon_statement(n, out, inn):
    for v in range(n):
        s = bits(out[v] & inn[v])
        if bits(second_out(n, out, v)) >= bits(out[v]) - s:
            return True
    return False


# ---------------------------------------------------------------- generators

def all_oriented_graphs(n):
    pairs = list(itertools.combinations(range(n), 2))
    for choice in itertools.product((0, 1, 2), repeat=len(pairs)):
        out = [0] * n
        inn = [0] * n
        for (x, y), c in zip(pairs, choice):
            if c == 1:
                out[x] |= 1 << y
                inn[y] |= 1 << x
            elif c == 2:
                out[y] |= 1 << x
                inn[x] |= 1 << y
        yield out, inn


def all_digraphs(n):
    pairs = list(itertools.combinations(range(n), 2))
    for choice in itertools.product((0, 1, 2, 3), repeat=len(pairs)):
        out = [0] * n
        inn = [0] * n
        for (x, y), c in zip(pairs, choice):
            if c & 1:
                out[x] |= 1 << y
                inn[y] |= 1 << x
            if c & 2:
                out[y] |= 1 << x
                inn[x] |= 1 << y
        yield out, inn


def reach_within(out, y, steps):
    """Vertices reachable from y in 1..steps steps (bitmask)."""
    seen = 0
    cur = 1 << y
    for _ in range(steps):
        nxt = 0
        for u in members(cur):
            nxt |= out[u]
        nxt &= ~seen
        seen |= nxt
        cur = nxt
    return seen


def girth_graphs(n, g):
    """All labelled oriented graphs on n vertices with no directed cycle of length < g
    (g = 4: triangle-free; g = 5: girth >= 5).  Backtracking over the pairs: the arc
    x -> y closes a cycle of length <= g-1 iff x is reachable from y in <= g-2 steps."""
    pairs = list(itertools.combinations(range(n), 2))
    out = [0] * n
    inn = [0] * n

    def rec(k):
        if k == len(pairs):
            yield out, inn
            return
        x, y = pairs[k]
        yield from rec(k + 1)
        if not (reach_within(out, y, g - 2) >> x & 1):
            out[x] |= 1 << y
            inn[y] |= 1 << x
            yield from rec(k + 1)
            out[x] &= ~(1 << y)
            inn[y] &= ~(1 << x)
        if not (reach_within(out, x, g - 2) >> y & 1):
            out[y] |= 1 << x
            inn[x] |= 1 << y
            yield from rec(k + 1)
            out[y] &= ~(1 << x)
            inn[x] &= ~(1 << y)

    yield from rec(0)


def eulerian_graphs(n):
    """All labelled oriented graphs with d+(v) = d-(v) for every v.  Pairs are taken in
    lexicographic order, so vertex x is complete once pair (x, n-1) is decided."""
    pairs = list(itertools.combinations(range(n), 2))
    last = {}
    for k, (x, y) in enumerate(pairs):
        last[x] = k
    out = [0] * n
    inn = [0] * n
    dp = [0] * n
    dm = [0] * n

    def rec(k):
        if k == len(pairs):
            if dp[n - 1] == dm[n - 1]:
                yield out, inn
            return
        x, y = pairs[k]
        done_x = last.get(x) == k
        # no arc
        if not (done_x and dp[x] != dm[x]):
            yield from rec(k + 1)
        # x -> y
        dp[x] += 1
        dm[y] += 1
        if not (done_x and dp[x] != dm[x]):
            out[x] |= 1 << y
            inn[y] |= 1 << x
            yield from rec(k + 1)
            out[x] &= ~(1 << y)
            inn[y] &= ~(1 << x)
        dp[x] -= 1
        dm[y] -= 1
        # y -> x
        dp[y] += 1
        dm[x] += 1
        if not (done_x and dp[x] != dm[x]):
            out[y] |= 1 << x
            inn[x] |= 1 << y
            yield from rec(k + 1)
            out[y] &= ~(1 << x)
            inn[x] &= ~(1 << y)
        dp[y] -= 1
        dm[x] -= 1

    yield from rec(0)


def random_oriented(n, rng, p=None):
    if p is None:
        p = rng.random()
    out = [0] * n
    inn = [0] * n
    for x in range(n):
        for y in range(x + 1, n):
            r = rng.random()
            if r < p / 2:
                out[x] |= 1 << y
                inn[y] |= 1 << x
            elif r < p:
                out[y] |= 1 << x
                inn[x] |= 1 << y
    return out, inn


def random_digraph(n, rng):
    p = rng.random()
    q = rng.random()  # probability that a present pair is a digon
    out = [0] * n
    inn = [0] * n
    for x in range(n):
        for y in range(x + 1, n):
            if rng.random() < p:
                if rng.random() < q:
                    out[x] |= 1 << y
                    inn[y] |= 1 << x
                    out[y] |= 1 << x
                    inn[x] |= 1 << y
                elif rng.random() < 0.5:
                    out[x] |= 1 << y
                    inn[y] |= 1 << x
                else:
                    out[y] |= 1 << x
                    inn[x] |= 1 << y
    return out, inn


def random_girth(n, rng, g, density=None):
    """Random oriented graph with no directed cycle shorter than g, by inserting random
    arcs that do not close a short cycle (greedy, so fairly dense)."""
    if density is None:
        density = rng.random()
    out = [0] * n
    inn = [0] * n
    pairs = list(itertools.combinations(range(n), 2))
    rng.shuffle(pairs)
    for x, y in pairs:
        if rng.random() > density:
            continue
        if rng.random() < 0.5:
            x, y = y, x
        if not (reach_within(out, y, g - 2) >> x & 1):
            out[x] |= 1 << y
            inn[y] |= 1 << x
    return out, inn


def random_eulerian(n, rng):
    """Union of random directed cycles whose arcs are new and do not oppose an existing
    arc; Eulerian because every cycle contributes 1 to d+ and d- of each of its vertices."""
    out = [0] * n
    inn = [0] * n
    cycles = rng.randint(1, 2 * n)
    for _ in range(cycles):
        k = rng.randint(3, n)
        cyc = rng.sample(range(n), k)
        arcs = [(cyc[i], cyc[(i + 1) % k]) for i in range(k)]
        if all(not (out[x] >> y & 1) and not (out[y] >> x & 1) for x, y in arcs):
            for x, y in arcs:
                out[x] |= 1 << y
                inn[y] |= 1 << x
    return out, inn


def is_girth_at_least(n, out, g):
    return all(not (reach_within(out, v, g - 1) >> v & 1) for v in range(n))


def arcs_of(n, out):
    return [(x, y) for x in range(n) for y in members(out[x])]


# ---------------------------------------------------------------- bookkeeping

class Tally:
    def __init__(self, names):
        self.names = names
        self.fail = {k: 0 for k in names}
        self.first = {}
        self.count = 0

    def add(self, n, out, res):
        self.count += 1
        for k, ok in res.items():
            if not ok:
                self.fail[k] += 1
                if k not in self.first:
                    self.first[k] = (n, arcs_of(n, out))

    def report(self, label):
        print(f"{label}: {self.count} graphs")
        for k in self.names:
            if k in self.fail:
                print(f"  {k:7s} fails in {self.fail[k]}")
        for k, (n, arcs) in self.first.items():
            print(f"  first counterexample to {k}: n={n}, arcs {' '.join(f'{x}{y}' for x, y in arcs)}")
        sys.stdout.flush()


def rebuild(n, arcs):
    out = [0] * n
    inn = [0] * n
    for x, y in arcs:
        out[x] |= 1 << y
        inn[y] |= 1 << x
    return out, inn


NAMES = ["SEY", "SUL", "SUL4", "SULSEY", "TWO", "MATCH", "DIST", "MINOUT", "ALLMIN", "BOTH"]


def run_all(N):
    for n in range(1, N + 1):
        t = Tally(NAMES)
        t0 = time.time()
        for out, inn in all_oriented_graphs(n):
            t.add(n, out, evaluate(n, out, inn))
        t.report(f"n={n} all oriented graphs ({time.time() - t0:.0f} s)")


def run_random(n, trials, seed=1):
    rng = random.Random(seed)
    t = Tally(NAMES)
    for _ in range(trials):
        out, inn = random_oriented(n, rng)
        t.add(n, out, evaluate(n, out, inn))
    t.report(f"n={n} random oriented graphs (seed {seed})")


def run_tf(N):
    for n in range(1, N + 1):
        t = Tally(["BUR3"])
        t0 = time.time()
        for out, inn in girth_graphs(n, 4):
            t.add(n, out, evaluate_levels(n, out, False))
        t.report(f"n={n} all triangle-free graphs ({time.time() - t0:.0f} s)")


def run_girth5(N):
    for n in range(1, N + 1):
        t = Tally(["BUR3", "BUR4"])
        t0 = time.time()
        for out, inn in girth_graphs(n, 5):
            t.add(n, out, evaluate_levels(n, out, True))
        t.report(f"n={n} all graphs of girth >= 5 ({time.time() - t0:.0f} s)")


def run_randtf(n, trials, seed=3):
    rng = random.Random(seed)
    t = Tally(["BUR3", "BUR4"])
    for i in range(trials):
        g = 5 if i % 2 else 4
        out, inn = random_girth(n, rng, g)
        t.add(n, out, evaluate_levels(n, out, g == 5))
    t.report(f"n={n} random triangle-free / girth-5 graphs (seed {seed})")


def run_eulerian(N):
    for n in range(1, N + 1):
        t = Tally(["EUL", "SEY", "SUL", "TWO", "MATCH"])
        t0 = time.time()
        for out, inn in eulerian_graphs(n):
            res = evaluate(n, out, inn)
            t.add(n, out, {"EUL": eulerian_sum(n, out, inn), "SEY": res["SEY"],
                           "SUL": res["SUL"], "TWO": res["TWO"], "MATCH": res["MATCH"]})
        t.report(f"n={n} all Eulerian oriented graphs ({time.time() - t0:.0f} s)")


def thomasse_kral(n, out, inn):
    """TK: an Eulerian oriented graph with at least n^2/3 arcs has a directed triangle
    (Thomasse-Kral, Conj. 6.16 in Sullivan's survey).  Returns True if the statement holds
    for this (Eulerian) graph."""
    m = sum(bits(out[v]) for v in range(n))
    if 3 * m < n * n:
        return True
    return not is_girth_at_least(n, out, 4)


def run_tk(N):
    for n in range(3, N + 1):
        t = Tally(["TK"])
        t0 = time.time()
        dense = 0
        for out, inn in eulerian_graphs(n):
            m = sum(bits(out[v]) for v in range(n))
            if 3 * m >= n * n:
                dense += 1
                t.add(n, out, {"TK": thomasse_kral(n, out, inn)})
        t.report(f"n={n} Eulerian oriented graphs with >= n^2/3 arcs ({dense} of them, {time.time() - t0:.0f} s)")


def run_randeul(n, trials, seed=5):
    rng = random.Random(seed)
    t = Tally(["EUL", "SEY", "SUL", "TWO", "MATCH", "TK"])
    for _ in range(trials):
        out, inn = random_eulerian(n, rng)
        assert all(bits(out[v]) == bits(inn[v]) for v in range(n))
        res = evaluate(n, out, inn)
        t.add(n, out, {"EUL": eulerian_sum(n, out, inn), "SEY": res["SEY"],
                       "SUL": res["SUL"], "TWO": res["TWO"], "MATCH": res["MATCH"],
                       "TK": thomasse_kral(n, out, inn)})
    t.report(f"n={n} random Eulerian oriented graphs (seed {seed})")


def run_digon(N):
    for n in range(1, N + 1):
        t = Tally(["DIGON"])
        t0 = time.time()
        for out, inn in all_digraphs(n):
            t.add(n, out, {"DIGON": digon_statement(n, out, inn)})
        t.report(f"n={n} all loopless digraphs ({time.time() - t0:.0f} s)")


def run_randdigon(n, trials, seed=9):
    rng = random.Random(seed)
    t = Tally(["DIGON"])
    for _ in range(trials):
        out, inn = random_digraph(n, rng)
        t.add(n, out, {"DIGON": digon_statement(n, out, inn)})
    t.report(f"n={n} random loopless digraphs (seed {seed})")


# ---------------------------------------------------------------- DeVos (LP)

def devos_feasible(n, out, inn):
    """Is there a probability vector p with p(N+(v)) >= p(N-(v)) and p(N2-(v)) >= p(N-(v))
    for every v?  (Only meaningful for triangle-free graphs.)"""
    import numpy as np
    from scipy.optimize import linprog
    rows = []
    for v in range(n):
        plus = [1.0 if out[v] >> u & 1 else 0.0 for u in range(n)]
        minus = [1.0 if inn[v] >> u & 1 else 0.0 for u in range(n)]
        n2m = second_in(n, inn, v)
        two = [1.0 if n2m >> u & 1 else 0.0 for u in range(n)]
        rows.append([m - p for p, m in zip(plus, minus)])   # p(N-) - p(N+) <= 0
        rows.append([m - w for w, m in zip(two, minus)])    # p(N-) - p(N2-) <= 0
    A = np.array(rows)
    r = linprog(np.zeros(n), A_ub=A, b_ub=np.zeros(len(rows)),
                A_eq=np.ones((1, n)), b_eq=[1.0], bounds=[(0, None)] * n, method="highs")
    return r.status == 0


CERT_ARCS = [(0, 3), (1, 0), (1, 5), (2, 0), (2, 4), (3, 4), (3, 5), (4, 1), (5, 2)]


def run_devos(n, trials, seed=11):
    # The 6-vertex graph of Remark 6.10(1).  By Ville's theorem the DeVos distribution
    # exists iff there are NO vertex weights xi, zeta >= 0 with
    #     xi(N2+(u)) + zeta(N-(u)) < (xi+zeta)(N+(u))   for every vertex u
    # (xi multiplies the constraints p(N2-(v)) >= p(N-(v)), zeta the constraints
    # p(N+(v)) >= p(N-(v)); the coefficient of p_u in the combination is the left side
    # minus the right side).  The weights of Remark 6.10(1) give -1 at every vertex.
    out, inn = rebuild(6, CERT_ARCS)
    assert is_girth_at_least(6, out, 4)
    print("certificate graph, arcs", " ".join(f"{x}{y}" for x, y in CERT_ARCS),
          "triangle-free:", is_girth_at_least(6, out, 4), " DEVOS feasible:", devos_feasible(6, out, inn))
    xi = [0, 1, 1, 1, 0, 0]
    zeta = [3, 0, 0, 0, 3, 3]

    def wsum(w, mask):
        return sum(w[v] for v in members(mask))

    for u in range(6):
        lhs = wsum(xi, second_out(6, out, u)) + wsum(zeta, inn[u])
        rhs = wsum([a + b for a, b in zip(xi, zeta)], out[u])
        print(f"  vertex {u}: xi(N2+) + zeta(N-) = {lhs}, (xi+zeta)(N+) = {rhs}, coefficient {lhs - rhs}")
    rout, rinn = rebuild(6, [(y, x) for x, y in CERT_ARCS])
    print("  the reversed graph (isomorphic to it) is DEVOS feasible:", devos_feasible(6, rout, rinn))
    rng = random.Random(seed)
    t = Tally(["DEVOS"])
    for _ in range(trials):
        out, inn = random_girth(n, rng, 4)
        t.add(n, out, {"DEVOS": devos_feasible(n, out, inn)})
    t.report(f"n={n} random triangle-free graphs, DEVOS (seed {seed})")


# ---------------------------------------------------------------- main

def verify_counterexample(name, n, arcs):
    out, inn = rebuild(n, arcs)
    if name in NAMES:
        return evaluate(n, out, inn)[name]
    if name in ("BUR3", "BUR4"):
        return evaluate_levels(n, out, name == "BUR4")[name]
    if name == "EUL":
        return eulerian_sum(n, out, inn)
    if name == "DIGON":
        return digon_statement(n, out, inn)
    raise ValueError(name)


def main():
    a = sys.argv[1:]
    if not a:
        print(__doc__)
        return
    mode = a[0]
    if mode == "all":
        run_all(int(a[1]))
    elif mode == "random":
        run_random(int(a[1]), int(a[2]), int(a[3]) if len(a) > 3 else 1)
    elif mode == "tf":
        run_tf(int(a[1]))
    elif mode == "girth5":
        run_girth5(int(a[1]))
    elif mode == "randtf":
        run_randtf(int(a[1]), int(a[2]), int(a[3]) if len(a) > 3 else 3)
    elif mode == "eulerian":
        run_eulerian(int(a[1]))
    elif mode == "randeul":
        run_randeul(int(a[1]), int(a[2]), int(a[3]) if len(a) > 3 else 5)
    elif mode == "tk":
        run_tk(int(a[1]))
    elif mode == "digon":
        run_digon(int(a[1]))
    elif mode == "randdigon":
        run_randdigon(int(a[1]), int(a[2]), int(a[3]) if len(a) > 3 else 9)
    elif mode == "devos":
        run_devos(int(a[1]), int(a[2]), int(a[3]) if len(a) > 3 else 11)
    elif mode == "verify":
        # python3 related.py verify NAME N arc arc ...   e.g. verify DIST 4 02 03 21 31
        # python3 related.py verify ALLMIN 8 01 02 03 12 23 31 14 15 24 25 34 35 40 50 60 70
        #                               61 62 63 71 72 73 45 46 56 57 74 67
        # (a tournament whose vertex 0 has minimum outdegree 3 and only two second
        # out-neighbours; the sanity statement ALLMIN fails, MINOUT holds)
        name, n = a[1], int(a[2])
        arcs = [(int(s[0]), int(s[1])) for s in a[3:]]
        print(name, "holds" if verify_counterexample(name, n, arcs) else "FAILS", "on", arcs)
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
