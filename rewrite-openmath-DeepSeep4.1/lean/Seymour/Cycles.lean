/-
  Corollary 6.1 of the paper (directed-cycle consequences), proved from the
  main theorem.  This is a genuine consequence: nothing is assumed except the
  conclusion of Seymour's conjecture, which enters as the hypothesis `hmain`.
-/
import Seymour.Basic

set_option linter.unusedSectionVars false

namespace Seymour
namespace OGraph

open Seymour

variable {V : Type*} [Fintype V] [DecidableEq V] (G : OGraph V) [DecidableRel G.Arc]

/-- `G` has no directed triangle. -/
def TriangleFree : Prop := ∀ a b c : V, G.Arc a b → G.Arc b c → ¬ G.Arc c a

/-- In a triangle-free oriented graph, no second out-neighbor is an in-neighbor. -/
theorem N2_subset_nonNeighbours (h : G.TriangleFree) (v : V) :
    G.N2 v ⊆ G.nonNeighbours v := by
  intro y hy
  rw [mem_N2] at hy
  obtain ⟨⟨x, h1, h2⟩, h3⟩ := hy
  rw [mem_nonNeighbours]
  refine ⟨?_, h3, ?_⟩
  · rintro rfl
    exact G.asymm h1 h2
  · intro hyv
    exact h v x y h1 h2 hyv

/-- `v` is not its own out-neighbor. -/
theorem not_mem_N1_self (v : V) : v ∉ G.N1 v := by
  rw [mem_N1]; exact G.irrefl v

/-- `v` is not its own in-neighbor. -/
theorem not_mem_N1in_self (v : V) : v ∉ G.N1in v := by
  rw [mem_N1in]; exact G.irrefl v

/-- First in- and out-neighborhoods are disjoint in an oriented graph. -/
theorem disjoint_N1_N1in (v : V) : Disjoint (G.N1 v) (G.N1in v) := by
  rw [Finset.disjoint_left]
  intro x hx hx'
  rw [mem_N1] at hx
  rw [mem_N1in] at hx'
  exact G.asymm hx hx'

/-- **The partition** `n - 1 = d⁺ + d⁻ + |non-neighbors|`. -/
theorem card_partition (v : V) :
    Fintype.card V - 1 = (G.N1 v).card + (G.N1in v).card + (G.nonNeighbours v).card := by
  classical
  have hcard_pos : 0 < Fintype.card V := Fintype.card_pos_iff.mpr ⟨v⟩
  have hd1 : Disjoint ({v} : Finset V) (G.N1 v) := by
    rw [Finset.disjoint_singleton_left]; exact G.not_mem_N1_self v
  have hd2 : Disjoint (({v} : Finset V) ∪ G.N1 v) (G.N1in v) := by
    rw [Finset.disjoint_union_left]
    exact ⟨by rw [Finset.disjoint_singleton_left]; exact G.not_mem_N1in_self v,
           G.disjoint_N1_N1in v⟩
  have hUcard : (({v} : Finset V) ∪ G.N1 v ∪ G.N1in v).card
      = 1 + (G.N1 v).card + (G.N1in v).card := by
    rw [Finset.card_union_of_disjoint hd2, Finset.card_union_of_disjoint hd1]
    simp
  have hdisj : Disjoint (({v} : Finset V) ∪ G.N1 v ∪ G.N1in v) (G.nonNeighbours v) := by
    rw [nonNeighbours]; exact Finset.disjoint_sdiff
  have hunion : (({v} : Finset V) ∪ G.N1 v ∪ G.N1in v) ∪ G.nonNeighbours v = Finset.univ := by
    rw [nonNeighbours]; exact Finset.union_sdiff_of_subset (Finset.subset_univ _)
  have h := Finset.card_union_of_disjoint hdisj
  rw [hunion, Finset.card_univ, hUcard] at h
  omega

/-- **Corollary 6.1(i)**: in a triangle-free oriented graph, the vertex promised by the
main theorem has at most as many out-neighbors as non-neighbors, and `n - 1 ≥ 2 d⁺ + d⁻`. -/
theorem cor_cycles_i (hmain : ∃ v : V, G.Good v) (h : G.TriangleFree) :
    ∃ v : V, (G.N1 v).card ≤ (G.nonNeighbours v).card ∧
      Fintype.card V - 1 ≥ 2 * (G.N1 v).card + (G.N1in v).card := by
  obtain ⟨v, hv⟩ := hmain
  have h1 : (G.N1 v).card ≤ (G.nonNeighbours v).card :=
    le_trans hv (Finset.card_le_card (G.N2_subset_nonNeighbours h v))
  refine ⟨v, h1, ?_⟩
  have := G.card_partition v
  omega

/-- **Corollary 6.1(ii)**: minimum in- and out-degree at least `n/3` forces a directed
triangle.  We state `n/3` as `n ≤ 3 * d`, equivalent for integral degrees. -/
theorem cor_cycles_ii
    (hout : ∀ v : V, Fintype.card V ≤ 3 * (G.N1 v).card)
    (hin : ∀ v : V, Fintype.card V ≤ 3 * (G.N1in v).card)
    (hmain : ∃ v : V, G.Good v) :
    ¬ G.TriangleFree := by
  intro h
  obtain ⟨v, -, h2⟩ := G.cor_cycles_i hmain h
  have hcard : 0 < Fintype.card V := Fintype.card_pos_iff.mpr ⟨v⟩
  have ho := hout v
  have hi := hin v
  omega

/-- **Corollary 6.1(iii)**: a triangle-free oriented graph with `d⁺ = d⁻ = r` everywhere
satisfies `n - 1 ≥ 3 r`, hence `n ≥ 3 r + 1`.  (Directed girth four implies triangle-free,
which is the only property of girth four that the argument uses.) -/
theorem cor_cycles_iii (r : ℕ)
    (hout : ∀ v : V, (G.N1 v).card = r)
    (hin : ∀ v : V, (G.N1in v).card = r)
    (hmain : ∃ v : V, G.Good v) (h : G.TriangleFree) :
    Fintype.card V ≥ 3 * r + 1 := by
  obtain ⟨v, -, h2⟩ := G.cor_cycles_i hmain h
  rw [hout v, hin v] at h2
  have hcard : 0 < Fintype.card V := Fintype.card_pos_iff.mpr ⟨v⟩
  omega

end OGraph
end Seymour
