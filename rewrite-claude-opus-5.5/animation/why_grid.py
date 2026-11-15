"""Prologue to ImprovementStep: why the proof moves to pairs and to a grid.

Render (from this folder):
    .venv/bin/manim -qh why_grid.py WhyGrid

Story (Section 3.1 of the paper, slide 9 of the talk):
  1. (G1)+(G2) alone are not contradictory: the complete digraph with all
     opposite arcs satisfies both.  So the proof must use "no opposite arcs".
  2. That is a statement about pairs: F1(Delta) = A^T and F2(Delta) = A meet
     exactly at opposite arcs (a conflict).
  3. Concavity lifts to the grid line by line.
  4. A fixed board: compatible images are disjoint, so the value is
     |X|^2 minus the expansion of the two families.
"""
import itertools

from manim import *

from engine import F, F1, F2, kappa

config.background_color = WHITE
_tpl = TexTemplate()
_tpl.add_to_preamble(r"\usepackage{xcolor}")
config.tex_template = _tpl
for cls in (Tex, MathTex, Text):
    cls.set_default(color=BLACK)

BLUE_L = ManimColor("#1f77b4")
ORANGE_R = ManimColor("#d6601a")
GREEN_Z = ManimColor("#2c8c3c")
GREY_U = ManimColor("#9a9a9a")

N = 3
DELTA = {(v, v) for v in range(N)}
ALL = {(i, j) for i in range(N) for j in range(N)}
REL_CYCLE = {(0, 1), (1, 0), (1, 2), (2, 0)}     # 1<->2, 2->3, 3->1
REL_ORIENTED = {(0, 1), (1, 2), (2, 0)}          # 1->2->3->1

CS = 1.1
GRID_ORIGIN = np.array([-2.3, 1.2, 0])


def cell(i, j):
    return GRID_ORIGIN + np.array([j * CS, -i * CS, 0])


def lab(v):
    return str(v + 1)


def strictly_concave(rel, n):
    return all(kappa(rel, set(U)) < 0
               for k in range(1, n) for U in itertools.combinations(range(n), k))


