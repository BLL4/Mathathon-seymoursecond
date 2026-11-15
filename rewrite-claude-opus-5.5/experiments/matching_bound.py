"""Numerical exploration of the pruning lemma's matching bound  nu(Gamma) <= |Z| + |H|.

Questions tested (random relations, random families R, C):
  Q1  Does nu(Gamma) <= |Z| + |H| hold?  How often with equality?
  Q2  For a maximum matching M with the fewest conflict edges, write
        k = #conflict edges, Z_a = {z : z_R matched}, Z_b = {z : z_L matched}.
      Then nu = k + |Z_a| + |Z_b| = k + |Z_a u Z_b| + |Z_a n Z_b|, so the bound
      would follow from the purely combinatorial statement
            k + |Z_a n Z_b| <= |H|.                                   (*)
      Each conflict edge (r,c) in M and each doubly used z (matched on both
      sides, to r_z and c_z, which then conflict) has an opposite corner h.
      Are these k + |Z_a n Z_b| corners always distinct?  Does (*) hold?
  Q3  Is the naive pruning (delete every member in a conflict) within budget,
      i.e. |R_conf| + |C_conf| <= |H| + |Z| ?
Run:  ../animation/.venv/bin/python matching_bound.py [n] [trials] [seed]
"""
import random
import sys

import networkx as nx

W = 10 ** 6


def conflicts(rel, R, C):
    return [(r, c) for r in sorted(R) for c in sorted(C)
            if (r[0], c[0]) in rel and (c[1], r[1]) in rel]


def gamma(rel, R, C):
    conf = conflicts(rel, R, C)
    Z = {(c[0], r[1]) for r, c in conf}
    H = {(r[0], c[1]) for r, c in conf}
    G = nx.Graph()
    for r, c in conf:
        G.add_edge(('r', r), ('c', c), weight=W - 1)
    for r in R:
        for z in Z:
            if z[1] == r[1] and (r[0], z[0]) in rel:
                G.add_edge(('r', r), ('zR', z), weight=W)
    for c in C:
        for z in Z:
            if z[0] == c[0] and (c[1], z[1]) in rel:
                G.add_edge(('zL', z), ('c', c), weight=W)
    return conf, Z, H, G


def analyse(rel, R, C):
    conf, Z, H, G = gamma(rel, R, C)
    if not conf:
        return None
    M = nx.max_weight_matching(G, maxcardinality=True)
    k, Za, Zb, corners = 0, set(), set(), []
    mate = {}
    for a, b in M:
        mate[a] = b
        mate[b] = a
    for a, b in M:
        kinds = {a[0], b[0]}
        if kinds == {'r', 'c'}:
            r, c = (a[1], b[1]) if a[0] == 'r' else (b[1], a[1])
            k += 1
            corners.append((r[0], c[1]))
        elif 'zR' in kinds:
            Za.add(a[1] if a[0] == 'zR' else b[1])
        else:
            Zb.add(a[1] if a[0] == 'zL' else b[1])
    for z in Za & Zb:
        r = mate[('zR', z)][1]
        c = mate[('zL', z)][1]
        corners.append((r[0], c[1]))
    Rc = {r for r, _ in conf}
    Cc = {c for _, c in conf}
    return dict(nu=len(M), Z=len(Z), H=len(H), k=k, both=len(Za & Zb),
                corners=corners, distinct=len(set(corners)) == len(corners),
                naive=len(Rc) + len(Cc))


def random_instance(n, rng, p_arc=0.4, p_mem=0.4):
    rel = {(a, b) for a in range(n) for b in range(n) if rng.random() < p_arc}
    R = {(i, j) for i in range(n) for j in range(n) if rng.random() < p_mem}
    C = {(i, j) for i in range(n) for j in range(n) if rng.random() < p_mem}
    return rel, R, C


if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    trials = int(sys.argv[2]) if len(sys.argv) > 2 else 2000
    rng = random.Random(int(sys.argv[3]) if len(sys.argv) > 3 else 1)
    stats = dict(inst=0, bound_fail=0, tight=0, star_fail=0, nondistinct=0, naive_fail=0, kpos=0)
    worst = None
    for _ in range(trials):
        rel, R, C = random_instance(n, rng, rng.uniform(0.2, 0.7), rng.uniform(0.2, 0.7))
        a = analyse(rel, R, C)
        if a is None:
            continue
        stats['inst'] += 1
        stats['bound_fail'] += a['nu'] > a['Z'] + a['H']
        stats['tight'] += a['nu'] == a['Z'] + a['H']
        stats['star_fail'] += a['k'] + a['both'] > a['H']
        stats['nondistinct'] += not a['distinct']
        stats['naive_fail'] += a['naive'] > a['H'] + a['Z']
        stats['kpos'] += a['k'] > 0
        if not a['distinct'] and (worst is None or len(a['corners']) < len(worst[1]['corners'])):
            worst = ((rel, R, C), a)
    print(n, stats)
    if worst:
        (rel, R, C), a = worst
        print("smallest non-distinct example:")
        print(" rel", sorted(rel)); print(" R", sorted(R)); print(" C", sorted(C))
        print(" ", {kk: v for kk, v in a.items() if kk != 'corners'}, "corners", a['corners'])
