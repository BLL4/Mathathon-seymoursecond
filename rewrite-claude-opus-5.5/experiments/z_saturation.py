"""Observation test: is there always a maximum matching M of Gamma with
      nu(Gamma) <= |H| + #{z in Z : at least one copy of z is matched by M} ?
(For such an M the bound nu <= |Z| + |H| is witnessed 'locally', since
 nu = k + |Z_a u Z_b| + |Z_a n Z_b| and the statement is k + |Z_a n Z_b| <= |H|.)
Brute force over all maximum matchings for instances with small Gamma."""
import random
from matching_bound import gamma, random_instance
from star_bruteforce import all_max_matchings, local_ok

rng = random.Random(11)
tot = fail = 0
for n in (3, 4, 5):
    for _ in range(4000):
        rel, R, C = random_instance(n, rng, rng.uniform(0.15, 0.7), rng.uniform(0.15, 0.6))
        conf, Z, H, G = gamma(rel, R, C)
        if not conf or G.number_of_edges() > 18:
            continue
        tot += 1
        Ms = all_max_matchings(G)
        if not any(local_ok(M, H)[0] for M in Ms):
            fail += 1
            print("counterexample:", sorted(rel), sorted(R), sorted(C), "nu", len(Ms[0]), "Z", len(Z), "H", len(H))
            if fail >= 3: break
    if fail >= 3: break
print("instances", tot, "failures", fail)
