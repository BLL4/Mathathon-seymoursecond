import SeymourLean.Final
import SeymourLean.Insights

/-!
# Directed triangles and the Caccetta–Häggkvist conjecture for `k = 3`

(`sec6-consequences.tex`, Corollary `cor:triangles`, and the discussion of the
Caccetta–Häggkvist conjecture that follows it.)

In an oriented graph without directed triangles the sets `{v}`, `N⁺₁(v)`, `N⁺₂(v)` and
`N⁻₁(v)` are pairwise disjoint, so a Seymour vertex `v` satisfies `2 d⁺(v) + d⁻(v) + 1 ≤ n`
(`exists_two_out_add_in_le`).  Consequently

* a digraph in which every out-degree and every in-degree is at least `n/3` has a directed
  cycle of length at most three (`ch3_symmetric`, the *symmetric* case of the
  Caccetta–Häggkvist conjecture for triangles);
* an `r`-regular oriented graph of girth four has at least `3r + 1` vertices
  (`regular_girth_four`).

The grid lemmas at the end say that triangle-freeness, like orientation, is a statement
about pairs: `F₁²Δ ∩ F₂Δ = ∅` (`triangleFree_iff_grid`), and the enlarged seed
`(Δ ∪ F₁Δ, Δ)` is compatible exactly for oriented triangle-free relations
(`seed_compatible_iff`).
-/

open Finset

namespace Seymour

/-- No directed triangle `x → y → z → x`. -/
def TriangleFree {V : Type*} (adj : V → V → Prop) : Prop :=
  ∀ x y z, adj x y → adj y z → ¬ adj z x

/-- A directed cycle of length at most three: a loop, a digon or a directed triangle. -/
def HasShortCycle {V : Type*} (adj : V → V → Prop) : Prop :=
  (∃ x, adj x x) ∨ (∃ x y, adj x y ∧ adj y x) ∨ (∃ x y z, adj x y ∧ adj y z ∧ adj z x)

section Defs

variable {V : Type*} [Fintype V] [DecidableEq V] (adj : V → V → Prop) [DecidableRel adj]

/-- In-neighbourhood `N⁻₁(v)`. -/
def Nin (v : V) : Finset V := univ.filter (fun u => adj u v)

variable {adj}

@[simp] lemma mem_Nin {u v : V} : u ∈ Nin adj v ↔ adj u v := by simp [Nin]

end Defs

section Triangles

variable {V : Type} [Fintype V] [DecidableEq V] {adj : V → V → Prop} [DecidableRel adj]

