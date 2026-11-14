/-
  Seymour's second-neighborhood conjecture: definitions and elementary lemmas.

  This file is part of the formal companion to the rewrite
  "A proof of Seymour's second-neighborhood conjecture --- a guided rewrite".
  It contains no deep input: only the definitions and the elementary
  consequences of orientation that the paper uses without comment.
-/
import Mathlib.Data.Fintype.Prod
import Mathlib.Data.Fintype.Powerset
import Mathlib.Data.Finset.Card
import Std

set_option linter.unusedSectionVars false

namespace Seymour

/-- A finite oriented graph: an irreflexive, antisymmetric binary relation. -/
structure OGraph (V : Type*) where
  /-- the arc relation -/
  Arc : V → V → Prop
  /-- no loops -/
  irrefl : ∀ v, ¬ Arc v v
  /-- no pair of opposite arcs -/
  asymm : ∀ {u v}, Arc u v → ¬ Arc v u

namespace OGraph

variable {V : Type*} (G : OGraph V)

theorem asymm' {u v : V} (h : G.Arc u v) : ¬ G.Arc v u := G.asymm h

variable [Fintype V] [DecidableEq V] [DecidableRel G.Arc]

/-- `F S` is the union of the out-neighborhoods of the vertices of `S`.
It never subtracts `S`: an arc inside `S` keeps its head in `F S`. -/
def F (S : Finset V) : Finset V :=
  S.biUnion (fun x => Finset.univ.filter (fun y => G.Arc x y))

@[simp] theorem mem_F {S : Finset V} {y : V} : y ∈ G.F S ↔ ∃ x ∈ S, G.Arc x y := by
  simp [F]

@[simp] theorem F_empty : G.F ∅ = ∅ := by
  ext y; simp

theorem F_mono {S T : Finset V} (h : S ⊆ T) : G.F S ⊆ G.F T := by
  intro y hy
  simp only [mem_F] at *
  obtain ⟨x, hx, hxy⟩ := hy
  exact ⟨x, h hx, hxy⟩

/-- The first out-neighborhood of `v`. -/
def N1 (v : V) : Finset V := G.F {v}

/-- The set of vertices at directed distance exactly two from `v`. -/
def N2 (v : V) : Finset V := G.F (G.F {v}) \ G.N1 v

/-- The first in-neighborhood of `v`. -/
def N1in (v : V) : Finset V := Finset.univ.filter (fun u => G.Arc u v)

/-- The non-neighbors of `v`: vertices joined to `v` in neither direction. -/
def nonNeighbours (v : V) : Finset V :=
  Finset.univ \ ({v} ∪ G.N1 v ∪ G.N1in v)

@[simp] theorem mem_N1 {v y : V} : y ∈ G.N1 v ↔ G.Arc v y := by
  simp [N1]

@[simp] theorem mem_N1in {v y : V} : y ∈ G.N1in v ↔ G.Arc y v := by
  simp [N1in]

theorem mem_N2 {v y : V} :
    y ∈ G.N2 v ↔ (∃ x, G.Arc v x ∧ G.Arc x y) ∧ ¬ G.Arc v y := by
  simp [N2]

@[simp] theorem mem_nonNeighbours {v y : V} :
    y ∈ G.nonNeighbours v ↔ y ≠ v ∧ ¬ G.Arc v y ∧ ¬ G.Arc y v := by
  simp [nonNeighbours]

/-- There is no two-step walk from a vertex to itself in an oriented graph. -/
theorem not_mem_F2_self (v : V) : v ∉ G.F (G.F {v}) := by
  intro h
  rw [mem_F] at h
  obtain ⟨x, hx, hxv⟩ := h
  rw [mem_F] at hx
  obtain ⟨w, hw, hwx⟩ := hx
  rw [Finset.mem_singleton] at hw
  subst hw
  exact G.asymm hwx hxv

theorem not_mem_N2_self (v : V) : v ∉ G.N2 v := by
  rw [mem_N2]
  rintro ⟨⟨x, h1, h2⟩, -⟩
  exact G.asymm h1 h2

theorem N2_subset_F2 (v : V) : G.N2 v ⊆ G.F (G.F {v}) :=
  Finset.sdiff_subset

theorem card_N2_le (v : V) : (G.N2 v).card ≤ (G.F (G.F {v})).card :=
  Finset.card_le_card (G.N2_subset_F2 v)

/-- The conjecture's conclusion at a vertex. -/
def Good (v : V) : Prop := (G.N1 v).card ≤ (G.N2 v).card

/-- A counterexample: every vertex has more first than second out-neighbors. -/
def IsCounterexample : Prop := ∀ v, (G.N2 v).card < (G.N1 v).card

theorem good_of_not_counterexample (h : ¬ G.IsCounterexample) : ∃ v, G.Good v := by
  by_contra hc
  apply h
  intro v
  have : ¬ G.Good v := by
    intro hv; exact hc ⟨v, hv⟩
  simp only [Good, not_le] at this
  exact this

end OGraph

end Seymour
