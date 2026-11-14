"""One improvement step of the proof, worked out on a 4-vertex graph.

Render (from this folder):
    .venv/bin/manim -qh improvement_step.py ImprovementStep

All numbers are computed by engine.py, not typed in.
"""
from manim import *

from engine import F1, F2, step, kappa

config.background_color = WHITE
_tpl = TexTemplate()
_tpl.add_to_preamble(r"\usepackage{xcolor}")
config.tex_template = _tpl
for cls in (Tex, MathTex, Text):
    cls.set_default(color=BLACK)

BLUE_L = ManimColor("#1f77b4")
ORANGE_R = ManimColor("#d6601a")
GREEN_Z = ManimColor("#2c8c3c")
PURPLE_H = ManimColor("#8c46a0")
GREY_U = ManimColor("#9a9a9a")

# ---------------------------------------------------------------- the example
N = 4
# vertices 0..3 are shown as 1..4
REL = {(0, 2), (2, 1), (2, 3), (3, 0), (3, 1)}   # 1->3, 3->2, 3->4, 4->1, 4->2
DELTA = {(v, v) for v in range(N)}
P0 = DELTA | {(0, 2)}
Q0 = DELTA | {(0, 3)}
S = step(REL, N, P0, Q0)
S2 = step(REL, N, S["P2"], S["Q2"])
ALL = {(i, j) for i in range(N) for j in range(N)}

CS = 1.0                       # grid cell size
GRID_ORIGIN = np.array([-2.5, 1.35, 0])   # centre of cell (0, 0)


def cell(i, j):
    return GRID_ORIGIN + np.array([j * CS, -i * CS, 0])


def lab(v):
    return str(v + 1)


