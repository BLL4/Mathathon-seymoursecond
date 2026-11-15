"""'Deleting less is necessary': an application instance where the naive
pruning (delete every member in a conflict) costs about n^2 while the budget
|H| + |Z| is about 2n, so a one-member pruning is forced.

X = A u J u {i0, s0}; arcs J -> A -> i0 -> s0 -> J (all arcs between
consecutive blocks).  Pair (Delta, Delta)."""
import sys
sys.path.insert(0, '../animation')
from engine import F1, F2, conflicts, unc, val, step

m = int(sys.argv[1]) if len(sys.argv) > 1 else 3
A = list(range(0, m)); J = list(range(m, 2 * m)); i0, s0 = 2 * m, 2 * m + 1
n = 2 * m + 2
rel = {(j, p) for j in J for p in A} | {(p, i0) for p in A} | {(i0, s0)} | {(s0, j) for j in J}
assert all(any(y == v for (_, y) in rel) for v in range(n))
assert not any((b, a) in rel for (a, b) in rel)
D = {(v, v) for v in range(n)}
X2 = {(i, j) for i in range(n) for j in range(n)}
R = X2 - F2(rel, F2(rel, D)); C = X2 - F1(rel, F1(rel, D))
conf = conflicts(rel, R, C)
Z = {(c[0], r[1]) for r, c in conf}; H = {(r[0], c[1]) for r, c in conf}
Rc = {r for r, _ in conf}; Cc = {c for _, c in conf}
d = unc(rel, n, D, D)
print(f"n={n}  val(D,D)={val(rel,n,D,D)}  |R|+|C|={len(R)+len(C)}  mu+2d={2*n+2*d}")
print(f"conflicts {len(conf)}  |Z|={len(Z)}  |H|={len(H)}  budget |H|+|Z|={len(H)+len(Z)}")
print(f"members in conflict: |R_conf|={len(Rc)} |C_conf|={len(Cc)}  naive cost {len(Rc)+len(Cc)}")
print("R_conf", sorted(Rc)); print("C_conf", sorted(Cc))
# the pruning that deletes only C_conf
R2, C2 = R, C - Cc
assert not conflicts(rel, R2, C2)
cov = F1(rel, R2) | F2(rel, C2)
print(f"delete C_conf only: cost {len(Cc)} <= |H| + uncovered Z = {len(H)} + {len(Z - cov)}")
print(f"val(R, C - C_conf) = {val(rel, n, R2, C2)}  vs val(D,D) = {val(rel,n,D,D)}")
print("H uncovered by (D,D)?", not (H & (F1(rel, D) | F2(rel, D))))
