"""For instances where the local count k + |Z_a n Z_b| <= |H| fails for the
matching networkx picked, enumerate ALL maximum matchings of Gamma and ask
whether SOME maximum matching satisfies it (any matching, and among those
with the fewest conflict edges)."""
import random, itertools
import networkx as nx
from matching_bound import gamma, random_instance, analyse

def all_max_matchings(G):
    edges = list(G.edges)
    best, out = 0, []
    def rec(idx, used, cur):
        nonlocal best, out
        if idx == len(edges):
            if len(cur) > best: best, out = len(cur), [list(cur)]
            elif len(cur) == best: out.append(list(cur))
            return
        u, v = edges[idx]
        if u not in used and v not in used:
            used.add(u); used.add(v); cur.append((u, v))
            rec(idx + 1, used, cur)
            cur.pop(); used.discard(u); used.discard(v)
        rec(idx + 1, used, cur)
    rec(0, set(), [])
    return out

def local_ok(M, H):
    k, Za, Zb = 0, set(), set()
    for a, b in M:
        kinds = {a[0], b[0]}
        if kinds == {'r', 'c'}: k += 1
        elif 'zR' in kinds: Za.add(a[1] if a[0] == 'zR' else b[1])
        else: Zb.add(a[1] if a[0] == 'zL' else b[1])
    return k + len(Za & Zb) <= len(H), k

rng = random.Random(7)
checked = rescued = 0
for n in (3, 4):
    for _ in range(3000):
        rel, R, C = random_instance(n, rng, rng.uniform(0.2, 0.7), rng.uniform(0.2, 0.7))
        a = analyse(rel, R, C)
        if a is None or a['k'] + a['both'] <= a['H']: continue
        conf, Z, H, G = gamma(rel, R, C)
        if G.number_of_edges() > 22: continue
        checked += 1
        Ms = all_max_matchings(G)
        kmin = min(local_ok(M, H)[1] for M in Ms)
        some = any(local_ok(M, H)[0] for M in Ms)
        some_min = any(local_ok(M, H)[0] for M in Ms if local_ok(M, H)[1] == kmin)
        rescued += some
        if not some:
            print("NO maximum matching satisfies the local count:", sorted(rel), sorted(R), sorted(C),
                  {k2: v for k2, v in a.items() if k2 != 'corners'}, "max matchings:", len(Ms))
        elif not some_min:
            print("rescued only by a matching with MORE conflict edges")
print("checked", checked, "rescued", rescued)