class WhyGrid(Scene):
    def caption(self, text, old=None):
        new = Tex(text, font_size=28).to_edge(DOWN, buff=0.3)
        if new.width > 13:
            new.scale_to_fit_width(13)
        if old is not None:
            self.play(FadeOut(old), run_time=0.35)
        self.play(FadeIn(new), run_time=0.5)
        return new

    def graph(self, rel, pos, double=()):
        verts = VGroup(*[VGroup(Circle(radius=0.27, color=BLACK, stroke_width=2.5).move_to(pos[v]),
                                MathTex(lab(v), font_size=30).move_to(pos[v])) for v in pos])
        arcs = {}
        for a, b in sorted(rel):
            if (b, a) in rel:
                # draw the two opposite arcs side by side
                d = pos[b] - pos[a]
                nrm = np.array([-d[1], d[0], 0]) / np.linalg.norm(d) * 0.13
                arcs[(a, b)] = Arrow(pos[a] + nrm, pos[b] + nrm, buff=0.3, color=BLACK,
                                     stroke_width=3, max_tip_length_to_length_ratio=0.15)
            else:
                arcs[(a, b)] = Arrow(pos[a], pos[b], buff=0.3, color=BLACK, stroke_width=3,
                                     max_tip_length_to_length_ratio=0.15)
        return verts, arcs

    def hollow_l(self, i, j):
        return Circle(radius=0.22, color=BLUE_L, stroke_width=4).move_to(cell(i, j)).set_z_index(2)

    def hollow_r(self, i, j):
        return Square(side_length=0.36, color=ORANGE_R, stroke_width=4).move_to(cell(i, j)).set_z_index(2)

    def move_arrow(self, src, dst, color):
        a, b = cell(*src), cell(*dst)
        if np.linalg.norm(b - a) > CS * 1.5:
            ang = 0.9 if src[0] == dst[0] else -0.9
            return CurvedArrow(a, b, angle=ang, color=color, stroke_width=4, tip_length=0.2).set_z_index(3)
        return Arrow(a, b, buff=0.22, color=color, stroke_width=4,
                     max_tip_length_to_length_ratio=0.25).set_z_index(3)

    def construct(self):
        title = Tex(r"Why pairs? Why a grid?", font_size=40).to_corner(UL, buff=0.3)
        self.play(Write(title))

        # ------------------------------------------------ 1. K4 with all opposite arcs
        n4 = 4
        K4 = {(a, b) for a in range(n4) for b in range(n4) if a != b}
        assert strictly_concave(K4, n4)
        pos4 = {0: np.array([-4.5, 1.5, 0]), 1: np.array([-2.5, 1.5, 0]),
                2: np.array([-2.5, -0.5, 0]), 3: np.array([-4.5, -0.5, 0])}
        v4, a4 = self.graph(K4, pos4)
        cap = self.caption(r"What remains: no oriented $G$ with (G1) in-neighbours and "
                           r"(G2) $|U|+|F^2U|<2|FU|$ for all proper $U$.")
        self.play(Create(v4))
        self.play(LaggedStart(*[GrowArrow(a) for a in a4.values()], lag_ratio=0.05))
        lines = VGroup(
            Tex(r"Complete digraph, all opposite arcs:", font_size=30),
            MathTex(r"|U|=1:\quad 1+4<2\cdot 3", font_size=32),
            MathTex(r"|U|=2,3:\quad |U|+4<2\cdot 4", font_size=32),
            Tex(r"(G1) and (G2) both hold!", font_size=30, color=GREEN_Z),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.3).move_to(np.array([2.4, 0.6, 0]))
        cap = self.caption(r"Without orientation, (G1) and (G2) can both hold.", cap)
        for m in lines:
            self.play(FadeIn(m), run_time=0.6)
        self.wait(0.6)
        moral = Tex(r"So the proof \emph{must} use: no opposite arcs.\\"
                    r"And that is a statement about \textbf{pairs} $(i,j)$.",
                    font_size=32).move_to(np.array([2.4, -1.7, 0]))
        cap = self.caption(r"A single vertex set cannot tell $G$ apart from this digraph.", cap)
        self.play(Write(moral))
        self.wait(1.5)
        self.play(FadeOut(VGroup(v4, *a4.values(), lines, moral)))

        # ------------------------------------------------ 2. orientation in the grid
        pos = {0: np.array([-5.6, 1.5, 0]), 1: np.array([-6.3, 0.2, 0]), 2: np.array([-4.9, 0.2, 0])}
        verts, arcs = self.graph(REL_CYCLE, pos)
        gname = Tex(r"$G$", font_size=32).move_to(np.array([-5.6, 2.3, 0]))
        cap = self.caption(r"A digraph with one pair of opposite arcs, $1\rightleftarrows 2$.", cap)
        self.play(Create(verts), FadeIn(gname))
        self.play(LaggedStart(*[GrowArrow(a) for a in arcs.values()], lag_ratio=0.15))

        frame = VGroup(*[Square(side_length=CS, color=GREY_U, stroke_width=1).move_to(cell(i, j))
                         for i, j in sorted(ALL)])
        clabels = VGroup(*[MathTex(lab(j), font_size=28).move_to(cell(0, j) + UP * 0.8) for j in range(N)])
        rlabels = VGroup(*[MathTex(lab(i), font_size=28).move_to(cell(i, 0) + LEFT * 0.8) for i in range(N)])
        dmarks = VGroup(*[Dot(cell(v, v), radius=0.1, color=BLACK).set_z_index(4) for v in range(N)])
        cap = self.caption(r"The grid $X\times X$ (row $i$, column $j$) and its diagonal "
                           r"$\Delta=\{(v,v)\}$.", cap)
        self.play(Create(frame), FadeIn(clabels), FadeIn(rlabels))
        self.play(LaggedStart(*[FadeIn(d, scale=1.6) for d in dmarks], lag_ratio=0.2))

        # ledger on the right
        def led(tex, row, color=BLACK):
            return MathTex(tex, font_size=32, color=color).move_to(
                np.array([1.1, 2.0 - 0.65 * row, 0]), aligned_edge=LEFT)

        # F1 Delta: vertical moves (j,j) -> (i,j) for j -> i
        cap = self.caption(r"$F_1$ moves $(j,j)$ \emph{down its column} to $(i,j)$ when $j\to i$: "
                           r"{\color[HTML]{1f77b4}$F_1\Delta=A^{\mathsf T}$}.", cap)
        F1D = F1(REL_CYCLE, DELTA)
        circ = {p: self.hollow_l(*p) for p in sorted(F1D)}
        arrs1 = [self.move_arrow((j, j), (i, j), BLUE_L) for (i, j) in sorted(F1D)]
        self.play(LaggedStart(*[GrowArrow(a) if isinstance(a, Arrow) else Create(a) for a in arrs1],
                              lag_ratio=0.2))
        self.play(*[FadeIn(c, scale=1.4) for c in circ.values()])
        l1 = led(r"F_1\Delta=A^{\mathsf T}\ \text{(in-arcs)}", 0, BLUE_L)
        self.play(FadeIn(l1), FadeOut(VGroup(*arrs1)))

        cap = self.caption(r"$F_2$ moves $(i,i)$ \emph{along its row} to $(i,j)$ when $i\to j$: "
                           r"{\color[HTML]{d6601a}$F_2\Delta=A$}.", cap)
        F2D = F2(REL_CYCLE, DELTA)
        sq = {p: self.hollow_r(*p) for p in sorted(F2D)}
        arrs2 = [self.move_arrow((i, i), (i, j), ORANGE_R) for (i, j) in sorted(F2D)]
        self.play(LaggedStart(*[GrowArrow(a) if isinstance(a, Arrow) else Create(a) for a in arrs2],
                              lag_ratio=0.2))
        self.play(*[FadeIn(s, scale=1.4) for s in sq.values()])
        l2 = led(r"F_2\Delta=A\ \text{(out-arcs)}", 1, ORANGE_R)
        self.play(FadeIn(l2), FadeOut(VGroup(*arrs2)))

        # the overlap = conflict
        both = sorted(F1D & F2D)
        assert both == [(0, 1), (1, 0)]
        dia = VGroup(*[Square(side_length=0.22, color=GREEN_Z, fill_opacity=1).rotate(PI / 4)
                       .move_to(cell(i, j)).set_z_index(5) for i, j in both])
        cap = self.caption(r"$(1,1)$ moves down and $(2,2)$ moves left: both reach $(2,1)$. "
                           r"Opposite arcs $=$ a point covered twice: a \emph{conflict}.", cap)
        down = self.move_arrow((0, 0), (1, 0), BLUE_L)
        left = self.move_arrow((1, 1), (1, 0), ORANGE_R)
        self.play(GrowArrow(down), GrowArrow(left))
        self.play(FadeIn(dia, scale=2), Indicate(arcs[(0, 1)], color=GREEN_Z),
                  Indicate(arcs[(1, 0)], color=GREEN_Z))
        l3 = led(r"F_1\Delta\cap F_2\Delta=\{(1,2),(2,1)\}", 2, GREEN_Z)
        self.play(FadeIn(l3))
        self.wait(1)

        # remove the arc 2 -> 1: oriented triangle
        cap = self.caption(r"Delete the arc $2\to1$. Now $G$ is oriented, and the two images "
                           r"no longer meet.", cap)
        F1o, F2o = F1(REL_ORIENTED, DELTA), F2(REL_ORIENTED, DELTA)
        gone = [circ[p] for p in circ if p not in F1o] + [sq[p] for p in sq if p not in F2o]
        new_arc = Arrow(pos[0], pos[1], buff=0.3, color=BLACK, stroke_width=3,
                        max_tip_length_to_length_ratio=0.15)
        self.play(FadeOut(arcs[(1, 0)]), Transform(arcs[(0, 1)], new_arc),
                  FadeOut(VGroup(*gone)), FadeOut(dia), FadeOut(down), FadeOut(left))
        assert not (F1o & F2o)
        l3b = led(r"F_1\Delta\cap F_2\Delta=\varnothing", 2, GREEN_Z)
        self.play(Transform(l3, l3b))
        key = Tex(r"oriented $\iff$ $F_1\Delta\cap F_2\Delta=\varnothing$", font_size=34)
        key.move_to(np.array([1.1, 0.1, 0]), aligned_edge=LEFT)
        box = SurroundingRectangle(key, color=GREEN_Z, buff=0.15)
        self.play(Write(key), Create(box))
        self.wait(1.2)
        cap = self.caption(r"Two families, two directions: compatibility $F_1P\cap F_2Q=\varnothing$ "
                           r"generalizes orientation from $(\Delta,\Delta)$ to $(P,Q)$.", cap)
        self.wait(2)

        # ------------------------------------------------ 3. concavity lifts line by line
        cap = self.caption(r"Each column is a vertex set, and $F_1$ acts on it by $F$: "
                           r"(G2) applies to every column of $P$ and every row of $Q$.", cap)
        colbox = SurroundingRectangle(VGroup(*[frame[3 * i + 0] for i in range(N)]),
                                      color=BLUE_L, buff=0.04, stroke_width=5)
        rowbox = SurroundingRectangle(VGroup(*[frame[3 * 2 + j] for j in range(N)]),
                                      color=ORANGE_R, buff=0.04, stroke_width=5)
        self.play(Create(colbox))
        self.play(Create(rowbox))
        self.wait(1.2)
        self.play(FadeOut(colbox), FadeOut(rowbox), FadeOut(key), FadeOut(box))

        # ------------------------------------------------ 4. a fixed board
        cap = self.caption(r"A fixed board of $|X|^2$ cells. Compatible images are disjoint, "
                           r"so every cell is counted once.", cap)
        tint = VGroup()
        for (i, j) in sorted(ALL):
            col = BLUE_L if (i, j) in F1o else ORANGE_R if (i, j) in F2o else GREY_U
            tint.add(Square(side_length=CS * 0.94, stroke_width=0, fill_color=col,
                            fill_opacity=0.25).move_to(cell(i, j)).set_z_index(-1))
        self.play(FadeIn(tint))
        unc = N * N - len(F1o) - len(F2o)
        b1 = led(r"|X|^2=|F_1P|+|F_2Q|+\mathrm{unc}", 3.6)
        b1n = led(rf"{N*N}={len(F1o)}+{len(F2o)}+{unc}", 4.4)
        self.play(FadeIn(b1), FadeIn(b1n))
        self.wait(1)
        cap = self.caption(r"So the value is the board minus how much the two families "
                           r"\emph{expand} when moved once.", cap)
        b2 = MathTex(r"\mathrm{val}=|X|^2-(|F_1P|-|P|)-(|F_2Q|-|Q|)", font_size=30).move_to(
            np.array([1.1, 2.0 - 0.65 * 3.6, 0]), aligned_edge=LEFT)
        b2n = MathTex(rf"{N}+{N}+{unc}={N*N}-0-0", font_size=30).move_to(
            np.array([1.1, 2.0 - 0.65 * 4.4, 0]), aligned_edge=LEFT)
        self.play(Transform(b1, b2), Transform(b1n, b2n))
        self.wait(1.5)
        cap = self.caption(r"Concavity: expansion \emph{shrinks} one step later. "
                           r"The cells this frees make room for new families.", cap)
        self.wait(2)
        cap = self.caption(r"New conflicts are paid for in free cells (the pruning lemma). "
                           r"Next video: one such step.", cap)
        self.wait(2.5)

        # ------------------------------------------------ summary card
        self.play(*[FadeOut(m) for m in self.mobjects if m is not title])
        summary = VGroup(
            Tex(r"1.\ Concavity alone is not contradictory: orientation must be used.", font_size=32),
            Tex(r"2.\ Orientation lives on pairs: $F_1\Delta\cap F_2\Delta=\varnothing$.", font_size=32),
            Tex(r"3.\ Concavity lifts to the grid, line by line, in both directions.", font_size=32),
            Tex(r"4.\ A fixed board: value $=|X|^2-$ expansion, and it is bounded.", font_size=32),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.45).move_to(ORIGIN)
        for m in summary:
            self.play(FadeIn(m, shift=RIGHT * 0.3), run_time=0.7)
        self.wait(3)