/-- **Corollary `cor:triangles` (i).** Without directed triangles, `N⁺₂(v)` consists of
non-neighbours of `v`, so a Seymour vertex satisfies `2 d⁺(v) + d⁻(v) + 1 ≤ n`. -/
theorem exists_two_out_add_in_le [Nonempty V] (hor : IsOriented adj) (htri : TriangleFree adj) :
    ∃ v, 2 * (N1 adj v).card + (Nin adj v).card + 1 ≤ Fintype.card V := by
  obtain ⟨v, hv⟩ := seymour_second_neighbourhood V adj hor
  refine ⟨v, ?_⟩
  -- `N⁺₁(v)`, `N⁺₂(v)`, `N⁻₁(v)` and `{v}` are pairwise disjoint
  have h12 : Disjoint (N1 adj v) (N2 adj v) := by
    rw [Finset.disjoint_left]
    intro w hw hw'
    exact (mem_N2.mp hw').2.1 (mem_N1.mp hw)
  have h3 : Disjoint (N1 adj v ∪ N2 adj v) (Nin adj v) := by
    rw [Finset.disjoint_left]
    intro w hw hw'
    rw [mem_Nin] at hw'
    rcases Finset.mem_union.mp hw with hw | hw
    · exact hor.2 v w (mem_N1.mp hw) hw'
    · obtain ⟨-, -, u, hvu, huw⟩ := mem_N2.mp hw
      exact htri v u w hvu huw hw'
  have hv0 : v ∉ N1 adj v ∪ N2 adj v ∪ Nin adj v := by
    intro h
    rcases Finset.mem_union.mp h with h | h
    · rcases Finset.mem_union.mp h with h | h
      · exact hor.1 v (mem_N1.mp h)
      · exact (mem_N2.mp h).1 rfl
    · exact hor.1 v (mem_Nin.mp h)
  have hcard := Finset.card_le_univ (insert v (N1 adj v ∪ N2 adj v ∪ Nin adj v))
  rw [Finset.card_insert_of_notMem hv0, card_union_of_disjoint h3,
    card_union_of_disjoint h12] at hcard
  omega

/-- **Corollary `cor:triangles` (ii): the symmetric Caccetta–Häggkvist statement for
triangles.** If every out-degree and every in-degree is at least `n/3`, there is a directed
cycle of length at most three. The relation is arbitrary here (loops and digons count as
short cycles). -/
theorem ch3_symmetric [Nonempty V] (hout : ∀ v, Fintype.card V ≤ 3 * (N1 adj v).card)
    (hin : ∀ v, Fintype.card V ≤ 3 * (Nin adj v).card) : HasShortCycle adj := by
  by_contra h
  have hloop : ∀ x, ¬ adj x x := fun x hx => h (Or.inl ⟨x, hx⟩)
  have hdigon : ∀ x y, adj x y → ¬ adj y x :=
    fun x y hxy hyx => h (Or.inr (Or.inl ⟨x, y, hxy, hyx⟩))
  have htri : TriangleFree adj :=
    fun x y z hxy hyz hzx => h (Or.inr (Or.inr ⟨x, y, z, hxy, hyz, hzx⟩))
  obtain ⟨v, hv⟩ := exists_two_out_add_in_le ⟨hloop, hdigon⟩ htri
  have := hout v
  have := hin v
  omega

/-- The same for loopless digraphs: the short cycle is a digon or a directed triangle. -/
theorem ch3_symmetric_loopless [Nonempty V] (hloop : ∀ x, ¬ adj x x)
    (hout : ∀ v, Fintype.card V ≤ 3 * (N1 adj v).card)
    (hin : ∀ v, Fintype.card V ≤ 3 * (Nin adj v).card) :
    (∃ x y, adj x y ∧ adj y x) ∨ (∃ x y z, adj x y ∧ adj y z ∧ adj z x) := by
  rcases ch3_symmetric hout hin with ⟨x, hx⟩ | h | h
  · exact absurd hx (hloop x)
  · exact Or.inl h
  · exact Or.inr h

/-- **Corollary `cor:triangles` (iii).** An `r`-regular oriented graph without directed
triangles (in particular, one of girth exactly four) has at least `3r + 1` vertices. -/
theorem regular_girth_four [Nonempty V] (hor : IsOriented adj) (htri : TriangleFree adj)
    (r : ℕ) (hreg : ∀ v, (N1 adj v).card = r ∧ (Nin adj v).card = r) :
    3 * r + 1 ≤ Fintype.card V := by
  obtain ⟨v, hv⟩ := exists_two_out_add_in_le hor htri
  obtain ⟨h1, h2⟩ := hreg v
  omega

end Triangles

section Grid

variable {X : Type*} [Fintype X] [DecidableEq X] (adj : X → X → Prop) [DecidableRel adj]

/-- Triangle-freeness is a statement about pairs: `(i,j) ∈ F₁²Δ` says `j → p → i` for some
`p`, and `(i,j) ∈ F₂Δ` says `i → j`; a common point is a directed triangle. -/
theorem triangleFree_iff_grid :
    TriangleFree adj ↔ Disjoint (F1 adj (F1 adj (diag X))) (F2 adj (diag X)) := by
  constructor
  · intro htri
    rw [Finset.disjoint_left]
    rintro ⟨i, j⟩ h1 h2
    obtain ⟨p, hp, hpi⟩ := (mem_F1 adj).mp h1
    obtain ⟨q, hq, hqp⟩ := (mem_F1 adj).mp hp
    obtain ⟨s, hs, hsj⟩ := (mem_F2 adj).mp h2
    simp only [mem_diag] at hq hs
    subst hq
    subst hs
    exact htri _ _ _ hsj hqp hpi
  · intro h x y z hxy hyz hzx
    have h1 : (x, y) ∈ F1 adj (F1 adj (diag X)) :=
      (mem_F1 adj).mpr ⟨z, (mem_F1 adj).mpr ⟨y, by simp [mem_diag], hyz⟩, hzx⟩
    have h2 : (x, y) ∈ F2 adj (diag X) := (mem_F2 adj).mpr ⟨x, by simp [mem_diag], hxy⟩
    exact Finset.disjoint_left.mp h h1 h2

lemma F1_union (S T : Finset (X × X)) : F1 adj (S ∪ T) = F1 adj S ∪ F1 adj T := by
  ext z
  simp only [mem_F1, Finset.mem_union]
  constructor
  · rintro ⟨p, hp | hp, hpi⟩
    · exact Or.inl ⟨p, hp, hpi⟩
    · exact Or.inr ⟨p, hp, hpi⟩
  · rintro (⟨p, hp, hpi⟩ | ⟨p, hp, hpi⟩)
    · exact ⟨p, Or.inl hp, hpi⟩
    · exact ⟨p, Or.inr hp, hpi⟩

/-- The enlarged seed `(Δ ∪ F₁Δ, Δ)` is compatible exactly when the relation is oriented and
has no directed triangle. (Compare `diag_compatible_iff_oriented`: the seed `(Δ,Δ)` sees only
orientation.) -/
theorem seed_compatible_iff :
    Disjoint (F1 adj (diag X ∪ F1 adj (diag X))) (F2 adj (diag X)) ↔
      IsOriented adj ∧ TriangleFree adj := by
  rw [F1_union, Finset.disjoint_union_left, diag_compatible_iff_oriented,
    ← triangleFree_iff_grid]

end Grid

end Seymour
