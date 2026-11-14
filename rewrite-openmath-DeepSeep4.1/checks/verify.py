#!/usr/bin/env python3
"""
Computational checks for "A proof of Seymour's second-neighborhood conjecture".

Each check tests an *identity* or an *implication* that the paper uses, on small
instances: the point is to catch sign errors, wrong index sets and off-by-one
bounds in the write-up.  Statements whose hypothesis is (conjecturally)
unsatisfiable cannot be tested directly; their internal steps can.

Run:  python3 verify.py
"""
import itertools, random, sys
from itertools import combinations, product

FAIL = []
def check(name, cond, detail=""):
    if not cond:
        FAIL.append((name, detail))
        print(f"  FAIL  {name}  {detail}")

def done(name):
    print(f"  ok    {name}")

# ---------------------------------------------------------------- basic digraph
class G:
    """finite oriented graph on range(n): arc set as a set of ordered pairs"""
    def __init__(self, n, arcs):
        self.n = n
        self.arcs = frozenset(arcs)
        assert all(u != v for u, v in self.arcs)
        assert all((v, u) not in self.arcs for u, v in self.arcs)
    def F(self, S):
        return frozenset(w for (u, w) in self.arcs if u in S)
    def F2(self, S):
        return self.F(self.F(S))
    def N1(self, v):
        return frozenset(w for (u, w) in self.arcs if u == v)
    def N2(self, v):
        return self.F2({v}) - self.N1(v) - {v}
    def indeg(self, v):
        return sum(1 for (u, w) in self.arcs if w == v)
    def outdeg(self, v):
        return len(self.N1(v))
    def subsets(self):
        for r in range(self.n + 1):
            for S in combinations(range(self.n), r):
                yield frozenset(S)
    def indeg1(self, v):  # in-neighbours
        return frozenset(u for (u, w) in self.arcs if w == v)

def rand_ograph(n, p, rng):
    arcs = []
    for u, v in combinations(range(n), 2):
        r = rng.random()
        if r < p / 2:
            arcs.append((u, v))
        elif r < p:
            arcs.append((v, u))
    return G(n, arcs)

def all_oriented_graphs(n):
    pairs = list(combinations(range(n), 2))
    for choice in product((0, 1, 2), repeat=len(pairs)):
        arcs = []
        for (u, v), c in zip(pairs, choice):
            if c == 1: arcs.append((u, v))
            elif c == 2: arcs.append((v, u))
        yield G(n, arcs)

# ================================================================ CHECK 1: theorem holds on small graphs
def check_main_theorem():
    print("[1] main theorem: every nonempty oriented graph has v with |N1(v)| <= |N2(v)|")
    tot = 0
    for n in range(1, 5):
        for g in all_oriented_graphs(n):
            tot += 1
            best = [v for v in range(n) if g.outdeg(v) <= len(g.N2(v))]
            check(f"thm n={n} {sorted(g.arcs)}", bool(best))
    done(f"exhaustive n<=4  ({tot} graphs)")
    rng = random.Random(7)
    for t in range(20000):
        n = rng.randint(5, 9)
        g = rand_ograph(n, rng.choice([0.2, 0.4, 0.7, 1.0]), rng)
        if not any(g.outdeg(v) <= len(g.N2(v)) for v in range(n)):
            check("thm random", False, f"n={n} {sorted(g.arcs)}")
    done("20000 random graphs with 5<=n<=9")

