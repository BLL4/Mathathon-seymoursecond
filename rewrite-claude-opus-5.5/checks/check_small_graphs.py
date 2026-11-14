"""Exhaustive checks on all labelled oriented graphs with at most N vertices.

For every oriented graph (each pair of vertices: no arc, x->y, or y->x):
  * Theorem 1.1: some vertex v has |N1+(v)| <= |N2+(v)|;
  * Proposition 5.1 (finite instances): if every vertex has an in-neighbour,
    then some nonempty proper U violates |U| + |F^2 U| < 2|F U|.
Also reports how often the minimum (|N2+| - |N1+|) equals zero (tightness).

Bitmask implementation, standard library only.  Run: python3 -I check_small_graphs.py [N]
"""
import itertools
import sys


def check(n):
    pairs = list(itertools.combinations(range(n), 2))
    full = (1 << n) - 1
    counts = {"graphs": 0, "pos_indeg": 0, "tight": 0}
    for states in itertools.product((0, 1, 2), repeat=len(pairs)):
        out = [0] * n
        for (x, y), st in zip(pairs, states):
            if st == 1:
                out[x] |= 1 << y
            elif st == 2:
                out[y] |= 1 << x
        image = [0] * (1 << n)          # image[U] = F(U) as bitmask
        for U in range(1, 1 << n):
            low = U & -U
            image[U] = image[U ^ low] | out[low.bit_length() - 1]
        counts["graphs"] += 1
        best = None
        for v in range(n):
            n1 = out[v]
            n2 = image[n1] & ~n1 & ~(1 << v)
            diff = bin(n2).count("1") - bin(n1).count("1")
            best = diff if best is None else max(best, diff)
        assert best >= 0, ("Seymour fails", n, states)
        if best == 0:
            counts["tight"] += 1
        if image[full] == full:          # every vertex has an in-neighbour
            counts["pos_indeg"] += 1
            violated = any(
                bin(U).count("1") + bin(image[image[U]]).count("1") >= 2 * bin(image[U]).count("1")
                for U in range(1, full))
            assert violated, ("strictly concave graph found", n, states)
    return counts


def main():
    N = int(sys.argv[1]) if len(sys.argv) > 1 else 5
    for n in range(1, N + 1):
        c = check(n)
        print(f"n={n}: {c['graphs']} oriented graphs OK; {c['pos_indeg']} with positive "
              f"indegrees, none strictly concave; best vertex tight (|N1|=|N2|) in {c['tight']}")


if __name__ == "__main__":
    main()
