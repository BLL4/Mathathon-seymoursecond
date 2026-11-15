"""Check two identities behind the 'move and repair' reading of the step:
  (a) |R| + |C| - d  ==  |F1P| + |F2Q| + |X|^2 - |F1^2P| - |F2^2Q|
      (the formal value of the moved pair (F1P, F2Q)), and
  (b) val(P',Q') >= that, i.e. expansion(P') + expansion(Q') <= expansion(F1P) + expansion(F2Q),
      where expansion_1(S) = |F1 S| - |S|.
Also: how often is F1P a subset of R (never guaranteed)?"""
import sys, random, itertools
sys.path.insert(0, '../animation')
from engine import F1, F2, step, oriented_graphs, unc, val

rng = random.Random(5)
tot = subset = 0
for n in (4, 5):
    graphs = list(oriented_graphs(n))
    rng.shuffle(graphs)
    for rel in graphs[:150]:
        D = {(v, v) for v in range(n)}
        for _ in range(6):
            P = D | {(i, j) for i in range(n) for j in range(n) if rng.random() < 0.25}
            Q = D | {(i, j) for i in range(n) for j in range(n) if rng.random() < 0.25}
            if F1(rel, P) & F2(rel, Q): continue
            S = step(rel, n, P, Q)
            if sum(1 for r in S['R'] for c in S['C']) > 0 and len(S['conf']) > 14: continue
            n2 = n * n
            moved = len(S['F1P']) + len(S['F2Q']) + n2 - len(S['F1sqP']) - len(S['F2sqQ'])
            assert len(S['R']) + len(S['C']) - S['d'] == moved
            assert S['val2'] >= moved, (S['val2'], moved)
            assert moved - S['val'] == -(sum(S['kappa_cols']) + sum(S['kappa_rows']))
            tot += 1
            subset += S['F1P'] <= S['R']
print("pairs checked", tot, "; (a),(b) hold in all;  F1P subset of R in", subset)