# ================================================================ CHECK 2: Lemma 2.2 ledger
def check_subset_deficit_ledger():
    print("[2] Lemma 2.2 (subset deficit): the gain/loss ledger")
    rng = random.Random(11)
    tested = 0
    hits = [0]
    for trial in range(4000):
        n = rng.randint(2, 7)
        g = rand_ograph(n, rng.choice([0.3, 0.5, 0.8]), rng)
        V = frozenset(range(n))
        # require strong connectivity for E != empty, and pick S proper nonempty
        if len(V) < 3: continue
        S = frozenset(rng.sample(sorted(V), rng.randint(1, n - 1)))
        FS = g.F(S)
        I = FS & S
        E = FS - S
        if not E: continue
        Y = frozenset(rng.sample(sorted(E), rng.randint(0, len(E))))
        deleted = frozenset((u, w) for (u, w) in g.arcs if u in S and w in (E - Y))
        gY = G(n, g.arcs - deleted)
        def gfun(T):
            return len(g.F(T) - (I | T))
        # (a) second image after deletion lies in I u Y u F(Y), for every v in S
        for v in S:
            check("(2.4) F2_{D_Y}(v) <= I u Y u F(Y)", gY.F2({v}) <= (I | Y | g.F(Y)),
                  f"n={n} S={sorted(S)} Y={sorted(Y)} v={v}")
        # (b) newly counted second out-neighbours are in Q cap F(Y)
        for v in S:
            Q = g.N1(v) & (E - Y)
            new = gY.N2(v) - g.N2(v)
            check("new second out-neighbours <= Q cap F(Y)", new <= Q & g.F(Y),
                  f"n={n} S={sorted(S)} Y={sorted(Y)} v={v} new={sorted(new)}")
        # (c) Lambda is inside N2_D(v) and disjoint from N2_{D_Y}(v)
        for v in S:
            Q = g.N1(v) & (E - Y)
            Lam = g.F(Q) - (I | Y | Q | g.F(Y))
            check("Lambda <= N2_D(v)", Lam <= g.N2(v), f"v={v}")
            check("Lambda cap N2_{D_Y}(v) = empty", not (Lam & gY.N2(v)), f"v={v}")
        # (d) exact change of g
        for v in S:
            Q = g.N1(v) & (E - Y)
            Lam = g.F(Q) - (I | Y | Q | g.F(Y))
            lhs = gfun(Y | Q) - gfun(Y)
            rhs = len(Lam) - len(Q & g.F(Y))
            check("g(Y u Q) - g(Y) = |Lambda| - |Q cap F(Y)|", lhs == rhs,
                  f"n={n} S={sorted(S)} Y={sorted(Y)} v={v}: {lhs} vs {rhs}")
        # (e) sandwich, conditional on v satisfying the inequality in D_Y
        for v in S:
            Q = g.N1(v) & (E - Y)
            Lam = g.F(Q) - (I | Y | Q | g.F(Y))
            d1, d2 = len(g.N1(v)), len(g.N2(v))
            n2Y = len(gY.N2(v))
            check("upper: |N2_{D_Y}(v)| <= d2 - |Lambda| + |Q cap F(Y)|",
                  n2Y <= d2 - len(Lam) + len(Q & g.F(Y)), f"v={v}")
            if gY.outdeg(v) <= n2Y:
                check("lower (given the D_Y inequality): d1 - |Q| <= |N2_{D_Y}(v)|",
                      d1 - len(Q) <= n2Y, f"v={v}")
                # the strict increment needs the counterexample hypothesis d2 < d1 at v
                if d2 < d1:
                    check("increment <= |Q| + d2 - d1 < |Q|",
                          len(Lam) - len(Q & g.F(Y)) <= len(Q) + d2 - d1 < len(Q), f"v={v}")
                    hits[0] += 1
        tested += 1
    done(f"ledger over {tested} random (D,S,Y) configurations; "
         f"strict-increment step exercised {hits[0]} times")

