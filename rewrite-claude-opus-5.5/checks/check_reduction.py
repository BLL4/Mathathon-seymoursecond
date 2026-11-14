"""Sanity checks for the unconditional ingredients of Sections 1 and 3.

1. Blow-up inequality (proof of Lemma 1.3).  For EVERY oriented graph D,
   every m >= 1 and every U in V(D[T_m]) with support S:
     |U| - 2|F_G U| + |F_G^2 U| <= m(|F^2 S \\ F S| - |F S \\ S|) + |S \\ F S|.
2. Increment identity (proof of Lemma 1.2).  For S, I, E, T, Q as there
   (Q any subset of E \\ T),  g(T u Q) - g(T) = |C| - |Q n F(T)|.
3. Extremal set-up (Section 3).  For every oriented G and every compatible
   P, Q containing the diagonal: the complements R, C contain the diagonal,
   diagonal members are conflict-free, and H avoids F1 P u F2 Q.
"""
import itertools
import random
import sys


def rand_oriented(rng, n, p):
    arcs = set()
    for x, y in itertools.combinations(range(n), 2):
        r = rng.random()
        if r < p / 2:
            arcs.add((x, y))
        elif r < p:
            arcs.add((y, x))
    return arcs


def F(arcs, S):
    return {y for (x, y) in arcs if x in S}


def check_blowup(rng):
    n = rng.choice([2, 3, 4])
    D = rand_oriented(rng, n, rng.random())
    m = rng.choice([1, 2, 3])
    V = [(v, a) for v in range(n) for a in range(m)]
    G = {((v, a), (w, b)) for (v, a) in V for (w, b) in V
         if (v == w and a < b) or (v, w) in D}
    U = {x for x in V if rng.random() < 0.5}
    S = {v for (v, a) in U}
    lhs = len(U) - 2 * len(F(G, U)) + len(F(G, F(G, U)))
    FS = F(D, S)
    rhs = m * (len(F(D, FS) - FS) - len(FS - S)) + len(S - FS)
    assert lhs <= rhs, (D, m, U, lhs, rhs)


def check_increment(rng):
    n = rng.choice([3, 4, 5, 6])
    D = rand_oriented(rng, n, rng.random())
    S = {v for v in range(n) if rng.random() < 0.5}
    FS = F(D, S)
    I, E = FS & S, FS - S
    T = {x for x in E if rng.random() < 0.5}
    Q = {x for x in E - T if rng.random() < 0.5}
    g = lambda T_: len(F(D, T_) - (I | T_))
    C = F(D, Q) - (I | T | Q | F(D, T))
    assert g(T | Q) - g(T) == len(C) - len(Q & F(D, T))


def check_extremal(rng):
    n = rng.choice([2, 3, 4])
    G = rand_oriented(rng, n, rng.random())
    X = range(n)
    F1 = lambda S: {(i, j) for (p, j) in S for i in X if (p, i) in G}
    F2 = lambda S: {(i, j) for (i, s) in S for j in X if (s, j) in G}
    Delta = {(v, v) for v in X}
    allp = set(itertools.product(X, X))
    P = Delta | {q for q in allp if rng.random() < 0.3}
    Q = Delta | {q for q in allp if rng.random() < 0.3}
    if F1(P) & F2(Q):
        return False
    R = allp - F2(F2(Q))
    C = allp - F1(F1(P))
    assert Delta <= R and Delta <= C
    for (p, j) in R:
        for (i, s) in C:
            if (p, i) in G and (s, j) in G:
                assert p != j and i != s, "diagonal member in conflict"
                assert (p, s) not in F1(P) | F2(Q), "H meets F1P u F2Q"
    return True


def main():
    trials = int(sys.argv[1]) if len(sys.argv) > 1 else 5000
    rng = random.Random(int(sys.argv[2]) if len(sys.argv) > 2 else 1)
    for _ in range(trials):
        check_blowup(rng)
        check_increment(rng)
    ok = sum(check_extremal(rng) for _ in range(trials))
    print(f"OK: blow-up and increment checks x{trials}; extremal set-up on {ok} compatible pairs")


if __name__ == "__main__":
    main()
