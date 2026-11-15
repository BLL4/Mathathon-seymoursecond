import SeymourLean.Final
import SeymourLean.Triangles

/-!
# Related conjectures that the theorem settles at once

(`sec6-consequences.tex`, Section 6.4.)

Two statements from Sullivan's 2006 survey of problems around the Caccetta–Häggkvist
conjecture follow from a single Seymour vertex:

* Conjecture 6.7 there: some vertex has `d⁺(v) + d⁺₂(v) ≥ 2 · min(d⁻(v), d⁺(v))`
  (`sullivan_min`);
* Conjecture 6.12 there (Thomassé): in a triangle-free oriented graph some vertex has at
  least `d⁺(v)` non-neighbours, which is `exists_two_out_add_in_le` in `Triangles.lean`,
  restated here as `thomasse_nonneighbours` with the non-neighbours counted explicitly.
-/

open Finset

namespace Seymour

variable {V : Type} [Fintype V] [DecidableEq V] (adj : V → V → Prop) [DecidableRel adj]

/-- Sullivan's Conjecture 6.7: a vertex with `d⁺ + d⁺₂ ≥ 2 min(d⁻, d⁺)`. A Seymour vertex
has `d⁺ + d⁺₂ ≥ 2 d⁺ ≥ 2 min(d⁻, d⁺)`. -/
theorem sullivan_min [Nonempty V] (hor : IsOriented adj) :
    ∃ v, 2 * min (Nin adj v).card (N1 adj v).card ≤ (N1 adj v).card + (N2 adj v).card := by
  obtain ⟨v, hv⟩ := seymour_second_neighbourhood V adj hor
  exact ⟨v, by have := min_le_right (Nin adj v).card (N1 adj v).card; omega⟩

/-- The non-neighbours of `v`: vertices other than `v` joined to `v` by no arc. -/
def nonNbrs (v : V) : Finset V := univ.filter (fun u => u ≠ v ∧ ¬ adj v u ∧ ¬ adj u v)

/-- Thomassé's conjecture (Sullivan's survey, Conjecture 6.12): without directed
triangles some vertex has at most as many out-neighbours as non-neighbours. -/
theorem thomasse_nonneighbours [Nonempty V] (hor : IsOriented adj) (htri : TriangleFree adj) :
    ∃ v, (N1 adj v).card ≤ (nonNbrs adj v).card := by
  obtain ⟨v, hv⟩ := exists_two_out_add_in_le hor htri
  refine ⟨v, ?_⟩
  -- `V` is the disjoint union of `{v}`, `N⁺₁(v)`, `N⁻₁(v)` and the non-neighbours
  have hcover : univ = insert v (N1 adj v ∪ Nin adj v ∪ nonNbrs adj v) := by
    ext u
    simp only [mem_univ, mem_insert, mem_union, mem_N1, mem_Nin, nonNbrs, mem_filter, true_and,
      true_iff]
    by_cases huv : u = v
    · exact Or.inl huv
    · by_cases h1 : adj v u
      · exact Or.inr (Or.inl (Or.inl h1))
      · by_cases h2 : adj u v
        · exact Or.inr (Or.inl (Or.inr h2))
        · exact Or.inr (Or.inr ⟨huv, h1, h2⟩)
  have hvnot : v ∉ N1 adj v ∪ Nin adj v ∪ nonNbrs adj v := by
    simp only [mem_union, mem_N1, mem_Nin, nonNbrs, mem_filter, not_or]
    exact ⟨⟨hor.1 v, hor.1 v⟩, fun h => h.2.1 rfl⟩
  have h1in : Disjoint (N1 adj v) (Nin adj v) := by
    rw [disjoint_left]
    intro u hu hu'
    rw [mem_N1] at hu
    rw [mem_Nin] at hu'
    exact hor.2 v u hu hu'
  have h12 : Disjoint (N1 adj v ∪ Nin adj v) (nonNbrs adj v) := by
    rw [disjoint_left]
    intro u hu hu'
    simp only [nonNbrs, mem_filter] at hu'
    rcases mem_union.1 hu with h | h
    · exact hu'.2.2.1 (mem_N1.1 h)
    · exact hu'.2.2.2 (mem_Nin.1 h)
  have hcard : Fintype.card V =
      (N1 adj v).card + (Nin adj v).card + (nonNbrs adj v).card + 1 := by
    rw [← Finset.card_univ, hcover, card_insert_of_notMem hvnot, card_union_of_disjoint h12,
      card_union_of_disjoint h1in]
  omega

/-- No transitive triangle `x → y → z` with `x → z`. -/
def NoTransitiveTriangle {W : Type*} (adj : W → W → Prop) : Prop :=
  ∀ x y z, adj x y → adj y z → ¬ adj x z

/-- Theorem 3.2 of Brantner, Brockman, Kay and Snively (arXiv:0808.0946): in an oriented
graph without transitive triangles, every vertex of minimum outdegree is a Seymour vertex.
If `v → u` then `N⁺₁(u) ⊆ N⁺₂(v)`, because `u`'s out-neighbours are not `v` (no digon) and
not out-neighbours of `v` (no transitive triangle), so `d⁺(v) ≤ d⁺(u) ≤ d⁺₂(v)`. -/
theorem min_outdegree_seymour (hor : IsOriented adj) (htt : NoTransitiveTriangle adj)
    (v : V) (hmin : ∀ u, (N1 adj v).card ≤ (N1 adj u).card) :
    (N1 adj v).card ≤ (N2 adj v).card := by
  rcases (N1 adj v).eq_empty_or_nonempty with h | ⟨u, hu⟩
  · simp [h]
  · have hvu : adj v u := mem_N1.1 hu
    have hsub : N1 adj u ⊆ N2 adj v := by
      intro w hw
      have huw : adj u w := mem_N1.1 hw
      refine mem_N2.2 ⟨?_, ?_, u, hvu, huw⟩
      · rintro rfl
        exact hor.2 _ _ hvu huw
      · exact fun hvw => htt v u w hvu huw hvw
    exact (hmin u).trans (card_le_card hsub)

end Seymour