# ================================================================ CHECK 3: Lemma 2.3 blowup algebra
def check_blowup():
    print("[3] Lemma 2.3 (transitive-tournament blowup): the algebraic bound")
    rng = random.Random(23)
    tested = 0
    for trial in range(300):
        n = rng.randint(2, 4)
        g = rand_ograph(n, 0.8, rng)
        for m in (n + 1, n + 2):
            # build G = D[T_m]: vertex (v,lab) gets index v*m + lab, lab in 0..m-1
            def vid(v, l): return v * m + l
            verts = [(v, l) for v in range(n) for l in range(m)]
            arcs = []
            for (v, a), (w, b) in combinations(verts, 2):
                if v == w:
                    arcs.append((vid(v, a), vid(w, b)) if a < b else (vid(w, b), vid(v, a)))
                else:
                    if (v, w) in g.arcs: arcs.append((vid(v, a), vid(w, b)))
                    elif (w, v) in g.arcs: arcs.append((vid(w, b), vid(v, a)))
            GB = G(n * m, arcs)
            # block-internal tau
            def tau(T):
                if not T: return frozenset()
                a = min(T); return frozenset(l for l in range(a + 1, m))
            # all nonempty proper U, but cap the enumeration
            nv = len(verts)
            Us = []
            if nv <= 10:
                Us = [frozenset(S) for S in g.subsets() if S and len(S) < nv]
            else:
                for _ in range(60):
                    U = frozenset(rng.sample(range(nv), rng.randint(1, nv - 1)))
                    Us.append(U)
            for U in Us:
                Uv = {verts[i] for i in U}
                T = {v: frozenset(l for (w, l) in Uv if w == v) for v in range(n)}
                assert sum(len(T[v]) for v in T) == len(U)
                S = frozenset(v for v in range(n) if T[v])
                W = g.F(S) | g.F2(S)
                # exact |F_G(U)| formula
                pred = m * len(g.F(S)) + sum(len(tau(T[v])) for v in S - g.F(S))
                check("|F_G(U)| exact formula", len(GB.F(U)) == pred,
                      f"n={n} m={m} U={sorted(U)}")
                check("|F_G^2(U)| <= m|W| + sum tau^2",
                      len(GB.F2(U)) <= m * len(W) + sum(len(tau(tau(T[v]))) for v in S - W),
                      f"n={n} m={m} U={sorted(U)}")
                lhs = len(U) - 2 * len(GB.F(U)) + len(GB.F2(U))
                bound = m * (len(g.F2(S) - g.F(S)) - len(g.F(S) - S)) + len(S - g.F(S))
                check("|U| - 2|F_G U| + |F_G^2 U| <= m(deficit) + n-version", lhs <= bound,
                      f"n={n} m={m} U={sorted(U)}: {lhs} vs {bound}")
                # internal block bounds
                for v in S:
                    Tv = T[v]; a = min(Tv)
                    check("|Tv| - |tau(Tv)| <= 1", len(Tv) - len(tau(Tv)) <= 1)
                    check("tau^2(Tv) <= tau(Tv)", tau(tau(Tv)) <= tau(Tv))
                    check("|Tv| - 2|tau| + |tau^2| <= 1",
                          len(Tv) - 2 * len(tau(Tv)) + len(tau(tau(Tv))) <= 1)
                tested += 1
    done(f"blowup algebra over {tested} (D,m,U) instances")

# ================================================================ CHECK 4: Section 4 machinery
def check_section4():
    print("[4] Section 4: pair families, coordinate images, compatibility, complements")
    rng = random.Random(31)
    tested = 0
    for trial in range(1500):
        n = rng.randint(2, 5)
        p = rng.choice([0.4, 0.7, 1.0])
        g = rand_ograph(n, p, rng)
        if any(g.indeg(v) == 0 for v in range(n)):   # Section 4 needs positive indegree
            continue
        X = range(n)
        cells = list(product(X, X))
        d1 = lambda S: frozenset((i, j) for (pp, j) in S for i in X if (pp, i) in g.arcs)
        d2 = lambda S: frozenset((i, j) for (i, s) in S for j in X if (s, j) in g.arcs)
        # random compatible pair containing the diagonal
        Delta = frozenset((v, v) for v in X)
        P, Q = set(Delta), set(Delta)
        order = cells[:]
        rng.shuffle(order)
        for c in order:
            if rng.random() < 0.5: continue
            if c in P or c in Q: continue
            for side in (0, 1):
                P2 = frozenset(P | {c}) if side == 0 else P
                Q2 = frozenset(Q | {c}) if side == 1 else Q
                if not (d1(P2) & d2(Q2)):
                    P, Q = set(P2), set(Q2)
                    break
        P, Q = frozenset(P), frozenset(Q)
        if d1(P) & d2(Q):
            continue                     # keep only compatible ones
        tested += 1
        # identity: sum over columns of the vertex-set image
        check("|P| = sum_j |P_j|", len(P) == sum(len([pp for (pp, jj) in P if jj == j]) for j in X))
        check("|Phi1 P| = sum_j |F(P_j)|",
              len(d1(P)) == sum(len(g.F({pp for (pp, jj) in P if jj == j})) for j in X))
        check("Phi1^2 P = fibrewise F^2", d1(d1(P)) == frozenset((i, j) for j in X
              for i in g.F2({pp for (pp, jj) in P if jj == j})))
        # columns proper, rows proper
        for j in X:
            Pj = {pp for (pp, jj) in P if jj == j}
            check("column nonempty", Pj)
            check("column proper", Pj != set(X), f"n={n} j={j}")
        for i in X:
            Qi = {s for (ii, s) in Q if ii == i}
            check("row nonempty", Qi)
            check("row proper", Qi != set(X), f"n={n} i={i}")
        # diagonal compatible with itself
        check("Delta compatible with Delta", not (d1(Delta) & d2(Delta)))
        # complements
        L = frozenset(cells) - d2(d2(Q))
        R = frozenset(cells) - d1(d1(P))
        check("|L|+|R| = 2n^2 - |Phi2^2 Q| - |Phi1^2 P|",
              len(L) + len(R) == 2 * n * n - len(d2(d2(Q))) - len(d1(d1(P))))
        check("Delta <= L", Delta <= L)
        check("Delta <= R", Delta <= R)
        # diagonals are conflict free in the new families
        for (pp, j) in L:
            if pp == j:
                for (i, s) in R:
                    check("no conflict left-diagonal", not ((pp, i) in g.arcs and (s, j) in g.arcs))
        for (i, s) in R:
            if i == s:
                for (pp, j) in L:
                    check("no conflict right-diagonal", not ((pp, i) in g.arcs and (s, j) in g.arcs))
        # H inside the uncovered set
        uncovered = frozenset(cells) - d1(P) - d2(Q)
        H = set()
        for (pp, j) in L:
            for (i, s) in R:
                if (pp, i) in g.arcs and (s, j) in g.arcs:
                    H.add((pp, s))
        check("H <= uncovered", H <= uncovered, f"n={n} H={sorted(H)} unc={sorted(uncovered)}")
        u = n * n - len(d1(P)) - len(d2(Q))
        check("u = n^2 - |Phi1 P| - |Phi2 Q|", u == len(uncovered))
    done(f"section-4 identities over {tested} compatible pairs")

