#!/usr/bin/env python3
"""Exhaustive check of Theorem 1.1 and of Proposition 4.1 on all oriented graphs
with n <= 5 vertices (59,049 at n = 5), by bitmask, in a few seconds.

Adopted after a review of my rewrite noted that my previous exhaustive range
(n <= 4) was smaller than what is cheap.  Independent code, written from scratch
here, so it also cross-checks the sibling rewrites' counts.
"""
from itertools import combinations

def main():
    tot = 0
    concave = 0
    posindeg = 0
    for n in range(1, 6):
        pairs = list(combinations(range(n), 2))
        nbr_out = [[0] * n for _ in range(3 ** len(pairs))]
        for mask in range(3 ** len(pairs)):
            # decode: digit 0 = no arc, 1 = u->v, 2 = v->u
            out = [0] * n
            m = mask
            for (u, v) in pairs:
                d = m % 3
                m //= 3
                if d == 1:
                    out[u] |= 1 << v
                elif d == 2:
                    out[v] |= 1 << u
            nbr_out[mask] = out
            tot += 1
            img = [0] * (1 << n)
            for S in range(1 << n):
                acc = 0
                for x in range(n):
                    if S >> x & 1:
                        acc |= out[x]
                img[S] = acc
            # theorem: some v with |N1| <= |N2|
            ok = False
            for v in range(n):
                n1 = out[v]
                n2 = img[n1] & ~n1 & ~(1 << v)
                if bin(n1).count("1") <= bin(n2).count("1"):
                    ok = True
                    break
            if not ok:
                raise SystemExit(f"THEOREM FAILS: n={n} mask={mask}")
            # positive indegrees
            indeg_ok = all(any((out[u] >> v) & 1 for u in range(n)) for v in range(n))
            if indeg_ok:
                posindeg += 1
                # strict concavity for every nonempty proper U?
                strict = True
                for U in range(1, (1 << n) - 1):
                    if bin(U).count("1") + bin(img[img[U]]).count("1") >= 2 * bin(img[U]).count("1"):
                        strict = False
                        break
                if strict:
                    concave += 1
                    raise SystemExit(f"PROP 4.1 FAILS: n={n} mask={mask}")
    print(f"oriented graphs with n <= 5 checked: {tot}")
    print(f"  graphs with positive indegrees:    {posindeg}")
    print(f"  of those, strictly concave:        {concave}   (Proposition 4.1 predicts 0)")
    print("OK")

if __name__ == "__main__":
    main()
