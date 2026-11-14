import SeymourLean.Contradiction
import SeymourLean.Reduction
import SeymourLean.BlowUp

/-!
# Assembly: from "no strictly concave graph" to Seymour's conjecture

* `seymour_of_noStrictlyConcave` : the reduction of Section 2 (minimal counterexample, subset
  deficit, blow-up), packaged as: if no nonempty oriented graph with positive indegrees is strictly
  concave, then Seymour's second neighbourhood conjecture holds.
* `seymour_of_pruningLemma` : `PruningLemma → SeymourStatement`.
-/

open Finset

namespace Seymour

/-- Proposition `prop:reduction` (in contrapositive form) together with the minimal-counterexample
argument: strict concavity being impossible implies the conjecture. -/
theorem seymour_of_noStrictlyConcave
    (hNC : ∀ (X : Type) [Fintype X] [DecidableEq X] [Nonempty X] (adj : X → X → Prop)
      [DecidableRel adj], IsOriented adj → PosIndeg adj → StrictlyConcave adj → False) :
    SeymourStatement := by
  have key : ∀ n : ℕ, ∀ (V : Type) [Fintype V] [DecidableEq V], Fintype.card V = n →
      ∀ k : ℕ, ∀ (adj : V → V → Prop) [DecidableRel adj], (arcs adj).card = k →
      IsOriented adj → Nonempty V → ∃ v, (N1 adj v).card ≤ (N2 adj v).card := by
    intro n
    induction n using Nat.strong_induction_on with
    | _ n ihn =>
    intro V _ _ hV k
    induction k using Nat.strong_induction_on with
    | _ k ihk =>
    intro adj _ hk hor hne
    by_contra hcon
    push Not at hcon
    -- induction hypothesis on the number of vertices
    have IHv : ∀ (W : Type) [Fintype W] [DecidableEq W] [Nonempty W] (adj' : W → W → Prop)
        [DecidableRel adj'], Fintype.card W < Fintype.card V → IsOriented adj' →
        ∃ v, (N1 adj' v).card ≤ (N2 adj' v).card :=
      fun W _ _ _ adj' _ hW hor' => ihn _ (hV ▸ hW) W rfl _ adj' rfl hor' inferInstance
    -- induction hypothesis on the number of arcs
    have IHa : ∀ (adj' : V → V → Prop) [DecidableRel adj'], (arcs adj').card < (arcs adj).card →
        IsOriented adj' → ∃ v, (N1 adj' v).card ≤ (N2 adj' v).card :=
      fun adj' _ h hor' => ihk _ (hk ▸ h) adj' rfl hor' hne
    -- no nonempty proper closed set (Lemma `lem:strong`)
    have hsc : ∀ S : Finset V, S.Nonempty → S ≠ univ → ∃ x ∈ S, ∃ y ∉ S, adj x y := by
      intro S hS hSne
      by_contra h
      push Not at h
      obtain ⟨v, hv⟩ := seymour_of_closed IHv hor S hS hSne (fun x hx y hxy => by
        by_contra hy; exact h x hx y hy hxy)
      exact absurd hv (not_le.mpr (hcon v))
    -- positive indegrees
    have hin : PosIndeg adj := by
      intro y
      obtain ⟨w, hw⟩ : (N1 adj y).Nonempty := by
        rw [← card_pos]; exact lt_of_le_of_lt (Nat.zero_le _) (hcon y)
      have hwy : w ≠ y := by rintro rfl; exact hor.1 _ (mem_N1.mp hw)
      have hS : (univ.erase y).Nonempty := ⟨w, mem_erase.mpr ⟨hwy, mem_univ _⟩⟩
      have hSne : univ.erase y ≠ univ := fun h => by
        have : y ∈ univ.erase y := by rw [h]; exact mem_univ y
        simp at this
      obtain ⟨x, _, z, hz, hxz⟩ := hsc _ hS hSne
      have : z = y := by
        by_contra hzy; exact hz (mem_erase.mpr ⟨hzy, mem_univ _⟩)
      exact ⟨x, this ▸ hxz⟩
    have hdef := subset_deficit hor hcon hsc IHa
    obtain ⟨h1, h2, h3⟩ := blowup hor hin hdef (Fintype.card V + 1) (Nat.lt_succ_self _)
    exact hNC (V × Fin (Fintype.card V + 1)) _ h1 h2 h3
  intro V _ _ _ adj _ hor
  exact key _ V rfl _ adj rfl hor inferInstance

/-- **Main theorem, conditional on the pruning lemma.** -/
theorem seymour_of_pruningLemma (hP : PruningLemma) : SeymourStatement :=
  seymour_of_noStrictlyConcave fun X _ _ _ adj _ hor hin hconc =>
    no_strictlyConcave hP X adj hor hin hconc

end Seymour