# ================================================================ CHECK 5: pruning lemma statement
def check_pruning_statement():
    print("[5] Lemma 3.1 (pruning): statement, brute force on tiny instances")
    rng = random.Random(41)
    inst = 0
    for trial in range(1200):
        n = rng.randint(2, 4)
        X = list(range(n))
        rel = {(u, v) for u in X for v in X if u != v and rng.random() < 0.5}
        def rnd_fam(maxs):
            k = rng.randint(0, maxs)
            return [tuple(rng.choice(list(product(X, X)))) for _ in range(k)]
        Lf = list(dict.fromkeys(rnd_fam(5)))
        Rf = list(dict.fromkeys(rnd_fam(5)))
        # conflict matrix
        conf = [[(p, i) in rel and (s, j) in rel for (i, s) in Rf] for (p, j) in Lf]
        cL = all(not any(conf[a]) for a in range(len(Lf)))   # conflict-free member flags
        cR = all(not any(conf[a][b] for a in range(len(Lf))) for b in range(len(Rf)))
        freeL = [a for a in range(len(Lf)) if not any(conf[a])]
        freeR = [b for b in range(len(Rf)) if not any(conf[a][b] for a in range(len(Lf)))]
        Z = {(i, j) for (p, j) in Lf for (i, s) in Rf if (p, i) in rel and (s, j) in rel}
        H = {(p, s) for (p, j) in Lf for (i, s) in Rf if (p, i) in rel and (s, j) in rel}
        # brute force over subfamilies
        ok = False
        for mL in range(1 << len(Lf)):
            Lsel = [a for a in range(len(Lf)) if mL >> a & 1]
            if any(a not in Lsel for a in freeL): continue
            forb = {b for b in range(len(Rf)) if any(conf[a][b] for a in Lsel)}
            for mR in range(1 << len(Rf)):
                Rsel = [b for b in range(len(Rf)) if mR >> b & 1]
                if any(b not in Rsel for b in freeR): continue
                if forb & set(Rsel): continue
                # count uncovered points of Z
                unc = 0
                for (i, j) in Z:
                    covL = any(Lf[a][1] == j and (Lf[a][0], i) in rel for a in Lsel)
                    covR = any(Rf[b][0] == i and (Rf[b][1], j) in rel for b in Rsel)
                    if not (covL or covR): unc += 1
                bound = len(H) + unc
                if len(Lf) - len(Lsel) + len(Rf) - len(Rsel) <= bound:
                    ok = True
                    break
            if ok: break
        inst += 1
        check("pruning conclusion holds", ok,
              f"n={n} rel={sorted(rel)} L={Lf} R={Rf}")
    done(f"pruning statement over {inst} random instances")

