import SeymourLean.Final
import SecondNeighborhood

/-!
Translate the rebuilt, attributed reference theorem to this exposition's
set-image convention. The full reference proof is by Claude Opus 5.5;
this definition audit and bridge are additions by Codex.
-/
namespace SecondNeighborhoodReferenceBridge

open SecondNeighborhood
open scoped Classical

/-- The copied exact second neighborhood agrees with second-walk endpoints
minus the first neighborhood, because asymmetry rules out a two-step return. -/
theorem second_neighborhood_agrees
    {X : Type} [Fintype X] [DecidableEq X]
    (E : X → X → Prop) [DecidableRel E]
    (hAsymm : ∀ x y, E x y → ¬ E y x) (v : X) :
    Seymour.N2 E v = Finset.univ.filter (fun w =>
      image E (image E (fun x => x = v)) w ∧ ¬ E v w) := by
  classical
  ext w
  simp only [Seymour.mem_N2, Finset.mem_filter, Finset.mem_univ, true_and]
  exact (exact_second_convention E hAsymm v w).symm

/-- Full unweighted conclusion, obtained from the independently rebuilt
reference proof and expressed in the Codex exposition's image convention.
No pruning, rank, or reduction lemma is an unproved hypothesis here. -/
theorem second_neighborhood_theorem
    (X : Type) [Fintype X] [DecidableEq X] [Nonempty X]
    (E : X → X → Prop) [DecidableRel E]
    (hAsymm : ∀ x y, E x y → ¬ E y x) :
    ∃ v, (Finset.univ.filter (E v)).card ≤
      (Finset.univ.filter (fun w =>
        image E (image E (fun x => x = v)) w ∧ ¬ E v w)).card := by
  classical
  have hor : Seymour.IsOriented E :=
    ⟨fun x hx => hAsymm x x hx hx, hAsymm⟩
  obtain ⟨v, hv⟩ := Seymour.seymour_second_neighbourhood X E hor
  refine ⟨v, ?_⟩
  simpa only [Seymour.N1, second_neighborhood_agrees E hAsymm v] using hv

#print axioms second_neighborhood_agrees
#print axioms second_neighborhood_theorem
end SecondNeighborhoodReferenceBridge
