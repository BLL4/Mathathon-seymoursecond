"""Brute-force sanity checks for the pruning lemma (Lemma 2.1 of the original).

For random relations on a small set X and random families R, C of pairs:
  * compute Z, H and the augmented bipartite graph Gamma,
  * check  max matching(Gamma) <= |Z| + |H|,
  * check the pruning statement itself by exhaustive search over deletions,
  * check that the Koenig cover gives a valid pruning satisfying the bound.

Pure Python, no dependencies.  Run:  python3 -I check_pruning.py [trials] [seed]
"""
import itertools
import random
import sys


def conflicts(rel, R, C):
    """All conflicting pairs (r, c): r=(p,j) in R, c=(i,s) in C, p->i and s->j."""
    return [(r, c) for r in R for c in C if (r[0], c[0]) in rel and (c[1], r[1]) in rel]


def covered_by_R(rel, r, z):
    return z[1] == r[1] and (r[0], z[0]) in rel


def covered_by_C(rel, c, z):
    return z[0] == c[0] and (c[1], z[1]) in rel


def build_gamma(rel, R, C):
    conf = conflicts(rel, R, C)
    Z = sorted({(c[0], r[1]) for r, c in conf})
    H = sorted({(r[0], c[1]) for r, c in conf})
    left = [("R", r) for r in R] + [("ZL", z) for z in Z]
    adj = {v: [] for v in left}
    for r, c in conf:
        adj[("R", r)].append(("C", c))
    for r in R:
        for z in Z:
            if covered_by_R(rel, r, z):
                adj[("R", r)].append(("ZR", z))
    for z in Z:
        for c in C:
            if covered_by_C(rel, c, z):
                adj[("ZL", z)].append(("C", c))
    return conf, Z, H, left, adj


def max_matching(left, adj):
    match_r = {}

    def try_aug(u, seen):
        for w in adj[u]:
            if w in seen:
                continue
            seen.add(w)
            if w not in match_r or try_aug(match_r[w], seen):
                match_r[w] = u
                return True
        return False

    size = sum(1 for u in left if try_aug(u, set()))
    return size, match_r


def koenig_cover(left, adj, match_r):
    match_l = {u: w for w, u in match_r.items()}
    WL, WR = set(), set()
    stack = [u for u in left if u not in match_l]
    WL.update(stack)
    while stack:
        u = stack.pop()
        for w in adj[u]:
            if match_l.get(u) == w or w in WR:
                continue
            WR.add(w)
            u2 = match_r.get(w)
            if u2 is not None and u2 not in WL:
                WL.add(u2)
                stack.append(u2)
    return (set(left) - WL) | WR


def uncovered_Z(rel, Rk, Ck, Z):
    return sum(1 for z in Z
               if not any(covered_by_R(rel, r, z) for r in Rk)
               and not any(covered_by_C(rel, c, z) for c in Ck))


def check_instance(rel, R, C, exhaustive=True):
    conf, Z, H, left, adj = build_gamma(rel, R, C)
    size, match_r = max_matching(left, adj)
    assert size <= len(Z) + len(H), ("matching bound fails", rel, R, C, size, Z, H)
    # Koenig cover -> pruning
    K = koenig_cover(left, adj, match_r)
    assert len(K) == size
    for u in left:
        for w in adj[u]:
            assert u in K or w in K
    Rk = [r for r in R if ("R", r) not in K]
    Ck = [c for c in C if ("C", c) not in K]
    assert not conflicts(rel, Rk, Ck)
    conflicted = {r for r, _ in conf} | {c for _, c in conf}
    assert all(r in Rk for r in R if r not in {x for x, _ in conf})
    assert all(c in Ck for c in C if c not in {y for _, y in conf})
    deleted = (len(R) - len(Rk)) + (len(C) - len(Ck))
    assert deleted <= len(H) + uncovered_Z(rel, Rk, Ck, Z), "cover pruning bound fails"
    if exhaustive:
        cR = [r for r in R if r in {x for x, _ in conf}]
        cC = [c for c in C if c in {y for _, y in conf}]
        if len(cR) + len(cC) <= 12:
            best = None
            for mask in range(1 << (len(cR) + len(cC))):
                dR = {cR[t] for t in range(len(cR)) if mask >> t & 1}
                dC = {cC[t] for t in range(len(cC)) if mask >> (len(cR) + t) & 1}
                Rk2 = [r for r in R if r not in dR]
                Ck2 = [c for c in C if c not in dC]
                if conflicts(rel, Rk2, Ck2):
                    continue
                if len(dR) + len(dC) <= len(H) + uncovered_Z(rel, Rk2, Ck2, Z):
                    best = True
                    break
            assert best, "no valid pruning exists!"
    return size, len(Z), len(H), len(conf)


def random_instance(rng, n, p_arc, p_fam, oriented):
    X = range(n)
    rel = set()
    for x in X:
        for y in X:
            if x == y and oriented:
                continue
            if rng.random() < p_arc:
                if oriented and (y, x) in rel:
                    continue
                rel.add((x, y))
    pairs = list(itertools.product(X, X))
    R = [q for q in pairs if rng.random() < p_fam]
    C = [q for q in pairs if rng.random() < p_fam]
    return rel, R, C


def main():
    trials = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    rng = random.Random(seed)
    tight = 0
    for t in range(trials):
        n = rng.choice([2, 3, 4])
        rel, R, C = random_instance(rng, n, rng.random(), rng.random(), rng.random() < 0.5)
        size, nz, nh, nc = check_instance(rel, R, C, exhaustive=(t % 3 == 0))
        if nc and size == nz + nh:
            tight += 1
    print(f"OK: {trials} random instances; matching bound tight in {tight} of them")


if __name__ == "__main__":
    main()
