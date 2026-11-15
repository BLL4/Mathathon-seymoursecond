"""Sanity check of a shorter rank count for the matching bound.

Claim: with the matrices L (Z x R), B (H x R), N (C x Z), A (C x H) of the
paper, NL = AB gives the 3-term complex
        R^R --[L;B]--> R^Z + R^H --[N,-A]--> R^C,
so rank[L;B] + rank[N,A] <= |Z| + |H|.  The paper's kernel argument gives
rank[L;B] >= l + k (l = nu(Gamma_L), k = conflict edges of a maximum matching
with fewest conflict edges) and trivially rank[N,A] >= rank N = t.
We check numerically, at random real assignments, that
   (i)  [N,-A][L;B] = 0,
   (ii) rank[L;B] >= l + k  and  rank N = t,  rank L = l,
   (iii) hence nu = k + l + t <= rank[L;B] + rank[N,A] <= |Z| + |H|.
"""
import random, sys
import numpy as np
import networkx as nx
from matching_bound import gamma, random_instance, W

def matrices(rel, R, C, Z, H, rng):
    a = {e: rng.uniform(1, 2) for e in rel}
    b = {e: rng.uniform(1, 2) for e in rel}
    R, C, Z, H = sorted(R), sorted(C), sorted(Z), sorted(H)
    ri, ci, zi, hi = ({x: n for n, x in enumerate(S)} for S in (R, C, Z, H))
    L = np.zeros((len(Z), len(R))); B = np.zeros((len(H), len(R)))
    N = np.zeros((len(C), len(Z))); A = np.zeros((len(C), len(H)))
    for (p, j) in R:
        for (i, jj) in Z:
            if jj == j and (p, i) in rel: L[zi[(i, j)], ri[(p, j)]] = a[(p, i)]
        for (pp, s) in H:
            if pp == p and (s, j) in rel: B[hi[(p, s)], ri[(p, j)]] = b[(s, j)]
    for (i, s) in C:
        for (ii, j) in Z:
            if ii == i and (s, j) in rel: N[ci[(i, s)], zi[(i, j)]] = b[(s, j)]
        for (p, ss) in H:
            if ss == s and (p, i) in rel: A[ci[(i, s)], hi[(p, s)]] = a[(p, i)]
    return L, B, N, A

def rk(M):
    return 0 if M.size == 0 else np.linalg.matrix_rank(M, tol=1e-9)

if __name__ == "__main__":
    rng = random.Random(3)
    bad = 0; tot = 0; slack = []
    for n in (3, 4, 5):
        for _ in range(600):
            rel, R, C = random_instance(n, rng, rng.uniform(0.2, 0.7), rng.uniform(0.2, 0.7))
            conf, Z, H, G = gamma(rel, R, C)
            if not conf: continue
            tot += 1
            M = nx.max_weight_matching(G, maxcardinality=True)
            k = sum(1 for e in M if {e[0][0], e[1][0]} == {'r', 'c'})
            GL = nx.Graph([(u, v) for u, v in G.edges if {u[0], v[0]} == {'r', 'zR'}])
            GN = nx.Graph([(u, v) for u, v in G.edges if {u[0], v[0]} == {'c', 'zL'}])
            l = len(nx.max_weight_matching(GL, maxcardinality=True)) if GL.edges else 0
            t = len(nx.max_weight_matching(GN, maxcardinality=True)) if GN.edges else 0
            assert len(M) == k + l + t, (len(M), k, l, t)
            L, B, N, A = matrices(rel, R, C, Z, H, rng)
            LB = np.vstack([L, B]); NA = np.hstack([N, -A])
            assert np.allclose(NA @ LB, 0), "square does not commute"
            assert rk(L) == l and rk(N) == t, (rk(L), l, rk(N), t)
            ok = rk(LB) >= l + k and rk(LB) + rk(NA) <= len(Z) + len(H)
            bad += not ok
            slack.append((len(Z) + len(H)) - (rk(LB) + rk(NA)))
    print("instances", tot, "violations", bad, "slack histogram", {s: slack.count(s) for s in sorted(set(slack))})
