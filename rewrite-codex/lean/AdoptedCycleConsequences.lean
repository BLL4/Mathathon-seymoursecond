import Seymour.Cycles
import SeymourLean.Final

/-!
Reuse the cycle lemmas from the DeepSeep4.1 companion, with attribution in
review-target/README.md. Their main-theorem input is now discharged by the
rebuilt Claude Opus 5.5 reference proof. The definition bridges below are
new Codex proofs; the copied cycle lemmas are unchanged.
-/
namespace SecondNeighborhoodAdoptedCycles

variable {V : Type} [Fintype V] [DecidableEq V]
  (G : Seymour.OGraph V) [DecidableRel G.Arc]

/-- The two formalizations use the same first neighborhood. -/
theorem first_neighborhood_agrees (v : V) :
    G.N1 v = Seymour.N1 G.Arc v := by
  ext w
  rw [Seymour.OGraph.mem_N1, Seymour.mem_N1]

/-- Asymmetry makes the companion's two-walk-minus-first convention equal
to the full reference proof's exact-distance convention. -/
theorem second_neighborhood_agrees (v : V) :
    G.N2 v = Seymour.N2 G.Arc v := by
  ext w
  rw [Seymour.OGraph.mem_N2, Seymour.mem_N2]
  constructor
  · rintro ⟨⟨u, h1, h2⟩, hnot⟩
    refine ⟨?_, hnot, u, h1, h2⟩
    intro hw
    subst w
    exact G.asymm h1 h2
  · rintro ⟨_, hnot, u, h1, h2⟩
    exact ⟨⟨u, h1, h2⟩, hnot⟩

/-- Supply the main theorem to the otherwise conditional companion. -/
theorem good_vertex [Nonempty V] : ∃ v, G.Good v := by
  have hor : Seymour.IsOriented G.Arc :=
    ⟨G.irrefl, fun _ _ h => G.asymm h⟩
  obtain ⟨v, hv⟩ := Seymour.seymour_second_neighbourhood V G.Arc hor
  refine ⟨v, ?_⟩
  change (G.N1 v).card ≤ (G.N2 v).card
  rw [first_neighborhood_agrees G v, second_neighborhood_agrees G v]
  exact hv

/-- Unconditional non-neighbor and degree conclusion for triangle-free graphs. -/
theorem triangle_free_vertex_bound [Nonempty V] (h : G.TriangleFree) :
    ∃ v, (G.N1 v).card ≤ (G.nonNeighbours v).card ∧
      2 * (G.N1 v).card + (G.N1in v).card ≤ Fintype.card V - 1 :=
  G.cor_cycles_i (good_vertex G) h

/-- Both minimum semidegrees at least n/3 force an actual directed triangle. -/
theorem triangle_of_semidegrees [Nonempty V]
    (hout : ∀ v, Fintype.card V ≤ 3 * (G.N1 v).card)
    (hin : ∀ v, Fintype.card V ≤ 3 * (G.N1in v).card) :
    ∃ a b c, G.Arc a b ∧ G.Arc b c ∧ G.Arc c a := by
  classical
  have hnot := G.cor_cycles_ii hout hin (good_vertex G)
  by_contra hn
  apply hnot
  intro a b c hab hbc hca
  exact hn ⟨a, b, c, hab, hbc, hca⟩

/-- The regular order bound only requires triangle-freeness, not girth exactly four. -/
theorem regular_triangle_free_order [Nonempty V] (r : ℕ)
    (hout : ∀ v, (G.N1 v).card = r) (hin : ∀ v, (G.N1in v).card = r)
    (h : G.TriangleFree) : 3 * r + 1 ≤ Fintype.card V :=
  G.cor_cycles_iii r hout hin (good_vertex G) h

#print axioms good_vertex
#print axioms triangle_free_vertex_bound
#print axioms triangle_of_semidegrees
#print axioms regular_triangle_free_order
end SecondNeighborhoodAdoptedCycles