# ================================================================ CHECK 6: consequences
def check_consequences():
    print("[6] Corollary 6.1: no directed 3-cycle, minimum degree, girth")
    rng = random.Random(53)
    cnt = 0
    for n in range(2, 7):
        for g in all_oriented_graphs(n) if n <= 5 else [rand_ograph(n, 0.4, rng) for _ in range(4000)]:
            # no directed triangle ?
            tri = any((a, b) in g.arcs and (b, c) in g.arcs and (c, a) in g.arcs
                      for a, b, c in permutations(range(n), 3))
            if not tri:
                cnt += 1
                ok = any(g.outdeg(v) <= g.n - 1 - g.outdeg(v) - len(g.indeg1(v))
                         and len(g.N2(v)) <= g.n - 1 - g.outdeg(v) - len(g.indeg1(v))
                         for v in range(n))
                check("6.1(i) some v: d+ <= |Z(v)|", ok, f"n={n} {sorted(g.arcs)}")
                # the count n-1 = d+ + d- + |Z|
                for v in range(n):
                    Zv = set(range(g.n)) - {v} - g.N1(v) - g.indeg1(v)
                    check("n-1 = d+ + d- + |Z|",
                          g.n - 1 == g.outdeg(v) + len(g.indeg1(v)) + len(Zv))
                # 6.1(ii)
                dplus = min(g.outdeg(v) for v in range(n))
                dminus = min(len(g.indeg1(v)) for v in range(n))
                if not (dplus >= n / 3 and dminus >= n / 3):
                    pass  # no contradiction expected
            else:
                pass
    done(f"3-cycle-free checks over {cnt} graphs")
    # 6.1(ii) contrapositive: if no 3-cycle then not both degrees >= n/3
    for n in range(3, 8):
        for _ in range(3000):
            g = rand_ograph(n, 0.5, rng)
            tri = any((a, b) in g.arcs and (b, c) in g.arcs and (c, a) in g.arcs
                      for a, b, c in permutations(range(n), 3))
            dp = min(g.outdeg(v) for v in range(n))
            dm = min(len(g.indeg1(v)) for v in range(n))
            if not tri and dp >= n / 3 and dm >= n / 3:
                check("6.1(ii) no 3-cycle => not both >= n/3", False, f"n={n} {sorted(g.arcs)}")
    done("6.1(ii) contrapositive, random")
    # 6.1(iii): regular, girth exactly 4 => n >= 3r+1.  Search small regular oriented graphs.
    found = []
    for n in range(4, 10):
        for r in range(1, (n - 1) // 2 + 1):
            for _ in range(4000):
                g = rand_ograph(n, min(1.0, 2.0 * r / (n - 1)) if n > 1 else 0, rng)
                if any(g.outdeg(v) != r or len(g.indeg1(v)) != r for v in range(n)):
                    continue
                if any((a, b) in g.arcs and (b, c) in g.arcs and (c, a) in g.arcs
                       for a, b, c in permutations(range(n), 3)):
                    continue
                # girth exactly 4: a directed 4-cycle exists
                has4 = any(len({(a, b), (b, c), (c, d), (d, a)}) == 4 and
                           all(x in g.arcs for x in [(a, b), (b, c), (c, d), (d, a)])
                           for a, b, c, d in permutations(range(n), 4))
                if has4:
                    found.append((n, r))
                    check("6.1(iii) n >= 3r+1", n >= 3 * r + 1, f"n={n} r={r}")
    done(f"6.1(iii) on {len(found)} regular girth-4 examples {sorted(set(found))}")

# ================================================================ report helpers
def permutations(iterable, r=None):
    return itertools.permutations(iterable, r)

if __name__ == "__main__":
    print("=" * 78)
    print("computational checks")
    print("=" * 78)
    check_main_theorem()
    check_subset_deficit_ledger()
    check_blowup()
    check_section4()
    check_pruning_statement()
    check_consequences()
    print("=" * 78)
    if FAIL:
        print(f"{len(FAIL)} FAILURES")
        for name, detail in FAIL[:40]:
            print(" -", name, detail)
        sys.exit(1)
    print("all checks passed")