class ImprovementStep(Scene):
    # ------------------------------------------------------------ helpers
    def caption(self, text, old=None):
        new = Tex(text, font_size=28).to_edge(DOWN, buff=0.3)
        if new.width > 13:
            new.scale_to_fit_width(13)
        if old is not None:
            self.play(FadeOut(old), run_time=0.35)
        self.play(FadeIn(new), run_time=0.5)
        return new

    def pmark(self, i, j, color=BLUE_L):
        return Dot(cell(i, j) + np.array([-0.2, 0.2, 0]), radius=0.12, color=color).set_z_index(3)

    def qmark(self, i, j, color=ORANGE_R):
        return Square(side_length=0.22, color=color, fill_opacity=1).move_to(
            cell(i, j) + np.array([0.2, -0.2, 0])).set_z_index(3)

    def tint(self, pts, color, opacity=0.28):
        return VGroup(*[Square(side_length=CS * 0.94, stroke_width=0, fill_color=color,
                               fill_opacity=opacity).move_to(cell(i, j)).set_z_index(-1)
                      for i, j in sorted(pts)])

    def unc_marks(self, pts):
        return VGroup(*[DashedVMobject(Square(side_length=CS * 0.8, color=GREY_U, stroke_width=3),
                                       num_dashes=16).move_to(cell(i, j)) for i, j in sorted(pts)])

    def ledger_line(self, tex, row):
        m = MathTex(tex, font_size=30)
        m.move_to(np.array([2.3, 2.55 - 0.6 * row, 0]), aligned_edge=LEFT)
        return m

    # ------------------------------------------------------------ scene
    def construct(self):
        title = Tex(r"One improvement step, worked out", font_size=40).to_corner(UL, buff=0.3)
        self.play(Write(title))

        # ---- the graph G
        pos = {0: np.array([-6.5, 1.9, 0]), 2: np.array([-5.1, 1.9, 0]),
               3: np.array([-5.8, 0.75, 0]), 1: np.array([-4.5, 0.25, 0])}
        verts = {v: VGroup(Circle(radius=0.27, color=BLACK, stroke_width=2.5).move_to(pos[v]),
                           MathTex(lab(v), font_size=30).move_to(pos[v])) for v in range(N)}
        arcs = VGroup(*[Arrow(pos[a], pos[b], buff=0.3, color=BLACK, stroke_width=3,
                              max_tip_length_to_length_ratio=0.18) for a, b in sorted(REL)])
        gname = MathTex("G", font_size=34).move_to(np.array([-5.8, 2.7, 0]))
        cap = self.caption(r"An oriented graph $G$ on $X=\{1,2,3,4\}$; every vertex has an in-neighbour.")
        self.play(*[Create(v) for v in verts.values()], FadeIn(gname))
        self.play(LaggedStart(*[GrowArrow(a) for a in arcs], lag_ratio=0.2))
        self.wait(0.5)

        # ---- the grid
        dots = VGroup(*[Dot(cell(i, j), radius=0.04, color=GREY_U) for i, j in sorted(ALL)])
        frame = VGroup(*[Square(side_length=CS, color=GREY_U, stroke_width=1).move_to(cell(i, j))
                         for i, j in sorted(ALL)])
        clabels = VGroup(*[MathTex(lab(j), font_size=28).move_to(cell(0, j) + UP * 0.75) for j in range(N)])
        rlabels = VGroup(*[MathTex(lab(i), font_size=28).move_to(cell(i, 0) + LEFT * 0.75) for i in range(N)])
        ctitle = Tex(r"column $j$", font_size=26, color=GREY_U).next_to(clabels, UP, buff=0.12)
        rtitle = Tex(r"row $i$", font_size=26, color=GREY_U).rotate(PI / 2).next_to(rlabels, LEFT, buff=0.12)
        cap = self.caption(r"The grid $X\times X$: the pair $(i,j)$ sits in row $i$, column $j$.", cap)
        self.play(Create(frame), FadeIn(dots), FadeIn(clabels), FadeIn(rlabels), FadeIn(ctitle), FadeIn(rtitle))

        # ---- F1 and F2 on single points
        cap = self.caption(r"$F_1$ moves the \emph{first} coordinate along an arc (vertical), "
                           r"$F_2$ the \emph{second} (horizontal).", cap)
        a = self.pmark(0, 2)
        tgt = self.pmark(2, 2)
        ar1 = Arrow(a.get_center(), tgt.get_center(), buff=0.12, color=BLUE_L, stroke_width=4)
        t1 = MathTex(r"1\to3", font_size=26, color=BLUE_L).next_to(ar1, LEFT, buff=0.05)
        self.play(FadeIn(a))
        self.play(GrowArrow(ar1), FadeIn(t1), TransformFromCopy(a, tgt))
        b = self.qmark(0, 3)
        b1, b2 = self.qmark(0, 0), self.qmark(0, 1)
        ar2 = CurvedArrow(b.get_center(), b1.get_center(), angle=-0.5, color=ORANGE_R, stroke_width=4)
        ar3 = CurvedArrow(b.get_center(), b2.get_center(), angle=-0.35, color=ORANGE_R, stroke_width=4)
        t2 = MathTex(r"4\to1,\ 4\to2", font_size=26, color=ORANGE_R).next_to(b, RIGHT, buff=0.35)
        self.play(FadeIn(b))
        self.play(Create(ar2), Create(ar3), FadeIn(t2), TransformFromCopy(b, b1), TransformFromCopy(b, b2))
        self.wait(1)
        self.play(FadeOut(VGroup(a, tgt, ar1, t1, b, b1, b2, ar2, ar3, t2)))

        # ---- the old pair
        cap = self.caption(r"Pick an admissible pair: {\color[HTML]{1f77b4}$P$} (disks) and "
                           r"{\color[HTML]{d6601a}$Q$} (squares), both containing the diagonal.", cap)
        Pm = VGroup(*[self.pmark(i, j) for i, j in sorted(S["P"])])
        Qm = VGroup(*[self.qmark(i, j) for i, j in sorted(S["Q"])])
        self.play(LaggedStart(*[FadeIn(m, scale=1.5) for m in Pm], lag_ratio=0.1))
        self.play(LaggedStart(*[FadeIn(m, scale=1.5) for m in Qm], lag_ratio=0.1))

        cap = self.caption(r"They cover {\color[HTML]{1f77b4}$F_1P$} and {\color[HTML]{d6601a}$F_2Q$}. "
                           r"No point is covered twice (compatible). Grey: uncovered.", cap)
        tP = self.tint(S["F1P"], BLUE_L)
        tQ = self.tint(S["F2Q"], ORANGE_R)
        old_unc = ALL - S["F1P"] - S["F2Q"]
        uP = self.unc_marks(old_unc)
        self.play(FadeIn(tP))
        self.play(FadeIn(tQ))
        self.play(Create(uP))

        L = [self.ledger_line(r"\mu=|P|+|Q|=%d+%d=%d" % (len(S["P"]), len(S["Q"]), S["mu"]), 0),
             self.ledger_line(r"d=\mathrm{unc}(P,Q)=%d" % S["d"], 1),
             self.ledger_line(r"\mathrm{val}(P,Q)=%d" % S["val"], 2)]
        ledger_title = Tex(r"\textbf{Ledger}", font_size=32).move_to(np.array([2.3, 3.15, 0]), aligned_edge=LEFT)
        self.play(FadeIn(ledger_title), *[Write(x) for x in L])
        box_old = SurroundingRectangle(L[2], color=BLACK, buff=0.1)
        self.play(Create(box_old))
        self.wait(1)

        # ---- concavity on lines
        kc, kr = S["kappa_cols"], S["kappa_rows"]
        cap = self.caption(r"Apply concavity to every column of $P$ and every row of $Q$: "
                           r"$\kappa(U)=|U|-2|FU|+|F^2U|$.", cap)
        kcol = VGroup(*[MathTex(r"%d" % kc[j], font_size=26, color=BLUE_L).move_to(cell(N - 1, j) + DOWN * 0.78)
                        for j in range(N)])
        krow = VGroup(*[MathTex(r"%d" % kr[i], font_size=26, color=ORANGE_R).move_to(cell(i, N - 1) + RIGHT * 0.8)
                        for i in range(N)])
        kname1 = MathTex(r"\kappa(P_j)", font_size=24, color=BLUE_L).next_to(kcol, LEFT, buff=0.35)
        kname2 = MathTex(r"\kappa(Q_i)", font_size=24, color=ORANGE_R).next_to(krow, UP, buff=0.15)
        self.play(FadeIn(kcol), FadeIn(krow), FadeIn(kname1), FadeIn(kname2))
        gain = -(sum(kc) + sum(kr))
        L.append(self.ledger_line(r"\textstyle\sum\kappa=%d" % (-gain), 3))
        self.play(Write(L[3]))
        self.wait(1.5)

        # ---- the new candidate families R and C
        cap = self.caption(r"New left family {\color[HTML]{1f77b4}$\mathcal R=X^2\setminus F_2^2Q$} "
                           r"(note the swap) and right family {\color[HTML]{d6601a}$\mathcal C=X^2\setminus F_1^2P$}.", cap)
        self.play(FadeOut(VGroup(tP, tQ, uP, kcol, krow, kname1, kname2)))
        t2Q = self.tint(S["F2sqQ"], ORANGE_R, 0.45)
        self.play(FadeIn(t2Q))
        Rm = VGroup(*[self.pmark(i, j) for i, j in sorted(S["R"])])
        self.play(FadeOut(Pm), LaggedStart(*[FadeIn(m, scale=1.5) for m in Rm], lag_ratio=0.05))
        self.play(FadeOut(t2Q))
        t2P = self.tint(S["F1sqP"], BLUE_L, 0.45)
        self.play(FadeIn(t2P))
        Cm = VGroup(*[self.qmark(i, j) for i, j in sorted(S["C"])])
        self.play(FadeOut(Qm), LaggedStart(*[FadeIn(m, scale=1.5) for m in Cm], lag_ratio=0.05))
        self.play(FadeOut(t2P))
        rc = len(S["R"]) + len(S["C"])
        L.append(self.ledger_line(r"|\mathcal R|+|\mathcal C|=%d=\mu+2d%+d" % (rc, rc - S["mu"] - 2 * S["d"]), 4))
        self.play(Write(L[4]))
        cap = self.caption(r"Gain: $|\mathcal R|+|\mathcal C|=\mu+2d-\sum\kappa$. "
                           r"In a counterexample every $\kappa\le-1$, so the gain is large.", cap)
        self.wait(1.5)

        # ---- conflicts
        cap = self.caption(r"But $(\mathcal R,\mathcal C)$ has \emph{conflicts}: a left and a right member "
                           r"whose images meet.", cap)
        conf = S["conf"]
        r0, c0 = conf[0]
        z0, h0 = (c0[0], r0[1]), (r0[0], c0[1])
        rect = Polygon(cell(*r0), cell(*h0), cell(*c0), cell(*z0), color=BLACK, stroke_width=2)
        rect = DashedVMobject(rect, num_dashes=40)
        v_ar = Arrow(cell(*r0) + np.array([-0.2, 0.2, 0]), cell(*z0), buff=0.15, color=BLUE_L, stroke_width=5)
        h_ar = Arrow(cell(*c0) + np.array([0.2, -0.2, 0]), cell(*z0), buff=0.15, color=ORANGE_R, stroke_width=5)
        zz = Square(side_length=0.3, color=GREEN_Z, fill_opacity=1).rotate(PI / 4).move_to(cell(*z0))
        hh = Star(5, outer_radius=0.2, color=PURPLE_H, fill_opacity=1).move_to(cell(*h0))
        self.play(Create(rect))
        self.play(GrowArrow(v_ar), GrowArrow(h_ar))
        self.play(FadeIn(zz, scale=1.5), FadeIn(hh, scale=1.5))
        tz = Tex(r"$z$", font_size=28, color=GREEN_Z).next_to(zz, DR, buff=0.02)
        th = Tex(r"$h$", font_size=28, color=PURPLE_H).next_to(hh, UR, buff=0.02)
        self.play(FadeIn(tz), FadeIn(th))
        self.wait(1)

        cap = self.caption(r"All four conflicts share the corner $h=(4,4)$: a complete block $K_{2,2}$. "
                           r"$|Z|=%d$, $|H|=%d$." % (len(S["Z"]), len(S["H"])), cap)
        Zm = VGroup(*[Square(side_length=0.3, color=GREEN_Z, fill_opacity=1).rotate(PI / 4).move_to(cell(i, j))
                      for i, j in sorted(S["Z"]) if (i, j) != z0])
        self.play(FadeOut(rect), FadeOut(v_ar), FadeOut(h_ar), FadeOut(tz))
        more = VGroup()
        for r, c in conf:
            z = (c[0], r[1])
            more.add(Arrow(cell(*r) + np.array([-0.2, 0.2, 0]), cell(*z), buff=0.18, color=BLUE_L, stroke_width=3))
            more.add(Arrow(cell(*c) + np.array([0.2, -0.2, 0]), cell(*z), buff=0.18, color=ORANGE_R, stroke_width=3))
        self.play(LaggedStart(*[GrowArrow(m) for m in more], lag_ratio=0.1), FadeIn(Zm))
        L.append(self.ledger_line(r"|Z|=%d,\ |H|=%d\le d" % (len(S["Z"]), len(S["H"])), 5))
        self.play(Write(L[5]))
        self.wait(1)
        cap = self.caption(r"$h$ was uncovered by the old pair (grey before), so $|H|\le d$.", cap)
        hmark = self.unc_marks({h0})
        self.play(Create(hmark), Indicate(hh, color=PURPLE_H, scale_factor=1.6))
        self.wait(0.5)
        self.play(FadeOut(hmark))

        # ---- pruning
        cap = self.caption(r"Pruning lemma: delete conflicting members; pay $|H|$ plus one per conflict point "
                           r"left uncovered.", cap)
        dels = [m for m in Rm if any(np.allclose(m.get_center(), self.pmark(i, j).get_center())
                                     for i, j in S["delR"])]
        dels += [m for m in Cm if any(np.allclose(m.get_center(), self.qmark(i, j).get_center())
                                      for i, j in S["delC"])]
        crosses = VGroup(*[Cross(m, stroke_color=RED, stroke_width=5, scale_factor=1.6) for m in dels])
        self.play(Create(crosses))
        self.play(FadeOut(VGroup(*dels)), FadeOut(crosses), FadeOut(more))
        ndel = len(S["delR"]) + len(S["delC"])
        L.append(self.ledger_line(r"\text{deleted}=%d\le|H|+%d=%d" % (ndel, S["uncZ"], len(S["H"]) + S["uncZ"]), 6))
        self.play(Write(L[6]))
        self.wait(1)

        # ---- the new pair
        P2, Q2 = S["P2"], S["Q2"]
        cap = self.caption(r"The new pair $(P',Q')$ is admissible. All four conflict points are now uncovered.", cap)
        tP2 = self.tint(F1(REL, P2), BLUE_L)
        tQ2 = self.tint(F2(REL, Q2), ORANGE_R)
        new_unc = ALL - F1(REL, P2) - F2(REL, Q2)
        self.play(FadeOut(Zm), FadeOut(zz), FadeIn(tP2), FadeIn(tQ2))
        uN = self.unc_marks(new_unc)
        self.play(Create(uN))
        L.append(self.ledger_line(r"\mathrm{val}(P',Q')=%d+%d+%d=%d>%d" % (len(P2), len(Q2), S["d2"], S["val2"], S["val"]), 7))
        self.play(Write(L[7]))
        box_new = SurroundingRectangle(L[7], color=GREEN_Z, buff=0.1)
        self.play(Create(box_new))
        cap = self.caption(r"Bigger than $\mathrm{val}(P,Q)=%d$: the uncovered points pay back the extra deletions."
                           % S["val"], cap)
        self.wait(2)

        # ---- why it stops in a real graph
        cap = self.caption(r"Repeat? Now some lines have $\kappa\ge0$, and the best next step drops to %d. "
                           r"A real graph always has such lines." % S2["val2"], cap)
        self.wait(2.5)
        cap = self.caption(r"In a counterexample every line has $\kappa\le-1$, so every step would gain: "
                           r"impossible, since $\mathrm{val}\le 3|X|^2$.", cap)
        self.wait(3)
