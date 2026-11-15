#!/usr/bin/env python3
"""Caccetta-Haggkvist for triangles: which strengthenings of Seymour's theorem survive?

For a triangle-free oriented graph G on n vertices write d+(v), d-(v) for the out- and
in-degree and d++(v) = |N2+(v)| for the size of the second out-neighbourhood.  Because
N1+(v), N2+(v), N-(v) and {v} are pairwise disjoint when there is no directed triangle,
any vertex with  d++(v) + d-(v) >= 2 d+(v)  has  3 d+(v) <= n - 1.  So each of the
following statements, if true for all triangle-free oriented graphs, implies the
Caccetta-Haggkvist conjecture for k = 3 (CH3: some vertex has d+(v) < n/3):

  SEY : some v has d++ >= d+                          (Seymour's theorem; always true)
  S1  : some v has d++ + d- >= 2 d+                   (implies CH3)
  S2  : some v has d++ >= d+ and d- >= d+             (implies S1)
  S3  : some v has d++ >= d+ and d++ + d- >= 2 d+     (a Seymour vertex satisfying S1)
  S4  : some v of minimum outdegree has d++ >= d+     (a Seymour vertex of minimum outdegree)
  LP  : there is a probability vector eta on V with eta(N2+(v)) >= eta(N1+(v)) and
        eta(N-(v)) >= eta(N1+(v)) for every v   (by Ville's theorem this is equivalent
        to: for all weightings xi, zeta >= 0 some v has
        xi(N2+(v)) + zeta(N-(v)) >= (xi+zeta)(N1+(v)); it implies S1 with xi = zeta = 1)
  VAL : the value of the matrix game max_p min_v p(N1+(v)) is < 1/3 (CH3 for all blow-ups
        of G by independent sets, by the minimax theorem)

Weighted versions of S1, S2 (positive integer weights = blow-ups by independent sets)
are also tested.  Standard library only, except that the LP/VAL modes use scipy.

Usage:
  python3 ch_triangle.py exhaustive N          all labelled triangle-free oriented graphs, n <= N
  python3 ch_triangle.py random N TRIALS       random maximal-ish triangle-free oriented graphs
  python3 ch_triangle.py weighted N TRIALS     exhaustive graphs on <= N vertices, random weights
  python3 ch_triangle.py lp N                  LP and VAL on all graphs with <= N vertices
  python3 ch_triangle.py circulant N           triangle-free circulants on Z_n, n <= N
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


def triangle_free_graphs(n):
    """Yield (out, inn) bitmask lists of all labelled triangle-free oriented graphs on n
    vertices (backtracking over the pairs; an arc x->y closes a triangle iff some w has
    y->w and w->x)."""
    pairs = list(itertools.combinations(range(n), 2))
    out = [0] * n
    inn = [0] * n

    def rec(k):
        if k == len(pairs):
            yield out, inn
            return
        x, y = pairs[k]
        yield from rec(k + 1)
        if not (out[y] & inn[x]):
            out[x] |= 1 << y
            inn[y] |= 1 << x
            yield from rec(k + 1)
            out[x] &= ~(1 << y)
            inn[y] &= ~(1 << x)
        if not (out[x] & inn[y]):
            out[y] |= 1 << x
            inn[x] |= 1 << y
            yield from rec(k + 1)
            out[y] &= ~(1 << x)
            inn[x] &= ~(1 << y)

    yield from rec(0)


def random_triangle_free(n, rng, density=None):
    """A random triangle-free oriented graph: scan the pairs in random order and add an
    arc (random direction) with probability `density` whenever it closes no triangle."""
    if density is None:
        density = rng.uniform(0.4, 1.0)
    out = [0] * n
    inn = [0] * n
    pairs = list(itertools.combinations(range(n), 2))
    rng.shuffle(pairs)
    for x, y in pairs:
        if rng.random() > density:
            continue
        if rng.random() < 0.5:
            x, y = y, x
        if not (out[y] & inn[x]):
            out[x] |= 1 << y
            inn[y] |= 1 << x
    return out, inn


def neighbourhoods(n, out, inn):
    """Per vertex: (N1+, N-, N2+) as bitmasks."""
    res = []
    for v in range(n):
        n1 = out[v]
        f2 = 0
        for u in members(n1):
            f2 |= out[u]
        n2 = f2 & ~n1 & ~(1 << v)
        res.append((n1, inn[v], n2))
    return res


def arcs_of(n, out):
    return [(x, y) for x in range(n) for y in members(out[x])]


STATEMENTS = ["SEY", "CH3", "S1", "S2", "S3", "S4"]


def evaluate(n, nb):
    deg = [(bits(a), bits(b), bits(c)) for a, b, c in nb]
    mindeg = min(dp for dp, _, _ in deg)
    return {
        "SEY": any(dpp >= dp for dp, dm, dpp in deg),
        "CH3": any(3 * dp < n for dp, dm, dpp in deg),
        "S1": any(dpp + dm >= 2 * dp for dp, dm, dpp in deg),
        "S2": any(dpp >= dp and dm >= dp for dp, dm, dpp in deg),
        "S3": any(dpp >= dp and dpp + dm >= 2 * dp for dp, dm, dpp in deg),
        "S4": any(dp == mindeg and dpp >= dp for dp, dm, dpp in deg),
    }


def wsum(w, mask):
    return sum(w[u] for u in members(mask))


def evaluate_weighted(n, nb, w):
    tot = sum(w)
    return {
        "wSEY": any(wsum(w, c) >= wsum(w, a) for a, b, c in nb),
        "wCH3": any(3 * wsum(w, a) < tot for a, b, c in nb),
        "wS1": any(wsum(w, c) + wsum(w, b) >= 2 * wsum(w, a) for a, b, c in nb),
        "wS2": any(wsum(w, c) >= wsum(w, a) and wsum(w, b) >= wsum(w, a) for a, b, c in nb),
    }


class Tally:
    def __init__(self, names):
        self.names = names
        self.count = 0
        self.fail = {s: 0 for s in names}
        self.examples = {s: [] for s in names}

    def add(self, n, out, res, extra=None):
        self.count += 1
        for s in self.names:
            if not res[s]:
                self.fail[s] += 1
                if len(self.examples[s]) < 3:
                    self.examples[s].append((n, arcs_of(n, out), extra))

    def report(self, label):
        print(f"{label}: {self.count} graphs")
        for s in self.names:
            f = self.fail[s]
            print(f"  {s:5s} fails in {f}")
            for ex in self.examples[s]:
                print(f"        e.g. n={ex[0]} arcs={ex[1]}" + (f" {ex[2]}" if ex[2] else ""))
        sys.stdout.flush()


def run_exhaustive(N):
    for n in range(1, N + 1):
        t0 = time.time()
        tally = Tally(STATEMENTS)
        tight = 0
        for out, inn in triangle_free_graphs(n):
            nb = neighbourhoods(n, out, inn)
            res = evaluate(n, nb)
            tally.add(n, out, res)
            if max(bits(c) + bits(b) - 2 * bits(a) for a, b, c in nb) == 0:
                tight += 1
        tally.report(f"n={n} exhaustive")
        print(f"  best vertex of S1 tight (d++ + d- = 2 d+) in {tight} graphs; {time.time()-t0:.0f} s")
        sys.stdout.flush()


def run_random(n, trials, seed=1):
    rng = random.Random(seed)
    tally = Tally(STATEMENTS)
    wt = Tally(["wSEY", "wCH3", "wS1", "wS2"])
    for _ in range(trials):
        out, inn = random_triangle_free(n, rng)
        nb = neighbourhoods(n, out, inn)
        tally.add(n, out, evaluate(n, nb))
        w = [rng.randint(1, 4) for _ in range(n)]
        wt.add(n, out, evaluate_weighted(n, nb, w), f"w={w}")
    tally.report(f"n={n} random ({trials} graphs, seed {seed})")
    wt.report(f"n={n} random weighted")


def run_weighted(N, trials, seed=1):
    rng = random.Random(seed)
    for n in range(2, N + 1):
        wt = Tally(["wSEY", "wCH3", "wS1", "wS2"])
        for out, inn in triangle_free_graphs(n):
            nb = neighbourhoods(n, out, inn)
            for _ in range(trials):
                w = [rng.randint(1, 5) for _ in range(n)]
                wt.add(n, out, evaluate_weighted(n, nb, w), f"w={w}")
        wt.report(f"n={n} exhaustive graphs x {trials} random weights")


def lp_eta(n, nb):
    """LP: is there a probability vector eta with eta(N2+) >= eta(N1+) and eta(N-) >= eta(N1+)
    at every vertex?  Returns True/False."""
    import numpy as np
    from scipy.optimize import linprog
    rows = []
    for a, b, c in nb:
        r1 = np.zeros(n)
        r2 = np.zeros(n)
        for u in members(a):
            r1[u] += 1
            r2[u] += 1
        for u in members(c):
            r1[u] -= 1
        for u in members(b):
            r2[u] -= 1
        rows.append(r1)
        rows.append(r2)
    A = np.array(rows)
    res = linprog(np.zeros(n), A_ub=A, b_ub=np.zeros(len(rows)), A_eq=np.ones((1, n)),
                  b_eq=[1.0], bounds=[(0, None)] * n, method="highs")
    return res.status == 0


def game_value(n, nb):
    """max_p min_v p(N1+(v)) for probability vectors p (the fractional CH3 value)."""
    import numpy as np
    from scipy.optimize import linprog
    # variables p_0..p_{n-1}, t ; maximize t s.t. t - p(N1+(v)) <= 0
    rows = []
    for a, b, c in nb:
        r = np.zeros(n + 1)
        r[n] = 1
        for u in members(a):
            r[u] = -1
        rows.append(r)
    A_eq = np.zeros((1, n + 1))
    A_eq[0, :n] = 1
    c = np.zeros(n + 1)
    c[n] = -1
    res = linprog(c, A_ub=np.array(rows), b_ub=np.zeros(len(rows)), A_eq=A_eq, b_eq=[1.0],
                  bounds=[(0, None)] * n + [(None, None)], method="highs")
    return -res.fun


def run_lp(N):
    for n in range(2, N + 1):
        t0 = time.time()
        cnt = 0
        lp_fail = []
        worst = (0.0, None)
        for out, inn in triangle_free_graphs(n):
            cnt += 1
            nb = neighbourhoods(n, out, inn)
            if not lp_eta(n, nb):
                if len(lp_fail) < 3:
                    lp_fail.append(arcs_of(n, out))
                lp_fail.append(None)
            val = game_value(n, nb)
            if val > worst[0] + 1e-9:
                worst = (val, arcs_of(n, out))
        print(f"n={n}: {cnt} graphs; LP (in-heavy fractional Seymour vector) fails in "
              f"{len(lp_fail)}; max game value {worst[0]:.4f} (1/3 = 0.3333) at {worst[1]}; "
              f"{time.time()-t0:.0f} s")
        for ex in lp_fail[:3]:
            if ex is not None:
                print(f"        LP fails e.g. arcs={ex}")
        sys.stdout.flush()


def run_circulant(N):
    """Triangle-free circulants: S subset of Z_n \\ {0} with S cap -S empty and no
    a+b+c = 0 (mod n) with a,b,c in S.  All vertices are alike (vertex-transitive)."""
    for n in range(3, N + 1):
        best = (0, None)
        for r in range(1, n):
            for S in itertools.combinations(range(1, n), r):
                Sset = set(S)
                if any((-a) % n in Sset for a in S):
                    continue
                if any((a + b + c) % n == 0 for a in S for b in S for c in S):
                    continue
                if r > best[0]:
                    best = (r, S)
            if best[0] < r and best[0] > 0 and r > best[0] + 1:
                break
        r, S = best
        if S is None:
            print(f"n={n}: no triangle-free circulant")
            continue
        n2 = {(a + b) % n for a in S for b in S} - set(S) - {0}
        print(f"n={n}: max out-degree {r} = {r/n:.4f} n, S={S}; d++={len(n2)}, "
              f"S1 margin d++ + d- - 2d+ = {len(n2) + r - 2*r}")


def all_oriented_graphs(n, tournaments=False):
    """All labelled oriented graphs (or tournaments) on n vertices, as (out, inn) bitmasks."""
    pairs = list(itertools.combinations(range(n), 2))
    states = (1, 2) if tournaments else (0, 1, 2)
    for st in itertools.product(states, repeat=len(pairs)):
        out = [0] * n
        inn = [0] * n
        for (x, y), s in zip(pairs, st):
            if s == 1:
                out[x] |= 1 << y
                inn[y] |= 1 << x
            elif s == 2:
                out[y] |= 1 << x
                inn[x] |= 1 << y
        yield out, inn


def run_all(N, tournaments=False):
    """S1, S2, S4 on ALL oriented graphs (or tournaments): here S1 does not imply CH3, but
    S2 ('a Seymour vertex with d- >= d+') makes sense for every oriented graph."""
    for n in range(1, N + 1):
        t0 = time.time()
        tally = Tally(["SEY", "S1", "S2", "S4"])
        for out, inn in all_oriented_graphs(n, tournaments):
            nb = neighbourhoods(n, out, inn)
            tally.add(n, out, {k: v for k, v in evaluate(n, nb).items() if k in tally.names})
        tally.report(f"n={n} all {'tournaments' if tournaments else 'oriented graphs'}")
        print(f"  {time.time()-t0:.0f} s")
        sys.stdout.flush()


def run_random_all(n, trials, seed=7, tournaments=False):
    """S2 on random oriented graphs (each pair: no arc / either direction, random density),
    or on random tournaments."""
    rng = random.Random(seed)
    tally = Tally(["SEY", "S1", "S2", "S4"])
    for _ in range(trials):
        dens = 1.0 if tournaments else rng.uniform(0.2, 1.0)
        out = [0] * n
        inn = [0] * n
        for x, y in itertools.combinations(range(n), 2):
            if rng.random() > dens:
                continue
            if rng.random() < 0.5:
                x, y = y, x
            out[x] |= 1 << y
            inn[y] |= 1 << x
        nb = neighbourhoods(n, out, inn)
        tally.add(n, out, {k: v for k, v in evaluate(n, nb).items() if k in tally.names})
    tally.report(f"n={n} random {'tournaments' if tournaments else 'oriented graphs'} "
                 f"({trials}, seed {seed})")


def run_structured(n, trials, seed=21, triangle_free=False):
    """Search for counterexamples to S2 where Proposition 6.8 says they must live: random
    oriented graphs repaired so that every vertex has d- >= d+ - 1 (delete out-arcs of
    offending vertices), no sinks, strongly connected."""
    rng = random.Random(seed)
    tally = Tally(["SEY", "S2"])
    kept = 0
    for _ in range(trials):
        if triangle_free:
            out, inn = random_triangle_free(n, rng)
        else:
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
        # repair: while some vertex has d+ > d- + 1, delete one of its out-arcs
        changed = True
        while changed:
            changed = False
            for v in range(n):
                if bits(out[v]) > bits(inn[v]) + 1:
                    ys = list(members(out[v]))
                    y = rng.choice(ys)
                    out[v] &= ~(1 << y)
                    inn[y] &= ~(1 << v)
                    changed = True
        if any(out[v] == 0 for v in range(n)):
            continue
        # strong connectivity
        def reach(start, adjm):
            seen = 1 << start
            frontier = [start]
            while frontier:
                x = frontier.pop()
                m = adjm[x] & ~seen
                seen |= m
                frontier.extend(members(m))
            return seen
        full = (1 << n) - 1
        if reach(0, out) != full or reach(0, inn) != full:
            continue
        kept += 1
        nb = neighbourhoods(n, out, inn)
        tally.add(n, out, {k: v for k, v in evaluate(n, nb).items() if k in tally.names})
    tally.report(f"n={n} structured{' triangle-free' if triangle_free else ''} "
                 f"({kept} of {trials} candidates kept, seed {seed})")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "exhaustive"
    if mode == "structured":
        run_structured(int(sys.argv[2]), int(sys.argv[3]) if len(sys.argv) > 3 else 10000,
                       int(sys.argv[4]) if len(sys.argv) > 4 else 21,
                       triangle_free=(len(sys.argv) > 5 and sys.argv[5] == "tf"))
    elif mode == "exhaustive":
        run_exhaustive(int(sys.argv[2]) if len(sys.argv) > 2 else 5)
    elif mode == "all":
        run_all(int(sys.argv[2]) if len(sys.argv) > 2 else 5)
    elif mode == "tournaments":
        run_all(int(sys.argv[2]) if len(sys.argv) > 2 else 7, tournaments=True)
    elif mode == "randomall":
        run_random_all(int(sys.argv[2]), int(sys.argv[3]) if len(sys.argv) > 3 else 10000,
                       int(sys.argv[4]) if len(sys.argv) > 4 else 7)
    elif mode == "randomtour":
        run_random_all(int(sys.argv[2]), int(sys.argv[3]) if len(sys.argv) > 3 else 10000,
                       int(sys.argv[4]) if len(sys.argv) > 4 else 11, tournaments=True)
    elif mode == "random":
        run_random(int(sys.argv[2]), int(sys.argv[3]) if len(sys.argv) > 3 else 10000,
                   int(sys.argv[4]) if len(sys.argv) > 4 else 1)
    elif mode == "weighted":
        run_weighted(int(sys.argv[2]), int(sys.argv[3]) if len(sys.argv) > 3 else 10)
    elif mode == "lp":
        run_lp(int(sys.argv[2]) if len(sys.argv) > 2 else 5)
    elif mode == "circulant":
        run_circulant(int(sys.argv[2]) if len(sys.argv) > 2 else 16)
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
