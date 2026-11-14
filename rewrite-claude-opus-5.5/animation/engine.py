"""Exact computation of one improvement step of Section 5, for the animation.

Given an oriented graph G on X = {0,...,n-1} and an admissible pair (P, Q),
compute every quantity used in the step:

    F1 P, F2 Q, unc, val            (the old pair)
    R = X^2 \\ F2^2 Q, C = X^2 \\ F1^2 P
    conflicts, Z, H                  (Definition 3.5)
    a pruning (P', Q') of (R, C) satisfying (P1)-(P3) of the pruning lemma
    unc', val'                       (the new pair)

Pure Python.  Pairs (i, j) mean row i, column j.
"""
import itertools


def F(rel, U):
    return {y for (x, y) in rel if x in U}


def F1(rel, S):
    """Move the first coordinate along an arc (vertical)."""
    return {(i, j) for (p, j) in S for (x, i) in rel if x == p}


def F2(rel, S):
    """Move the second coordinate along an arc (horizontal)."""
    return {(i, j) for (i, s) in S for (x, j) in rel if x == s}


def conflicts(rel, R, C):
    return [(r, c) for r in sorted(R) for c in sorted(C)
            if (r[0], c[0]) in rel and (c[1], r[1]) in rel]


def unc(rel, n, P, Q):
    return n * n - len(F1(rel, P)) - len(F2(rel, Q))


def val(rel, n, P, Q):
    return len(P) + len(Q) + unc(rel, n, P, Q)


def kappa(rel, U):
    """|U| - 2|F U| + |F^2 U|; strict concavity means kappa < 0."""
    FU = F(rel, U)
    return len(U) - 2 * len(FU) + len(F(rel, FU))


def best_pruning(rel, R, C, n):
    """Among prunings satisfying (P1)-(P3), one of maximum val(R', C').

    Only members that are in a conflict may be deleted (P2), so we search
    over subsets of those.  Fine for the small examples of the animation.
    """
    conf = conflicts(rel, R, C)
    Z = {(c[0], r[1]) for r, c in conf}
    H = {(r[0], c[1]) for r, c in conf}
    cR = sorted({r for r, _ in conf})
    cC = sorted({c for _, c in conf})
    best = None
    for mask in range(1 << (len(cR) + len(cC))):
        dR = {cR[t] for t in range(len(cR)) if mask >> t & 1}
        dC = {cC[t] for t in range(len(cC)) if mask >> (len(cR) + t) & 1}
        Rk, Ck = set(R) - dR, set(C) - dC
        if conflicts(rel, Rk, Ck):
            continue
        cov = F1(rel, Rk) | F2(rel, Ck)
        uz = len(Z - cov)
        if len(dR) + len(dC) > len(H) + uz:
            continue
        key = (len(Rk) + len(Ck) + n * n - len(cov), -len(dR) - len(dC))
        if best is None or key > best[0]:
            best = (key, Rk, Ck, dR, dC, uz)
    return conf, Z, H, best


def step(rel, n, P, Q):
    X2 = {(i, j) for i in range(n) for j in range(n)}
    d = unc(rel, n, P, Q)
    R = X2 - F2(rel, F2(rel, Q))
    C = X2 - F1(rel, F1(rel, P))
    conf, Z, H, best = best_pruning(rel, R, C, n)
    _, P2, Q2, dR, dC, uz = best
    cols = [{p for (p, j) in P if j == jj} for jj in range(n)]
    rows = [{s for (i, s) in Q if i == ii} for ii in range(n)]
    return dict(
        P=P, Q=Q, F1P=F1(rel, P), F2Q=F2(rel, Q), d=d,
        val=len(P) + len(Q) + d, mu=len(P) + len(Q),
        F1sqP=F1(rel, F1(rel, P)), F2sqQ=F2(rel, F2(rel, Q)),
        R=R, C=C, conf=conf, Z=Z, H=H,
        delR=dR, delC=dC, uncZ=uz, P2=P2, Q2=Q2,
        d2=unc(rel, n, P2, Q2), val2=val(rel, n, P2, Q2),
        kappa_cols=[kappa(rel, U) for U in cols],
        kappa_rows=[kappa(rel, U) for U in rows],
    )


def oriented_graphs(n):
    pairs = [(a, b) for a in range(n) for b in range(a + 1, n)]
    for choice in itertools.product((0, 1, 2), repeat=len(pairs)):
        rel = set()
        for (a, b), ch in zip(pairs, choice):
            if ch == 1:
                rel.add((a, b))
            elif ch == 2:
                rel.add((b, a))
        if all(any(y == v for (_, y) in rel) for v in range(n)):
            yield frozenset(rel)


if __name__ == "__main__":
    import sys
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    Delta = {(v, v) for v in range(n)}
    seen = set()
    for rel in oriented_graphs(n):
        key = tuple(sorted(rel))
        s1 = step(rel, n, Delta, Delta)
        if not s1["conf"] or s1["val2"] <= s1["val"]:
            continue
        s2 = step(rel, n, s1["P2"], s1["Q2"])
        print(len(rel), sorted(rel), "val", s1["val"], "->", s1["val2"], "->", s2["val2"],
              "| conf", len(s1["conf"]), "Z", len(s1["Z"]), "H", len(s1["H"]),
              "del", len(s1["delR"]) + len(s1["delC"]), "uncZ", s1["uncZ"],
              "| conf2", len(s2["conf"]))
